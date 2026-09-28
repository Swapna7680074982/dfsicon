import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../domain/api_service.dart';
import '../domain/utility_models.dart';
import '../widgets/app_update_dialog.dart';
import '../utils/custom_logger.dart';

class AppVersionService {
  AppVersionService._();

  static bool _isDialogShowing = false;
  static bool _hasCheckedInCurrentSession = false;

  static void resetSessionCheck() {
    _hasCheckedInCurrentSession = false;
  }

  /// Fetches app version status from the server
  static Future<AppVersionInfo?> fetchVersionInfo({
    required String accessToken,
  }) async {
    if (accessToken.trim().isEmpty) {
      return null;
    }

    try {
      final String platform = Platform.isIOS ? 'ios' : 'android';
      int currentBuildNumber = 10;
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        final parsedBuild = int.tryParse(packageInfo.buildNumber);
        if (parsedBuild != null && parsedBuild > 0) {
          currentBuildNumber = parsedBuild;
        }
      } catch (e) {
        CustomLogger.logError('Failed to get local package info', e);
      }

      final response = await ApiService.checkAppVersion(
        platform: platform,
        versionCode: currentBuildNumber,
        accessToken: accessToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final info = AppVersionInfo.fromJson(
            data['data'] as Map<String, dynamic>,
          );
          return info;
        }
      }
    } catch (e) {
      CustomLogger.logError('Error during app version check', e);
    }
    return null;
  }

  /// Checks the app version against the API and presents the update dialog if an update is available.
  static Future<void> checkAndShowUpdateDialog(
    BuildContext context, {
    required String accessToken,
    bool forceCheck = false,
  }) async {
    if (_isDialogShowing) return;
    if (_hasCheckedInCurrentSession && !forceCheck) return;

    if (accessToken.trim().isEmpty) return;

    final info = await fetchVersionInfo(accessToken: accessToken);
    if (info == null) return;

    _hasCheckedInCurrentSession = true;

    final bool isUpdateNeeded = info.updateAvailable ||
        info.forceUpdate ||
        (info.latestVersionCode > 0 &&
            info.currentVersionCode > 0 &&
            info.latestVersionCode > info.currentVersionCode);

    if (!isUpdateNeeded) return;
    if (!context.mounted) return;

    String installedVersion = '';
    try {
      final pkg = await PackageInfo.fromPlatform();
      installedVersion = pkg.version;
    } catch (_) {}

    _isDialogShowing = true;

    if (!context.mounted) {
      _isDialogShowing = false;
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: '/app_update_dialog'),
      builder: (dialogContext) => AppUpdateDialog(
        versionInfo: info,
        installedVersionName: installedVersion,
      ),
    );

    _isDialogShowing = false;
  }
}
