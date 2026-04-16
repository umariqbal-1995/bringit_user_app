import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        if (controller.notifications.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.notifications_outlined,
            title: 'No notifications',
            subtitle: 'You\'re all caught up!',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (controller.todayNotifications.isNotEmpty) ...[
                _sectionHeader('Today'),
                ...controller.todayNotifications
                    .map((n) => _NotificationTile(notification: n)),
              ],
              if (controller.earlierNotifications.isNotEmpty) ...[
                _sectionHeader('Earlier'),
                ...controller.earlierNotifications
                    .map((n) => _NotificationTile(notification: n)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      );
}

class _NotificationTile extends StatelessWidget {
  final dynamic notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead as bool;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isRead ? AppColors.background : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? AppColors.border : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBg(notification.type),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon(notification.type),
                color: _iconColor(notification.type),
                size: 22,
              ),
            ),
            if (!isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 2)),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification.title ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              notification.message ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM dd').format(dt);
  }

  IconData _icon(String? type) {
    switch (type) {
      case 'order':
        return Icons.receipt_long_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconBg(String? type) {
    switch (type) {
      case 'order':
        return AppColors.primaryLight;
      case 'promo':
        return const Color(0xFFFEF9C3);
      default:
        return AppColors.backgroundSecondary;
    }
  }

  Color _iconColor(String? type) {
    switch (type) {
      case 'order':
        return AppColors.primary;
      case 'promo':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
