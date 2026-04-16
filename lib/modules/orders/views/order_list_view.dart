import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/order_card_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/bottom_nav_widget.dart';
import '../controllers/order_controller.dart';

class OrderListView extends GetView<OrderController> {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: Column(
        children: [
          // Tab bar
          Obx(() => Container(
                color: AppColors.background,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: List.generate(
                    ['All', 'Active', 'Completed', 'Cancelled'].length,
                    (i) {
                      final tab =
                          ['All', 'Active', 'Completed', 'Cancelled'][i];
                      final isSelected = controller.selectedTab.value == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectedTab.value = i,
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tab,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
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
              final list = controller.filteredOrders;
              if (list.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  subtitle: 'Your orders will appear here',
                  buttonLabel: 'Order Now',
                  onButtonTap: () => Get.offAllNamed(AppRoutes.home),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchOrders,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (_, i) => OrderCardWidget(
                    order: list[i],
                    onTap: () => Get.toNamed(
                      AppRoutes.orderDetail,
                      arguments: list[i],
                    ),
                  ),
                ),
              );
            }),
          ),
          BottomNavWidget(
            selectedIndex: 2,
            onTap: (i) {
              if (i == 0) Get.offAllNamed(AppRoutes.home);
              if (i == 1) Get.toNamed(AppRoutes.favourites);
              if (i == 3) Get.toNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
    );
  }
}
