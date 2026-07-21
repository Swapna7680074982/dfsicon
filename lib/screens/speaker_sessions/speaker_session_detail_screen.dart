import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/connections_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/abstract_provider.dart';
import '../gallery/gallery_tab.dart';
import '../../providers/gallery_provider.dart';
import '../../utils/time_formatter.dart';

class SpeakerSessionDetailScreen extends StatefulWidget {
  final String title;
  final String date;
  final String time;
  final String location;
  final String tag;
  final String coordinatorName;
  final String coordinatorPhone;
  final String coordinatorEmail;
  final String? description;
  final String? topicId;

  const SpeakerSessionDetailScreen({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.tag,
    required this.coordinatorName,
    required this.coordinatorPhone,
    required this.coordinatorEmail,
    this.description,
    this.topicId,
  });

  @override
  State<SpeakerSessionDetailScreen> createState() => _SpeakerSessionDetailScreenState();
}

class _SpeakerSessionDetailScreenState extends State<SpeakerSessionDetailScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final connProvider = Provider.of<ConnectionsProvider>(context, listen: false);
      final abstractProvider = Provider.of<AbstractProvider>(context, listen: false);
      final topicIdVal = widget.topicId ?? '1';
      connProvider.fetchSessionParticipants(
        topicId: topicIdVal,
        accessToken: auth.accessToken,
      );
      if (widget.topicId != null) {
        abstractProvider.fetchTopicDetails(widget.topicId!, auth.accessToken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessProvider = Provider.of<SessionsProvider>(context);
    final connProvider = Provider.of<ConnectionsProvider>(context);
    final abstractProvider = Provider.of<AbstractProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final topicDetails = abstractProvider.selectedTopicDetails;
    final isLoadingTopic = abstractProvider.isLoadingTopicDetails;

    String getInitials(String name) {
      if (name.isEmpty) return 'SK';
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }

    String displayTitle = widget.title;
    String? displayDescription = widget.description;
    if (topicDetails != null && topicDetails['topic_id']?.toString() == widget.topicId) {
      final String topicTitle = topicDetails['title']?.toString() ?? '';
      if (topicTitle.isNotEmpty) {
        displayTitle = topicTitle;
      }
      final String background = topicDetails['background_introduction']?.toString() ?? '';
      if (background.isNotEmpty) {
        displayDescription = background;
      }
    }

    String coordinatorName = widget.coordinatorName;
    String coordinatorPhone = widget.coordinatorPhone;
    String coordinatorEmail = widget.coordinatorEmail;

    if (topicDetails != null && topicDetails['topic_id']?.toString() == widget.topicId) {
      final String? name = topicDetails['coordinator_name']?.toString() ?? topicDetails['coordinator']?.toString();
      final String? phone = (topicDetails['coordinator_phone'] ?? topicDetails['coordinator_mobile'] ?? topicDetails['coordinator_contact'])?.toString();
      final String? email = topicDetails['coordinator_email']?.toString();

      if (name != null && name.trim().isNotEmpty) {
        coordinatorName = name.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        coordinatorPhone = phone.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        coordinatorEmail = email.trim();
      }
    }

    final sessionData = connProvider.sessionData;
    if (sessionData != null) {
      final String? name = sessionData['coordinator_name']?.toString() ?? sessionData['coordinator']?.toString();
      final String? phone = (sessionData['coordinator_phone'] ?? sessionData['coordinator_mobile'] ?? sessionData['coordinator_contact'])?.toString();
      final String? email = sessionData['coordinator_email']?.toString();

      if (name != null && name.trim().isNotEmpty) {
        coordinatorName = name.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        coordinatorPhone = phone.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        coordinatorEmail = email.trim();
      }

      final String? background = sessionData['background_introduction']?.toString();
      if (background != null && background.trim().isNotEmpty) {
        displayDescription = background.trim();
      }
    }

    final halls = sessProvider.halls.isNotEmpty
        ? sessProvider.halls
        : [
            HallItem(hallId: '1', hallName: 'Hall 1', hallCapacity: '0'),
            HallItem(hallId: '2', hallName: 'Hall 2', hallCapacity: '0'),
            HallItem(hallId: '3', hallName: 'Hall 3', hallCapacity: '0'),
            HallItem(hallId: '4', hallName: 'Hall 4', hallCapacity: '0'),
          ];

    String locationText = widget.location;
    String timeText = widget.time;
    String dateText = widget.date;

    final sessionDetails = (topicDetails != null && topicDetails['session_details'] is Map)
        ? topicDetails['session_details'] as Map<String, dynamic>
        : (topicDetails != null && topicDetails['session'] is Map)
            ? topicDetails['session'] as Map<String, dynamic>
            : (sessionData != null && sessionData['session_details'] is Map)
                ? sessionData['session_details'] as Map<String, dynamic>
                : (sessionData != null && sessionData['session'] is Map)
                    ? sessionData['session'] as Map<String, dynamic>
                    : null;

    final String hallLabel = sessionDetails?['hall_label']?.toString() ??
        topicDetails?['hall_label']?.toString() ??
        (topicDetails?['hall'] is Map ? topicDetails!['hall']['hall_label']?.toString() : null) ??
        sessionData?['hall_label']?.toString() ??
        (sessionData?['hall'] is Map ? sessionData!['hall']['hall_label']?.toString() : null) ??
        '';

    final String hallName = sessionDetails?['hall_name']?.toString() ??
        topicDetails?['hall_name']?.toString() ??
        (topicDetails?['hall'] is Map ? topicDetails!['hall']['hall_name']?.toString() : null) ??
        (topicDetails?['hall'] is String ? topicDetails!['hall'].toString() : null) ??
        sessionData?['hall_name']?.toString() ??
        (sessionData?['hall'] is Map ? sessionData!['hall']['hall_name']?.toString() : null) ??
        (sessionData?['hall'] is String ? sessionData!['hall'].toString() : null) ??
        '';

    final String displayHall = hallLabel.trim().isNotEmpty ? hallLabel.trim() : hallName.trim();

    final String slotLabel = sessionDetails?['slot_label']?.toString() ??
        topicDetails?['slot_label']?.toString() ??
        sessionData?['slot_label']?.toString() ??
        '';

    final String slotName = sessionDetails?['slot_name']?.toString() ??
        topicDetails?['slot_name']?.toString() ??
        sessionData?['slot_name']?.toString() ??
        '';

    final String venueName = sessionDetails?['venue_name']?.toString() ??
        topicDetails?['venue_name']?.toString() ??
        sessionData?['venue_name']?.toString() ??
        '';

    final String scheduleDateStr = sessionDetails?['schedule_date']?.toString() ??
        topicDetails?['schedule_date']?.toString() ??
        sessionData?['schedule_date']?.toString() ??
        '';

    final String startTime = sessionDetails?['start_time']?.toString() ??
        topicDetails?['start_time']?.toString() ??
        sessionData?['start_time']?.toString() ??
        '';

    final String endTime = sessionDetails?['end_time']?.toString() ??
        topicDetails?['end_time']?.toString() ??
        sessionData?['end_time']?.toString() ??
        '';

    if (venueName.isNotEmpty) {
      locationText = displayHall.isNotEmpty ? '$displayHall, $venueName' : venueName;
    } else if (displayHall.isNotEmpty) {
      locationText = displayHall;
    }

    if (scheduleDateStr.isNotEmpty) {
      try {
        final dt = DateTime.tryParse(scheduleDateStr);
        if (dt != null) {
          final months = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
          ];
          dateText = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
        } else {
          dateText = scheduleDateStr;
        }
      } catch (_) {
        dateText = scheduleDateStr;
      }
    }

    if (startTime.isNotEmpty && endTime.isNotEmpty && startTime.toLowerCase() != 'null' && endTime.toLowerCase() != 'null') {
      timeText = '${TimeFormatter.formatTime(startTime)} - ${TimeFormatter.formatTime(endTime)}';
    } else if (slotLabel.isNotEmpty) {
      timeText = slotLabel;
    } else if (slotName.isNotEmpty) {
      timeText = slotName;
    }

    final sessionLocation = locationText.toLowerCase();

    bool checkHighlight(String hName, String hLabel) {
      final nameLower = hName.toLowerCase();
      final labelLower = hLabel.toLowerCase();
      if (sessionLocation.contains(nameLower) || (labelLower.isNotEmpty && sessionLocation.contains(labelLower))) return true;
      if (nameLower == 'hall 1' && (sessionLocation.contains('hall a') || sessionLocation.contains('room a') || sessionLocation.contains('hall 1'))) return true;
      if (nameLower == 'hall 2' && (sessionLocation.contains('hall b') || sessionLocation.contains('room b') || sessionLocation.contains('hall 2'))) return true;
      if (nameLower == 'hall 3' && (sessionLocation.contains('hall c') || sessionLocation.contains('room c') || sessionLocation.contains('hall 3'))) return true;
      if (nameLower == 'hall 4' && (sessionLocation.contains('hall d') || sessionLocation.contains('room d') || sessionLocation.contains('hall 4'))) return true;
      return false;
    }

    String highlightedText = 'No Hall highlighted';
    for (var hall in halls) {
      if (checkHighlight(hall.hallName, hall.hallLabel)) {
        highlightedText = '${hall.hallLabel.isNotEmpty ? hall.hallLabel : hall.hallName} highlighted';
        break;
      }
    }

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
          'Session Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF4338CA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tag.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.tag.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    displayTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  if (timeText.isNotEmpty || dateText.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            timeText.isNotEmpty && dateText.isNotEmpty
                                ? '$timeText ($dateText)'
                                : '$timeText$dateText',
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (locationText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationText.toUpperCase(),
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (coordinatorName.trim().isNotEmpty && coordinatorName.trim().toUpperCase() != 'NOT ASSIGNED') ...[
              const Text(
                'Coordinator Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.tileBorder, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.person_outline, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NAME',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                coordinatorName.toUpperCase(),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1, color: AppColors.tileBorder),
                    ),
                    _buildCoordinatorContact(Icons.phone_outlined, coordinatorPhone.isNotEmpty ? coordinatorPhone : 'N/A'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1, color: AppColors.tileBorder),
                    ),
                    _buildCoordinatorContact(Icons.mail_outline, coordinatorEmail.isNotEmpty ? coordinatorEmail : 'N/A'),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                'Speaker Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.tileBorder, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          child: auth.hasValidProfileImage
                              ? Image.network(
                                  auth.profileImage,
                                  fit: BoxFit.cover,
                                  width: 44,
                                  height: 44,
                                  errorBuilder: (c, o, s) => Text(
                                    getInitials(auth.userName),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : Text(
                                  getInitials(auth.userName),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auth.userName.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${auth.designation}, ${auth.hospitalClinicName}'.toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1, color: AppColors.tileBorder),
                    ),
                    _buildCoordinatorContact(Icons.phone_outlined, auth.mobile.isNotEmpty ? auth.mobile : 'N/A'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1, color: AppColors.tileBorder),
                    ),
                    _buildCoordinatorContact(Icons.mail_outline, auth.email.isNotEmpty ? auth.email : 'N/A'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            const Text(
              'Session Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (isLoadingTopic && (displayDescription == null || displayDescription.isEmpty))
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else
              Text(
                displayDescription != null && displayDescription.isNotEmpty
                    ? displayDescription
                    : 'No description provided for this session.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => _showParticipantsModal(context),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Participants',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${connProvider.participantsCount} attending',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_outlined, size: 12, color: AppColors.textLight),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (connProvider.isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (connProvider.participants.isEmpty)
              const Text(
                'No participants attending this session.',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              )
            else
              GestureDetector(
                onTap: () => _showParticipantsModal(context),
                child: Row(
                  children: [
                    for (int i = 0; i < connProvider.participants.length && i < 4; i++) ...[
                      _buildAvatarChip(
                        connProvider.participants[i].initials,
                        connProvider.participants[i].bg,
                        Colors.white,
                        connProvider.participants[i].profileImage,
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (connProvider.participants.length > 4)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+${connProvider.participants.length - 4}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 28),
            const Text(
              'Convention Center Map',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              highlightedText,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tileBorder, width: 1),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: halls.length,
                itemBuilder: (context, index) {
                  final hall = halls[index];
                  final isHighlighted = checkHighlight(hall.hallName, hall.hallLabel);
                  final displayName = hall.hallLabel.isNotEmpty ? hall.hallLabel : hall.hallName;
                  return _buildMapHall(displayName, '', isHighlighted);
                },
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GalleryTab(isStandalone: true),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Builder(
              builder: (context) {
                final galProvider = Provider.of<GalleryProvider>(context);
                final List<String> galleryPhotos = [];
                for (var g in galProvider.sessions) {
                  galleryPhotos.addAll(g.photos);
                }
                final displayPhotos = galleryPhotos.take(3).toList();
                
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayPhotos.isEmpty ? 3 : displayPhotos.length,
                    itemBuilder: (context, index) {
                      final url = index < displayPhotos.length ? displayPhotos[index] : '';
                      return _buildGalleryThumb(context, url);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMapHall(String name, String subtitle, bool isHighlighted) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? Colors.green.shade600 : Colors.grey.shade300,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isHighlighted ? Colors.green.shade800 : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: isHighlighted ? Colors.green.shade700 : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isHighlighted)
            Positioned(
              top: 6,
              left: 8,
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'You',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoordinatorContact(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarChip(String initials, Color bg, Color text, String? profileImage) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: profileImage != null && profileImage.isNotEmpty
          ? Image.network(
              profileImage,
              fit: BoxFit.cover,
              width: 38,
              height: 38,
              errorBuilder: (c, o, s) => Text(
                initials,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
            )
          : Text(
              initials,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
    );
  }

  Widget _buildGalleryThumb(BuildContext context, String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GalleryTab(isStandalone: true),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        clipBehavior: Clip.antiAlias,
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Center(
                  child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                ),
              )
            : const Center(
                child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
              ),
      ),
    );
  }

  void _showParticipantsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<ConnectionsProvider>(
          builder: (context, connProvider, _) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PARTICIPANTS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${connProvider.participantsCount} ATTENDING THIS SESSION',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: connProvider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : connProvider.participants.isEmpty
                          ? const Center(
                              child: Text(
                                'No participants attending this session.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: connProvider.participants.length,
                              itemBuilder: (context, idx) {
                                final p = connProvider.participants[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(color: p.bg, shape: BoxShape.circle),
                                        clipBehavior: Clip.antiAlias,
                                        alignment: Alignment.center,
                                        child: p.profileImage != null && p.profileImage!.isNotEmpty
                                            ? Image.network(
                                                p.profileImage!,
                                                fit: BoxFit.cover,
                                                width: 44,
                                                height: 44,
                                                errorBuilder: (c, o, s) => Text(
                                                  p.initials,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                                ),
                                              )
                                            : Text(
                                                p.initials,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              p.title.toUpperCase(),
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      p.isConnected
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFECFDF5),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                children: const [
                                                  Icon(Icons.check, size: 12, color: Color(0xFF10B981)),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'CONNECTED',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF10B981),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : OutlinedButton.icon(
                                              onPressed: () {
                                                connProvider.toggleConnect(p.id);
                                              },
                                              icon: const Icon(Icons.person_add_alt_1, size: 12, color: AppColors.primary),
                                              label: const Text(
                                                'CONNECT',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: AppColors.primary),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
