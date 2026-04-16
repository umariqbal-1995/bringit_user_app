import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/empty_state_widget.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<AppSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          padding: EdgeInsets.zero,
        ),
        title: TextField(
          controller: textController,
          autofocus: true,
          onChanged: (v) => controller.query.value = v,
          decoration: InputDecoration(
            hintText: 'Search restaurants, stores, items...',
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            prefixIcon: const Icon(Icons.search,
                color: AppColors.textTertiary, size: 20),
            suffixIcon: Obx(() => controller.query.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppColors.textTertiary, size: 18),
                    onPressed: () {
                      textController.clear();
                      controller.query.value = '';
                    },
                  )
                : const SizedBox.shrink()),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Obx(() => SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  children: ['All', 'Food', 'Grocery'].map((f) {
                    final isSelected = controller.selectedFilter.value == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => controller.selectedFilter.value = f,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
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
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
          Expanded(
            child: Obx(() {
              final results = controller.searchResults;

              if (controller.query.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Search for food or stores',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try "Biryani", "Pizza", "Grocery"...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (results.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.search_off_outlined,
                  title: 'No results found',
                  subtitle: 'Try searching for something else',
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final store = results[i];
                  return GestureDetector(
                    onTap: () {
                      if (store.isRestaurant) {
                        Get.toNamed(
                          AppRoutes.restaurantDetail,
                          arguments: store,
                        );
                      } else {
                        Get.toNamed(
                          AppRoutes.storeDetail,
                          arguments: store,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 56,
                              height: 56,
                              color: store.isRestaurant
                                  ? AppColors.primaryLight
                                  : AppColors.backgroundSecondary,
                              child: Icon(
                                store.isRestaurant
                                    ? Icons.restaurant
                                    : Icons.storefront_outlined,
                                color: store.isRestaurant
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  store.categories.take(2).join(' · '),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 12, color: AppColors.star),
                                  const SizedBox(width: 2),
                                  Text(
                                    store.rating?.toStringAsFixed(1) ?? '4.0',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${store.deliveryTime ?? 30} min',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
