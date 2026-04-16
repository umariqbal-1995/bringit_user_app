import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/models/store_model.dart';

class StoreCardWidget extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const StoreCardWidget({
    super.key,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildImage(),
            ),
            // Info area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          store.categories.take(2).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: AppColors.star),
                        const SizedBox(width: 2),
                        Text(
                          store.rating?.toStringAsFixed(1) ?? '4.0',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.access_time, size: 11, color: AppColors.textTertiary),
                        const SizedBox(width: 2),
                        Text(
                          '${store.deliveryTime ?? 30} min',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (store.deliveryFee == 0 || store.deliveryFee == null)
                                ? AppColors.successLight
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (store.deliveryFee == 0 || store.deliveryFee == null)
                                ? 'Free'
                                : 'Rs ${store.deliveryFee!.toInt()}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: (store.deliveryFee == 0 || store.deliveryFee == null)
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (store.image != null && store.image!.isNotEmpty) {
      return Image.network(
        store.image!,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }
    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      height: 120,
      width: double.infinity,
      color: store.isRestaurant ? AppColors.primaryLight : AppColors.backgroundSecondary,
      child: Icon(
        store.isRestaurant ? Icons.restaurant : Icons.storefront_outlined,
        size: 40,
        color: store.isRestaurant ? AppColors.primary : AppColors.textTertiary,
      ),
    );
  }
}
