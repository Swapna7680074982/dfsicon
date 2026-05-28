import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/sessions_provider.dart';
import '../gallery/gallery_tab.dart';

class SpeakerSessionDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String location;
  final String tag;
  final String coordinatorName;
  final String coordinatorPhone;
  final String coordinatorEmail;
  final String? description;

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
  });

  @override
  Widget build(BuildContext context) {
    final sessProvider = Provider.of<SessionsProvider>(context);

    final halls = sessProvider.halls.isNotEmpty
        ? sessProvider.halls
        : [
            HallItem(hallId: '1', hallName: 'Hall 1', hallCapacity: '0'),
            HallItem(hallId: '2', hallName: 'Hall 2', hallCapacity: '0'),
            HallItem(hallId: '3', hallName: 'Hall 3', hallCapacity: '0'),
            HallItem(hallId: '4', hallName: 'Hall 4', hallCapacity: '0'),
          ];

    final sessionLocation = location.toLowerCase();

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildWhiteBannerDetail(Icons.calendar_today_outlined, date),
                  const SizedBox(height: 10),
                  _buildWhiteBannerDetail(Icons.access_time, time),
                  const SizedBox(height: 10),
                  _buildWhiteBannerDetail(Icons.location_on_outlined, location),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'About this Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              (description != null && description!.trim().isNotEmpty)
                  ? description!
                  : 'Explore how artificial intelligence is revolutionizing diagnostic accuracy, reducing misdiagnosis rates, and enabling clinicians to make faster, evidence-based decisions. Real-world case studies from leading health systems and a look at the regulatory landscape ahead.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Session Coordinator',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
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
                          color: Color(0xFFEEECF9),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coordinatorName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Session Coordinator',
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
                  const SizedBox(height: 20),
                  _buildCoordinatorContact(Icons.phone_outlined, coordinatorPhone),
                  const SizedBox(height: 12),
                  _buildCoordinatorContact(Icons.mail_outline_outlined, coordinatorEmail),
                ],
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => _showParticipantsModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
                      children: const [
                        Text(
                          '248 attending',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_outlined, size: 12, color: AppColors.textLight),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showParticipantsModal(context),
              child: Row(
                children: [
                  _buildAvatarChip('MJ', const Color(0xFFF3E8FF), const Color(0xFF7C3AED)),
                  const SizedBox(width: 6),
                  _buildAvatarChip('ER', const Color(0xFFD1FAE5), const Color(0xFF059669)),
                  const SizedBox(width: 6),
                  _buildAvatarChip('AP', const Color(0xFFFFE4E6), const Color(0xFFE11D48)),
                  const SizedBox(width: 6),
                  _buildAvatarChip('LW', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                  const SizedBox(width: 6),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+244',
                      style: TextStyle(
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
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildGalleryThumb(context, 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=300'),
                  _buildGalleryThumb(context, 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=300'),
                  _buildGalleryThumb(context, 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=300'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteBannerDetail(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMapHall(String name, String subtitle, bool isHighlighted) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFEEECF9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : Colors.grey.shade200,
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
                    color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
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
                      color: AppColors.primary,
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

  Widget _buildAvatarChip(String initials, Color bg, Color text) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 12,
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
        return Container(
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
                    'Participants',
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
              const Text(
                '248 attending this session',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildParticipantTile('Marcus Johnson', 'VP Engineering, ChainLogic', 'MJ', const Color(0xFFF3E8FF), const Color(0xFF7C3AED), false),
                    _buildParticipantTile('Emily Rodriguez', 'Head of Design, DesignLab', 'ER', const Color(0xFFD1FAE5), const Color(0xFF059669), false),
                    _buildParticipantTile('Dr. Alan Park', 'Research Director, Quant', 'AP', const Color(0xFFFFE4E6), const Color(0xFFE11D48), true),
                    _buildParticipantTile('Lisa Wong', 'CEO, GreenFuture Ventures', 'LW', const Color(0xFFFEF3C7), const Color(0xFFD97706), false),
                    _buildParticipantTile('Raj Kumar', 'CTO, NexusTech', 'RK', const Color(0xFFE0F2FE), const Color(0xFF0284C7), false),
                    _buildParticipantTile('Aisha Mensah', 'Product Lead, InnovateLab', 'AM', const Color(0xFFECFDF5), const Color(0xFF059669), false),
                    _buildParticipantTile('Thomas Ng', 'Data Scientist, DataSync', 'TN', const Color(0xFFF1F5F9), const Color(0xFF475569), true),
                    _buildParticipantTile('Sofia Okonjo', 'UX Researcher, DesignLab', 'SO', const Color(0xFFFFF1F2), const Color(0xFFE11D48), false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantTile(
    String name,
    String subtitle,
    String initials,
    Color bg,
    Color text,
    bool isConnected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: text),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          isConnected
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
                        'Connected',
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
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_alt_1, size: 12, color: AppColors.primary),
                  label: const Text(
                    'Connect',
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
  }
}
