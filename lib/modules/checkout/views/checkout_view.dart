import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/checkout_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => controller.addresses.isEmpty
                      ? GestureDetector(
                          onTap: () async {
                            await Get.toNamed(AppRoutes.addAddress);
                            controller.fetchAddresses();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primary, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.primaryLight,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_location_outlined,
                                    color: AppColors.primary),
                                SizedBox(width: 12),
                                Text(
                                  'Add delivery address',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: controller.addresses.map((addr) {
                            final isSelected =
                                controller.selectedAddress.value?.id == addr.id;
                            return GestureDetector(
                              onTap: () =>
                                  controller.selectedAddress.value = addr,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.background,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      addr.label.toLowerCase() == 'home'
                                          ? Icons.home_outlined
                                          : addr.label.toLowerCase() == 'work'
                                              ? Icons.work_outline
                                              : Icons.location_on_outlined,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            addr.label,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            addr.address,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle,
                                          color: AppColors.primary),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                  const SizedBox(height: 20),
                  // Payment method
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        children: [
                          _PaymentOption(
                            label: 'Cash on Delivery',
                            icon: Icons.money_outlined,
                            value: 'cash',
                            selected: controller.selectedPayment.value,
                            onTap: () =>
                                controller.selectedPayment.value = 'cash',
                          ),
                          const SizedBox(height: 8),
                          _PaymentOption(
                            label: 'Online Payment (Coming Soon)',
                            icon: Icons.credit_card_outlined,
                            value: 'online',
                            selected: controller.selectedPayment.value,
                            onTap: null,
                            disabled: true,
                          ),
                        ],
                      )),
                  const SizedBox(height: 20),
                  // Order items
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        children: cartController.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                'Rs ${item.total.toInt()}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      )),
                  const SizedBox(height: 20),
                  // Price breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() => Column(
                          children: [
                            _PriceRow(
                                'Subtotal',
                                'Rs ${cartController.subtotal.toStringAsFixed(0)}'),
                            const SizedBox(height: 8),
                            _PriceRow(
                                'Delivery Fee',
                                'Rs ${cartController.deliveryFee.toStringAsFixed(0)}'),
                            const SizedBox(height: 8),
                            _PriceRow('Tax (5%)',
                                'Rs ${cartController.tax.toStringAsFixed(0)}'),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child:
                                  Divider(color: AppColors.border, height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Rs ${cartController.total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.placeOrder,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Place Order'),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final VoidCallback? onTap;
  final bool disabled;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primaryLight : AppColors.background,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: disabled
                  ? AppColors.textTertiary
                  : isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: disabled
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected && !disabled)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
