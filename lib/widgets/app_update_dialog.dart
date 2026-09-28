import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../domain/utility_models.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppVersionInfo versionInfo;
  final String installedVersionName;

  static const String defaultIosStoreUrl =
      'https://apps.apple.com/us/app/dfsicon/id6804636698';
  static const String defaultAndroidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.hhcl.dfsicon&pcampaignid=web_share';

  const AppUpdateDialog({
    super.key,
    required this.versionInfo,
    this.installedVersionName = '',
  });

  Future<void> _launchStoreUrl(BuildContext context) async {
    String targetUrl = versionInfo.updateUrl.trim();
    if (targetUrl.isEmpty) {
      targetUrl = Platform.isIOS ? defaultIosStoreUrl : defaultAndroidStoreUrl;
    }

    try {
      final uri = Uri.parse(targetUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to default platform URL
        final fallbackUri = Uri.parse(
          Platform.isIOS ? defaultIosStoreUrl : defaultAndroidStoreUrl,
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        final fallbackUri = Uri.parse(
          Platform.isIOS ? defaultIosStoreUrl : defaultAndroidStoreUrl,
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open store link: $targetUrl'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isForced = versionInfo.forceUpdate;
    final String displayMessage = versionInfo.message.isNotEmpty
        ? versionInfo.message
        : (isForced
            ? 'A mandatory update is required to continue using DFSICON. Please update to the latest version.'
            : 'A new version of DFSICON is available with improvements and new features.');

    final String latestVersion = versionInfo.latestVersionName.isNotEmpty
        ? 'v${versionInfo.latestVersionName}'
        : (versionInfo.latestVersionCode > 0 ? 'Build ${versionInfo.latestVersionCode}' : '');

    final String currentVersion = installedVersionName.isNotEmpty
        ? 'v$installedVersionName'
        : (versionInfo.currentVersionCode > 0 ? 'Build ${versionInfo.currentVersionCode}' : '');

    return PopScope(
      canPop: !isForced,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 16,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient banner & decorative icon
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      Color(0xFF2B52BA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon Circle
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isForced
                              ? Icons.system_security_update_rounded
                              : Icons.system_update_alt_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isForced ? 'Update Required' : 'New Update Available',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isForced ? 'Critical Update' : 'Recommended Update',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Version info badges
                    if (latestVersion.isNotEmpty || currentVersion.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (currentVersion.isNotEmpty)
                              Column(
                                children: [
                                  const Text(
                                    'Installed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentVersion,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            if (currentVersion.isNotEmpty && latestVersion.isNotEmpty)
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            if (latestVersion.isNotEmpty)
                              Column(
                                children: [
                                  const Text(
                                    'Latest Version',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    latestVersion,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Update Message
                    Text(
                      displayMessage,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 22),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _launchStoreUrl(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Platform.isIOS ? Icons.apple : Icons.shop_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Update Now',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Cancel / Later Button (only if not force update)
                    if (!isForced) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Later',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
