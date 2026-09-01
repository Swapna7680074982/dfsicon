import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  int _selectedTabIndex = 0; // 0: Indian (default), 1: Foreign
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _foreignPhoneController = TextEditingController();
  final TextEditingController _foreignPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _foreignPhoneController.dispose();
    _foreignPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/logo2.png',
                          height: 48,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tab Selector Widget (Indian / Foreign)
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_selectedTabIndex != 0) {
                                      setState(() {
                                        _selectedTabIndex = 0;
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedTabIndex == 0
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _selectedTabIndex == 0
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Indian',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedTabIndex == 0
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_selectedTabIndex != 1) {
                                      setState(() {
                                        _selectedTabIndex = 1;
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedTabIndex == 1
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _selectedTabIndex == 1
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Foreigner',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedTabIndex == 1
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Render Tab Content
                        if (_selectedTabIndex == 0) ...[
                          // INDIAN DELEGATE TAB FLOW
                          const Text(
                            'Enter your mobile number to receive a one-time verification code.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
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
                                      ? () async {
                                          final String? errorMsg = !authProvider.otpSent
                                              ? await authProvider.sendOtp(citizenType: 'INDIAN')
                                              : await authProvider.resendOtp(citizenType: 'INDIAN');
                                          if (errorMsg != null && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(errorMsg),
                                                behavior: SnackBarBehavior.floating,
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
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
                              final String? errorMsg = await authProvider.verifyOtp(citizenType: 'INDIAN');
                              if (errorMsg == null && mounted) {
                                if (authProvider.hasValidProfileImage) {
                                  navigator.pushReplacementNamed('/dashboard');
                                } else {
                                  navigator.pushNamed('/photo_upload');
                                }
                              } else if (errorMsg != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                          ),
                        ] else ...[
                          // FOREIGN DELEGATE TAB FLOW
                          const Text(
                            'Enter your phone number and password to login.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
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
                            child: TextField(
                              controller: _foreignPhoneController,
                              keyboardType: TextInputType.phone,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter mobile number',
                                hintStyle: TextStyle(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Password',
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
                            child: TextField(
                              controller: _foreignPasswordController,
                              obscureText: !_isPasswordVisible,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter password',
                                hintStyle: const TextStyle(
                                  color: AppColors.textLight,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomButton(
                            text: 'Login',
                            isEnabled: _foreignPhoneController.text.trim().isNotEmpty &&
                                _foreignPasswordController.text.isNotEmpty,
                            isLoading: authProvider.isLoggingInPassword,
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              final String? errorMsg = await authProvider.loginPassword(
                                mobile: _foreignPhoneController.text.trim(),
                                password: _foreignPasswordController.text,
                                citizenType: 'FOREIGN',
                              );
                              if (errorMsg == null && mounted) {
                                if (authProvider.hasValidProfileImage) {
                                  navigator.pushReplacementNamed('/dashboard');
                                } else {
                                  navigator.pushNamed('/photo_upload');
                                }
                              } else if (errorMsg != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                          ),
                        ],

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Are you a Doctor?",
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final Uri uri = Uri.parse('https://dfsicon2026.com/');
                                try {
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    await launchUrl(uri);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not open link: https://dfsicon2026.com/'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text(
                                'Add Doctor',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

