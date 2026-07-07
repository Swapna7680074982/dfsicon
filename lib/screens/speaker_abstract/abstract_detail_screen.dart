import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../constants/api_urls.dart';
import '../../providers/auth_provider.dart';
import '../../providers/abstract_provider.dart';
import 'create_abstract_screen.dart';
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
    await abstractProvider.fetchAbstractDetails(widget.abstractId, auth.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    final abstractProvider = Provider.of<AbstractProvider>(context);
    final details = abstractProvider.selectedAbstractDetails;
    final isLoading = abstractProvider.isLoadingDetails;

    // Fallbacks from parameters
    final String title = details != null ? (details['abstract_title'] ?? widget.initialTitle).toString() : widget.initialTitle;
    final String status = details != null ? (details['review_status'] ?? widget.initialStatus).toString() : widget.initialStatus;
    final String topic = details != null ? (details['summit_title'] ?? widget.initialTopic).toString() : widget.initialTopic;
    final String date = details != null ? (details['submitted_at'] ?? widget.initialDate).toString() : widget.initialDate;
    final String description = details != null ? (details['abstract_description'] ?? '').toString() : '';
    final String keywords = details != null ? (details['keywords'] ?? '').toString() : '';
    final String? fileUrl = details != null ? (details['file_path'] ?? details['abstract_file'])?.toString() : null;
    final String? feedback = details != null ? details['reviewer_feedback']?.toString() : null;
    final bool hasFeedback = feedback != null && feedback.trim().isNotEmpty;
    final String? rawThumbnail = details != null 
        ? (details['thumbnail'] ?? 
           details['thumbnail_path'] ?? 
           details['thumbnail_image'] ?? 
           details['thumbnail_file'] ?? 
           details['image_path'])?.toString()
        : null;
    final String? thumbnailUrl = (rawThumbnail != null && rawThumbnail.trim().isNotEmpty && rawThumbnail.trim() != 'NA' && rawThumbnail.trim() != 'null') 
        ? rawThumbnail.trim() 
        : null;

    Color badgeBgColor;
    Color badgeTextColor;
    IconData? badgeIcon;

    if (status == 'Confirmed') {
      badgeBgColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF10B981);
      badgeIcon = Icons.check;
    } else if (status == 'Accepted') {
      badgeBgColor = const Color(0xFFEFF6FF);
      badgeTextColor = const Color(0xFF3B82F6);
      badgeIcon = Icons.check_circle_outline;
    } else if (status == 'Submitted' || status == 'Under Review') {
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
          backgroundColor: AppColors.primary,
          elevation: 2.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            (title.length > 20 ? '${title.substring(0, 18)}...' : title).toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
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
              padding: EdgeInsets.fromLTRB(20, 20, 20, status == 'Revision Required' ? 100 : 20),
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
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  topic.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.tileBorder, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description.isNotEmpty ? description : 'No description provided.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (keywords.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.tileBorder, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KEYWORDS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
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
                        ],
                      ),
                    ),
                  ],
                  if (fileUrl != null && fileUrl.isNotEmpty && fileUrl != 'NA') ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.tileBorder, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SUPPORTING DOCUMENT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEECF9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.picture_as_pdf_outlined,
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
                                        fileUrl.split('/').last,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'PDF/Document Attachment',
                                        style: TextStyle(
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
                                    Icons.open_in_new_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    String finalFileUrl = fileUrl;
                                    if (!finalFileUrl.startsWith('http')) {
                                      if (finalFileUrl.startsWith('/')) {
                                        finalFileUrl = '${ApiUrls.domain}$finalFileUrl';
                                      } else {
                                        finalFileUrl = '${ApiUrls.domain}/$finalFileUrl';
                                      }
                                    }
                                    finalFileUrl = finalFileUrl.replaceAll('/./', '/');
                                    
                                    final Uri uri = Uri.parse(finalFileUrl);
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
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (hasFeedback) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REVIEWER FEEDBACK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            feedback,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB45309),
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (status == 'Revision Required' && !isLoading)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAbstractScreen(
                          isUpdate: true,
                          abstractId: widget.abstractId,
                          initialTitle: title,
                          initialTopic: topic,
                          initialDescription: description,
                          initialFileName: fileUrl?.split('/').last ?? 'Topic_Draft.pdf',
                          initialFileSize: 'Click to select revised draft',
                          initialKeywords: keywords,
                          initialThumbnail: thumbnailUrl,
                          initialThumbnailName: thumbnailUrl?.split('/').last ?? 'thumbnail.jpg',
                          initialThumbnailSize: 'Previously uploaded',
                        ),
                      ),
                    ).then((updated) {
                      if (updated == true && context.mounted) {
                        Navigator.pop(context, true);
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
                    'RESUBMIT REVISED TOPIC',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),);
  }
}
