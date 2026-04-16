class OrderModel {
  final String id;
  final String storeId;
  final String storeName;
  final String status;
  final double total;
  final double deliveryFee;
  final String address;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final String? trackingInfo;

  OrderModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.status,
    required this.total,
    required this.deliveryFee,
    required this.address,
    required this.items,
    required this.createdAt,
    this.trackingInfo,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final addr = json['address'];
    final addressStr = addr is Map
        ? '${addr['street'] ?? ''}, ${addr['city'] ?? ''}'.trim().replaceAll(RegExp(r'^,\s*|,\s*$'), '')
        : (addr as String? ?? '');
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      storeId: json['store']?['id'] ?? json['storeId'] ?? '',
      storeName: json['store']?['name'] ?? json['storeName'] ?? '',
      status: (json['status'] as String? ?? 'pending').toLowerCase(),
      total: double.tryParse(json['totalPkr']?.toString() ?? '') ??
          (json['total'] as num?)?.toDouble() ?? 0,
      deliveryFee: double.tryParse(json['deliveryFeePkr']?.toString() ?? '') ??
          (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      address: addressStr,
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      trackingInfo: json['trackingInfo'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'picked_up':
        return 'Picked Up';
      case 'delivering':
        return 'On the Way';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get isCancellable =>
      status == 'pending' || status == 'accepted';
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final menuItem = json['menuItem'] as Map<String, dynamic>?;
    final storeProduct = json['storeProduct'] as Map<String, dynamic>?;
    final name = menuItem?['name'] ?? storeProduct?['name'] ?? json['name'] ?? '';
    final price = double.tryParse(json['unitPricePkr']?.toString() ?? '') ??
        (json['price'] as num?)?.toDouble() ?? 0;
    return OrderItemModel(
      name: name,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: price,
    );
  }
}
