import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/product_card_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/store_controller.dart';
import '../../../data/models/store_model.dart';

class StoreDetailView extends GetView<StoreController> {
  const StoreDetailView({super.key});

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
                  expandedHeight: 200,
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
                        Text(
                          currentStore.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
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
                              '${currentStore.rating?.toStringAsFixed(1) ?? "4.0"} (${currentStore.reviewCount ?? 0})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Body: tab bar (sticky at top) + scrollable product grid
              body: Column(
                children: [
                  // Category tab bar — lives outside any Obx that reads
                  // selectedCategory, so it is never destroyed on tab taps.
                  // _CategoryTabBar uses ever() + setState for its own updates.
                  Container(
                    color: AppColors.background,
                    child: _CategoryTabBar(controller: controller),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // Products — own Obx, reads filteredProducts + isLoading
                  Expanded(
                    child: Obx(() {
                      if (controller.isProductsLoading.value) {
                        return const Center(child: LoadingWidget());
                      }
                      final products = controller.filteredProducts;
                      if (products.isEmpty) {
                        return const Center(
                          child: Text('No products found',
                              style: TextStyle(color: AppColors.textSecondary)),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products.length,
                        itemBuilder: (_, i) {
                          final p = products[i];
                          return Obx(() => ProductCardWidget(
                                id: p.id,
                                name: p.name,
                                description: p.description,
                                price: p.price,
                                image: p.image,
                                quantity: cartController.getQuantity(p.id),
                                onAdd: () => cartController.addItem(
                                  itemId: p.id,
                                  name: p.name,
                                  price: p.price,
                                  image: p.image,
                                  currentStoreId: currentStore.id,
                                  currentStoreName: currentStore.name,
                                  itemType: 'product',
                                ),
                                onIncrement: () =>
                                    cartController.increment(p.id),
                                onDecrement: () =>
                                    cartController.decrement(p.id),
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
                    border: Border(top: BorderSide(color: AppColors.border)),
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
        errorBuilder: (_, __, ___) => _heroPlaceholder(),
      );
    }
    return _heroPlaceholder();
  }

  Widget _heroPlaceholder() {
    return Container(
      color: AppColors.backgroundSecondary,
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 72,
          color: AppColors.textTertiary.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _CategoryTabBar extends StatefulWidget {
  final StoreController controller;
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
    final cats = widget.controller.productCategories;
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
