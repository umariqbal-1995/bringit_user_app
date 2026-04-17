import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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

  // Custom marker icons (loaded once)
  final userIcon = Rxn<BitmapDescriptor>();
  final storeIcon = Rxn<BitmapDescriptor>();
  final riderIcon = Rxn<BitmapDescriptor>();

  // Route polylines
  final polylines = <Polyline>{}.obs;

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
    await Future.wait([
      _getUserLocation(),
      _loadMarkerIcons(),
    ]);
    await _fetchTracking();
    _startPolling();
  }

  Future<void> _loadMarkerIcons() async {
    userIcon.value = await _buildMarkerIcon(
      color: const Color(0xFF22C55E),
      icon: Icons.person,
    );
    storeIcon.value = await _buildMarkerIcon(
      color: const Color(0xFFF97316),
      icon: Icons.storefront,
    );
    riderIcon.value = await _buildMarkerIcon(
      color: const Color(0xFF3B82F6),
      icon: Icons.delivery_dining,
    );
  }

  Future<BitmapDescriptor> _buildMarkerIcon({
    required Color color,
    required IconData icon,
  }) async {
    const double size = 100;
    const double radius = size / 2 - 6;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Drop shadow
    canvas.drawCircle(
      const Offset(size / 2, size / 2 + 4),
      radius,
      Paint()
        ..color = Colors.black.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Filled circle
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      radius,
      Paint()..color = color,
    );

    // White border ring
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Icon in center
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 42,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      )
      ..layout();
    tp.paint(
      canvas,
      Offset((size - tp.width) / 2, (size - tp.height) / 2),
    );

    final img = await recorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
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
      _updatePolylines();
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
    _updatePolylines();
    _fitMap();
  }

  void _updatePolylines() {
    final s = storeLocation.value;
    final r = riderLocation.value;
    final u = userLocation.value;

    const completedColor = Color(0xFFADB5BD); // gray — already traveled
    const remainingColor = Color(0xFFF97316); // orange — remaining to user

    final updated = <Polyline>{};

    // Store → Rider: gray dashed (completed portion)
    if (s != null && r != null) {
      updated.add(Polyline(
        polylineId: const PolylineId('store_to_rider'),
        points: [s, r],
        color: completedColor,
        width: 4,
        patterns: [PatternItem.dash(18), PatternItem.gap(10)],
      ));
    }

    // Rider → User: orange dashed (remaining delivery path)
    if (r != null && u != null) {
      updated.add(Polyline(
        polylineId: const PolylineId('rider_to_user'),
        points: [r, u],
        color: remainingColor,
        width: 4,
        patterns: [PatternItem.dash(18), PatternItem.gap(10)],
      ));
    } else if (s != null && u != null) {
      // No rider yet — draw full store→user path
      updated.add(Polyline(
        polylineId: const PolylineId('store_to_user'),
        points: [s, u],
        color: remainingColor,
        width: 4,
        patterns: [PatternItem.dash(18), PatternItem.gap(10)],
      ));
    }

    polylines.value = updated;
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
