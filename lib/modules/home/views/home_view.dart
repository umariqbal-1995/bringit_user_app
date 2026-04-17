import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../../widgets/store_card_widget.dart';
import '../../../widgets/bottom_nav_widget.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                onRefresh: controller.fetchData,
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildSearchBar()),
                    SliverToBoxAdapter(child: _buildCategories()),
                    SliverToBoxAdapter(child: _buildFeaturedOffers()),
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        'Popular Near You',
                        onTap: () => Get.toNamed(AppRoutes.restaurants),
                      ),
                    ),
                    _buildRestaurantList(),
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        'Grocery Stores',
                        onTap: () => Get.toNamed(AppRoutes.stores),
                      ),
                    ),
                    _buildStoreList(),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
                  // Floating active order tiles — overlaid above scroll content
                  Obx(() {
                    final orders = controller.activeOrders;
                    if (orders.isEmpty) return const SizedBox.shrink();
                    return Positioned(
                      bottom: 8,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: orders
                            .map((o) => _buildActiveOrderTile(o))
                            .toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Obx(() => BottomNavWidget(
                  selectedIndex: 0,
                  onTap: (i) {
                    if (i == 1) Get.toNamed(AppRoutes.favourites);
                    if (i == 2) Get.toNamed(AppRoutes.orders);
                    if (i == 3) Get.toNamed(AppRoutes.profile);
                  },
                  cartCount: cartController.totalItems,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrderTile(OrderModel order) {
    final statusColor = _activeOrderStatusColor(order.status);
    final statusLabel = _activeOrderStatusLabel(order.status);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.trackOrder, arguments: order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Animated delivery icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delivery_dining,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.storeName.isEmpty ? 'Your Order' : order.storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Text(
                  'Track',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _activeOrderStatusColor(String status) {
    switch (status) {
      case 'delivering':
      case 'picked_up':
      case 'ready':
        return AppColors.primary;
      case 'accepted':
      case 'preparing':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.textSecondary;
    }
  }

  String _activeOrderStatusLabel(String status) {
    switch (status) {
      case 'pending':
      case 'placed':
        return 'Order placed';
      case 'accepted':
        return 'Accepted by store';
      case 'preparing':
        return 'Preparing your order';
      case 'ready':
        return 'Ready for pickup';
      case 'picked_up':
        return 'Rider picked up';
      case 'delivering':
        return 'Out for delivery';
      default:
        return status;
    }
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deliver to',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Obx(() => Text(
                        controller.deliveryAddress.value.isNotEmpty
                            ? controller.deliveryAddress.value
                            : 'Set your location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: controller.deliveryAddress.value.isNotEmpty
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.notifications),
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.search),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                SizedBox(width: 10),
                Text(
                  'Search food, restaurants, groceries...',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildCategories() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.restaurants),
                child: Container(
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                      SizedBox(height: 6),
                      Text(
                        'Food',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Restaurants & Meals',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.stores),
                child: Container(
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.shopping_basket_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Grocery',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Supermarkets & More',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFeaturedOffers() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Featured Offers', showSeeAll: false),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _offerCard('Free Delivery', 'on First Order', AppColors.primary),
                const SizedBox(width: 12),
                _offerCard(
                  '20% off Groceries',
                  'Use code: FRESH20',
                  const Color(0xFF16A34A),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _offerCard(String title, String subtitle, Color color) => Container(
        width: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onTap,
    bool showSeeAll = true,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (showSeeAll && onTap != null)
              GestureDetector(
                onTap: onTap,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildRestaurantList() => Obx(() => SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.restaurants.length,
                  itemBuilder: (_, i) => Padding(
                    padding: EdgeInsets.only(
                      right:
                          i < controller.restaurants.length - 1 ? 12 : 0,
                    ),
                    child: SizedBox(
                      width: 200,
                      child: StoreCardWidget(
                        store: controller.restaurants[i],
                        onTap: () => Get.toNamed(
                          AppRoutes.restaurantDetail,
                          arguments: controller.restaurants[i],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ));

  Widget _buildStoreList() => Obx(() => SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.stores.length,
                  itemBuilder: (_, i) => Padding(
                    padding: EdgeInsets.only(
                      right: i < controller.stores.length - 1 ? 12 : 0,
                    ),
                    child: SizedBox(
                      width: 200,
                      child: StoreCardWidget(
                        store: controller.stores[i],
                        onTap: () => Get.toNamed(
                          AppRoutes.storeDetail,
                          arguments: controller.stores[i],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ));
}
