import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/otp_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/logo2.png',
                height: 48,
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your mobile number to receive a one-time verification code.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => authProvider.setPhoneNumber(value),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '987654 3210',
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: (authProvider.isPhoneValid && !authProvider.isSendingOtp)
                          ? () {
                              if (!authProvider.otpSent) {
                                authProvider.sendOtp();
                              } else {
                                authProvider.resendOtp();
                              }
                            }
                          : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: authProvider.isSendingOtp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Text(
                              authProvider.otpSent ? 'Resend' : 'Send OTP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: authProvider.isPhoneValid
                                    ? AppColors.primary
                                    : AppColors.textLight,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              if (authProvider.otpSent) ...[
                const SizedBox(height: 24),
                const Text(
                  'OTP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                OtpInputRow(
                  length: 6,
                  onOtpChanged: (otp) => authProvider.setOtpCode(otp),
                ),
                const SizedBox(height: 12),
                Text(
                  authProvider.resendSeconds > 0
                      ? 'Resend in ${authProvider.resendSeconds}s'
                      : 'Resend in 0s',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              const Spacer(),
              CustomButton(
                text: 'Verify and Continue',
                isEnabled: authProvider.otpSent && authProvider.isOtpComplete,
                isLoading: authProvider.isVerifying,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final bool success = await authProvider.verifyOtp();
                  if (success && mounted) {
                    if (authProvider.profileImage != 'NA' && authProvider.profileImage.isNotEmpty) {
                      navigator.pushReplacementNamed('/dashboard');
                    } else {
                      navigator.pushNamed('/photo_upload');
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
