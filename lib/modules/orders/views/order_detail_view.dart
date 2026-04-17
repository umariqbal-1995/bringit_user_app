import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/order_controller.dart';
import '../../../data/models/order_model.dart';

class OrderDetailView extends GetView<OrderController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as OrderModel?;
    if (order != null) controller.currentOrder.value = order;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: Obx(() {
        final o = controller.currentOrder.value ?? order;
        if (o == null) {
          return const Center(child: Text('Order not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusColor(o.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _statusColor(o.status).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      _statusIcon(o.status),
                      size: 40,
                      color: _statusColor(o.status),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      o.statusLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(o.status),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #${o.id.length > 8 ? o.id.substring(o.id.length - 8) : o.id}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Status timeline
              _buildTimeline(o.status),
              const SizedBox(height: 20),
              // Store info
              _sectionTitle('From'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      o.storeName.isEmpty ? 'Store' : o.storeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Delivery address
              _sectionTitle('Delivery Address'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        o.address.isEmpty
                            ? 'No address specified'
                            : o.address,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Items
              _sectionTitle('Items'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: o.items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        if (i > 0)
                          const Divider(color: AppColors.border, height: 16),
                        Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                              ),
                            ),
                            Text(
                              'Rs ${(item.price * item.quantity).toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Price breakdown
              _sectionTitle('Price Breakdown'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _priceRow('Subtotal',
                        'Rs ${(o.total - o.deliveryFee).toInt()}'),
                    const SizedBox(height: 8),
                    _priceRow(
                        'Delivery Fee', 'Rs ${o.deliveryFee.toInt()}'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Rs ${o.total.toInt()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Date
              Text(
                'Placed on ${DateFormat('MMM dd, yyyy at hh:mm a').format(o.createdAt)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
              // Track Order button
              if (o.isTrackable) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.trackOrder, arguments: o),
                    icon: const Icon(Icons.delivery_dining_outlined, size: 20),
                    label: const Text('Track Order'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
              // Cancel button
              if (o.isCancellable) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(o.id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel Order',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  void _showCancelDialog(String orderId) {
    Get.defaultDialog(
      title: 'Cancel Order?',
      middleText: 'Are you sure you want to cancel this order?',
      textConfirm: 'Yes, Cancel',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        controller.cancelOrder(orderId);
        Get.back();
      },
    );
  }

  Widget _buildTimeline(String status) {
    final steps = [
      ('Order Placed', 'pending', Icons.receipt_outlined),
      ('Accepted', 'accepted', Icons.check_circle_outline),
      ('Preparing', 'preparing', Icons.restaurant_outlined),
      ('On the Way', 'delivering', Icons.delivery_dining_outlined),
      ('Delivered', 'delivered', Icons.home_outlined),
    ];

    final statusOrder = [
      'pending',
      'accepted',
      'preparing',
      'ready',
      'picked_up',
      'delivering',
      'delivered'
    ];
    final currentIdx = statusOrder.indexOf(status);

    return Row(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final stepIdx = statusOrder.indexOf(step.$2);
        final isDone = currentIdx >= stepIdx && currentIdx != -1;
        final isCancelled = status == 'cancelled';

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? AppColors.errorLight
                          : isDone
                              ? AppColors.primary
                              : AppColors.backgroundSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCancelled ? Icons.close : step.$3,
                      size: 16,
                      color: isCancelled
                          ? AppColors.error
                          : isDone
                              ? Colors.white
                              : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDone
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      fontWeight:
                          isDone ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? AppColors.primary : AppColors.border,
                    margin: const EdgeInsets.only(bottom: 18),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );

  Widget _priceRow(String label, String value) => Row(
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

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'delivering':
      case 'picked_up':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'delivering':
        return Icons.delivery_dining;
      case 'preparing':
        return Icons.restaurant_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}
