import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.all(24),
                    child: Obx(() => Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  ((controller.user.value?.name.trim().isNotEmpty == true)
                                      ? controller.user.value!.name.substring(0, 1)
                                      : 'G').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.user.value?.name ?? 'Guest User',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.user.value?.phone ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.primary),
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(height: 12),
                  // Menu items
                  _MenuSection(
                    title: 'Orders & Delivery',
                    items: [
                      _MenuItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'My Orders',
                        onTap: () => Get.toNamed(AppRoutes.orders),
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        label: 'Saved Addresses',
                        onTap: () => Get.toNamed(AppRoutes.addresses),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MenuSection(
                    title: 'Preferences',
                    items: [
                      _MenuItem(
                        icon: Icons.favorite_border,
                        label: 'Favourites',
                        onTap: () => Get.toNamed(AppRoutes.favourites),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () => Get.toNamed(AppRoutes.notifications),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MenuSection(
                    title: 'Account',
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.info_outline,
                        label: 'About Bringit',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.logout,
                        label: 'Logout',
                        onTap: controller.logout,
                        isDestructive: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          BottomNavWidget(
            selectedIndex: 3,
            onTap: (i) {
              if (i == 0) Get.offAllNamed(AppRoutes.home);
              if (i == 1) Get.toNamed(AppRoutes.favourites);
              if (i == 2) Get.toNamed(AppRoutes.orders);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.map((item) => item),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorLight
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDestructive ? AppColors.error : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
