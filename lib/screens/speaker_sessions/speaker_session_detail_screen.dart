import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/connections_provider.dart';
import '../../providers/auth_provider.dart';
import '../gallery/gallery_tab.dart';

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
      final topicIdVal = widget.topicId ?? '1';
      connProvider.fetchSessionParticipants(
        topicId: topicIdVal,
        accessToken: auth.accessToken,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessProvider = Provider.of<SessionsProvider>(context);
    final connProvider = Provider.of<ConnectionsProvider>(context);

    final halls = sessProvider.halls.isNotEmpty
        ? sessProvider.halls
        : [
            HallItem(hallId: '1', hallName: 'Hall 1', hallCapacity: '0'),
            HallItem(hallId: '2', hallName: 'Hall 2', hallCapacity: '0'),
            HallItem(hallId: '3', hallName: 'Hall 3', hallCapacity: '0'),
            HallItem(hallId: '4', hallName: 'Hall 4', hallCapacity: '0'),
          ];

    final sessionLocation = widget.location.toLowerCase();

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SESSION DETAILS',
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
                  Text(
                    widget.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.time} (${widget.date})',
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        widget.location.toUpperCase(),
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'COORDINATOR DETAILS',
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
                              widget.coordinatorName.toUpperCase(),
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
                  _buildCoordinatorContact(Icons.phone_outlined, widget.coordinatorPhone),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1, color: AppColors.tileBorder),
                  ),
                  _buildCoordinatorContact(Icons.mail_outline, widget.coordinatorEmail),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'SESSION DESCRIPTION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.description != null && widget.description!.isNotEmpty
                  ? widget.description!
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
                      'PARTICIPANTS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${connProvider.participantsCount} ATTENDING',
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
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildGalleryThumb(context, 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400&auto=format&fit=crop'),
                  _buildGalleryThumb(context, 'https://images.unsplash.com/photo-1554907984-15263bfd63bd?w=400&auto=format&fit=crop'),
                  _buildGalleryThumb(context, 'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=400&auto=format&fit=crop'),
                ],
              ),
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
        child: Image.network(url, fit: BoxFit.cover),
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
