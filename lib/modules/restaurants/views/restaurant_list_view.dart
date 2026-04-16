import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/store_card_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../controllers/restaurant_controller.dart';

class RestaurantListView extends StatefulWidget {
  const RestaurantListView({super.key});

  @override
  State<RestaurantListView> createState() => _RestaurantListViewState();
}

class _RestaurantListViewState extends State<RestaurantListView> {
  final RestaurantController controller = Get.find<RestaurantController>();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreRestaurants();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Restaurants'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Obx(() {
            final filters = controller.filters.toList();
            final selected = controller.selectedFilter.value;
            return SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filters.length,
                  itemBuilder: (_, i) {
                    final f = filters[i];
                    final isSelected = selected == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          controller.selectedFilter.value = f;
                          controller.selectedFilter.refresh();
                        },
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
                  },
                ),
              );
            }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();
              final list = controller.filteredRestaurants;
              if (list.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.restaurant_outlined,
                  title: 'No restaurants found',
                  subtitle: 'Try a different filter',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchRestaurants,
                color: AppColors.primary,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length + (controller.hasMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == list.length) {
                      return Obx(() => controller.isLoadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink());
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        height: 220,
                        child: StoreCardWidget(
                          store: list[i],
                          onTap: () => Get.toNamed(
                            AppRoutes.restaurantDetail,
                            arguments: list[i],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
