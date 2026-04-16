import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class VerifyOtpView extends StatefulWidget {
  const VerifyOtpView({super.key});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  final AuthController _controller = Get.find<AuthController>();
  final TextEditingController _pinController = TextEditingController();
  final String _phone;
  final String _masked;

  _VerifyOtpViewState()
      : _phone = (() {
          final args = Get.arguments as Map<String, dynamic>? ?? {};
          return args['phone'] as String? ?? '';
        })(),
        _masked = (() {
          final args = Get.arguments as Map<String, dynamic>? ?? {};
          final phone = args['phone'] as String? ?? '';
          return phone.length > 6
              ? '${phone.substring(0, 3)} ••• ••${phone.substring(phone.length - 2)}'
              : phone;
        })();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _masked,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  defaultPinTheme: PinTheme(
                    width: 52,
                    height: 60,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.backgroundSecondary,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 52,
                    height: 60,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primaryLight,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onCompleted: (otp) => _controller.verifyOtp(_phone, otp),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Resend code in 00:45',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Obx(() => ElevatedButton(
                    onPressed: _controller.isLoading.value
                        ? null
                        : () {
                            final otp = _pinController.text.trim();
                            if (otp.length == 6) {
                              _controller.verifyOtp(_phone, otp);
                            }
                          },
                    child: _controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verify'),
                  )),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => _controller.sendOtp(_phone),
                  child: const Text(
                    "Didn't receive code? Resend",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
