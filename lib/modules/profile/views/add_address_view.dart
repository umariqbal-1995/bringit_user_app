import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

class AddAddressView extends GetView<ProfileController> {
  const AddAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    GoogleMapController? mapController;
    final floorController = TextEditingController();
    final notesController = TextEditingController();
    final searchFocusNode = FocusNode();

    void animateMapTo(double lat, double lng) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Address'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: Column(
        children: [
          // ── MAP SECTION ──────────────────────────────────────────
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                // Google Map
                Obx(() => GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          controller.selectedLat.value,
                          controller.selectedLng.value,
                        ),
                        zoom: 14,
                      ),
                      onMapCreated: (c) => mapController = c,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: LatLng(
                            controller.selectedLat.value,
                            controller.selectedLng.value,
                          ),
                          draggable: true,
                          onDragEnd: (pos) => controller.reverseGeocode(
                              pos.latitude, pos.longitude),
                        ),
                      },
                      onLongPress: (pos) => controller.reverseGeocode(
                          pos.latitude, pos.longitude),
                    )),

                // Search bar overlay
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          focusNode: searchFocusNode,
                          onChanged: controller.searchPlaces,
                          decoration: InputDecoration(
                            hintText: 'Search for a location...',
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.textTertiary),
                            suffixIcon: Obx(() => controller.isSearching.value
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : const SizedBox.shrink()),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      // Suggestions dropdown
                      Obx(() {
                        if (controller.placeSuggestions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Material(
                          elevation: 4,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12)),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 180),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(12)),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount:
                                  controller.placeSuggestions.length,
                              itemBuilder: (context, i) {
                                final s = controller.placeSuggestions[i];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                      Icons.location_on_outlined,
                                      size: 20,
                                      color: AppColors.primary),
                                  title: Text(
                                    s.description,
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    searchFocusNode.unfocus();
                                    controller.selectPlace(s,
                                        onSelected: (lat, lng, address) {
                                      animateMapTo(lat, lng);
                                    });
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
                  bottom: 10,
                  right: 10,
                  child: Obx(() => FloatingActionButton.small(
                        heroTag: 'locateme',
                        backgroundColor: Colors.white,
                        onPressed: controller.isLocating.value
                            ? null
                            : () => controller.getCurrentLocation(
                                  onLocated: (lat, lng) =>
                                      animateMapTo(lat, lng),
                                ),
                        child: controller.isLocating.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location,
                                color: AppColors.primary),
                      )),
                ),
              ],
            ),
          ),

          // ── FORM SECTION ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label selection
                  const Text(
                    'Label',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Row(
                        children: ['Home', 'Work', 'Other'].map((label) {
                          final isSelected =
                              controller.selectedLabel.value == label;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () =>
                                  controller.selectedLabel.value = label,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.backgroundSecondary,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      label == 'Home'
                                          ? Icons.home_outlined
                                          : label == 'Work'
                                              ? Icons.work_outline
                                              : Icons.location_on_outlined,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                  const SizedBox(height: 20),

                  // Street Address (auto-filled from map)
                  const Text(
                    'Street Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.mapAddressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Search above or tap on the map',
                      prefixIcon: Icon(Icons.location_on_outlined,
                          color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Flat / Floor
                  const Text(
                    'Flat / Floor (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: floorController,
                    decoration: const InputDecoration(
                      hintText: 'Floor 3, Flat 5B...',
                      prefixIcon:
                          Icon(Icons.apartment, color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Instructions
                  const Text(
                    'Delivery Instructions (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText:
                          'e.g., Ring the bell twice, leave at door...',
                      prefixIcon: Icon(Icons.note_outlined,
                          color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                final address = controller
                                    .mapAddressController.text
                                    .trim();
                                if (address.isEmpty) {
                                  Get.snackbar('Error',
                                      'Please search or pin your address on the map');
                                  return;
                                }
                                String fullAddress = address;
                                if (floorController.text.trim().isNotEmpty) {
                                  fullAddress =
                                      '${floorController.text.trim()}, $fullAddress';
                                }
                                controller.addAddress(
                                  label: controller.selectedLabel.value,
                                  address: fullAddress,
                                  lat: controller.selectedLat.value,
                                  lng: controller.selectedLng.value,
                                );
                              },
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Address'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
