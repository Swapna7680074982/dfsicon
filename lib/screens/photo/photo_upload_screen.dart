import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/photo_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/dashed_circle_avatar.dart';
import '../../main.dart';

class PhotoUploadScreen extends StatelessWidget {
  const PhotoUploadScreen({super.key});

  Widget _buildSelectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.tileBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.tileBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MyApp.resetRedirectFlag();
    final photoProvider = Provider.of<PhotoProvider>(context);

    Future<void> navigateToNextScreen() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.skipPhotoUpload();
      if (!context.mounted) return;
      if (authProvider.isSpeakerRole) {
        Navigator.of(context).pushNamedAndRemoveUntil('/role_selection', (route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      }
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add your photo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: navigateToNextScreen,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Info banner explaining why photo is important
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF1D4ED8),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Adding a face photo enables automatic AI facial recognition to tag and show all your photos in the event Gallery.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF1E3A8A),
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                Center(
                  child: DashedCircleAvatar(
                    imagePath: photoProvider.imagePath,
                    radius: 70,
                    onTap: () {
                      photoProvider.pickImage(ImageSource.gallery);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                _buildSelectionCard(
                  icon: Icons.camera_alt_outlined,
                  iconColor: AppColors.iconCamera,
                  iconBgColor: AppColors.iconBgCamera,
                  title: 'Take a Photo',
                  subtitle: 'Open camera and snap a selfie',
                  onTap: () => photoProvider.pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 14),
                _buildSelectionCard(
                  icon: Icons.image_outlined,
                  iconColor: AppColors.iconGallery,
                  iconBgColor: AppColors.iconBgGallery,
                  title: 'Choose from Gallery',
                  subtitle: 'Select an existing photo',
                  onTap: () => photoProvider.pickImage(ImageSource.gallery),
                ),

                const Spacer(),

                CustomButton(
                  text: 'Save and Continue',
                  isEnabled: photoProvider.hasPhoto,
                  isLoading: photoProvider.isUploading,
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final navigator = Navigator.of(context);
                    final String? photoUrl = await photoProvider.uploadPhoto(authProvider.accessToken);
                    if (photoUrl != null) {
                      await authProvider.updateProfileImage(photoUrl);
                      if (authProvider.isSpeakerRole) {
                        navigator.pushNamedAndRemoveUntil('/role_selection', (route) => false);
                      } else {
                        navigator.pushNamedAndRemoveUntil('/dashboard', (route) => false);
                      }
                    } else if (photoProvider.uploadError != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(photoProvider.uploadError!),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: navigateToNextScreen,
                    child: const Text(
                      'Skip for now (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
