import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository _repo;
  OrderController(this._repo);

  final isLoading = false.obs;
  final orders = <OrderModel>[].obs;
  final currentOrder = Rxn<OrderModel>();
  final selectedTab = 0.obs; // 0=All, 1=Active, 2=Completed, 3=Cancelled

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    final args = Get.arguments;
    if (args is OrderModel) {
      currentOrder.value = args;
    } else if (args is Map && args['orderId'] != null) {
      fetchOrder(args['orderId']);
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      orders.value = await _repo.getOrders();
    } catch (e) {
      orders.value = _mockOrders();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrder(String orderId) async {
    try {
      currentOrder.value = await _repo.getOrder(orderId);
    } catch (e) {
      // keep current
    }
  }

  List<OrderModel> get filteredOrders {
    switch (selectedTab.value) {
      case 1:
        return orders
            .where((o) => [
                  'pending',
                  'accepted',
                  'preparing',
                  'ready',
                  'picked_up',
                  'delivering'
                ].contains(o.status))
            .toList();
      case 2:
        return orders.where((o) => o.status == 'delivered').toList();
      case 3:
        return orders.where((o) => o.status == 'cancelled').toList();
      default:
        return orders;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _repo.cancelOrder(orderId, 'User cancelled');
      final idx = orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        orders.refresh();
      }
      fetchOrders();
      Get.snackbar('Order Cancelled', 'Your order has been cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Could not cancel order');
    }
  }

  List<OrderModel> _mockOrders() => [
        OrderModel(
          id: 'ord001',
          storeId: '1',
          storeName: 'Burger Lab',
          status: 'delivered',
          total: 1350,
          deliveryFee: 49,
          address: 'House 12, Block B, Gulberg III, Lahore',
          items: [
            OrderItemModel(name: 'Classic Burger', quantity: 2, price: 650),
            OrderItemModel(name: 'Loaded Fries', quantity: 1, price: 350),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        OrderModel(
          id: 'ord002',
          storeId: '5',
          storeName: 'Metro Superstore',
          status: 'delivering',
          total: 2760,
          deliveryFee: 99,
          address: 'House 12, Block B, Gulberg III, Lahore',
          items: [
            OrderItemModel(name: 'Whole Milk 1L', quantity: 2, price: 180),
            OrderItemModel(name: 'Basmati Rice 5kg', quantity: 1, price: 1200),
            OrderItemModel(name: 'Desi Ghee 1kg', quantity: 1, price: 2200),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        OrderModel(
          id: 'ord003',
          storeId: '3',
          storeName: 'Pizza Point',
          status: 'pending',
          total: 1820,
          deliveryFee: 59,
          address: 'House 12, Block B, Gulberg III, Lahore',
          items: [
            OrderItemModel(name: 'Margherita Pizza', quantity: 2, price: 850),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ];
}
