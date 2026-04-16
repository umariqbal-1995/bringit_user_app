class AddressModel {
  final String id;
  final String label;
  final String address;
  final double lat;
  final double lng;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['_id'] ?? json['id'] ?? '',
        label: json['label'] ?? 'Home',
        address: json['street'] ?? json['address'] ?? '',
        lat: double.tryParse(json['latitude']?.toString() ?? '') ??
            (json['lat'] as num?)?.toDouble() ?? 0,
        lng: double.tryParse(json['longitude']?.toString() ?? '') ??
            (json['lng'] as num?)?.toDouble() ?? 0,
        isDefault: json['isDefault'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'address': address,
        'lat': lat,
        'lng': lng,
      };
}
