import '../../core/constants/app_constants.dart';

String? _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '${AppConstants.imageBaseUrl}$url';
}

class StoreModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String type;
  final double? rating;
  final int? reviewCount;
  final int? deliveryTime;
  final double? deliveryFee;
  final bool isOpen;
  final String? address;
  final List<String> categories;

  StoreModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.type,
    this.rating,
    this.reviewCount,
    this.deliveryTime,
    this.deliveryFee,
    this.isOpen = true,
    this.address,
    this.categories = const [],
  });

  bool get isRestaurant => type == 'restaurant';

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final subType = json['subType'] as String?;
    final rawType = (json['type'] as String? ?? 'store').toLowerCase();
    return StoreModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: _resolveImageUrl(
        json['logoUrl'] ??
        (json['bannerUrls'] as List?)?.whereType<String>().firstOrNull ??
        json['image'],
      ),
      type: rawType,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      deliveryTime: json['deliveryTime'] as int?,
      deliveryFee: double.tryParse(json['deliveryFeePkr']?.toString() ?? '') ??
          (json['deliveryFee'] as num?)?.toDouble(),
      isOpen: json['isOpen'] ?? true,
      address: json['addressLine'] ?? json['address'],
      categories: subType != null
          ? [subType]
          : List<String>.from(json['categories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'type': type,
        'rating': rating,
        'reviewCount': reviewCount,
        'deliveryTime': deliveryTime,
        'deliveryFee': deliveryFee,
        'isOpen': isOpen,
        'address': address,
        'categories': categories,
      };
}
