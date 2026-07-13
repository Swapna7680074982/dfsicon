import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workshops_provider.dart';
import '../../widgets/water_droplets_background.dart';

class WorkshopDetailsScreen extends StatefulWidget {
  final WorkshopItem workshop;

  const WorkshopDetailsScreen({super.key, required this.workshop});

  @override
  State<WorkshopDetailsScreen> createState() => _WorkshopDetailsScreenState();
}

class _WorkshopDetailsScreenState extends State<WorkshopDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final workshopsProv = Provider.of<WorkshopsProvider>(context, listen: false);
      workshopsProv.fetchWorkshopParticipants(widget.workshop.workshopId, auth.accessToken);
    });
  }

  String _formatDateString(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.tryParse(dateStr);
      if (dateTime == null) return dateStr;
      
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final monthStr = months[dateTime.month - 1];
      final dayStr = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;
      
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      
      return '$dayStr $monthStr $year, $formattedHour:$minute $period';
    } catch (_) {
      return dateStr;
    }
  }

  String _getAbsoluteUrl(String? path) {
    if (path == null || path.isEmpty || path.trim() == 'null' || path.trim() == 'NA') {
      return '';
    }
    String cleanPath = path.trim();
    if (cleanPath.startsWith('http')) {
      return cleanPath.replaceAll('/./', '/');
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
    final bannerUrl = _getAbsoluteUrl(widget.workshop.workshopImage);
    final brochureUrl = _getAbsoluteUrl(widget.workshop.brochureFile);

    final workshopsProv = Provider.of<WorkshopsProvider>(context);
    final isLoadingParticipants = workshopsProv.isLoadingParticipants;
    final speakers = workshopsProv.workshopSpeakers;
    final delegates = workshopsProv.workshopDelegates;

    final venue = widget.workshop.venueName;
    final address = widget.workshop.address;
    final city = widget.workshop.city;
    final state = widget.workshop.state;
    final postalCode = widget.workshop.postalCode;
    final hasLocation = venue.isNotEmpty || address.isNotEmpty || city.isNotEmpty;

    final startFormatted = _formatDateString(widget.workshop.workshopStart);
    final endFormatted = _formatDateString(widget.workshop.workshopEnd);
    final regStartFormatted = _formatDateString(widget.workshop.registrationStart);
    final regEndFormatted = _formatDateString(widget.workshop.registrationEnd);

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
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.workshop.workshopName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Banner Image Section
              if (bannerUrl.isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.network(
                    bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Code and Type badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.workshop.workshopType.toUpperCase(),
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
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CODE: ${widget.workshop.workshopCode}'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.workshop.workshopName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Brochure File Section
                    if (brochureUrl.isNotEmpty) ...[
                      const Text(
                        'BROCHURE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                color: const Color(0xFFEEECF9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.picture_as_pdf_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.workshop.brochureFile!.split('/').last,
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
                                    'Downloadable PDF Brochure',
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
                                size: 22,
                              ),
                              onPressed: () async {
                                final Uri uri = Uri.parse(brochureUrl);
                                try {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Could not open brochure: $e'),
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
                      const SizedBox(height: 24),
                    ],

                    // Description Section
                    if (widget.workshop.description.isNotEmpty) ...[
                      const Text(
                        'ABOUT WORKSHOP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.tileBorder, width: 1.5),
                        ),
                        child: Text(
                          widget.workshop.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Venue Section
                    if (hasLocation) ...[
                      const Text(
                        'VENUE & LOCATION',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.tileBorder, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (venue.isNotEmpty) ...[
                                        Text(
                                          venue.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                      if (address.isNotEmpty || city.isNotEmpty || state.isNotEmpty) ...[
                                        if (venue.isNotEmpty) const SizedBox(height: 6),
                                        Text(
                                          '${address.isNotEmpty ? "$address, " : ""}${city.isNotEmpty ? "$city, " : ""}${state.isNotEmpty ? "$state" : ""}${postalCode.isNotEmpty ? " - $postalCode" : ""}'
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Timing & Registration Period
                    if (startFormatted.isNotEmpty ||
                        endFormatted.isNotEmpty ||
                        regStartFormatted.isNotEmpty ||
                        regEndFormatted.isNotEmpty) ...[
                      const Text(
                        'TIMING & SCHEDULE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.tileBorder, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (startFormatted.isNotEmpty) ...[
                              _buildDetailRow(Icons.play_circle_outline, 'WORKSHOP START', startFormatted),
                            ],
                            if (endFormatted.isNotEmpty) ...[
                              if (startFormatted.isNotEmpty) const SizedBox(height: 14),
                              _buildDetailRow(Icons.stop_circle_outlined, 'WORKSHOP END', endFormatted),
                            ],
                            if (regStartFormatted.isNotEmpty) ...[
                              if (startFormatted.isNotEmpty || endFormatted.isNotEmpty) const SizedBox(height: 14),
                              _buildDetailRow(Icons.app_registration, 'REGISTRATION OPEN', regStartFormatted),
                            ],
                            if (regEndFormatted.isNotEmpty) ...[
                              if (startFormatted.isNotEmpty || endFormatted.isNotEmpty || regStartFormatted.isNotEmpty) const SizedBox(height: 14),
                              _buildDetailRow(Icons.event_busy_outlined, 'REGISTRATION CLOSE', regEndFormatted),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Fee & Registration Status
                    const Text(
                      'REGISTRATION DETAILS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.tileBorder, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.workshop.fee.isNotEmpty && widget.workshop.fee != '0' && widget.workshop.fee != '0.00') ...[
                            _buildDetailRow(Icons.payments_outlined, 'WORKSHOP FEE', '${widget.workshop.fee} ${widget.workshop.currency}'),
                          ],
                          if (widget.workshop.role != null && widget.workshop.role!.isNotEmpty) ...[
                            if (widget.workshop.fee.isNotEmpty && widget.workshop.fee != '0' && widget.workshop.fee != '0.00') const SizedBox(height: 14),
                            _buildDetailRow(Icons.person_pin_outlined, 'ASSIGNED ROLE', widget.workshop.role!),
                          ],
                          if (widget.workshop.attendanceStatus.isNotEmpty) ...[
                            if ((widget.workshop.fee.isNotEmpty && widget.workshop.fee != '0' && widget.workshop.fee != '0.00') || (widget.workshop.role != null && widget.workshop.role!.isNotEmpty)) const SizedBox(height: 14),
                            _buildDetailRow(Icons.verified_user_outlined, 'ATTENDANCE STATUS', widget.workshop.attendanceStatus),
                          ],
                          const SizedBox(height: 14),
                          _buildDetailRow(Icons.card_membership_outlined, 'CERTIFICATE AVAILABLE', widget.workshop.certificateAvailable == '1' ? 'Yes' : 'No'),
                          const SizedBox(height: 14),
                          _buildDetailRow(Icons.assignment_turned_in_outlined, 'FEEDBACK SUBMITTED', widget.workshop.feedbackSubmitted == '1' ? 'Yes' : 'No'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Workshop Speakers Section
                    _buildSpeakersSection(context, isLoadingParticipants, speakers),
                    const SizedBox(height: 24),

                    // Workshop Delegates Section
                    _buildDelegatesSection(context, isLoadingParticipants, delegates),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakersSection(BuildContext context, bool isLoading, List<WorkshopParticipant> speakers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showAllSpeakersModal(context, speakers),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WORKSHOP SPEAKERS (${speakers.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (speakers.isNotEmpty)
                  Row(
                    children: const [
                      Text(
                        'VIEW ALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_outlined, size: 12, color: AppColors.primary),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (speakers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.tileBorder, width: 1.5),
            ),
            child: const Center(
              child: Text(
                'No speakers assigned to this workshop.',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => _showAllSpeakersModal(context, speakers),
            child: Row(
              children: [
                for (int i = 0; i < speakers.length && i < 4; i++) ...[
                  _buildAvatarChip(speakers[i]),
                  const SizedBox(width: 6),
                ],
                if (speakers.length > 4)
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
                      '+${speakers.length - 4}',
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
      ],
    );
  }

  Widget _buildDelegatesSection(BuildContext context, bool isLoading, List<WorkshopParticipant> delegates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showAllDelegatesModal(context, delegates),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WORKSHOP DELEGATES (${delegates.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (delegates.isNotEmpty)
                  Row(
                    children: const [
                      Text(
                        'VIEW ALL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_outlined, size: 12, color: AppColors.primary),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (delegates.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.tileBorder, width: 1.5),
            ),
            child: const Center(
              child: Text(
                'No delegates registered to this workshop yet.',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => _showAllDelegatesModal(context, delegates),
            child: Row(
              children: [
                for (int i = 0; i < delegates.length && i < 4; i++) ...[
                  _buildAvatarChip(delegates[i]),
                  const SizedBox(width: 6),
                ],
                if (delegates.length > 4)
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
                      '+${delegates.length - 4}',
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
      ],
    );
  }

  Widget _buildAvatarChip(WorkshopParticipant p) {
    final avatarUrl = _getAbsoluteUrl(p.profileImage);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: p.bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: avatarUrl.isNotEmpty
          ? Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              width: 38,
              height: 38,
              errorBuilder: (c, o, s) => Text(
                p.initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : Text(
              p.initials,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  void _showAllSpeakersModal(BuildContext context, List<WorkshopParticipant> speakers) {
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
                    'WORKSHOP SPEAKERS',
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
                '${speakers.length} SPEAKERS ASSIGNED',
                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: speakers.length,
                  itemBuilder: (context, idx) {
                    final s = speakers[idx];
                    return _buildParticipantTile(s);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantTile(WorkshopParticipant p) {
    final avatarUrl = _getAbsoluteUrl(p.profileImage);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tileBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.bg,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
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
                  p.fullName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (p.designation.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    p.designation.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (p.mobile.isNotEmpty && p.mobile != 'NA' && p.mobile.toLowerCase() != 'null') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 12, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Text(
                        p.mobile,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
                if (p.email.isNotEmpty && p.email != 'NA' && p.email.toLowerCase() != 'null') ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.mail_outline, size: 12, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          p.email,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllDelegatesModal(BuildContext context, List<WorkshopParticipant> delegates) {
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
                    'WORKSHOP DELEGATES',
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
                '${delegates.length} DELEGATES REGISTERED',
                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: delegates.length,
                  itemBuilder: (context, idx) {
                    final d = delegates[idx];
                    return _buildParticipantTile(d);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
