import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/photo_provider.dart';
import '../../providers/auth_provider.dart';
import '../../main.dart';
import '../../widgets/event_qr_modal.dart';
import 'edit_profile_screen.dart';
// import '../help_desk/help_desk_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUpdatingPrivacy = false;
  bool _isSwitchingRole = false;

  Future<void> _switchRole(String targetRole, AuthProvider authProvider) async {
    final currentRole = authProvider.isAdmin ? 'AD' : (authProvider.isSpeaker ? 'SK' : 'DL');
    if (targetRole == currentRole) return;

    setState(() {
      _isSwitchingRole = true;
    });

    // Update selected role in auth provider and persist
    authProvider.setSelectedRole(targetRole);

    if (!mounted) return;

    final roleName = targetRole == 'AD' ? 'Admin' : (targetRole == 'SK' ? 'Speaker' : 'Delegate');

    // Navigate to fresh dashboard so all tabs, data and state reload cleanly
    Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Switched to $roleName Portal'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchMyProfile();
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'DL';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'DL';
  }

  Future<void> _togglePrivacySetting(
    String key,
    bool currentValue,
    AuthProvider authProvider,
  ) async {
    setState(() {
      _isUpdatingPrivacy = true;
    });

    final showMobile = key == 'mobile' ? (!currentValue ? '1' : '0') : (authProvider.showMobile ? '1' : '0');
    final showEmail = key == 'email' ? (!currentValue ? '1' : '0') : (authProvider.showEmail ? '1' : '0');
    final showOrganisation = key == 'organisation' ? (!currentValue ? '1' : '0') : (authProvider.showOrganisation ? '1' : '0');
    final showDesignation = key == 'designation' ? (!currentValue ? '1' : '0') : (authProvider.showDesignation ? '1' : '0');

    final success = await authProvider.updatePrivacySettings(
      showMobile: showMobile,
      showEmail: showEmail,
      showOrganisation: showOrganisation,
      showDesignation: showDesignation,
    );

    setState(() {
      _isUpdatingPrivacy = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy settings updated successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: Duration(milliseconds: 1500),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update privacy settings'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSubmitting = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEECF9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Update your account password',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: isSubmitting ? null : () => Navigator.pop(sheetContext),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          height: 1,
                          color: AppColors.tileBorder,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Form fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Current Password
                            const Text(
                              'Current Password',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: currentPasswordController,
                              obscureText: obscureCurrent,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Enter current password',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textLight),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      obscureCurrent = !obscureCurrent;
                                    });
                                  },
                                  child: Icon(
                                    obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 20,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.inputBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.inputBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // New Password
                            const Text(
                              'New Password',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: newPasswordController,
                              obscureText: obscureNew,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Enter new password',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: const Icon(Icons.lock_reset_outlined, size: 18, color: AppColors.textLight),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      obscureNew = !obscureNew;
                                    });
                                  },
                                  child: Icon(
                                    obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 20,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.inputBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.inputBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Confirm New Password
                            const Text(
                              'Confirm New Password',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: obscureConfirm,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Confirm new password',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.textLight),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      obscureConfirm = !obscureConfirm;
                                    });
                                  },
                                  child: Icon(
                                    obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 20,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.inputBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.inputBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: isSubmitting ? null : () => Navigator.pop(sheetContext),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () async {
                                          final currentPassword = currentPasswordController.text;
                                          final newPassword = newPasswordController.text;
                                          final confirmPassword = confirmPasswordController.text;

                                          if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please fill all password fields'),
                                                behavior: SnackBarBehavior.floating,
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                            return;
                                          }
                                          if (newPassword != confirmPassword) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('New password and confirm password do not match'),
                                                behavior: SnackBarBehavior.floating,
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                            return;
                                          }

                                          setSheetState(() {
                                            isSubmitting = true;
                                          });

                                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                          final errorMsg = await authProvider.changePassword(
                                            currentPassword: currentPassword,
                                            newPassword: newPassword,
                                            confirmPassword: confirmPassword,
                                          );

                                          setSheetState(() {
                                            isSubmitting = false;
                                          });

                                          if (context.mounted) {
                                            if (errorMsg == null) {
                                              Navigator.pop(sheetContext);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Password changed successfully. Please login again.'),
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: AppColors.primary,
                                                ),
                                              );
                                              MyApp.redirectToLogin();
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(errorMsg),
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: Colors.redAccent,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text(
                                          'Update Password',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Delete Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your personal data and connections will be lost.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() {
                            isSubmitting = true;
                          });

                          final photo = Provider.of<PhotoProvider>(context, listen: false);
                          final errorMsg = await authProvider.deleteAccount(
                            confirm: true,
                          );

                          setDialogState(() {
                            isSubmitting = false;
                          });

                          if (context.mounted) {
                            if (errorMsg == null) {
                              Navigator.pop(dialogContext);
                              MyApp.redirectToLogin();
                              photo.clearImage();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your account has been deleted'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    // final homeProvider = Provider.of<HomeProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final isSpeaker = authProvider.isSpeaker;

    final String name = authProvider.userName;
    final String initials = _getInitials(name);
    final String designation = authProvider.designation;
    final String roleLabel = isAdmin ? 'Admin' : (isSpeaker ? 'Speaker' : 'Delegate');
    final String email = authProvider.email;
    final String phone = authProvider.mobile;
    final String orgName = authProvider.hospitalClinicName;
    final String orgLabel = isSpeaker ? 'Organization' : 'Hospital Name';



    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  ).then((_) {
                    authProvider.fetchMyProfile();
                  });
                },
                icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.textPrimary),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: photoProvider.hasPhoto
                          ? Image.file(
                              File(photoProvider.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : authProvider.hasValidProfileImage
                              ? Image.network(
                                  authProvider.profileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            designation,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Logged in as: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isAdmin
                                      ? const Color(0xFFEEF2FF)
                                      : const Color(0xFFEEECF9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  roleLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isAdmin
                                        ? const Color(0xFF6366F1)
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (authProvider.isAdminRole || authProvider.isSpeakerRole) ...[
                            const SizedBox(height: 8),
                            PopupMenuButton<String>(
                                  tooltip: 'Switch Portal',
                                  offset: const Offset(0, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  elevation: 8,
                                  color: Colors.white,
                                  onSelected: (targetRole) => _switchRole(targetRole, authProvider),
                                  itemBuilder: (context) {
                                    return [
                                      if (authProvider.isAdminRole && !isAdmin)
                                        PopupMenuItem<String>(
                                          value: 'AD',
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEEF2FF),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.admin_panel_settings_rounded, size: 17, color: Color(0xFF6366F1)),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Admin Portal',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Dashboard & stats',
                                                      style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (authProvider.isSpeakerRole && !isSpeaker)
                                        PopupMenuItem<String>(
                                          value: 'SK',
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEEECF9),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.record_voice_over_rounded, size: 17, color: AppColors.primary),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Speaker Portal',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Topics & presentations',
                                                      style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((authProvider.isAdminRole || authProvider.isSpeakerRole) && (isAdmin || isSpeaker))
                                        PopupMenuItem<String>(
                                          value: 'DL',
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFECFDF5),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.badge_outlined, size: 17, color: Color(0xFF0F766E)),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Delegate Portal',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Sessions & agenda',
                                                      style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ];
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A), // Premium sleek dark navy
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Switch',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: Colors.white70),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => EventQrModal(
                        userName: name,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.tileBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'My Event QR Code',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tap to view & share your QR code',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.qr_code_2_outlined,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.tileBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem(
                        icon: Icons.mail_outline,
                        iconBg: const Color(0xFFEEECF9),
                        iconColor: AppColors.primary,
                        label: 'Email',
                        value: email,
                      ),
                      const Divider(height: 1, color: AppColors.tileBorder),
                      _buildDetailItem(
                        icon: Icons.phone_outlined,
                        iconBg: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF10B981),
                        label: 'Phone',
                        value: phone,
                      ),
                      const Divider(height: 1, color: AppColors.tileBorder),
                      _buildDetailItem(
                        icon: Icons.business_outlined,
                        iconBg: const Color(0xFFFDF2F8),
                        iconColor: const Color(0xFFDB2777),
                        label: orgLabel,
                        value: orgName,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // WORKSPACE PORTAL SECTION
                Row(
                  children: const [
                    Text(
                      'WORKSPACE PORTAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildWorkspaceRoleCard(authProvider),
                const SizedBox(height: 24),
                // PRIVACY SETTINGS SECTION
                Row(
                  children: const [
                    Text(
                      'PRIVACY SETTINGS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.tileBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildPrivacyToggleItem(
                        title: 'Show Mobile Number',
                        subtitle: 'Allow other delegates/speakers to view your mobile number',
                        value: authProvider.showMobile,
                        onChanged: (val) => _togglePrivacySetting('mobile', authProvider.showMobile, authProvider),
                      ),
                      const Divider(height: 1, color: AppColors.tileBorder),
                      _buildPrivacyToggleItem(
                        title: 'Show Email Address',
                        subtitle: 'Allow other delegates/speakers to view your email address',
                        value: authProvider.showEmail,
                        onChanged: (val) => _togglePrivacySetting('email', authProvider.showEmail, authProvider),
                      ),
                      const Divider(height: 1, color: AppColors.tileBorder),
                      _buildPrivacyToggleItem(
                        title: 'Show Organization/Hospital',
                        subtitle: 'Allow other delegates/speakers to view your organization',
                        value: authProvider.showOrganisation,
                        onChanged: (val) => _togglePrivacySetting('organisation', authProvider.showOrganisation, authProvider),
                      ),
                      const Divider(height: 1, color: AppColors.tileBorder),
                      _buildPrivacyToggleItem(
                        title: 'Show Designation',
                        subtitle: 'Allow other delegates/speakers to view your designation',
                        value: authProvider.showDesignation,
                        onChanged: (val) => _togglePrivacySetting('designation', authProvider.showDesignation, authProvider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Text(
                      'SUPPORT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                /*
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.tileBorder, width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.help_outline,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    title: const Text(
                      'Help & Support',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpDeskScreen()),
                      );
                    },
                  ),
                ),
                */
                const SizedBox(height: 36),
                if (authProvider.isForeignUser) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showChangePasswordDialog(context);
                      },
                      icon: const Icon(Icons.lock_outline, size: 16),
                      label: const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final photo = Provider.of<PhotoProvider>(context, listen: false);

                      MyApp.redirectToLogin();
                      
                      Future.microtask(() {
                        photo.clearImage();
                        auth.logout();
                      });
                    },
                    icon: const Icon(Icons.logout_outlined, size: 16),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFCA5A5), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteAccountDialog(context);
                    },
                    icon: const Icon(Icons.delete_forever_outlined, size: 16),
                    label: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_isUpdatingPrivacy || _isSwitchingRole)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _isSwitchingRole ? 'Switching portal...' : 'Updating settings...',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withAlpha(50),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceRoleCard(AuthProvider authProvider) {
    final bool isAdminRole = authProvider.isAdminRole;
    final bool isSpeakerRole = authProvider.isSpeakerRole;
    final bool isAdmin = authProvider.isAdmin;
    final bool isSpeaker = authProvider.isSpeaker;

    if (!isAdminRole && !isSpeakerRole) {
      // Delegate-only user
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.tileBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.badge_outlined,
                color: Color(0xFF0F766E),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Delegate Portal',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Standard Attendee Access for DFSICON 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tileBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Option 1: Admin Portal (If Admin role)
          if (isAdminRole) ...[
            InkWell(
              onTap: (_isSwitchingRole || isAdmin)
                  ? null
                  : () => _switchRole('AD', authProvider),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: isAdmin ? const Color(0xFFF9FAFF) : Colors.transparent,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isAdmin ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 20,
                        color: isAdmin ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Admin Portal',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: isAdmin ? const Color(0xFF6366F1) : AppColors.textPrimary,
                                ),
                              ),
                              if (isAdmin) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Current',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Conference stats, speakers, topics, workshops & booths',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isAdmin)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF6366F1),
                        size: 20,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(35),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz_rounded, size: 13, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Switch',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.tileBorder),
          ],

          // Option 2: Speaker Portal
          InkWell(
            onTap: (_isSwitchingRole || isSpeaker)
                ? null
                : () => _switchRole('SK', authProvider),
            borderRadius: isAdminRole ? BorderRadius.zero : const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: isSpeaker ? const Color(0xFFF9FAFF) : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSpeaker ? AppColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      size: 19,
                      color: isSpeaker ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Speaker Portal',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isSpeaker ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            if (isSpeaker) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Topics, my schedule, presentation & abstracts',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isSpeaker)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 20,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(35),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Switch',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.tileBorder),

          // Option 3: Delegate Portal
          InkWell(
            onTap: (_isSwitchingRole || (!isAdmin && !isSpeaker))
                ? null
                : () => _switchRole('DL', authProvider),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: (!isAdmin && !isSpeaker) ? const Color(0xFFF9FAFF) : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: (!isAdmin && !isSpeaker) ? const Color(0xFF0F766E) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.badge_outlined,
                      size: 19,
                      color: (!isAdmin && !isSpeaker) ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Delegate Portal',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: (!isAdmin && !isSpeaker) ? const Color(0xFF0F766E) : AppColors.textPrimary,
                              ),
                            ),
                            if (!isAdmin && !isSpeaker) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Full conference agenda, stalls & workshops',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!isAdmin && !isSpeaker)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF0F766E),
                      size: 20,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(35),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Switch',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
