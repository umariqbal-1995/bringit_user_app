import '../../core/constants/app_constants.dart';

String? _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '${AppConstants.imageBaseUrl}$url';
}

class MenuItemModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final String? category;
  final bool isAvailable;
  final String storeId;

  MenuItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.category,
    this.isAvailable = true,
    required this.storeId,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        price: double.tryParse(json['pricePkr']?.toString() ?? '') ??
            (json['price'] as num?)?.toDouble() ?? 0,
        image: _resolveImageUrl(json['imageUrl'] ?? json['image']),
        category: json['category'],
        isAvailable: json['isActive'] ?? json['isAvailable'] ?? true,
        storeId: json['storeId'] ?? json['store'] ?? '',
      );

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
