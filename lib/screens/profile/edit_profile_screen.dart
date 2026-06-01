import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../providers/photo_provider.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _hospitalController;
  late TextEditingController _specializationController;
  late TextEditingController _designationController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.userName);
    _emailController = TextEditingController(text: authProvider.email);
    _phoneController = TextEditingController(text: authProvider.mobile);
    _hospitalController = TextEditingController(text: authProvider.hospitalClinicName);
    _specializationController = TextEditingController(text: authProvider.specialization);
    _designationController = TextEditingController(text: authProvider.designation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hospitalController.dispose();
    _specializationController.dispose();
    _designationController.dispose();
    super.dispose();
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

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Photo Gallery'),
                onTap: () async {
                  await photoProvider.pickImage(ImageSource.gallery);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () async {
                  await photoProvider.pickImage(ImageSource.camera);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final String initials = _getInitials(authProvider.userName);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
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
              child: ElevatedButton(
                onPressed: photoProvider.isUploading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          // Upload photo if a new one is selected
                          if (photoProvider.hasPhoto && !photoProvider.uploadSuccess) {
                            final String? newProfilePic = await photoProvider.uploadPhoto(authProvider.accessToken);
                            if (newProfilePic != null) {
                              await authProvider.updateProfileImage(newProfilePic);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to upload profile photo. Saving text changes.'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          }

                          await authProvider.updateProfileLocal(
                            name: _nameController.text,
                            email: _emailController.text,
                            mobile: _phoneController.text,
                            hospitalClinicName: _hospitalController.text,
                            specialization: _specializationController.text,
                            designation: _designationController.text,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile saved successfully!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: photoProvider.isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _showImagePicker(context),
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
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
                                          fontSize: 26,
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
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildFieldLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(_nameController),
              const SizedBox(height: 20),
              _buildFieldLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(_emailController),
              const SizedBox(height: 20),
              _buildFieldLabel('Phone'),
              const SizedBox(height: 8),
              _buildTextField(_phoneController),
              const SizedBox(height: 20),
              _buildFieldLabel('Hospital Name'),
              const SizedBox(height: 8),
              _buildTextField(_hospitalController),
              const SizedBox(height: 20),
              _buildFieldLabel('Specialization'),
              const SizedBox(height: 8),
              _buildTextField(_specializationController),
              const SizedBox(height: 20),
              _buildFieldLabel('Designation'),
              const SizedBox(height: 8),
              _buildTextField(_designationController),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
