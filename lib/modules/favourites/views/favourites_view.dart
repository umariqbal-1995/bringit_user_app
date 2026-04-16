import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/store_card_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/bottom_nav_widget.dart';
import '../controllers/favourites_controller.dart';

class FavouritesView extends GetView<FavouritesController> {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Favourites')),
      body: Column(
        children: [
          // Tab bar
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: List.generate(
                    ['All', 'Restaurants', 'Stores'].length,
                    (i) {
                      final tab = ['All', 'Restaurants', 'Stores'][i];
                      final isSelected = controller.selectedTab.value == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectedTab.value = i,
                          child: Container(
                            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              tab,
                              textAlign: TextAlign.center,
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
                    },
                  ),
                ),
              )),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();
              final list = controller.filteredFavourites;
              if (list.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.favorite_border,
                  title: 'No favourites yet',
                  subtitle: 'Add restaurants and stores to your favourites',
                  buttonLabel: 'Explore Now',
                  onButtonTap: () => Get.offAllNamed(AppRoutes.home),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchFavourites,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 220,
                      child: StoreCardWidget(
                        store: list[i],
                        onTap: () {
                          if (list[i].isRestaurant) {
                            Get.toNamed(
                              AppRoutes.restaurantDetail,
                              arguments: list[i],
                            );
                          } else {
                            Get.toNamed(
                              AppRoutes.storeDetail,
                              arguments: list[i],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          BottomNavWidget(
            selectedIndex: 1,
            onTap: (i) {
              if (i == 0) Get.offAllNamed(AppRoutes.home);
              if (i == 2) Get.toNamed(AppRoutes.orders);
              if (i == 3) Get.toNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
    );
  }
}
