import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class _PakistanFlag extends StatelessWidget {
  const _PakistanFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 24,
        height: 16,
        child: CustomPaint(painter: _PakistanFlagPainter()),
      ),
    );
  }
}

class _PakistanFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // White stripe (left 1/4)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * 0.25, size.height),
      Paint()..color = Colors.white,
    );
    // Green field (right 3/4)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.25, 0, size.width * 0.75, size.height),
      Paint()..color = const Color(0xFF01411C),
    );
    // White crescent
    final cx = size.width * 0.62;
    final cy = size.height * 0.5;
    final r = size.height * 0.32;
    final crescentPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r, crescentPaint);
    canvas.drawCircle(
      Offset(cx + r * 0.28, cy),
      r * 0.82,
      Paint()..color = const Color(0xFF01411C),
    );
    // White star
    final starPaint = Paint()..color = Colors.white;
    final starCx = cx + r * 0.55;
    final starCy = cy - r * 0.1;
    _drawStar(canvas, starPaint, starCx, starCy, r * 0.22, r * 0.09, 5);
  }

  void _drawStar(Canvas canvas, Paint paint, double cx, double cy,
      double outerR, double innerR, int points) {
    final path = Path();
    final angle = math.pi / points;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final a = i * angle - math.pi / 2;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SendOtpView extends GetView<AuthController> {
  const SendOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bringit',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Enter your phone number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We'll send you a 6-digit verification code",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backgroundSecondary,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const _PakistanFlag(),
                          const SizedBox(width: 6),
                          const Text(
                            '+92',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 24, color: AppColors.border),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: '3XX XXX XXXX',
                          hintStyle:
                              TextStyle(color: AppColors.textTertiary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            final num =
                                '+92${phoneController.text.trim()}';
                            controller.sendOtp(num);
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Send Code'),
                  )),
              const SizedBox(height: 24),
              const Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
