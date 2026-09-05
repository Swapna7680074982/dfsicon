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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Add your photo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please upload a clear photo to help attendees recognize you and get tagged in event photos automatically.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please upload a clear photo with your face clearly visible.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              DashedCircleAvatar(
                imagePath: photoProvider.imagePath,
                radius: 80,
                onTap: () {
                  photoProvider.pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 40),

              _buildSelectionCard(
                icon: Icons.camera_alt_outlined,
                iconColor: AppColors.iconCamera,
                iconBgColor: AppColors.iconBgCamera,
                title: 'Take a Photo',
                subtitle: 'Open camera and snap a selfie',
                onTap: () => photoProvider.pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 16),
              _buildSelectionCard(
                icon: Icons.image_outlined,
                iconColor: AppColors.iconGallery,
                iconBgColor: AppColors.iconBgGallery,
                title: 'Choose from Gallery',
                subtitle: 'Select an existing photo',
                onTap: () => photoProvider.pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Your photo is used solely for event identification and gallery tagging. It is never shared externally or used for advertising.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              CustomButton(
                text: photoProvider.hasPhoto ? 'Save and Continue' : 'Upload a Photo to Continue',
                isEnabled: photoProvider.hasPhoto,
                isLoading: photoProvider.isUploading,
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final navigator = Navigator.of(context);
                  final String? photoUrl = await photoProvider.uploadPhoto(authProvider.accessToken);
                  if (photoUrl != null) {
                    await authProvider.updateProfileImage(photoUrl);
                    if (authProvider.isSpeakerRole) {
                      navigator.pushReplacementNamed('/role_selection');
                    } else {
                      navigator.pushReplacementNamed('/dashboard');
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
            ],
          ),
        ),
      ),
    );
  }
}
