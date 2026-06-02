import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../gallery/gallery_tab.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/connections_provider.dart';
import '../../providers/home_provider.dart';
import '../../widgets/event_qr_modal.dart';
import '../../utils/time_formatter.dart';

class SessionDetailsScreen extends StatefulWidget {
  final SessionItem session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  bool _isSpeakerConnected = false;

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
                            children: const [
                              Text(
                                'Participants',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '248 attending this session',
                                style: TextStyle(
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
                        child: ListView.builder(
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
                                    alignment: Alignment.center,
                                    child: Text(
                                      p.initials,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: p.initials == 'TN'
                                            ? AppColors.textPrimary
                                            : Colors.white,
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
                                  SizedBox(
                                    height: 36,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        connProvider.toggleConnect(p.id);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: p.isConnected
                                            ? const Color(0xFFECFDF5)
                                            : Colors.white,
                                        foregroundColor: p.isConnected
                                            ? const Color(0xFF10B981)
                                            : AppColors.primary,
                                        side: BorderSide(
                                          color: p.isConnected
                                              ? const Color(0xFFA7F3D0)
                                              : AppColors.primary,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                      ),
                                      child: Row(
                                        children: [
                                          if (p.isConnected) ...[
                                            const Icon(Icons.check, size: 14, color: Color(0xFF10B981)),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            p.isConnected ? 'Connected' : 'Connect',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: p.isConnected
                                                  ? const Color(0xFF047857)
                                                  : AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Showing 8 of 248 participants',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
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

  String _getThumbnailUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&auto=format&fit=crop';
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

  @override
  Widget build(BuildContext context) {
    final sessProvider = Provider.of<SessionsProvider>(context);

    final isBookmarked = sessProvider.sessions
        .firstWhere((s) => s.id == widget.session.id, orElse: () => widget.session)
        .isBookmarked;

    final isAdded = sessProvider.sessions
        .firstWhere((s) => s.id == widget.session.id, orElse: () => widget.session)
        .isAdded;

    final halls = sessProvider.halls.isNotEmpty
        ? sessProvider.halls
        : [
            HallItem(hallId: '1', hallName: 'Hall 1', hallCapacity: '0'),
            HallItem(hallId: '2', hallName: 'Hall 2', hallCapacity: '0'),
            HallItem(hallId: '3', hallName: 'Hall 3', hallCapacity: '0'),
            HallItem(hallId: '4', hallName: 'Hall 4', hallCapacity: '0'),
          ];

    final sessionLocation = widget.session.location.toLowerCase();

    bool checkHighlight(String hallName) {
      final nameLower = hallName.toLowerCase();
      if (sessionLocation.contains(nameLower)) return true;
      if (nameLower == 'hall 1' && (sessionLocation.contains('hall a') || sessionLocation.contains('room a'))) return true;
      if (nameLower == 'hall 2' && (sessionLocation.contains('hall b') || sessionLocation.contains('room b'))) return true;
      if (nameLower == 'hall 3' && (sessionLocation.contains('hall c') || sessionLocation.contains('room c'))) return true;
      if (nameLower == 'hall 4' && (sessionLocation.contains('hall d') || sessionLocation.contains('room d'))) return true;
      return false;
    }

    String highlightedText = 'No Hall highlighted';
    for (var hall in halls) {
      if (checkHighlight(hall.hallName)) {
        highlightedText = '${hall.hallName} highlighted';
        break;
      }
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
            'SESSION DETAILS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      _getThumbnailUrl(widget.session.thumbnail),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.network(
                        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&auto=format&fit=crop',
                        fit: BoxFit.cover,
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
                fontSize: 22,
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
                    TimeFormatter.formatString(widget.session.date, timeStr: widget.session.time).toUpperCase(),
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
                    widget.session.location.toUpperCase(),
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
                    onTap: () {
                      sessProvider.toggleBookmark(widget.session.id);
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
                          Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBookmarked ? 'Saved' : 'Save',
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
                      sessProvider.toggleAdded(widget.session.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAdded
                                ? 'Removed from calendar schedule'
                                : 'Added to calendar schedule!',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isAdded ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAdded ? const Color(0xFF818CF8) : AppColors.tileBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: isAdded ? AppColors.primary : AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Calendar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isAdded ? AppColors.primary : AppColors.textSecondary,
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
              'ABOUT THIS SESSION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.session.description != null && widget.session.description!.isNotEmpty
                  ? widget.session.description!
                  : 'Explore how artificial intelligence is revolutionizing diagnostic accuracy, reducing misdiagnosis rates, and enabling clinicians to make faster, evidence-based decisions. Real-world case studies from leading health systems and a look at the regulatory landscape ahead.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'SPEAKER',
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
                    alignment: Alignment.center,
                    child: Text(
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
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isSpeakerConnected = !_isSpeakerConnected;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _isSpeakerConnected
                            ? const Color(0xFFECFDF5)
                            : Colors.white,
                        foregroundColor: _isSpeakerConnected
                            ? const Color(0xFF10B981)
                            : AppColors.primary,
                        side: BorderSide(
                          color: _isSpeakerConnected
                              ? const Color(0xFFA7F3D0)
                              : AppColors.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: Row(
                        children: [
                          if (_isSpeakerConnected) ...[
                            const Icon(Icons.check, size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            _isSpeakerConnected ? 'Connected' : 'Connect',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isSpeakerConnected
                                  ? const Color(0xFF047857)
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PARTICIPANTS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '248 attending',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 36,
                  child: Stack(
                    children: [
                      _buildOverlappingAvatar('MJ', const Color(0xFFE0DBFC), 0),
                      _buildOverlappingAvatar('ER', const Color(0xFFD1FAE5), 24),
                      _buildOverlappingAvatar('AP', const Color(0xFFFEF3C7), 48),
                      _buildOverlappingAvatar('LW', const Color(0xFFFCE7F3), 72),
                      _buildOverlappingAvatar('+244', Colors.grey.shade100, 96, textColor: AppColors.textSecondary),
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
                          'VIEW PARTICIPANTS',
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
            const SizedBox(height: 28),
            const Text(
              'CONVENTION CENTER MAP',
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
                  final isHighlighted = checkHighlight(hall.hallName);
                  String subtitle = 'Venue Hall';
                  if (hall.hallName.toLowerCase().contains('1') || hall.hallName.toLowerCase().contains('a')) {
                    subtitle = 'Auditorium';
                  } else if (hall.hallName.toLowerCase().contains('2') || hall.hallName.toLowerCase().contains('b')) {
                    subtitle = 'Conference';
                  } else if (hall.hallName.toLowerCase().contains('3') || hall.hallName.toLowerCase().contains('c')) {
                    subtitle = 'Workshop';
                  } else if (hall.hallName.toLowerCase().contains('4') || hall.hallName.toLowerCase().contains('d')) {
                    subtitle = 'Breakout';
                  }
                  return _buildMapHall(hall.hallName, subtitle, isHighlighted);
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
            Row(
              children: [
                Expanded(
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
                        color: Colors.black12,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                        color: Colors.black12,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1554907984-15263bfd63bd?w=400&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                        color: Colors.black12,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=400&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlappingAvatar(String initials, Color bg, double leftOffset, {Color textColor = Colors.white}) {
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
        alignment: Alignment.center,
        child: Text(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? Colors.green.shade800 : Colors.grey.shade400,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isHighlighted ? Colors.green.shade700 : Colors.grey.shade400,
                  ),
                ),
              ],
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
}

