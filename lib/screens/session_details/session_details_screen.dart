import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../gallery/gallery_tab.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/connections_provider.dart';
import '../../providers/network_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/gallery_provider.dart';
import '../../widgets/event_qr_modal.dart';
import '../../widgets/venue_media_widget.dart';
import '../../utils/time_formatter.dart';

class SessionDetailsScreen extends StatefulWidget {
  final SessionItem session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  bool _isSavingBookmark = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParticipants();
    });
  }

  void _loadParticipants() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final connProvider = Provider.of<ConnectionsProvider>(context, listen: false);
    final assignmentId = widget.session.assignmentId ?? widget.session.id.toString();
    connProvider.fetchSessionParticipants(
      assignmentId: assignmentId,
      accessToken: auth.accessToken,
    );
  }

  void _showParticipantsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<ConnectionsProvider>(
              builder: (context, connProvider, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Participants',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${connProvider.participantsCount} attending this session',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: AppColors.tileBorder,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: connProvider.isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                            : connProvider.participants.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No participants found for this session.',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    itemCount: connProvider.participants.length,
                                    itemBuilder: (context, index) {
                                      final p = connProvider.participants[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 20.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: p.bg,
                                                shape: BoxShape.circle,
                                              ),
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
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      p.initials,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.name,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    p.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                             const SizedBox(width: 12),
                                             _buildConnectionButton(p, widget.session.assignmentId ?? widget.session.id.toString()),
                                           ],
                                         ),
                                       );
                                    },
                                  ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Consumer<ConnectionsProvider>(
                          builder: (context, conn, _) => Text(
                            'Showing ${conn.participants.length} of ${conn.participantsCount} participants',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  bool get _hasMedia {
    final thumb = widget.session.thumbnail?.trim();
    final file = widget.session.acceptedFilePath?.trim();
    final hasThumb = thumb != null && thumb.isNotEmpty && thumb != 'null' && thumb != 'NA';
    final hasFile = file != null && file.isNotEmpty && file != 'null' && file != 'NA';
    return hasThumb || hasFile;
  }

  String _getThumbnailUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http')) {
      return path;
    }
    String cleanPath = path;
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  String? _getSpeakerProfileImageUrl(String? path) {
    if (path == null || path.isEmpty || path == 'null' || path == 'NA') {
      return null;
    }
    String cleanPath = path.trim();
    if (cleanPath.contains('/./')) {
      cleanPath = cleanPath.replaceAll('/./', '/');
    }
    if (cleanPath.startsWith('http')) {
      return cleanPath;
    }
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final sessProvider = Provider.of<SessionsProvider>(context);
    final connProvider = Provider.of<ConnectionsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final isBookmarked = sessProvider.sessions
        .firstWhere((s) => s.id == widget.session.id, orElse: () => widget.session)
        .isBookmarked;

    final halls = sessProvider.halls.isNotEmpty
        ? sessProvider.halls
        : [
            HallItem(hallId: '1', hallName: 'Hall 1', hallCapacity: '0'),
            HallItem(hallId: '2', hallName: 'Hall 2', hallCapacity: '0'),
            HallItem(hallId: '3', hallName: 'Hall 3', hallCapacity: '0'),
            HallItem(hallId: '4', hallName: 'Hall 4', hallCapacity: '0'),
          ];

    String locationText = widget.session.location;
    String timeText = widget.session.time;
    String dateText = widget.session.date;

    final sessionData = connProvider.sessionData;
    if (sessionData != null) {
      final sessionDetails = (sessionData['session_details'] is Map)
          ? sessionData['session_details'] as Map<String, dynamic>
          : null;

      final String hallLabel = sessionDetails?['hall_label']?.toString() ??
          sessionData['hall_label']?.toString() ??
          '';

      final String hallName = sessionDetails?['hall_name']?.toString() ??
          sessionData['hall_name']?.toString() ??
          '';

      final String displayHall = hallLabel.trim().isNotEmpty ? hallLabel.trim() : hallName.trim();

      final String slotLabel = sessionDetails?['slot_label']?.toString() ??
          sessionData['slot_label']?.toString() ??
          '';

      final String slotName = sessionDetails?['slot_name']?.toString() ??
          sessionData['slot_name']?.toString() ??
          '';

      final String venueName = sessionDetails?['venue_name']?.toString() ??
          sessionData['venue_name']?.toString() ??
          '';

      final String scheduleDateStr = sessionDetails?['schedule_date']?.toString() ??
          sessionData['schedule_date']?.toString() ??
          '';

      final String startTime = sessionDetails?['start_time']?.toString() ??
          sessionData['start_time']?.toString() ??
          '';

      final String endTime = sessionDetails?['end_time']?.toString() ??
          sessionData['end_time']?.toString() ??
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
    }

    String displayDescription = widget.session.description ?? '';
    if (sessionData != null) {
      final backgroundIntro = sessionData['background_introduction']?.toString();
      if (backgroundIntro != null && backgroundIntro.isNotEmpty) {
        displayDescription = backgroundIntro;
      }
    }

    String? speakerProfileImageUrl = _getSpeakerProfileImageUrl(widget.session.speakerProfileImage);
    if (sessionData != null && sessionData['speaker_profile_image'] != null) {
      final img = sessionData['speaker_profile_image'].toString();
      final cleaned = _getSpeakerProfileImageUrl(img);
      if (cleaned != null) {
        speakerProfileImageUrl = cleaned;
      }
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

    ParticipantItem? speakerParticipant;
    try {
      speakerParticipant = connProvider.participants.firstWhere(
        (p) => p.isSpeaker || p.name.toLowerCase() == widget.session.speakerName.toLowerCase(),
      );
    } catch (_) {
      speakerParticipant = null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 2.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Session Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasMedia) ...[
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: const Text(
                        'Session Recording',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      content: const Text(
                        'It will be uploaded after session recording is done.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'OK',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.black12,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _getThumbnailUrl(widget.session.thumbnail ?? widget.session.acceptedFilePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.slideshow, color: Colors.white54, size: 48),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (widget.session.keywords != null && widget.session.keywords!.isNotEmpty)
                        ? widget.session.keywords!.split(',').first.trim()
                        : 'Health Tech',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Confirmed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.session.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.textLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${TimeFormatter.formatTimeRange(timeText)} ($dateText)'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationText.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (_isSavingBookmark) return;
                      setState(() {
                        _isSavingBookmark = true;
                      });
                      final errorMessage = await sessProvider.toggleBookmark(widget.session.id, auth.accessToken);
                      if (mounted) {
                        setState(() {
                          _isSavingBookmark = false;
                        });
                      }
                      if (errorMessage == null) {
                        _loadParticipants();
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isBookmarked ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isBookmarked ? const Color(0xFF818CF8) : AppColors.tileBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isSavingBookmark
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Icon(
                                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
                                  size: 18,
                                ),
                          const SizedBox(width: 8),
                          Text(
                            isBookmarked ? 'Bookmarked' : 'Bookmark',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EventQrModal(
                          userName: 'Alex Kumar',
                          eventName: Provider.of<HomeProvider>(context, listen: false).eventInfo.name,
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.tileBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.qr_code_2, color: AppColors.textSecondary, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'QR Code',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'About This Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              displayDescription.isNotEmpty
                  ? displayDescription
                  : 'No description provided for this session.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Speaker',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tileBorder, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.session.speakerBg,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    child: speakerProfileImageUrl != null
                        ? Image.network(
                            speakerProfileImageUrl,
                            fit: BoxFit.cover,
                            width: 44,
                            height: 44,
                            errorBuilder: (c, o, s) => Text(
                              widget.session.speakerInitials.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.session.speakerInitials.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.speakerName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.session.speakerTitle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (speakerParticipant != null)
                    _buildConnectionButton(speakerParticipant, widget.session.assignmentId ?? widget.session.id.toString()),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (isBookmarked) ...[
              Row(
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
                  Text(
                    '${connProvider.participantsCount} attending',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (connProvider.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primary))
              else if (connProvider.participants.isEmpty)
                const Text('No participants attending yet.', style: TextStyle(fontSize: 13, color: AppColors.textLight))
              else
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 36,
                      child: Stack(
                        children: [
                          for (int i = 0; i < connProvider.participants.length && i < 4; i++)
                            _buildOverlappingAvatar(
                              connProvider.participants[i].initials,
                              connProvider.participants[i].bg,
                              (i * 24).toDouble(),
                              profileImage: connProvider.participants[i].profileImage,
                            ),
                          if (connProvider.participants.length > 4)
                            _buildOverlappingAvatar(
                              '+${connProvider.participants.length - 4}',
                              Colors.grey.shade100,
                              96.0,
                              textColor: AppColors.textSecondary,
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showParticipantsSheet(context),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text(
                              'View Participants',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ] else ...[
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.tileBorder, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_outline, color: Colors.amber.shade800, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Participants Locked',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Bookmark this session to view participants.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            if (sessProvider.venueMedia.isNotEmpty) ...[
              const SizedBox(height: 14),
              VenueMediaWidget(
                mediaList: sessProvider.venueMedia,
              ),
            ],
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
                
                return Row(
                  children: List.generate(3, (index) {
                    final hasImage = index < displayPhotos.length;
                    final imgUrl = hasImage ? displayPhotos[index] : '';
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 2 ? 12.0 : 0.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GalleryTab(isStandalone: true),
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFF1E3A8A).withAlpha(30),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: hasImage && imgUrl.isNotEmpty
                                ? Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => const Center(
                                      child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlappingAvatar(String initials, Color bg, double leftOffset, {Color textColor = Colors.white, String? profileImage}) {
    return Positioned(
      left: leftOffset,
      child: Container(
        width: 32,
        height: 32,
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
                width: 32,
                height: 32,
                errorBuilder: (c, o, s) => Text(
                  initials,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: initials == 'TN' ? AppColors.textPrimary : textColor,
                  ),
                ),
              )
            : Text(
                initials,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: initials == 'TN' ? AppColors.textPrimary : textColor,
                ),
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

  Widget _buildConnectionButton(ParticipantItem p, String? assignmentId) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final connProvider = Provider.of<ConnectionsProvider>(context, listen: false);
    final netProvider = Provider.of<NetworkProvider>(context, listen: false);

    if (p.isConnecting) {
      return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    final bool isConnected = p.isConnected || p.action == 'CONNECTED' || p.connectionStatus == 'CONNECTED';
    final bool isRequested = p.action == 'REQUESTED' || p.connectionStatus == 'PENDING';
    final bool isAccept = p.action == 'ACCEPT';

    if (isConnected) {
      return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check, size: 14, color: Color(0xFF10B981)),
            SizedBox(width: 4),
            Text(
              'Connected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF047857),
              ),
            ),
          ],
        ),
      );
    }

    if (isRequested) {
      return SizedBox(
        height: 36,
        child: OutlinedButton(
          onPressed: () async {
            if (p.connectionId != null) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Cancel Request'),
                  content: Text('Do you want to cancel the connection request sent to ${p.name}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await connProvider.cancelConnectionRequest(
                  connectionId: p.connectionId!,
                  targetUserId: p.id,
                  accessToken: auth.accessToken,
                );
              }
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFBEB),
            foregroundColor: const Color(0xFFD97706),
            side: const BorderSide(color: Color(0xFFFCD34D), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.access_time, size: 14, color: Color(0xFFD97706)),
              SizedBox(width: 4),
              Text(
                'Requested',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB45309),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isAccept) {
      return SizedBox(
        height: 36,
        child: OutlinedButton(
          onPressed: () async {
            if (p.connectionId != null) {
              await connProvider.respondConnectionRequest(
                connectionId: p.connectionId!,
                targetUserId: p.id,
                action: 'ACCEPT',
                accessToken: auth.accessToken,
              );
              if (mounted) {
                netProvider.fetchConversations(accessToken: auth.accessToken);
                netProvider.fetchMyConnections(accessToken: auth.accessToken);
              }
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFEEF2FF),
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Text(
            'Accept',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: () async {
          final success = await connProvider.sendConnectionRequest(
            targetUserId: p.id,
            assignmentId: assignmentId ?? widget.session.assignmentId ?? widget.session.id.toString(),
            accessToken: auth.accessToken,
          );
          if (success && mounted) {
            netProvider.fetchPendingRequests(accessToken: auth.accessToken);
            netProvider.fetchConversations(accessToken: auth.accessToken);
          }
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: const Text(
          'Connect',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

