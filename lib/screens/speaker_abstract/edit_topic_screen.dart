import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/abstract_provider.dart';
import '../../widgets/water_droplets_background.dart';

class EditTopicScreen extends StatefulWidget {
  final String topicId;
  final Map<String, dynamic> initialData;

  const EditTopicScreen({
    super.key,
    required this.topicId,
    required this.initialData,
  });

  @override
  State<EditTopicScreen> createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _author1Controller = TextEditingController();
  final TextEditingController _author2Controller = TextEditingController();
  final TextEditingController _backgroundController = TextEditingController();
  final TextEditingController _aimsController = TextEditingController();
  final TextEditingController _methodsController = TextEditingController();
  final TextEditingController _resultsController = TextEditingController();
  final TextEditingController _conclusionController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _author1Controller.text = widget.initialData['contributing_author1_name']?.toString() ?? '';
    _author2Controller.text = widget.initialData['contributing_author2_name']?.toString() ?? '';
    _backgroundController.text = widget.initialData['background_introduction']?.toString() ?? '';
    _aimsController.text = widget.initialData['aims_objectives']?.toString() ?? '';
    _methodsController.text = widget.initialData['materials_methods']?.toString() ?? '';
    _resultsController.text = widget.initialData['results']?.toString() ?? '';
    _conclusionController.text = widget.initialData['conclusion']?.toString() ?? '';
    _keywordsController.text = widget.initialData['keywords']?.toString() ?? '';
  }

  @override
  void dispose() {
    _author1Controller.dispose();
    _author2Controller.dispose();
    _backgroundController.dispose();
    _aimsController.dispose();
    _methodsController.dispose();
    _resultsController.dispose();
    _conclusionController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final abstractProvider = Provider.of<AbstractProvider>(context, listen: false);

    final Map<String, dynamic> body = {
      'topic_id': widget.topicId,
      'contributing_author1_name': _author1Controller.text.trim(),
      'contributing_author2_name': _author2Controller.text.trim(),
      'background_introduction': _backgroundController.text.trim(),
      'aims_objectives': _aimsController.text.trim(),
      'materials_methods': _methodsController.text.trim(),
      'results': _resultsController.text.trim(),
      'conclusion': _conclusionController.text.trim(),
      'keywords': _keywordsController.text.trim(),
    };

    final success = await abstractProvider.updateTopicDetails(
      body: body,
      accessToken: auth.accessToken,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Topic details updated successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(abstractProvider.errorMessage ?? 'Failed to update topic details'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final abstractProvider = Provider.of<AbstractProvider>(context);

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 2.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Edit Topic',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Author Information'),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Contributing Author 1',
                  controller: _author1Controller,
                  hint: 'Enter author name...',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Contributing Author 2',
                  controller: _author2Controller,
                  hint: 'Enter author name...',
                ),
                const SizedBox(height: 28),
                _buildSectionHeader('Scientific Text Content'),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Background Introduction',
                  controller: _backgroundController,
                  hint: 'Provide introduction details...',
                  maxLines: 4,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Aims & Objectives',
                  controller: _aimsController,
                  hint: 'Specify aims and objectives...',
                  maxLines: 4,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Materials & Methods',
                  controller: _methodsController,
                  hint: 'Describe materials and methods used...',
                  maxLines: 4,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Results',
                  controller: _resultsController,
                  hint: 'Summarize results...',
                  maxLines: 4,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Conclusion',
                  controller: _conclusionController,
                  hint: 'Formulate conclusion...',
                  maxLines: 4,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Keywords (Comma Separated)',
                  controller: _keywordsController,
                  hint: 'e.g. AI, diabetes, wound care',
                  isRequired: true,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: abstractProvider.isUpdatingTopic ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    child: abstractProvider.isUpdatingTopic
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SAVE CHANGES',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.tileBorder, width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '  This field is required';
                    }
                    return null;
                  }
                : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
