import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/photo_provider.dart';
import '../../providers/auth_provider.dart';
// import '../../providers/home_provider.dart';
import '../../main.dart';
// import '../../widgets/event_qr_modal.dart';
import 'edit_profile_screen.dart';
// import '../help_desk/help_desk_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUpdatingPrivacy = false;

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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final photo = Provider.of<PhotoProvider>(context, listen: false);

                // Simulate/Mock account deletion for now, navigate back to login
                MyApp.redirectToLogin();

                Future.microtask(() {
                  photo.clearImage();
                  auth.logout();
                  // Note: the delete account API will be integrated here later.
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
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
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    // final homeProvider = Provider.of<HomeProvider>(context);
    final isSpeaker = authProvider.isSpeaker;

    final String name = authProvider.userName;
    final String initials = _getInitials(name);
    final String designation = authProvider.designation;
    final String roleLabel = isSpeaker ? 'Speaker' : 'Delegate';
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEECF9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              roleLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                /*
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => EventQrModal(
                        userName: name,
                        eventName: homeProvider.eventInfo.name,
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
                          color: Colors.black.withAlpha(2),
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
                          color: AppColors.textPrimary,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
                */
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
          if (_isUpdatingPrivacy)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
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
}
