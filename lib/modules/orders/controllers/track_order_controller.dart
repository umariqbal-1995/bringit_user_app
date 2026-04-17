import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class TrackOrderController extends GetxController {
  final OrderRepository _repo;
  TrackOrderController(this._repo);

  late final OrderModel order;

  final riderLocation = Rxn<LatLng>();
  final storeLocation = Rxn<LatLng>();
  final userLocation = Rxn<LatLng>();
  final estimatedMinutes = Rxn<int>();
  final isRiderNearby = false.obs;
  final isLoadingMap = true.obs;

  final _mapCompleter = Completer<GoogleMapController>();
  Timer? _pollTimer;

  static const double _nearbyThresholdMeters = 500;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    order = args is OrderModel ? args : (args as Map)['order'] as OrderModel;
    _init();
  }

  Future<void> _init() async {
    await _getUserLocation();
    await _fetchTracking();
    _startPolling();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        userLocation.value = const LatLng(31.5204, 74.3587);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      userLocation.value = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      userLocation.value = const LatLng(31.5204, 74.3587);
    }
  }

  Future<void> _fetchTracking() async {
    try {
      final data = await _repo.getOrderTracking(order.id);
      final rider = data['rider'];
      final store = data['store'];
      if (rider != null) {
        riderLocation.value = LatLng(
          (rider['lat'] as num).toDouble(),
          (rider['lng'] as num).toDouble(),
        );
      }
      if (store != null) {
        storeLocation.value = LatLng(
          (store['lat'] as num).toDouble(),
          (store['lng'] as num).toDouble(),
        );
      }
      if (data['estimatedMinutes'] != null) {
        estimatedMinutes.value = (data['estimatedMinutes'] as num).toInt();
      }
      _checkRiderNearby();
      _fitMap();
    } catch (_) {
      _useMockLocations();
    } finally {
      isLoadingMap.value = false;
    }
  }

  void _useMockLocations() {
    final baseLat = userLocation.value?.latitude ?? 31.5204;
    final baseLng = userLocation.value?.longitude ?? 74.3587;
    storeLocation.value = LatLng(baseLat + 0.022, baseLng - 0.018);
    riderLocation.value = LatLng(baseLat + 0.009, baseLng - 0.006);
    estimatedMinutes.value = 12;
    _checkRiderNearby();
    _fitMap();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (['delivered', 'cancelled'].contains(order.status)) {
        _pollTimer?.cancel();
        return;
      }
      _fetchTracking();
    });
  }

  void _checkRiderNearby() {
    if (riderLocation.value == null || userLocation.value == null) return;
    final distMeters = Geolocator.distanceBetween(
      riderLocation.value!.latitude,
      riderLocation.value!.longitude,
      userLocation.value!.latitude,
      userLocation.value!.longitude,
    );
    isRiderNearby.value = distMeters <= _nearbyThresholdMeters;
    if (distMeters > 0 && estimatedMinutes.value == null) {
      const speedMps = 30000.0 / 3600.0; // 30 km/h in m/s
      estimatedMinutes.value = max(1, (distMeters / speedMps / 60).ceil());
    }
  }

  Future<void> _fitMap() async {
    if (!_mapCompleter.isCompleted) return;
    final ctrl = await _mapCompleter.future;
    final locations = [
      userLocation.value,
      storeLocation.value,
      riderLocation.value,
    ].whereType<LatLng>().toList();

    if (locations.length < 2) return;

    final lats = locations.map((l) => l.latitude);
    final lngs = locations.map((l) => l.longitude);
    final bounds = LatLngBounds(
      southwest: LatLng(lats.reduce(min) - 0.005, lngs.reduce(min) - 0.005),
      northeast: LatLng(lats.reduce(max) + 0.005, lngs.reduce(max) + 0.005),
    );
    await ctrl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void onMapCreated(GoogleMapController ctrl) {
    if (!_mapCompleter.isCompleted) {
      _mapCompleter.complete(ctrl);
    }
    Future.delayed(const Duration(milliseconds: 500), _fitMap);
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}
