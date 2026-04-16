import '../../core/constants/app_constants.dart';

String? _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '${AppConstants.imageBaseUrl}$url';
}

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final String? category;
  final bool isAvailable;
  final String storeId;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.category,
    this.isAvailable = true,
    required this.storeId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // API returns nested: {id, pricePkr, isActive, product: {id, name, category, imageUrl}}
    final product = json['product'] as Map<String, dynamic>?;
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: product?['name'] ?? json['name'] ?? '',
      description: product?['description'] ?? json['description'],
      price: double.tryParse(json['pricePkr']?.toString() ?? '') ??
          (json['price'] as num?)?.toDouble() ?? 0,
      image: _resolveImageUrl(product?['imageUrl'] ?? json['imageUrl'] ?? json['image']),
      category: product?['category'] ?? json['category'],
      isAvailable: json['isActive'] ?? json['isAvailable'] ?? true,
      storeId: json['storeId'] ?? json['store'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'category': category,
        'isAvailable': isAvailable,
        'storeId': storeId,
      };
}
