import '../../core/constants/app_constants.dart';

String? _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '${AppConstants.imageBaseUrl}$url';
}

class CartItemModel {
  final String id;
  final String itemId;
  final String name;
  final double price;
  final String? image;
  int quantity;
  final String storeId;
  final String itemType;

  CartItemModel({
    required this.id,
    required this.itemId,
    required this.name,
    required this.price,
    this.image,
    required this.quantity,
    required this.storeId,
    required this.itemType,
  });

  double get total => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // API: {id, quantity, menuItemId, storeProductId, menuItem:{name,pricePkr,imageUrl}, storeProduct:{...}}
    final menuItem = json['menuItem'] as Map<String, dynamic>?;
    final storeProduct = json['storeProduct'] as Map<String, dynamic>?;
    final product = storeProduct?['product'] as Map<String, dynamic>?;
    final name = menuItem?['name'] ?? product?['name'] ?? json['name'] ?? '';
    final priceStr = menuItem?['pricePkr'] ?? storeProduct?['pricePkr'] ?? json['pricePkr'];
    final price = double.tryParse(priceStr?.toString() ?? '') ??
        (json['price'] as num?)?.toDouble() ?? 0;
    final image = _resolveImageUrl(menuItem?['imageUrl'] ?? product?['imageUrl'] ?? json['image']);
    final itemId = json['menuItemId'] ?? json['storeProductId'] ?? json['productId'] ?? '';
    final itemType = json['menuItemId'] != null ? 'menuItem' : 'product';
    return CartItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      itemId: itemId,
      name: name,
      price: price,
      image: image,
      quantity: json['quantity'] ?? 1,
      storeId: json['storeId'] ?? '',
      itemType: itemType,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'name': name,
        'price': price,
        'image': image,
        'quantity': quantity,
        'storeId': storeId,
        'itemType': itemType,
      };
}
