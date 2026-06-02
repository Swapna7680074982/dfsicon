import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/abstract_provider.dart';
import '../../widgets/water_droplets_background.dart';
import '../../constants/api_urls.dart';

class CreateAbstractScreen extends StatefulWidget {
  final bool isUpdate;
  final String? abstractId;
  final String? initialTitle;
  final String? initialTopic;
  final String? initialDescription;
  final String? initialFileName;
  final String? initialFileSize;
  final String? initialKeywords;
  final String? initialThumbnail;
  final String? initialThumbnailName;
  final String? initialThumbnailSize;

  const CreateAbstractScreen({
    super.key,
    this.isUpdate = false,
    this.abstractId,
    this.initialTitle,
    this.initialTopic,
    this.initialDescription,
    this.initialFileName,
    this.initialFileSize,
    this.initialKeywords,
    this.initialThumbnail,
    this.initialThumbnailName,
    this.initialThumbnailSize,
  });

  @override
  State<CreateAbstractScreen> createState() => _CreateAbstractScreenState();
}

class _CreateAbstractScreenState extends State<CreateAbstractScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  String? _selectedTopic;
  String? _selectedSummitId;
  String _selectedPresentationType = 'oral';
  int _wordCount = 0;

  File? _pickedFile;
  String? _uploadedFileName;
  String? _uploadedFileSize;

  File? _pickedThumbnail;
  String? _uploadedThumbnailName;
  String? _uploadedThumbnailSize;

  final List<String> _topics = [
    'AI & Machine Learning',
    'Digital Health',
    'Telehealth',
    'Clinical Diagnostics',
    'Pathology Workflows'
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _descController.text = widget.initialDescription ?? '';
    _keywordsController.text = widget.initialKeywords ?? '';
    _selectedTopic = widget.initialTopic;
    _uploadedFileName = widget.initialFileName;
    _uploadedFileSize = widget.initialFileSize;
    _uploadedThumbnailName = widget.initialThumbnailName;
    _uploadedThumbnailSize = widget.initialThumbnailSize;
    _descController.addListener(_updateWordCount);
    _updateWordCount();

    if (!widget.isUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSummits();
      });
    }
  }

  Future<void> _loadSummits() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final abstractProvider = Provider.of<AbstractProvider>(context, listen: false);
    final success = await abstractProvider.fetchSummits(authProvider.accessToken);
    if (success && mounted && abstractProvider.summits.isNotEmpty) {
      setState(() {
        _selectedSummitId = abstractProvider.summits.first['summit_id']?.toString();
        _selectedTopic = abstractProvider.summits.first['summit_title']?.toString();
      });
    }
  }

  void _updateWordCount() {
    final text = _descController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _wordCount = 0;
      });
      return;
    }
    final words = text.split(RegExp(r'\s+'));
    setState(() {
      _wordCount = words.length;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final abstractProvider = Provider.of<AbstractProvider>(context);
    final isSubmitting = widget.isUpdate ? abstractProvider.isResubmitting : abstractProvider.isSubmitting;

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 2.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            (widget.isUpdate ? 'Update Abstract' : 'New Abstract').toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Abstract Title'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tileBorder),
              ),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your abstract title...',
                  hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(widget.isUpdate ? 'Summit' : 'Select Summit'),
            const SizedBox(height: 8),
            widget.isUpdate
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tileBorder),
                    ),
                    child: Text(
                      _selectedTopic ?? 'N/A',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tileBorder),
                    ),
                    child: abstractProvider.isLoadingSummits
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Loading summits...',
                                  style: TextStyle(color: AppColors.textLight, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSummitId,
                              hint: const Text(
                                'Select a summit',
                                style: TextStyle(color: AppColors.textLight, fontSize: 14),
                              ),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
                              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                              items: abstractProvider.summits.isEmpty
                                  ? _topics.map((t) {
                                      return DropdownMenuItem<String>(
                                        value: t,
                                        child: Text(t),
                                      );
                                    }).toList()
                                  : abstractProvider.summits.map((summit) {
                                      final String id = summit['summit_id']?.toString() ?? '';
                                      final String title = summit['summit_title']?.toString() ?? '';
                                      return DropdownMenuItem<String>(
                                        value: id,
                                        child: Text(title),
                                      );
                                    }).toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() {
                                  if (abstractProvider.summits.isEmpty) {
                                    _selectedSummitId = val;
                                    _selectedTopic = val;
                                  } else {
                                    _selectedSummitId = val;
                                    final matched = abstractProvider.summits.firstWhere(
                                      (s) => s['summit_id']?.toString() == val,
                                      orElse: () => <String, dynamic>{},
                                    );
                                    _selectedTopic = matched['summit_title']?.toString() ?? val;
                                  }
                                });
                              },
                            ),
                          ),
                  ),
            const SizedBox(height: 24),
            _buildFieldLabel('Description'),
            const SizedBox(height: 8),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tileBorder),
              ),
              child: TextField(
                controller: _descController,
                maxLines: null,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Provide a detailed description of your abstract...',
                  hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_wordCount words',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('Keywords (comma separated)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tileBorder),
              ),
              child: TextField(
                controller: _keywordsController,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. AI, Healthcare, Radiology',
                  hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('Presentation Type'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPresentationTypeCard('Oral', 'oral'),
                const SizedBox(width: 16),
                _buildPresentationTypeCard('Poster', 'poster'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'SUPPORTING DOCUMENT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (_uploadedFileName == null)
              GestureDetector(
                onTap: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                    );
                    if (result != null && result.files.single.path != null) {
                      final path = result.files.single.path!;
                      final file = File(path);
                      final sizeInBytes = await file.length();
                      final sizeInMb = sizeInBytes / (1024 * 1024);
                      if (sizeInMb > 10.0) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File size exceeds the 10MB limit!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                        return;
                      }
                      setState(() {
                        _pickedFile = file;
                        _uploadedFileName = result.files.single.name;
                        _uploadedFileSize = '${sizeInMb.toStringAsFixed(1)} MB';
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Document "${result.files.single.name}" selected.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to pick file: $e'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFC084FC),
                      width: 1.2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.upload_file_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'TAP TO UPLOAD',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Any file format (Max 10MB)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC084FC), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _getFileIcon(_uploadedFileName),
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _uploadedFileName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                _uploadedFileSize!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppColors.textLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF10B981),
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Ready',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _pickedFile = null;
                          _uploadedFileName = null;
                          _uploadedFileSize = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'THUMBNAIL IMAGE (OPTIONAL)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (_uploadedThumbnailName == null)
              GestureDetector(
                onTap: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.single.path != null) {
                      final path = result.files.single.path!;
                      final file = File(path);
                      final sizeInBytes = await file.length();
                      final sizeInMb = sizeInBytes / (1024 * 1024);
                      if (sizeInMb > 5.0) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thumbnail size exceeds the 5MB limit!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                        return;
                      }
                      setState(() {
                        _pickedThumbnail = file;
                        _uploadedThumbnailName = result.files.single.name;
                        _uploadedThumbnailSize = '${sizeInMb.toStringAsFixed(1)} MB';
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to pick thumbnail image: $e'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFC084FC),
                      width: 1.2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'TAP TO SELECT THUMBNAIL IMAGE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PNG, JPG, JPEG (Max 5MB)',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC084FC), width: 1.2),
                ),
                child: Row(
                  children: [
                    if (_pickedThumbnail != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _pickedThumbnail!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (widget.initialThumbnail != null && widget.initialThumbnail!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _getAbsoluteThumbnailUrl(widget.initialThumbnail!),
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.image, color: AppColors.primary),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, color: AppColors.primary),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _uploadedThumbnailName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _uploadedThumbnailSize!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _pickedThumbnail = null;
                          _uploadedThumbnailName = null;
                          _uploadedThumbnailSize = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final title = _titleController.text.trim();
                        final description = _descController.text.trim();
                        final keywords = _keywordsController.text.trim();

                        final hasTopicOrSummit = widget.isUpdate ? (_selectedTopic != null) : (_selectedSummitId != null);
                        if (title.isEmpty || !hasTopicOrSummit || description.isEmpty || keywords.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill out all required fields!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        if (_pickedFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload a supporting document!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        if (widget.isUpdate) {
                          if (widget.abstractId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: Abstract ID is missing!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final success = await abstractProvider.resubmitAbstract(
                            abstractId: widget.abstractId!,
                            title: title,
                            description: description,
                            keywords: keywords,
                            file: _pickedFile!,
                            thumbnail: _pickedThumbnail,
                            accessToken: authProvider.accessToken,
                          );

                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Revised abstract updated successfully!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            Navigator.pop(context, true);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(abstractProvider.errorMessage ?? 'Failed to resubmit abstract. Please try again.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        } else {
                          final abstractId = await abstractProvider.submitAbstract(
                            summitId: _selectedSummitId!,
                            title: title,
                            description: description,
                            keywords: keywords,
                            presentationType: _selectedPresentationType,
                            file: _pickedFile!,
                            thumbnail: _pickedThumbnail,
                            accessToken: authProvider.accessToken,
                          );

                          if (abstractId != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Abstract submitted successfully!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            Navigator.pop(context, true);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(abstractProvider.errorMessage ?? 'Failed to submit abstract. Please try again.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 4,
                ),
                child: isSubmitting
                    ? const SizedBox(

                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        (widget.isUpdate ? 'Update Abstract' : 'Submit Abstract').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),);
  }

  IconData _getFileIcon(String? fileName) {
    if (fileName == null) return Icons.insert_drive_file_outlined;
    final ext = fileName.split('.').last.toLowerCase();
    if (ext == 'pdf') {
      return Icons.picture_as_pdf_outlined;
    } else if (ext == 'doc' || ext == 'docx') {
      return Icons.description_outlined;
    } else if (ext == 'xls' || ext == 'xlsx') {
      return Icons.table_chart_outlined;
    } else if (ext == 'ppt' || ext == 'pptx') {
      return Icons.slideshow_outlined;
    } else if (ext == 'png' || ext == 'jpg' || ext == 'jpeg') {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _getAbsoluteThumbnailUrl(String path) {
    if (path.startsWith('http')) {
      return path.replaceAll('/./', '/');
    }
    String cleanPath = path;
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    
    String finalUrl;
    if (cleanPath.contains('dfs-icon')) {
      finalUrl = '${ApiUrls.domain}/$cleanPath';
    } else {
      finalUrl = '${ApiUrls.domain}/dfs-icon/$cleanPath';
    }
    return finalUrl.replaceAll('/./', '/');
  }

  Widget _buildPresentationTypeCard(String label, String value) {
    final isSelected = _selectedPresentationType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPresentationType = value;
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.tileBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
