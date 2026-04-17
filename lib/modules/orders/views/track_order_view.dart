import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/track_order_controller.dart';

class TrackOrderView extends GetView<TrackOrderController> {
  const TrackOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const bottomPanelHeight = 290.0;

    return Scaffold(
      body: Obx(() {
        final user = controller.userLocation.value;
        final store = controller.storeLocation.value;
        final rider = controller.riderLocation.value;
        final center = rider ?? store ?? user ?? const LatLng(31.5204, 74.3587);

        final markers = <Marker>{
          if (user != null)
            Marker(
              markerId: const MarkerId('user'),
              position: user,
              icon: controller.userIcon.value ??
                  BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
              infoWindow: const InfoWindow(title: 'You'),
              zIndex: 1,
            ),
          if (store != null)
            Marker(
              markerId: const MarkerId('store'),
              position: store,
              icon: controller.storeIcon.value ??
                  BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(title: controller.order.storeName),
              zIndex: 2,
            ),
          if (rider != null)
            Marker(
              markerId: const MarkerId('rider'),
              position: rider,
              icon: controller.riderIcon.value ??
                  BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
              infoWindow: const InfoWindow(title: 'Rider'),
              zIndex: 3,
            ),
        };

        return Stack(
          children: [
            // Full screen map (extends behind bottom panel for depth)
            Positioned.fill(
              bottom: bottomPanelHeight - 30,
              child: controller.isLoadingMap.value
                  ? Container(
                      color: const Color(0xFFE8EAF0),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 14,
                      ),
                      markers: markers,
                      polylines: controller.polylines.value,
                      onMapCreated: controller.onMapCreated,
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                      buildingsEnabled: true,
                    ),
            ),

            // Back button
            Positioned(
              top: topPadding + 12,
              left: 16,
              child: _MapButton(
                onTap: Get.back,
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Title pill
            Positioned(
              top: topPadding + 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Track Order',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

            // Rider nearby banner
            if (controller.isRiderNearby.value)
              Positioned(
                top: topPadding + 72,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🛵', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Text(
                        'Your rider is nearby!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Legend
            Positioned(
              bottom: bottomPanelHeight + 8,
              right: 16,
              child: _buildLegend(),
            ),

            // Bottom panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPanel(bottomPadding),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendItem(Colors.green, 'You'),
          const SizedBox(height: 5),
          _legendItem(Colors.orange, 'Store'),
          const SizedBox(height: 5),
          _legendItem(Colors.blue, 'Rider'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(double bottomPadding) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: bottomPadding + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Store name + status badge + ETA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.order.storeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(controller.order.status),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Obx(() {
                final eta = controller.estimatedMinutes.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      eta != null ? '~$eta min' : '--',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Estimated arrival',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          const SizedBox(height: 20),

          // Status stepper
          _buildStatusStepper(controller.order.status),

          const SizedBox(height: 14),

          // Refresh info
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sync, size: 12, color: AppColors.textTertiary),
              SizedBox(width: 4),
              Text(
                'Rider location refreshes every 30 seconds',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            controller.order.statusLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(String status) {
    final steps = [
      ('Placed', 'pending', Icons.receipt_outlined),
      ('Accepted', 'accepted', Icons.check_circle_outline),
      ('Preparing', 'preparing', Icons.restaurant_outlined),
      ('On the Way', 'delivering', Icons.delivery_dining_outlined),
      ('Delivered', 'delivered', Icons.home_outlined),
    ];

    final statusOrder = [
      'pending',
      'accepted',
      'preparing',
      'ready',
      'picked_up',
      'delivering',
      'delivered',
    ];
    final currentIdx = statusOrder.indexOf(status);

    return Row(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final stepIdx = statusOrder.indexOf(step.$2);
        final isDone = currentIdx >= stepIdx && currentIdx != -1;
        // "On the Way" covers picked_up too
        final isCurrent = step.$2 == status ||
            (step.$2 == 'delivering' &&
                ['picked_up', 'delivering'].contains(status)) ||
            (step.$2 == 'accepted' && status == 'ready');

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.primary
                            : (isCurrent
                                ? AppColors.primaryLight
                                : AppColors.backgroundSecondary),
                        shape: BoxShape.circle,
                        border: isCurrent && !isDone
                            ? Border.all(
                                color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Icon(
                        step.$3,
                        size: 16,
                        color: isDone
                            ? Colors.white
                            : (isCurrent
                                ? AppColors.primary
                                : AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDone || isCurrent
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        fontWeight: isDone || isCurrent
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? AppColors.primary : AppColors.border,
                    margin: const EdgeInsets.only(bottom: 18),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'delivering':
      case 'picked_up':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }
}

class _MapButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _MapButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
