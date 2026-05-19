import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../gallery/gallery_tab.dart';
import '../../providers/sessions_provider.dart';
import '../../providers/connections_provider.dart';
import '../../widgets/event_qr_modal.dart';

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

  @override
  Widget build(BuildContext context) {
    final sessProvider = Provider.of<SessionsProvider>(context);

    final isBookmarked = sessProvider.sessions
        .firstWhere((s) => s.id == widget.session.id, orElse: () => widget.session)
        .isBookmarked;

    final isAdded = sessProvider.sessions
        .firstWhere((s) => s.id == widget.session.id, orElse: () => widget.session)
        .isAdded;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Session Details',
          style: TextStyle(
            color: AppColors.textPrimary,
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
            Container(
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
                    'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
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
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '48:22 remaining',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '60 min',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.session.title,
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
                const SizedBox(width: 6),
                Text(
                  '${widget.session.time.split(' – ').first} – 10:00 AM · Mar 31',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Text(
                  widget.session.location,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
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
                        builder: (context) => const EventQrModal(
                          userName: 'Alex Kumar',
                          eventName: 'TechSummit 2026',
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
              'About this Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Explore how artificial intelligence is revolutionizing diagnostic accuracy, reducing misdiagnosis rates, and enabling clinicians to make faster, evidence-based decisions. Real-world case studies from leading health systems and a look at the regulatory landscape ahead.',
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
                    alignment: Alignment.center,
                    child: Text(
                      widget.session.speakerInitials,
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
                          widget.session.speakerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.session.speakerTitle,
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
                  'Participants',
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
            const SizedBox(height: 28),
            const Text(
              'Session Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Convention Center',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Floor Plan',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.circle, color: AppColors.primary, size: 8),
                            SizedBox(width: 4),
                            Text(
                              'Hall A',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CustomPaint(
                      painter: FloorPlanPainter(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Hall A · Convention Center',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
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
}

class FloorPlanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillHallA = Paint()
      ..color = const Color(0xFFEEF2FF)
      ..style = PaintingStyle.fill;

    final borderHallA = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillOther = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final hallARect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 16, (size.width - 48) * 0.45, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(hallARect, fillHallA);
    canvas.drawRRect(hallARect, borderHallA);

    final hallBRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.45, 16, (size.width - 48) * 0.55, 60),
      const Radius.circular(8),
    );
    canvas.drawRRect(hallBRect, fillOther);
    canvas.drawRRect(hallBRect, paintLine);

    final roomCRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 88, (size.width - 48) * 0.3, 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(roomCRect, fillOther);
    canvas.drawRRect(roomCRect, paintLine);

    final lobbyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.3, 88, (size.width - 48) * 0.7, 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(lobbyRect, fillOther);
    canvas.drawRRect(lobbyRect, paintLine);

    final roomDRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 140, (size.width - 48) * 0.33, 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(roomDRect, fillOther);
    canvas.drawRRect(roomDRect, paintLine);

    final exhibitRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 + (size.width - 48) * 0.33, 140, (size.width - 48) * 0.67, 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(exhibitRect, fillOther);
    canvas.drawRRect(exhibitRect, paintLine);

    _drawCenterText(canvas, textPainter, 'Hall A', Offset(16 + (size.width - 48) * 0.225, 46), isHighlighted: true);
    _drawCenterText(canvas, textPainter, 'Hall B', Offset(24 + (size.width - 48) * 0.725, 46));
    _drawCenterText(canvas, textPainter, 'Room C', Offset(16 + (size.width - 48) * 0.15, 108));
    _drawCenterText(canvas, textPainter, 'Lobby', Offset(24 + (size.width - 48) * 0.65, 108));
    _drawCenterText(canvas, textPainter, 'Room D', Offset(16 + (size.width - 48) * 0.165, 155));
    _drawCenterText(canvas, textPainter, 'Exhibition Hall', Offset(24 + (size.width - 48) * 0.665, 155));

    final dotPaint = Paint()
      ..color = const Color(0xFF2B1F7D)
      ..style = PaintingStyle.fill;
    final outerDotPaint = Paint()
      ..color = const Color(0xFF2B1F7D).withAlpha(40)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(16 + (size.width - 48) * 0.225, 62), 10, outerDotPaint);
    canvas.drawCircle(Offset(16 + (size.width - 48) * 0.225, 62), 4, dotPaint);
  }

  void _drawCenterText(Canvas canvas, TextPainter tp, String text, Offset center, {bool isHighlighted = false}) {
    tp.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
        color: isHighlighted ? const Color(0xFF2B1F7D) : AppColors.textSecondary,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
