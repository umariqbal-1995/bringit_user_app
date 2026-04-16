import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repo;
  NotificationController(this._repo);

  final isLoading = false.obs;
  final notifications = <NotificationModel>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      notifications.value = await _repo.getNotifications();
    } catch (e) {
      notifications.value = _mockNotifications();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _repo.markRead(id);
    } catch (_) {}
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      notifications.refresh();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllRead();
    } catch (_) {}
    notifications.refresh();
  }

  List<NotificationModel> get todayNotifications {
    final today = DateTime.now();
    return notifications.where((n) =>
        n.createdAt.year == today.year &&
        n.createdAt.month == today.month &&
        n.createdAt.day == today.day).toList();
  }

  List<NotificationModel> get earlierNotifications {
    final today = DateTime.now();
    return notifications.where((n) =>
        !(n.createdAt.year == today.year &&
            n.createdAt.month == today.month &&
            n.createdAt.day == today.day)).toList();
  }

  List<NotificationModel> _mockNotifications() => [
        NotificationModel(
          id: 'n1',
          title: 'Order Delivered!',
          message: 'Your order from Burger Lab has been delivered. Enjoy your meal!',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          type: 'order',
        ),
        NotificationModel(
          id: 'n2',
          title: 'Order On the Way',
          message: 'Your grocery order from Metro Superstore is on the way.',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'order',
        ),
        NotificationModel(
          id: 'n3',
          title: 'Special Offer!',
          message: 'Get 20% off on all grocery orders today. Use code FRESH20.',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          type: 'promo',
        ),
        NotificationModel(
          id: 'n4',
          title: 'New Restaurant Near You',
          message: 'Grill Station just joined Bringit. Try their amazing BBQ!',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          type: 'info',
        ),
      ];
}
