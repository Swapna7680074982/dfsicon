import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/abstract_provider.dart';
import 'edit_topic_screen.dart';
import '../../widgets/water_droplets_background.dart';
import '../../utils/time_formatter.dart';

class AbstractDetailScreen extends StatefulWidget {
  final String abstractId;
  final String initialTitle;
  final String initialStatus;
  final String initialTopic;
  final String initialDate;

  const AbstractDetailScreen({
    super.key,
    required this.abstractId,
    required this.initialTitle,
    required this.initialStatus,
    required this.initialTopic,
    required this.initialDate,
  });

  @override
  State<AbstractDetailScreen> createState() => _AbstractDetailScreenState();
}

class _AbstractDetailScreenState extends State<AbstractDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final abstractProvider = Provider.of<AbstractProvider>(context, listen: false);
    await abstractProvider.fetchTopicDetails(widget.abstractId, auth.accessToken);
  }

  String _getAbsoluteUrl(String? path) {
    if (path == null || path.isEmpty || path.trim() == 'null' || path.trim() == 'NA') {
      return '';
    }
    if (path.startsWith('http')) {
      return path;
    }
    String cleanPath = path.trim();
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final abstractProvider = Provider.of<AbstractProvider>(context);
    final details = abstractProvider.selectedTopicDetails;
    final isLoading = abstractProvider.isLoadingTopicDetails;

    // Fallbacks from parameters
    final String title = details != null ? (details['title'] ?? widget.initialTitle).toString() : widget.initialTitle;
    final String status = details != null ? (details['status'] ?? widget.initialStatus).toString() : widget.initialStatus;
    final String format = details != null ? (details['presentation_format'] ?? '').toString() : '';
    final String category = details != null ? (details['category_of_submission'] ?? '').toString() : '';
    final String date = details != null ? (details['created_on'] ?? widget.initialDate).toString() : widget.initialDate;
    
    final String author1 = details != null ? (details['contributing_author1_name'] ?? '').toString() : '';
    final String author2 = details != null ? (details['contributing_author2_name'] ?? '').toString() : '';
    final String background = details != null ? (details['background_introduction'] ?? '').toString() : '';
    final String aims = details != null ? (details['aims_objectives'] ?? '').toString() : '';
    final String methods = details != null ? (details['materials_methods'] ?? '').toString() : '';
    final String results = details != null ? (details['results'] ?? '').toString() : '';
    final String conclusion = details != null ? (details['conclusion'] ?? '').toString() : '';
    final String keywords = details != null ? (details['keywords'] ?? '').toString() : '';
    
    final List<dynamic> attachedFiles = details != null && details['files'] != null
        ? details['files'] as List<dynamic>
        : [];

    Color badgeBgColor;
    Color badgeTextColor;
    IconData? badgeIcon;

    if (status == 'Confirmed') {
      badgeBgColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF10B981);
      badgeIcon = Icons.check;
    } else if (status == 'Approved') {
      badgeBgColor = const Color(0xFFEFF6FF);
      badgeTextColor = const Color(0xFF3B82F6);
      badgeIcon = Icons.check_circle_outline;
    } else if (status == 'Submitted' || status == 'Under Review' || status == 'Active' || status == 'Draft') {
      badgeBgColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFF59E0B);
      badgeIcon = Icons.access_time;
    } else {
      badgeBgColor = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFEF4444);
      badgeIcon = Icons.cancel_outlined;
    }

    final String displayVersion = "ID: ${widget.abstractId}";

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
          title: Text(
            (title.length > 20 ? '${title.substring(0, 25)}...' : title),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Stack(
          children: [
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.tileBorder, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEECF9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.description_outlined,
                              color: AppColors.primary,
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEECF9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        displayVersion,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: badgeBgColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            badgeIcon,
                                            color: badgeTextColor,
                                            size: 10,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: badgeTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  title.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (category.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$category ($format)'.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  'SUBMITTED: ${TimeFormatter.formatString(date)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Contributing Authors Section
                    if (author1.isNotEmpty || author2.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Contributing Authors',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (author1.isNotEmpty)
                              _buildAuthorRow('Author 1', author1),
                            if (author1.isNotEmpty && author2.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(height: 1, color: AppColors.tileBorder),
                              ),
                            if (author2.isNotEmpty)
                              _buildAuthorRow('Author 2', author2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Background Section
                    if (background.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Background Introduction',
                        content: Text(
                          background,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Aims Section
                    if (aims.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Aims & Objectives',
                        content: Text(
                          aims,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Methods Section
                    if (methods.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Materials & Methods',
                        content: Text(
                          methods,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Results Section
                    if (results.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Results',
                        content: Text(
                          results,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Conclusion Section
                    if (conclusion.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Conclusion',
                        content: Text(
                          conclusion,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Keywords Section
                    if (keywords.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Keywords',
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: keywords.split(',').map((kw) {
                            final trimmed = kw.trim();
                            if (trimmed.isEmpty) return const SizedBox.shrink();
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEECF9),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                trimmed,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Files Section
                    if (attachedFiles.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Supporting Documents & Images',
                        content: Column(
                          children: attachedFiles.map((file) {
                            final String originalName = file['original_name']?.toString() ?? 'attachment';
                            final String fileType = file['file_type']?.toString() ?? 'pdf';
                            final String fileUrl = _getAbsoluteUrl(file['file_path']);
                            final String sizeInBytes = file['file_size']?.toString() ?? '0';
                            
                            double sizeInMb = 0.0;
                            try {
                              sizeInMb = int.parse(sizeInBytes) / (1024 * 1024);
                            } catch (_) {}

                            final isImage = fileType.toLowerCase() == 'image' ||
                                originalName.endsWith('.jpg') ||
                                originalName.endsWith('.jpeg') ||
                                originalName.endsWith('.png');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9FB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEECF9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
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
                                          originalName,
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
                                          '${fileType.toUpperCase()} File · ${sizeInMb.toStringAsFixed(2)} MB',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.open_in_new_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      if (fileUrl.isEmpty) return;
                                      final Uri uri = Uri.parse(fileUrl);
                                      try {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to open document: $e'),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (!isLoading)
              Positioned(
                bottom: 50,
                left: 20,
                right: 20,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTopicScreen(
                            topicId: widget.abstractId,
                            initialData: details ?? {
                              'contributing_author1_name': author1,
                              'contributing_author2_name': author2,
                              'background_introduction': background,
                              'aims_objectives': aims,
                              'materials_methods': methods,
                              'results': results,
                              'conclusion': conclusion,
                              'keywords': keywords,
                            },
                          ),
                        ),
                      ).then((updated) {
                        if (updated == true) {
                          _loadDetails();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'EDIT TOPIC DETAILS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.tileBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildAuthorRow(String role, String name) {
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(
          '$role: '.toUpperCase(),
          style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.bold),
        ),
        Text(
          name.toUpperCase(),
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
