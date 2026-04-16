import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class QuantitySelectorWidget extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelectorWidget({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleButton(
          icon: Icons.remove,
          onTap: onDecrement,
          isActive: quantity > 0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.add,
          onTap: onIncrement,
          isActive: true,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.backgroundSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : AppColors.textTertiary,
        ),
      ),
    );
  }
}
