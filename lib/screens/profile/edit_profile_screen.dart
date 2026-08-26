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
  
  // Dynamic API fields
  late TextEditingController _genderController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _countryIdController;
  late TextEditingController _postalCodeController;
  late TextEditingController _categoryController;
  late TextEditingController _qualificationController;
  late TextEditingController _experienceYearsController;

  bool _isSaving = false;

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

    _genderController = TextEditingController(text: authProvider.gender);
    _stateController = TextEditingController(text: authProvider.state);
    _cityController = TextEditingController(text: authProvider.city);
    _countryIdController = TextEditingController(text: authProvider.countryId.isEmpty ? '1' : authProvider.countryId);
    _postalCodeController = TextEditingController(text: authProvider.postalCode);
    _categoryController = TextEditingController(text: authProvider.category);
    _qualificationController = TextEditingController(text: authProvider.qualification);
    _experienceYearsController = TextEditingController(text: authProvider.experienceYears);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hospitalController.dispose();
    _specializationController.dispose();
    _designationController.dispose();
    
    _genderController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _countryIdController.dispose();
    _postalCodeController.dispose();
    _categoryController.dispose();
    _qualificationController.dispose();
    _experienceYearsController.dispose();
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
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Text(
                  'Please upload a clear photo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
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
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isSaving = true;
                          });

                          final fields = {
                            'gender': _genderController.text.trim(),
                            'state': _stateController.text.trim(),
                            'city': _cityController.text.trim(),
                            'country_id': _countryIdController.text.trim(),
                            'postal_code': _postalCodeController.text.trim(),
                            'category': _categoryController.text.trim(),
                            'specialization': _specializationController.text.trim(),
                            'qualification': _qualificationController.text.trim(),
                            'experience_years': _experienceYearsController.text.trim(),
                            'organisation_name': _hospitalController.text.trim(),
                            'designation': _designationController.text.trim(),
                          };

                          File? imgFile;
                          if (photoProvider.hasPhoto) {
                            imgFile = File(photoProvider.imagePath!);
                          }

                          final success = await authProvider.updateProfileApi(
                            fields: fields,
                            profileImage: imgFile,
                          );

                          setState(() {
                            _isSaving = false;
                          });

                          if (mounted) {
                            if (success) {
                              photoProvider.clearImage();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile saved successfully!'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update profile. Please try again.'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
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
                child: _isSaving
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
                child: Column(
                  children: [
                    GestureDetector(
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
                    const SizedBox(height: 10),
                    const Text(
                      'Please upload a clear photo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Read-only section warning
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.amber.shade800, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Full Name, Email, and Phone cannot be edited.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildFieldLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, isEnabled: false),
              const SizedBox(height: 20),
              
              _buildFieldLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(_emailController, isEnabled: false),
              const SizedBox(height: 20),
              
              _buildFieldLabel('Phone'),
              const SizedBox(height: 8),
              _buildTextField(_phoneController, isEnabled: false),
              const SizedBox(height: 20),

              _buildFieldLabel('Gender'),
              const SizedBox(height: 8),
              _buildDropdownField(
                controller: _genderController,
                items: ['Male', 'Female', 'Other'],
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('Hospital / Organisation'),
              const SizedBox(height: 8),
              _buildTextField(_hospitalController),
              const SizedBox(height: 20),

              _buildFieldLabel('Designation'),
              const SizedBox(height: 8),
              _buildTextField(_designationController),
              const SizedBox(height: 20),
              
              _buildFieldLabel('Specialization'),
              const SizedBox(height: 8),
              _buildTextField(_specializationController),
              const SizedBox(height: 20),

              _buildFieldLabel('Qualification'),
              const SizedBox(height: 8),
              _buildTextField(_qualificationController),
              const SizedBox(height: 20),

              _buildFieldLabel('Experience (Years)'),
              const SizedBox(height: 8),
              _buildTextField(_experienceYearsController, keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              _buildFieldLabel('Category'),
              const SizedBox(height: 8),
              _buildTextField(_categoryController),
              const SizedBox(height: 20),

              _buildFieldLabel('City'),
              const SizedBox(height: 8),
              _buildTextField(_cityController),
              const SizedBox(height: 20),

              _buildFieldLabel('State'),
              const SizedBox(height: 8),
              _buildTextField(_stateController),
              const SizedBox(height: 20),

              _buildFieldLabel('Postal Code'),
              const SizedBox(height: 8),
              _buildTextField(_postalCodeController, keyboardType: TextInputType.number),
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

  Widget _buildTextField(
    TextEditingController controller, {
    bool isEnabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        color: isEnabled ? AppColors.textSecondary : Colors.grey.shade500,
        fontWeight: isEnabled ? FontWeight.normal : FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isEnabled ? Colors.grey.shade50 : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
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

  Widget _buildDropdownField({
    required TextEditingController controller,
    required List<String> items,
  }) {
    if (controller.text.isEmpty && items.isNotEmpty) {
      controller.text = items.first;
    }
    return DropdownButtonFormField<String>(
      value: items.contains(controller.text) ? controller.text : items.first,
      onChanged: (val) {
        if (val != null) {
          controller.text = val;
        }
      },
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
    );
  }
}
