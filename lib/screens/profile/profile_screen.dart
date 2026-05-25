import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/photo_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../main.dart';
import '../../widgets/event_qr_modal.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import '../help_desk/help_desk_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
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
                  );
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
      body: SingleChildScrollView(
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
                      : (authProvider.profileImage != 'NA' && authProvider.profileImage.isNotEmpty)
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
            const SizedBox(height: 28),
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
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final photo = Provider.of<PhotoProvider>(context, listen: false);

                  // 1. Navigate to LoginScreen first using standard debounced redirect
                  MyApp.redirectToLogin();
                  
                  // 2. Perform logout cleanup asynchronously in the next frame
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
            const SizedBox(height: 30),
          ],
        ),
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
}
