import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/user_setup_controller.dart';

class UserSetupView extends GetView<UserSetupController> {
  const UserSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.currentStep.value == 0
        ? _NameStep(controller: controller)
        : _LocationStep(controller: controller));
  }
}

// ─── Step 1: Name ────────────────────────────────────────────────────────────

class _NameStep extends StatelessWidget {
  final UserSetupController controller;
  const _NameStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.waving_hand_rounded,
                    size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 28),
              const Text(
                'What\'s your name?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We\'ll use this to personalise your experience.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: controller.nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppColors.textTertiary),
                ),
                onSubmitted: (_) => controller.submitName(),
              ),
              const Spacer(),
              Obx(() => ElevatedButton(
                    onPressed: controller.isNameLoading.value
                        ? null
                        : controller.submitName,
                    child: controller.isNameLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Continue'),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step 2: Location ─────────────────────────────────────────────────────────

class _LocationStep extends StatefulWidget {
  final UserSetupController controller;
  const _LocationStep({required this.controller});

  @override
  State<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<_LocationStep> {
  GoogleMapController? _mapController;
  final _searchFocus = FocusNode();

  void _animateTo(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on,
                            size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Set your delivery location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 52),
                    child: Text(
                      'Search or drag the pin to your address',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Map ─────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Google Map
                Obx(() => GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(c.selectedLat.value, c.selectedLng.value),
                        zoom: 13,
                      ),
                      onMapCreated: (ctrl) => _mapController = ctrl,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('delivery'),
                          position:
                              LatLng(c.selectedLat.value, c.selectedLng.value),
                          draggable: true,
                          onDragEnd: (pos) =>
                              c.reverseGeocode(pos.latitude, pos.longitude),
                        ),
                      },
                      onLongPress: (pos) =>
                          c.reverseGeocode(pos.latitude, pos.longitude),
                    )),

                // Search bar overlay
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(14),
                        child: TextField(
                          focusNode: _searchFocus,
                          onChanged: c.searchPlaces,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search for your address...',
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.textTertiary, size: 20),
                            suffixIcon: Obx(() => c.isSearching.value
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : const SizedBox.shrink()),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      // Suggestions
                      Obx(() {
                        if (c.placeSuggestions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Material(
                          elevation: 4,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14)),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(14)),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: c.placeSuggestions.length,
                              itemBuilder: (_, i) {
                                final s = c.placeSuggestions[i];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                      Icons.location_on_outlined,
                                      size: 20,
                                      color: AppColors.primary),
                                  title: Text(s.description,
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  onTap: () {
                                    _searchFocus.unfocus();
                                    c.selectPlace(s,
                                        onSelected: (lat, lng) =>
                                            _animateTo(lat, lng));
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // My location button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Obx(() => FloatingActionButton.small(
                        heroTag: 'setup_locate',
                        backgroundColor: Colors.white,
                        elevation: 4,
                        onPressed: c.isLocating.value
                            ? null
                            : () => c.getCurrentLocation(
                                onLocated: (lat, lng) => _animateTo(lat, lng)),
                        child: c.isLocating.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary))
                            : const Icon(Icons.my_location,
                                color: AppColors.primary, size: 20),
                      )),
                ),
              ],
            ),
          ),

          // ── Bottom Panel ─────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery address',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                      final addr = c.address.value;
                      return Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              addr.isNotEmpty
                                  ? addr
                                  : 'Tap the map or search to set your address',
                              style: TextStyle(
                                fontSize: 14,
                                color: addr.isNotEmpty
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                                fontWeight: addr.isNotEmpty
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }),
                const SizedBox(height: 16),
                Obx(() => ElevatedButton(
                      onPressed: c.isSaving.value ? null : c.submitLocation,
                      child: c.isSaving.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Confirm Location'),
                    )),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: c.skipLocation,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
