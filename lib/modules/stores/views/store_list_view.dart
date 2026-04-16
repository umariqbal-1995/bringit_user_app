import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/store_card_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../controllers/store_controller.dart';

class StoreListView extends StatefulWidget {
  const StoreListView({super.key});

  @override
  State<StoreListView> createState() => _StoreListViewState();
}

class _StoreListViewState extends State<StoreListView> {
  final StoreController controller = Get.find<StoreController>();
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
      controller.loadMoreStores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Grocery Stores'),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: filters.length,
                  itemBuilder: (_, i) {
                    final f = filters[i];
                    final isSelected = selected == f;
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
                  },
                ),
              );
            }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();
              final list = controller.filteredStores;
              if (list.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.storefront_outlined,
                  title: 'No stores found',
                  subtitle: 'Try a different filter',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchStores,
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
                            AppRoutes.storeDetail,
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
