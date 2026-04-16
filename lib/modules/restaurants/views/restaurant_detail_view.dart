import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/menu_item_card_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/restaurant_controller.dart';
import '../../../data/models/store_model.dart';

class RestaurantDetailView extends GetView<RestaurantController> {
  const RestaurantDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Get.arguments as StoreModel?;
    final cartController = Get.find<CartController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (store != null) controller.setStoreIfNeeded(store);
    });

    // Outer Obx ONLY reads currentStore — never reads selectedCategory,
    // so tab taps do NOT cause this level to rebuild.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final currentStore = controller.currentStore.value ?? store;
        if (currentStore == null) {
          return const Center(child: Text('Store not found'));
        }

        return Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // Hero header
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  forceElevated: innerBoxIsScrolled,
                  leading: IconButton(
                    onPressed: Get.back,
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border,
                            size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeroImage(currentStore),
                  ),
                ),
                // Store info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentStore.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (!currentStore.isOpen)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Closed',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentStore.categories.join(' · '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: AppColors.star),
                            const SizedBox(width: 4),
                            Text(
                              '${currentStore.rating?.toStringAsFixed(1) ?? "4.0"} (${currentStore.reviewCount ?? 0} reviews)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time,
                                size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              '${currentStore.deliveryTime ?? 30} min',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.delivery_dining,
                                size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              (currentStore.deliveryFee == 0 ||
                                      currentStore.deliveryFee == null)
                                  ? 'Free delivery'
                                  : 'Rs ${currentStore.deliveryFee!.toInt()} delivery',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(color: AppColors.border, height: 1),
                ),
              ],
              // Body: tab bar (sticky at top) + scrollable menu list
              body: Column(
                children: [
                  // Category tab bar — lives outside any Obx that reads
                  // selectedCategory, so it is never destroyed on tab taps.
                  Container(
                    color: AppColors.background,
                    child: _CategoryTabBar(controller: controller),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // Menu items — own Obx, reads filteredMenu + isLoading
                  Expanded(
                    child: Obx(() {
                      if (controller.isMenuLoading.value) {
                        return const Center(child: LoadingWidget());
                      }
                      final menu = controller.filteredMenu;
                      if (menu.isEmpty) {
                        return const Center(
                          child: Text('No items found',
                              style: TextStyle(color: AppColors.textSecondary)),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: menu.length,
                        itemBuilder: (_, i) {
                          final item = menu[i];
                          return Obx(() => MenuItemCardWidget(
                                id: item.id,
                                name: item.name,
                                description: item.description,
                                price: item.price,
                                image: item.image,
                                quantity:
                                    cartController.getQuantity(item.id),
                                onAdd: () => cartController.addItem(
                                  itemId: item.id,
                                  name: item.name,
                                  price: item.price,
                                  image: item.image,
                                  currentStoreId: currentStore.id,
                                  currentStoreName: currentStore.name,
                                  itemType: 'menuItem',
                                ),
                                onIncrement: () =>
                                    cartController.increment(item.id),
                                onDecrement: () =>
                                    cartController.decrement(item.id),
                              ));
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Sticky cart bar
            Obx(() {
              if (cartController.items.value.isEmpty ||
                  cartController.storeId.value != currentStore.id) {
                return const SizedBox.shrink();
              }
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border:
                        Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.cart),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${cartController.totalItems}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'View Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              'Rs ${cartController.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildHeroImage(StoreModel store) {
    if (store.image != null && store.image!.isNotEmpty) {
      return Image.network(
        store.image!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _heroPlaceholder(store),
      );
    }
    return _heroPlaceholder(store);
  }

  Widget _heroPlaceholder(StoreModel store) {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 72,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _CategoryTabBar extends StatefulWidget {
  final RestaurantController controller;
  const _CategoryTabBar({required this.controller});

  @override
  State<_CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<_CategoryTabBar> {
  late final Worker _worker;

  @override
  void initState() {
    super.initState();
    _worker = ever(widget.controller.selectedCategory, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.controller.selectedCategory.value;
    final cats = widget.controller.menuCategories;
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final cat = cats[i];
          final isSelected =
              cat == 'All' ? selected.isEmpty : selected == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => widget.controller.selectedCategory.value =
                  cat == 'All' ? '' : cat,
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
                  cat,
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
  }
}
