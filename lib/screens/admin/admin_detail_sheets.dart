import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/time_formatter.dart';

/// Entry helper functions to show modal bottom sheets for Admin details

void showAdminSpeakerDetailsModal(
  BuildContext context, {
  required String userId,
  AdminSpeaker? initialSpeaker,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminSpeakerDetailsSheet(
      userId: userId,
      initialSpeaker: initialSpeaker,
    ),
  );
}

void showAdminDelegateDetailsModal(
  BuildContext context, {
  required String userId,
  AdminDelegate? initialDelegate,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminDelegateDetailsSheet(
      userId: userId,
      initialDelegate: initialDelegate,
    ),
  );
}

void showAdminTopicDetailsModal(
  BuildContext context, {
  required String topicId,
  AdminTopic? initialTopic,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminTopicDetailsSheet(
      topicId: topicId,
      initialTopic: initialTopic,
    ),
  );
}

void showAdminWorkshopDetailsModal(
  BuildContext context, {
  required String workshopId,
  AdminWorkshop? initialWorkshop,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminWorkshopDetailsSheet(
      workshopId: workshopId,
      initialWorkshop: initialWorkshop,
    ),
  );
}

void showAdminSponsorDetailsModal(
  BuildContext context, {
  required String sponsorId,
  AdminSponsor? initialSponsor,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminSponsorDetailsSheet(
      sponsorId: sponsorId,
      initialSponsor: initialSponsor,
    ),
  );
}

void showAdminExhibitorDetailsModal(
  BuildContext context, {
  required String exhibitorId,
  AdminSponsor? initialExhibitor,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminSponsorDetailsSheet(
      sponsorId: exhibitorId,
      initialSponsor: initialExhibitor,
    ),
  );
}

void showAdminBoothDetailsModal(
  BuildContext context, {
  required String boothId,
  AdminBooth? initialBooth,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminBoothDetailsSheet(
      boothId: boothId,
      initialBooth: initialBooth,
    ),
  );
}

void showAdminFootfallParticipantDetailModal(
  BuildContext context, {
  required AdminFootfallParticipant participant,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminFootfallParticipantDetailSheet(
      participant: participant,
    ),
  );
}

void showAdminSlotDetailsModal(
  BuildContext context, {
  required String slotId,
  AdminSlotItem? initialSlot,
  String? hallId,
  String? hallName,
  String? hallLabel,
  String? scheduleDate,
  String? scheduleDay,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdminSlotDetailsSheet(
      slotId: slotId,
      initialSlot: initialSlot,
      hallId: hallId,
      hallName: hallName,
      hallLabel: hallLabel,
      scheduleDate: scheduleDate,
      scheduleDay: scheduleDay,
    ),
  );
}

void showAdminAllSlotsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AdminAllSlotsSheet(),
  );
}

String formatWorkshopSchedule(String startStr, String endStr) {
  if (startStr.isEmpty) return '';
  try {
    final startDt = DateTime.tryParse(startStr);
    final endDt = DateTime.tryParse(endStr);
    if (startDt != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final datePart = '${startDt.day.toString().padLeft(2, '0')} ${months[startDt.month - 1]} ${startDt.year}';

      String formatTimeFromDt(DateTime dt) {
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        final displayHour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
        final hourStr = displayHour.toString().padLeft(2, '0');
        final minuteStr = dt.minute.toString().padLeft(2, '0');
        return '$hourStr:$minuteStr $period';
      }

      final startTimePart = formatTimeFromDt(startDt);
      if (endDt != null) {
        final endTimePart = formatTimeFromDt(endDt);
        if (startDt.year == endDt.year && startDt.month == endDt.month && startDt.day == endDt.day) {
          return '$datePart  •  $startTimePart - $endTimePart';
        } else {
          final endDatePart = '${endDt.day.toString().padLeft(2, '0')} ${months[endDt.month - 1]} ${endDt.year}';
          return '$datePart $startTimePart - $endDatePart $endTimePart';
        }
      }
      return '$datePart  •  $startTimePart';
    }
  } catch (_) {}
  return startStr;
}

// ==========================================
// 1. SPEAKER DETAILS BOTTOM SHEET
// ==========================================
class AdminSpeakerDetailsSheet extends StatefulWidget {
  final String userId;
  final AdminSpeaker? initialSpeaker;

  const AdminSpeakerDetailsSheet({
    super.key,
    required this.userId,
    this.initialSpeaker,
  });

  @override
  State<AdminSpeakerDetailsSheet> createState() => _AdminSpeakerDetailsSheetState();
}

class _AdminSpeakerDetailsSheetState extends State<AdminSpeakerDetailsSheet> {
  AdminSpeakerDetail? _details;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    try {
      final res = await admin.fetchSpeakerDetails(auth.accessToken, widget.userId);
      if (mounted) {
        setState(() {
          _details = res;
          _isLoading = false;
          if (res == null) {
            _errorMessage = 'Could not load speaker details.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _details?.fullName.isNotEmpty == true
        ? _details!.fullName
        : (widget.initialSpeaker?.fullName.isNotEmpty == true ? widget.initialSpeaker!.fullName : 'Speaker Details');

    final citizenType = _details?.citizenType.isNotEmpty == true
        ? _details!.citizenType
        : (widget.initialSpeaker?.citizenType ?? '');

    final designation = _details?.designation.isNotEmpty == true
        ? _details!.designation
        : (widget.initialSpeaker?.designation ?? '');

    final organisation = _details?.organisationName.isNotEmpty == true
        ? _details!.organisationName
        : (widget.initialSpeaker?.organisationName ?? '');

    final email = _details?.email.isNotEmpty == true
        ? _details!.email
        : (widget.initialSpeaker?.email ?? '');

    final mobile = _details?.mobile.isNotEmpty == true
        ? _details!.mobile
        : (widget.initialSpeaker?.mobile ?? '');

    final city = _details?.city.isNotEmpty == true
        ? _details!.city
        : (widget.initialSpeaker?.city ?? '');

    final state = _details?.state.isNotEmpty == true
        ? _details!.state
        : (widget.initialSpeaker?.state ?? '');

    final location = [city, state].where((s) => s.isNotEmpty && s != 'NA' && s != 'null').join(', ');

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC7D2FE), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.record_voice_over_rounded, size: 13, color: Color(0xFF4F46E5)),
                          SizedBox(width: 4),
                          Text(
                            'SPEAKER PROFILE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Content
          Expanded(
            child: _isLoading && _details == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  )
                : _errorMessage != null && _details == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
                              const SizedBox(height: 10),
                              Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _fetchDetails,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Card Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _getInitials(name),
                                      style: const TextStyle(
                                        fontSize: 18,
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
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (citizenType.isNotEmpty) ...[
                                          const SizedBox(height: 5),
                                          _buildBadge(
                                            'Citizen Type: $citizenType',
                                            const Color(0xFF0F766E),
                                            const Color(0xFFF0FDF4),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Professional Credentials Section
                            _buildSectionHeader('PROFESSIONAL INFORMATION', Icons.badge_outlined),
                            const SizedBox(height: 8),
                            _buildInfoCard([
                              _buildInfoRow('Designation', designation, Icons.work_outline_rounded),
                              _buildInfoRow('Hospital / Organisation', organisation, Icons.business_rounded),
                              _buildInfoRow('Specialization', _details?.specialization, Icons.medical_services_outlined),
                              _buildInfoRow(
                                'Experience',
                                (_details?.experienceYears.isNotEmpty == true && _details?.experienceYears != '0')
                                    ? '${_details!.experienceYears} Years'
                                    : null,
                                Icons.hourglass_top_rounded,
                              ),
                              _buildInfoRow(
                                'Qualification',
                                (_details?.qualification.isNotEmpty == true && _details?.qualification != 'NA')
                                    ? _details!.qualification
                                    : null,
                                Icons.school_outlined,
                              ),
                              _buildInfoRow('Category', _details?.category, Icons.category_outlined),
                              _buildInfoRow('Gender', _details?.gender, Icons.person_outline_rounded),
                              _buildInfoRow('Medical Reg. Number', _details?.medicalRegistrationNumber, Icons.verified_user_outlined),
                            ]),
                            const SizedBox(height: 16),

                            // Contact Details Section
                            _buildSectionHeader('CONTACT DETAILS', Icons.contact_phone_outlined),
                            const SizedBox(height: 8),
                            _buildInfoCard([
                              _buildInfoRow('Mobile Number', mobile, Icons.phone_outlined, copyable: true),
                              _buildInfoRow('Email Address', email, Icons.mail_outline_rounded, copyable: true),
                              _buildInfoRow('Location', location, Icons.location_on_outlined),
                            ]),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'SP';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'SP';
  }
}

// ==========================================
// 2. DELEGATE DETAILS BOTTOM SHEET
// ==========================================
class AdminDelegateDetailsSheet extends StatefulWidget {
  final String userId;
  final AdminDelegate? initialDelegate;

  const AdminDelegateDetailsSheet({
    super.key,
    required this.userId,
    this.initialDelegate,
  });

  @override
  State<AdminDelegateDetailsSheet> createState() => _AdminDelegateDetailsSheetState();
}

class _AdminDelegateDetailsSheetState extends State<AdminDelegateDetailsSheet> {
  AdminDelegateDetail? _details;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    try {
      final res = await admin.fetchDelegateDetails(auth.accessToken, widget.userId);
      if (mounted) {
        setState(() {
          _details = res;
          _isLoading = false;
          if (res == null) {
            _errorMessage = 'Could not load delegate details.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _details?.fullName.isNotEmpty == true
        ? _details!.fullName
        : (widget.initialDelegate?.fullName.isNotEmpty == true ? widget.initialDelegate!.fullName : 'Delegate Details');

    final citizenType = _details?.citizenType.isNotEmpty == true
        ? _details!.citizenType
        : (widget.initialDelegate?.citizenType ?? '');

    final designation = _details?.designation.isNotEmpty == true
        ? _details!.designation
        : (widget.initialDelegate?.designation ?? '');

    final organisation = _details?.organisationName.isNotEmpty == true
        ? _details!.organisationName
        : (widget.initialDelegate?.organisationName ?? '');

    final email = _details?.email.isNotEmpty == true
        ? _details!.email
        : (widget.initialDelegate?.email ?? '');

    final mobile = _details?.mobile.isNotEmpty == true
        ? _details!.mobile
        : (widget.initialDelegate?.mobile ?? '');

    final city = _details?.city.isNotEmpty == true
        ? _details!.city
        : (widget.initialDelegate?.city ?? '');

    final state = _details?.state.isNotEmpty == true
        ? _details!.state
        : (widget.initialDelegate?.state ?? '');

    final location = [city, state].where((s) => s.isNotEmpty && s != 'NA' && s != 'null').join(', ');

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_alt_rounded, size: 13, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'DELEGATE PROFILE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Content
          Expanded(
            child: _isLoading && _details == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF059669)),
                  )
                : _errorMessage != null && _details == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
                              const SizedBox(height: 10),
                              Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _fetchDetails,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Card Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF059669), Color(0xFF10B981)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _getInitials(name),
                                      style: const TextStyle(
                                        fontSize: 18,
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
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (citizenType.isNotEmpty) ...[
                                          const SizedBox(height: 5),
                                          _buildBadge(
                                            'Citizen Type: $citizenType',
                                            const Color(0xFF0F766E),
                                            const Color(0xFFF0FDF4),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Professional Credentials Section
                            _buildSectionHeader('PROFESSIONAL INFORMATION', Icons.badge_outlined),
                            const SizedBox(height: 8),
                            _buildInfoCard([
                              _buildInfoRow('Designation', designation, Icons.work_outline_rounded),
                              _buildInfoRow('Hospital / Organisation', organisation, Icons.business_rounded),
                              _buildInfoRow('Specialization', _details?.specialization, Icons.medical_services_outlined),
                              _buildInfoRow(
                                'Experience',
                                (_details?.experienceYears.isNotEmpty == true && _details?.experienceYears != '0')
                                    ? '${_details!.experienceYears} Years'
                                    : null,
                                Icons.hourglass_top_rounded,
                              ),
                              _buildInfoRow(
                                'Qualification',
                                (_details?.qualification.isNotEmpty == true && _details?.qualification != 'NA')
                                    ? _details!.qualification
                                    : null,
                                Icons.school_outlined,
                              ),
                              _buildInfoRow('Category', _details?.category, Icons.category_outlined),
                              _buildInfoRow('Gender', _details?.gender, Icons.person_outline_rounded),
                              _buildInfoRow('Medical Reg. Number', _details?.medicalRegistrationNumber, Icons.verified_user_outlined),
                            ]),
                            const SizedBox(height: 16),

                            // Contact Details Section
                            _buildSectionHeader('CONTACT DETAILS', Icons.contact_phone_outlined),
                            const SizedBox(height: 8),
                            _buildInfoCard([
                              _buildInfoRow('Mobile Number', mobile, Icons.phone_outlined, copyable: true),
                              _buildInfoRow('Email Address', email, Icons.mail_outline_rounded, copyable: true),
                              _buildInfoRow('Location', location, Icons.location_on_outlined),
                            ]),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'DL';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'DL';
  }
}

// ==========================================
// 3. TOPIC DETAILS & BOOKMARKS BOTTOM SHEET
// ==========================================
class AdminTopicDetailsSheet extends StatefulWidget {
  final String topicId;
  final AdminTopic? initialTopic;

  const AdminTopicDetailsSheet({
    super.key,
    required this.topicId,
    this.initialTopic,
  });

  @override
  State<AdminTopicDetailsSheet> createState() => _AdminTopicDetailsSheetState();
}

class _AdminTopicDetailsSheetState extends State<AdminTopicDetailsSheet> {
  AdminTopicDetail? _topicDetail;
  List<AdminTopicBookmarkItem> _bookmarks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetailsAndBookmarks();
  }

  Future<void> _fetchDetailsAndBookmarks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    try {
      final results = await Future.wait([
        admin.fetchTopicDetails(auth.accessToken, widget.topicId),
        admin.fetchTopicBookmarks(auth.accessToken, widget.topicId),
      ]);

      if (mounted) {
        setState(() {
          _topicDetail = results[0] as AdminTopicDetail?;
          _bookmarks = (results[1] as List<AdminTopicBookmarkItem>?) ?? [];
          _isLoading = false;
          if (_topicDetail == null) {
            _errorMessage = 'Could not load topic details.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _topicDetail?.title.isNotEmpty == true
        ? _topicDetail!.title
        : (widget.initialTopic?.title.isNotEmpty == true ? widget.initialTopic!.title : 'Scientific Topic');

    final status = _topicDetail?.status.isNotEmpty == true
        ? _topicDetail!.status
        : (widget.initialTopic?.status ?? '');

    final category = _topicDetail?.categoryOfSubmission.isNotEmpty == true
        ? _topicDetail!.categoryOfSubmission
        : (widget.initialTopic?.categoryOfSubmission ?? '');

    final speakerName = _topicDetail?.speakerName.isNotEmpty == true
        ? _topicDetail!.speakerName
        : (widget.initialTopic?.speakerName ?? '');

    // final presentationFormat = _topicDetail?.presentationFormat ?? '';
    final speakerEmail = _topicDetail?.speakerEmail ?? '';
    final author1 = _topicDetail?.contributingAuthor1Name ?? '';
    final author2 = _topicDetail?.contributingAuthor2Name ?? '';
    final bool isConfirmed = status.toLowerCase() == 'confirmed';
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final scheduleInfo = admin.getTopicScheduleInfo(widget.topicId);
    final scheduleDate = (_topicDetail?.scheduleDate.isNotEmpty == true
        ? _topicDetail!.scheduleDate
        : (widget.initialTopic?.scheduleDate.isNotEmpty == true
            ? widget.initialTopic!.scheduleDate
            : scheduleInfo?['schedule_date'])) ?? '';
    final scheduleDay = (_topicDetail?.scheduleDay.isNotEmpty == true
        ? _topicDetail!.scheduleDay
        : (widget.initialTopic?.scheduleDay.isNotEmpty == true
            ? widget.initialTopic!.scheduleDay
            : scheduleInfo?['schedule_day'])) ?? '';
    final startTime = (_topicDetail?.startTime.isNotEmpty == true
        ? _topicDetail!.startTime
        : (widget.initialTopic?.startTime.isNotEmpty == true
            ? widget.initialTopic!.startTime
            : scheduleInfo?['start_time'])) ?? '';
    final endTime = (_topicDetail?.endTime.isNotEmpty == true
        ? _topicDetail!.endTime
        : (widget.initialTopic?.endTime.isNotEmpty == true
            ? widget.initialTopic!.endTime
            : scheduleInfo?['end_time'])) ?? '';
    final hallName = (_topicDetail?.hallLabel.isNotEmpty == true
        ? _topicDetail!.hallLabel
        : (_topicDetail?.hallName.isNotEmpty == true
            ? _topicDetail!.hallName
            : (widget.initialTopic?.hallLabel.isNotEmpty == true
                ? widget.initialTopic!.hallLabel
                : (scheduleInfo?['hall_label'] ?? scheduleInfo?['hall_name'])))) ?? '';
    final slotTitle = (_topicDetail?.slotLabel.isNotEmpty == true
        ? _topicDetail!.slotLabel
        : (_topicDetail?.slotName.isNotEmpty == true
            ? _topicDetail!.slotName
            : (widget.initialTopic?.slotLabel.isNotEmpty == true
                ? widget.initialTopic!.slotLabel
                : (scheduleInfo?['slot_label'] ?? scheduleInfo?['slot_name'])))) ?? '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.description_rounded, size: 13, color: Color(0xFFD97706)),
                          SizedBox(width: 4),
                          Text(
                            'TOPIC DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Content
          Expanded(
            child: _isLoading && _topicDetail == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD97706)),
                  )
                : _errorMessage != null && _topicDetail == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
                              const SizedBox(height: 10),
                              Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _fetchDetailsAndBookmarks,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status & Tags Row
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (status.isNotEmpty)
                                  _buildBadge(
                                    isConfirmed
                                        ? 'Slot Assigned'
                                        : (status.toLowerCase() == 'approved' ? 'Slot Not Assigned' : status),
                                    isConfirmed ? const Color(0xFF059669) : const Color(0xFFD97706),
                                    isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                                  ),
                                // Format commented out as requested
                                /*
                                if (presentationFormat.isNotEmpty)
                                  _buildBadge(
                                    'Format: $presentationFormat',
                                    const Color(0xFF4F46E5),
                                    const Color(0xFFEEF2FF),
                                  ),
                                */
                                if (category.isNotEmpty)
                                  _buildBadge(
                                    category,
                                    const Color(0xFF0284C7),
                                    const Color(0xFFF0F9FF),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Topic Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Assigned Presentation Slot & Timing (Date, Time, Hall)
                            if (isConfirmed || scheduleDate.isNotEmpty || startTime.isNotEmpty || hallName.isNotEmpty) ...[
                              _buildSectionHeader('ASSIGNED PRESENTATION SLOT & TIMING', Icons.event_available_rounded),
                              const SizedBox(height: 8),
                              _buildInfoCard([
                                if (scheduleDate.isNotEmpty || scheduleDay.isNotEmpty)
                                  _buildInfoRow(
                                    'Schedule Date & Day',
                                    [scheduleDate, scheduleDay.isNotEmpty ? 'Day $scheduleDay' : ''].where((s) => s.isNotEmpty).join('  •  '),
                                    Icons.calendar_today_rounded,
                                  ),
                                if (startTime.isNotEmpty)
                                  _buildInfoRow(
                                    'Time Window',
                                    endTime.isNotEmpty ? '$startTime - $endTime' : startTime,
                                    Icons.access_time_rounded,
                                  ),
                                if (hallName.isNotEmpty)
                                  _buildInfoRow('Hall / Track', hallName, Icons.meeting_room_rounded),
                                if (slotTitle.isNotEmpty)
                                  _buildInfoRow('Slot', slotTitle, Icons.layers_outlined),
                              ]),
                              const SizedBox(height: 16),
                            ],

                            // Speaker & Author Info Card
                            _buildSectionHeader('PRIMARY SPEAKER & AUTHORS', Icons.person_outline_rounded),
                            const SizedBox(height: 8),
                            _buildInfoCard([
                              _buildInfoRow('Speaker Name', speakerName, Icons.record_voice_over_rounded),
                              _buildInfoRow('Speaker Email', speakerEmail, Icons.mail_outline_rounded, copyable: true),
                              if (author1.isNotEmpty) _buildInfoRow('Co-Author 1', author1, Icons.people_outline_rounded),
                              if (author2.isNotEmpty) _buildInfoRow('Co-Author 2', author2, Icons.people_outline_rounded),
                            ]),
                            const SizedBox(height: 16),

                            // Abstract Sections
                            if (_hasAbstractContent(_topicDetail)) ...[
                              _buildSectionHeader('SCIENTIFIC ABSTRACT', Icons.article_outlined),
                              const SizedBox(height: 8),
                              _buildAbstractBlock('Background & Introduction', _topicDetail?.backgroundIntroduction),
                              _buildAbstractBlock('Aims & Objectives', _topicDetail?.aimsObjectives),
                              _buildAbstractBlock('Materials & Methods', _topicDetail?.materialsMethods),
                              _buildAbstractBlock('Results', _topicDetail?.results),
                              _buildAbstractBlock('Conclusion', _topicDetail?.conclusion),
                              _buildAbstractBlock('Keywords', _topicDetail?.keywords),
                              const SizedBox(height: 16),
                            ],

                            // Bookmarked by Delegates Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionHeader('BOOKMARKED BY DELEGATES', Icons.bookmark_added_rounded),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_bookmarks.length} Bookmark${_bookmarks.length == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            if (_bookmarks.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.bookmark_border_rounded, size: 28, color: Color(0xFF94A3B8)),
                                    SizedBox(height: 8),
                                    Text(
                                      'No delegates have bookmarked this topic yet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _bookmarks.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final bm = _bookmarks[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius: BorderRadius.circular(9),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getInitials(bm.candidateName),
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4F46E5),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      bm.candidateName.isNotEmpty ? bm.candidateName : 'Candidate',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  if (bm.role.isNotEmpty)
                                                    _buildBadge(bm.role, const Color(0xFF059669), const Color(0xFFECFDF5)),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              if (bm.designation.isNotEmpty || bm.organisationName.isNotEmpty)
                                                Text(
                                                  [bm.designation, bm.organisationName]
                                                      .where((s) => s.isNotEmpty)
                                                      .join(' • '),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              // Bookmarked date commented out as requested
                                              /*
                                              if (bm.bookmarkedOn.isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Bookmarked: ${TimeFormatter.formatString(bm.bookmarkedOn)}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF94A3B8),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                              */
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  bool _hasAbstractContent(AdminTopicDetail? d) {
    if (d == null) return false;
    return d.backgroundIntroduction.isNotEmpty ||
        d.aimsObjectives.isNotEmpty ||
        d.materialsMethods.isNotEmpty ||
        d.results.isNotEmpty ||
        d.conclusion.isNotEmpty ||
        d.keywords.isNotEmpty;
  }

  Widget _buildAbstractBlock(String title, String? content) {
    if (content == null || content.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content.trim(),
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'TP';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'TP';
  }
}

// ==========================================
// 4. WORKSHOP DETAILS & PARTICIPANTS SHEET
// ==========================================
class AdminWorkshopDetailsSheet extends StatefulWidget {
  final String workshopId;
  final AdminWorkshop? initialWorkshop;

  const AdminWorkshopDetailsSheet({
    super.key,
    required this.workshopId,
    this.initialWorkshop,
  });

  @override
  State<AdminWorkshopDetailsSheet> createState() => _AdminWorkshopDetailsSheetState();
}

class _AdminWorkshopDetailsSheetState extends State<AdminWorkshopDetailsSheet> {
  AdminWorkshopParticipantsData? _data;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTabIndex = 0; // 0 for Speakers, 1 for Delegates

  @override
  void initState() {
    super.initState();
    _fetchWorkshopParticipants();
  }

  Future<void> _fetchWorkshopParticipants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    try {
      final res = await admin.fetchWorkshopParticipants(auth.accessToken, widget.workshopId);
      if (mounted) {
        setState(() {
          _data = res;
          _isLoading = false;
          if (res == null) {
            _errorMessage = 'Could not load workshop details.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = _data?.workshop ?? widget.initialWorkshop ?? const AdminWorkshop();
    final name = ws.workshopName.isNotEmpty ? ws.workshopName : 'Workshop Details';
    final code = ws.workshopCode.isNotEmpty ? ws.workshopCode : 'WS';
    final location = [ws.venueName, ws.city, ws.state].where((s) => s.isNotEmpty && s != 'NA' && s != 'null').join(', ');
    final schedule = formatWorkshopSchedule(ws.workshopStart, ws.workshopEnd);

    final speakers = _data?.speakers ?? [];
    final delegates = _data?.delegates ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE9D5FF), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.assignment_turned_in_rounded, size: 13, color: Color(0xFF9333EA)),
                          const SizedBox(width: 4),
                          Text(
                            'WORKSHOP $code',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9333EA),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Content
          Expanded(
            child: _isLoading && _data == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF9333EA)),
                  )
                : _errorMessage != null && _data == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
                              const SizedBox(height: 10),
                              Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _fetchWorkshopParticipants,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9333EA)),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Workshop Title Header
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Workshop Info Card
                            _buildInfoCard([
                              _buildInfoRow('Venue & Location', location, Icons.location_city_rounded),
                              _buildInfoRow('Date & Schedule', schedule, Icons.access_time_rounded),
                              if (ws.workshopType.isNotEmpty && ws.workshopType != 'Other')
                                _buildInfoRow('Workshop Type', ws.workshopType, Icons.category_outlined),
                            ]),
                            const SizedBox(height: 20),

                            // Section Title & Tabs for Participants
                            _buildSectionHeader('WORKSHOP PARTICIPANTS', Icons.people_alt_rounded),
                            const SizedBox(height: 12),

                            // Custom Segmented Toggle Tabs
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _selectedTabIndex = 0),
                                      borderRadius: BorderRadius.circular(9),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _selectedTabIndex == 0 ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(9),
                                          boxShadow: _selectedTabIndex == 0
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Faculty / Speakers (${speakers.length})',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedTabIndex == 0 ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _selectedTabIndex = 1),
                                      borderRadius: BorderRadius.circular(9),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _selectedTabIndex == 1 ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(9),
                                          boxShadow: _selectedTabIndex == 1
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Delegates (${delegates.length})',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedTabIndex == 1 ? const Color(0xFF059669) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Display Selected Participant List
                            if (_selectedTabIndex == 0)
                              _buildParticipantList(
                                participants: speakers,
                                roleType: 'Speaker',
                                emptyMessage: 'No speakers or faculty assigned to this workshop yet.',
                                themeColor: const Color(0xFF4F46E5),
                                bgThemeColor: const Color(0xFFEEF2FF),
                              )
                            else
                              _buildParticipantList(
                                participants: delegates,
                                roleType: 'Delegate',
                                emptyMessage: 'No delegates registered for this workshop yet.',
                                themeColor: const Color(0xFF059669),
                                bgThemeColor: const Color(0xFFECFDF5),
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantList({
    required List<AdminWorkshopParticipant> participants,
    required String roleType,
    required String emptyMessage,
    required Color themeColor,
    required Color bgThemeColor,
  }) {
    if (participants.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.person_off_rounded, size: 28, color: Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final p = participants[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar & Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: bgThemeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getInitials(p.fullName),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.fullName.isNotEmpty ? p.fullName : roleType,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 14),

              // Stacked details with generous vertical gaps
              if (p.designation.isNotEmpty)
                _buildParticipantInfoRow('Designation', p.designation, Icons.work_outline_rounded),
              if (p.organisationName.isNotEmpty)
                _buildParticipantInfoRow('Hospital / Organisation', p.organisationName, Icons.business_rounded),
              if (p.mobile.isNotEmpty)
                _buildParticipantInfoRow('Mobile', p.mobile, Icons.phone_outlined, copyable: true),
              if (p.email.isNotEmpty)
                _buildParticipantInfoRow('Email', p.email, Icons.mail_outline_rounded, copyable: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantInfoRow(String label, String value, IconData icon, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF94A3B8)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value.trim()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied $label to clipboard'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'WS';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0].isNotEmpty && parts[1].isNotEmpty)
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'WS';
  }
}

// ==========================================
// 5. EXHIBITOR DETAILS BOTTOM SHEET
// ==========================================
class AdminSponsorDetailsSheet extends StatefulWidget {
  final String sponsorId;
  final AdminSponsor? initialSponsor;

  const AdminSponsorDetailsSheet({
    super.key,
    required this.sponsorId,
    this.initialSponsor,
  });

  @override
  State<AdminSponsorDetailsSheet> createState() => _AdminSponsorDetailsSheetState();
}

class _AdminSponsorDetailsSheetState extends State<AdminSponsorDetailsSheet> {
  AdminSponsorDetail? _details;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    try {
      final res = await admin.fetchSponsorDetails(auth.accessToken, widget.sponsorId);
      if (mounted) {
        setState(() {
          _details = res;
          _isLoading = false;
          if (res == null && widget.initialSponsor == null) {
            _errorMessage = 'Could not load exhibitor details.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = _details?.companyName.isNotEmpty == true
        ? _details!.companyName
        : (widget.initialSponsor?.companyName.isNotEmpty == true ? widget.initialSponsor!.companyName : 'Exhibitor Details');

    final category = _details?.sponsorCategory.isNotEmpty == true
        ? _details!.sponsorCategory
        : (widget.initialSponsor?.sponsorCategory ?? '');

    final contactPerson = _details?.contactPerson.isNotEmpty == true
        ? _details!.contactPerson
        : (widget.initialSponsor?.contactPerson ?? '');

    final designation = _details?.designation.isNotEmpty == true
        ? _details!.designation
        : (widget.initialSponsor?.designation ?? '');

    final mobile = _details?.mobile.isNotEmpty == true
        ? _details!.mobile
        : (widget.initialSponsor?.mobile ?? '');

    final email = _details?.email.isNotEmpty == true
        ? _details!.email
        : (widget.initialSponsor?.email ?? '');

    final website = _details?.website.isNotEmpty == true
        ? _details!.website
        : (widget.initialSponsor?.website ?? '');

    final description = _details?.companyDescription.isNotEmpty == true
        ? _details!.companyDescription
        : (widget.initialSponsor?.companyDescription ?? '');

    final booths = _details?.booths ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF2F8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFBCFE8), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.storefront_rounded, size: 13, color: Color(0xFFDB2777)),
                          SizedBox(width: 4),
                          Text(
                            'EXHIBITOR DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDB2777),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Content
          Expanded(
            child: _isLoading && _details == null && widget.initialSponsor == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFDB2777)),
                  )
                : _errorMessage != null && _details == null && widget.initialSponsor == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
                              const SizedBox(height: 10),
                              Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _fetchDetails,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDB2777)),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Icon + Company Name & Category
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF2F8),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFFBCFE8)),
                                  ),
                                  child: const Icon(
                                    Icons.business_rounded,
                                    color: Color(0xFFDB2777),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        companyName,
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          height: 1.3,
                                        ),
                                      ),
                                      if (category.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        _buildBadge(category, const Color(0xFFDB2777), const Color(0xFFFDF2F8)),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Company Description (if available)
                            if (description.isNotEmpty && description != 'NA') ...[
                              _buildSectionHeader('ABOUT COMPANY', Icons.info_outline_rounded),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Contact Information Section
                            _buildSectionHeader('CONTACT & BUSINESS INFORMATION', Icons.contact_phone_rounded),
                            const SizedBox(height: 8),
                            _buildInfoCard([
                              _buildInfoRow('Contact Person', contactPerson, Icons.person_outline_rounded),
                              _buildInfoRow('Designation', designation, Icons.badge_outlined),
                              _buildInfoRow('Mobile Number', mobile, Icons.phone_outlined, copyable: true),
                              _buildInfoRow('Email Address', email, Icons.mail_outline_rounded, copyable: true),
                              _buildInfoRow('Website', website, Icons.language_rounded, copyable: true),
                            ]),
                            const SizedBox(height: 20),

                            // Assigned Booths Section
                            _buildSectionHeader('ASSIGNED BOOTHS (${booths.length})', Icons.meeting_room_rounded),
                            const SizedBox(height: 8),

                            if (_isLoading && _details == null)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator(color: Color(0xFFDB2777))),
                              )
                            else if (booths.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.meeting_room_outlined, size: 28, color: Color(0xFF94A3B8)),
                                    SizedBox(height: 6),
                                    Text(
                                      'No booths assigned yet',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: booths.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final b = booths[index];
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                if (b.boothLabel.isNotEmpty) ...[
                                                  _buildBadge(
                                                    b.boothLabel,
                                                    const Color(0xFF4F46E5),
                                                    const Color(0xFFEEF2FF),
                                                  ),
                                                  const SizedBox(width: 6),
                                                ],
                                                _buildBadge(
                                                  b.boothNumber.isNotEmpty ? b.boothNumber : 'BOOTH',
                                                  const Color(0xFF0284C7),
                                                  const Color(0xFFF0F9FF),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (b.sizeSqft != null && b.sizeSqft!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            'Size: ${b.sizeSqft} sqft',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                        if (b.price != null && b.price!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Price: ${b.price}',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. BOOTH DETAILS BOTTOM SHEET
// ==========================================
class AdminBoothDetailsSheet extends StatefulWidget {
  final String boothId;
  final AdminBooth? initialBooth;

  const AdminBoothDetailsSheet({
    super.key,
    required this.boothId,
    this.initialBooth,
  });

  @override
  State<AdminBoothDetailsSheet> createState() => _AdminBoothDetailsSheetState();
}

class _AdminBoothDetailsSheetState extends State<AdminBoothDetailsSheet> {
  AdminBoothDetail? _details;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    try {
      final res = await admin.fetchBoothDetails(auth.accessToken, widget.boothId);
      if (mounted) {
        setState(() {
          _details = res;
          _isLoading = false;
          if (res == null && widget.initialBooth == null) {
            _errorMessage = 'Could not load booth details.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final boothNumber = _details?.boothNumber.isNotEmpty == true
        ? _details!.boothNumber
        : (widget.initialBooth?.boothNumber.isNotEmpty == true ? widget.initialBooth!.boothNumber : 'Booth');

    final boothLabel = _details?.boothLabel.isNotEmpty == true
        ? _details!.boothLabel
        : (widget.initialBooth?.boothLabel ?? '');

    final sizeSqft = _details?.sizeSqft ?? widget.initialBooth?.sizeSqft;
    final price = _details?.price ?? widget.initialBooth?.price;

    final sponsor = _details?.sponsor;
    final bool isAssigned = _details?.isAssigned == true || (widget.initialBooth?.companyName.isNotEmpty == true);

    final companyName = sponsor?.companyName.isNotEmpty == true
        ? sponsor!.companyName
        : (widget.initialBooth?.companyName ?? '');

    final category = sponsor?.sponsorCategory ?? '';
    final contactPerson = sponsor?.contactPerson.isNotEmpty == true
        ? sponsor!.contactPerson
        : (widget.initialBooth?.contactPerson ?? '');

    final mobile = sponsor?.mobile.isNotEmpty == true
        ? sponsor!.mobile
        : (widget.initialBooth?.mobile ?? '');

    final email = sponsor?.email.isNotEmpty == true
        ? sponsor!.email
        : (widget.initialBooth?.email ?? '');

    final designation = sponsor?.designation ?? '';
    final website = sponsor?.website ?? '';
    final description = sponsor?.companyDescription ?? '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBAE6FD), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.meeting_room_rounded, size: 13, color: Color(0xFF0284C7)),
                          SizedBox(width: 4),
                          Text(
                            'BOOTH DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Content
          Expanded(
            child: _isLoading && _details == null && widget.initialBooth == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                  )
                : _errorMessage != null && _details == null && widget.initialBooth == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
                              const SizedBox(height: 10),
                              Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _fetchDetails,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Booth Identification Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F9FF),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFBAE6FD)),
                                    ),
                                    child: const Icon(Icons.meeting_room_rounded, color: Color(0xFF0284C7), size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          boothLabel.isNotEmpty ? boothLabel : (boothNumber.isNotEmpty ? boothNumber : 'Booth'),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            if (boothLabel.isNotEmpty && boothNumber.isNotEmpty) ...[
                                              _buildBadge(boothNumber, const Color(0xFF0284C7), const Color(0xFFF0F9FF)),
                                              const SizedBox(width: 6),
                                            ],
                                            _buildBadge(
                                              isAssigned ? 'Allocated' : 'Available',
                                              isAssigned ? const Color(0xFF059669) : const Color(0xFF0284C7),
                                              isAssigned ? const Color(0xFFECFDF5) : const Color(0xFFF0F9FF),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Specifications (No Type, No Assigned timestamp)
                            if ((sizeSqft != null && sizeSqft.isNotEmpty) || (price != null && price.isNotEmpty)) ...[
                              _buildSectionHeader('BOOTH SPECIFICATIONS', Icons.straighten_rounded),
                              const SizedBox(height: 8),
                              _buildInfoCard([
                                if (sizeSqft != null && sizeSqft.isNotEmpty)
                                  _buildInfoRow('Dimensions / Size', '$sizeSqft sqft', Icons.aspect_ratio_rounded),
                                if (price != null && price.isNotEmpty)
                                  _buildInfoRow('Tariff / Price', price, Icons.payments_outlined),
                              ]),
                              const SizedBox(height: 18),
                            ],

                            // Allocated Exhibitor Information
                            _buildSectionHeader('ALLOCATED EXHIBITOR', Icons.business_rounded),
                            const SizedBox(height: 8),

                            if (!isAssigned && companyName.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.storefront_outlined, size: 28, color: Color(0xFF94A3B8)),
                                    SizedBox(height: 8),
                                    Text(
                                      'This booth is currently available and not yet allocated to an exhibitor.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF2F8),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFFBCFE8)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.storefront_rounded, size: 22, color: Color(0xFFDB2777)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                companyName.isNotEmpty ? companyName : 'Exhibitor',
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              if (category.isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  category,
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFDB2777),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoCard([
                                    _buildInfoRow('Contact Person', contactPerson, Icons.person_outline_rounded),
                                    _buildInfoRow('Designation', designation, Icons.badge_outlined),
                                    _buildInfoRow('Mobile', mobile, Icons.phone_outlined, copyable: true),
                                    _buildInfoRow('Email', email, Icons.mail_outline_rounded, copyable: true),
                                    _buildInfoRow('Website', website, Icons.language_rounded, copyable: true),
                                  ]),
                                  if (description.isNotEmpty && description != 'NA') ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Text(
                                        description,
                                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. SLOT DETAILS BOTTOM SHEET
// ==========================================
class AdminSlotDetailsSheet extends StatefulWidget {
  final String slotId;
  final AdminSlotItem? initialSlot;
  final String? hallId;
  final String? hallName;
  final String? hallLabel;
  final String? scheduleDate;
  final String? scheduleDay;

  const AdminSlotDetailsSheet({
    super.key,
    required this.slotId,
    this.initialSlot,
    this.hallId,
    this.hallName,
    this.hallLabel,
    this.scheduleDate,
    this.scheduleDay,
  });

  @override
  State<AdminSlotDetailsSheet> createState() => _AdminSlotDetailsSheetState();
}

class _AdminSlotDetailsSheetState extends State<AdminSlotDetailsSheet> {
  AdminSlotDetail? _details;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    try {
      final res = await admin.fetchSlotDetails(
        auth.accessToken,
        widget.slotId,
        hallId: widget.hallId,
        scheduleDay: widget.scheduleDay,
      );
      if (mounted) {
        setState(() {
          _details = res;
          _isLoading = false;
          if (res == null && widget.initialSlot == null) {
            _errorMessage = 'Could not load slot details.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotLabel = _details?.slotLabel.isNotEmpty == true
        ? _details!.slotLabel
        : (widget.initialSlot?.slotLabel ?? '');

    final rawSlotName = _details?.slotName.isNotEmpty == true
        ? _details!.slotName
        : (widget.initialSlot?.slotName ?? '');

    final slotNumber = _details?.slotNumber.isNotEmpty == true
        ? _details!.slotNumber
        : (widget.initialSlot?.slotNumber ?? '');

    final slotTitle = slotLabel.trim().isNotEmpty
        ? slotLabel.trim()
        : (rawSlotName.trim().isNotEmpty ? rawSlotName.trim() : (slotNumber.isNotEmpty ? 'Slot $slotNumber' : 'Presentation Slot'));

    final slotStatus = _details?.slotStatus.isNotEmpty == true
        ? _details!.slotStatus
        : (widget.initialSlot?.slotStatus ?? 'FREE');

    final cleanSlotStatus = slotStatus.trim().toUpperCase();
    final bool isCancelled = cleanSlotStatus == 'CANCELLED';
    final bool isBooked = !isCancelled && (cleanSlotStatus == 'BOOKED' || cleanSlotStatus == 'ASSIGNED' || cleanSlotStatus == 'ALLOCATED' || (_details?.isAssigned ?? widget.initialSlot?.isAssigned ?? false));

    final hallName = _details?.hallName.isNotEmpty == true
        ? _details!.hallName
        : (widget.hallName ?? '');

    final hallLabel = _details?.hallLabel.isNotEmpty == true
        ? _details!.hallLabel
        : (widget.hallLabel ?? '');

    final scheduleDate = _details?.scheduleDate.isNotEmpty == true
        ? _details!.scheduleDate
        : (widget.scheduleDate ?? '');

    final scheduleDay = _details?.scheduleDay.isNotEmpty == true
        ? _details!.scheduleDay
        : (widget.scheduleDay ?? '');

    final startTime = _details?.startTime.isNotEmpty == true
        ? _details!.startTime
        : (widget.initialSlot?.startTime ?? '');

    final endTime = _details?.endTime.isNotEmpty == true
        ? _details!.endTime
        : (widget.initialSlot?.endTime ?? '');

    final formattedStart = TimeFormatter.formatTime(startTime);
    final formattedEnd = TimeFormatter.formatTime(endTime);
    final timeWindow = (formattedStart.isNotEmpty && formattedEnd.isNotEmpty)
        ? '$formattedStart - $formattedEnd'
        : (formattedStart.isNotEmpty ? formattedStart : (startTime.isNotEmpty ? startTime : ''));

    final topic = _details?.topic;
    final speaker = _details?.speaker;

    final topicTitle = topic?.title.isNotEmpty == true
        ? topic!.title
        : (widget.initialSlot?.topicTitle ?? '');

    final speakerName = speaker?.fullName.isNotEmpty == true
        ? speaker!.fullName
        : (widget.initialSlot?.speakerName ?? '');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF99F6E4), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_filled_rounded, size: 13, color: Color(0xFF0D9488)),
                          SizedBox(width: 4),
                          Text(
                            'SLOT DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Content
          Expanded(
            child: _isLoading && _details == null && widget.initialSlot == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                  )
                : _errorMessage != null && _details == null && widget.initialSlot == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
                              const SizedBox(height: 10),
                              Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _fetchDetails,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Banner Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isCancelled
                                          ? const Color(0xFFFEF2F2)
                                          : (isBooked ? const Color(0xFFECFDF5) : const Color(0xFFF0FDFA)),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isCancelled
                                            ? const Color(0xFFFECACA)
                                            : (isBooked ? const Color(0xFFA7F3D0) : const Color(0xFF99F6E4)),
                                      ),
                                    ),
                                    child: Icon(
                                      isCancelled
                                          ? Icons.cancel_outlined
                                          : (isBooked ? Icons.event_available_rounded : Icons.access_time_rounded),
                                      color: isCancelled
                                          ? const Color(0xFFDC2626)
                                          : (isBooked ? const Color(0xFF059669) : const Color(0xFF0D9488)),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: () {
                                      String cleanText(String s) =>
                                          s.replaceAll('#', '').replaceAll(RegExp(r'\s+'), ' ').trim();

                                      String mainSlotTitle = '';
                                      String slotBadgeLabel = '';

                                      if (slotTitle.contains('#')) {
                                        final parts = slotTitle.split('#');
                                        final prefix = cleanText(parts[0]);
                                        final suffix = cleanText(parts.sublist(1).join(' '));

                                        if (suffix.isNotEmpty) {
                                          mainSlotTitle = suffix;
                                          if (prefix.isNotEmpty && prefix.toLowerCase() != suffix.toLowerCase()) {
                                            slotBadgeLabel = prefix;
                                          }
                                        } else {
                                          mainSlotTitle = prefix;
                                        }
                                      } else {
                                        mainSlotTitle = cleanText(slotTitle);
                                      }

                                      if (mainSlotTitle.isEmpty) {
                                        if (rawSlotName.contains('#')) {
                                          final parts = rawSlotName.split('#');
                                          final prefix = cleanText(parts[0]);
                                          final suffix = cleanText(parts.sublist(1).join(' '));
                                          mainSlotTitle = suffix.isNotEmpty ? suffix : prefix;
                                          if (prefix.isNotEmpty && suffix.isNotEmpty && prefix.toLowerCase() != suffix.toLowerCase()) {
                                            slotBadgeLabel = prefix;
                                          }
                                        } else {
                                          mainSlotTitle = cleanText(rawSlotName);
                                        }
                                      }

                                      if (mainSlotTitle.isEmpty) {
                                        mainSlotTitle = slotNumber.isNotEmpty ? 'Slot $slotNumber' : 'Slot';
                                      }

                                      if (slotBadgeLabel.isEmpty && slotNumber.isNotEmpty) {
                                        if (!mainSlotTitle.toLowerCase().contains('slot $slotNumber') &&
                                            mainSlotTitle.toLowerCase() != 'slot $slotNumber'.toLowerCase() &&
                                            mainSlotTitle != slotNumber) {
                                          slotBadgeLabel = 'Slot $slotNumber';
                                        }
                                      }

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  mainSlotTitle,
                                                  style: const TextStyle(
                                                    fontSize: 15.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textPrimary,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ),
                                              if (slotBadgeLabel.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                _buildBadge(slotBadgeLabel, const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              _buildBadge(
                                                slotStatus,
                                                isCancelled
                                                    ? const Color(0xFFDC2626)
                                                    : (isBooked ? const Color(0xFF059669) : const Color(0xFF0D9488)),
                                                isCancelled
                                                    ? const Color(0xFFFEF2F2)
                                                    : (isBooked ? const Color(0xFFECFDF5) : const Color(0xFFF0FDFA)),
                                              ),
                                              if (hallLabel.isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                _buildBadge(hallLabel, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
                                              ],
                                            ],
                                          ),
                                        ],
                                      );
                                    }(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Schedule Info
                            _buildSectionHeader('SCHEDULE', Icons.calendar_month_rounded),
                            const SizedBox(height: 8),
                            _buildInfoCard([
                              if (hallLabel.isNotEmpty || hallName.isNotEmpty)
                                _buildInfoRow(
                                  'Hall / Track',
                                  hallLabel.trim().isNotEmpty ? hallLabel.trim() : hallName.trim(),
                                  Icons.meeting_room_rounded,
                                ),
                              if (scheduleDate.isNotEmpty || scheduleDay.isNotEmpty)
                                _buildInfoRow(
                                  'Schedule Date & Day',
                                  [scheduleDate, scheduleDay.isNotEmpty ? 'Day $scheduleDay' : ''].where((s) => s.isNotEmpty).join('  •  '),
                                  Icons.event_outlined,
                                ),
                              if (timeWindow.isNotEmpty)
                                _buildInfoRow('Time Window', timeWindow, Icons.access_time_rounded),
                            ]),
                            const SizedBox(height: 18),

                            // Scientific Presentation / Assigned Sessions
                            if (_details?.sessions.isNotEmpty == true) ...[
                              _buildSectionHeader('ASSIGNED SESSIONS (${_details!.sessions.length})', Icons.assignment_turned_in_rounded),
                              const SizedBox(height: 10),
                              ..._details!.sessions.asMap().entries.map((e) => _buildSessionAssignmentCard(e.key, e.value)),
                              const SizedBox(height: 16),
                            ] else if (isBooked || topicTitle.isNotEmpty) ...[
                              _buildSectionHeader('SCIENTIFIC PRESENTATION', Icons.description_rounded),
                              const SizedBox(height: 8),
                              _buildInfoCard([
                                _buildInfoRow('Topic Title', topicTitle, Icons.title_rounded),
                                _buildInfoRow('Category', topic?.categoryOfSubmission, Icons.category_outlined),
                                if (topic?.presentationFormat.isNotEmpty == true)
                                  _buildInfoRow('Format', topic?.presentationFormat, Icons.slideshow_rounded),
                              ]),
                              const SizedBox(height: 18),

                              // Speaker Information
                              if (speakerName.isNotEmpty || speaker != null) ...[
                                _buildSectionHeader('ASSIGNED SPEAKER', Icons.record_voice_over_rounded),
                                const SizedBox(height: 8),
                                _buildInfoCard([
                                  _buildInfoRow('Speaker Name', speakerName, Icons.person_outline_rounded),
                                  _buildInfoRow('Designation', speaker?.designation, Icons.work_outline_rounded),
                                  _buildInfoRow('Hospital / Organisation', speaker?.organisation, Icons.business_rounded),
                                  _buildInfoRow('Mobile', speaker?.mobile, Icons.phone_outlined, copyable: true),
                                  _buildInfoRow('Email', speaker?.email, Icons.mail_outline_rounded, copyable: true),
                                ]),
                                const SizedBox(height: 24),
                              ],
                            ],
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionAssignmentCard(int index, AdminSlotSessionAssignment sess) {
    final topic = sess.topic;
    final speaker = sess.speaker;
    final topicStatus = topic?.status ?? '';
    final isConfirmed = topicStatus.toLowerCase() == 'confirmed';
    final isApproved = topicStatus.toLowerCase() == 'approved';
    final displayTopicStatus = isConfirmed
        ? 'Slot Assigned'
        : (isApproved ? 'Slot Not Assigned' : (topicStatus.isNotEmpty ? topicStatus : 'Slot Assigned'));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment_turned_in_rounded, size: 15, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 6),
                    Text(
                      'ASSIGNMENT #${index + 1}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4338CA),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                if (displayTopicStatus.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayTopicStatus,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isConfirmed ? const Color(0xFF10B981) : const Color(0xFFD97706),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topic != null && topic.title.isNotEmpty) ...[
                  Text(
                    topic.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (topic.categoryOfSubmission.isNotEmpty || topic.presentationFormat.isNotEmpty) ...[
                    Row(
                      children: [
                        if (topic.categoryOfSubmission.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEECF9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              topic.categoryOfSubmission.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        if (topic.presentationFormat.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            topic.presentationFormat,
                            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
                if (speaker != null && speaker.fullName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEECF9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              speaker.fullName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (speaker.designation.isNotEmpty || speaker.organisation.isNotEmpty)
                              Text(
                                [speaker.designation, speaker.organisation].where((s) => s.isNotEmpty).join(' • '),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (speaker.mobile.isNotEmpty || speaker.email.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    if (speaker.mobile.isNotEmpty)
                      _buildInfoRow('Mobile', speaker.mobile, Icons.phone_outlined, copyable: true),
                    if (speaker.email.isNotEmpty)
                      _buildInfoRow('Email', speaker.email, Icons.mail_outline_rounded, copyable: true),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. ALL SLOTS INTERACTIVE SCHEDULE VIEWER
// ==========================================
class AdminAllSlotsSheet extends StatefulWidget {
  const AdminAllSlotsSheet({super.key});

  @override
  State<AdminAllSlotsSheet> createState() => _AdminAllSlotsSheetState();
}

class _AdminAllSlotsSheetState extends State<AdminAllSlotsSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedDay = 'All';
  String _selectedHall = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final admin = Provider.of<AdminProvider>(context, listen: false);
      if (admin.hallTracks.isEmpty) {
        admin.fetchSlots(auth.accessToken);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Groups tracks by day with filtering
  List<_GroupedDaySchedule> _buildFilteredGroupedDays(List<AdminHallTrack> tracks) {
    final Map<String, _GroupedDaySchedule> dayMap = {};
    final q = _searchQuery.trim().toLowerCase();

    for (final track in tracks) {
      final hallMatches = _selectedHall == 'All' ||
          track.hallName == _selectedHall ||
          track.hallLabel == _selectedHall ||
          track.hallId == _selectedHall;

      if (!hallMatches) continue;

      for (final day in track.days) {
        final dayKey = day.scheduleDay.isNotEmpty ? day.scheduleDay : '1';
        if (_selectedDay != 'All' && dayKey != _selectedDay) continue;

        // Filter slots by search query
        final matchingSlots = day.slots.where((s) {
          if (q.isNotEmpty) {
            final matchSlotName = s.slotName.toLowerCase().contains(q);
            final matchSlotNumber = s.slotNumber.toLowerCase().contains(q);
            final matchSlotLabel = s.slotLabel.toLowerCase().contains(q);
            final matchHallName = track.hallName.toLowerCase().contains(q);
            final matchHallLabel = track.hallLabel.toLowerCase().contains(q);
            final matchTopic = (s.topicTitle ?? '').toLowerCase().contains(q);
            final matchSpeaker = (s.speakerName ?? '').toLowerCase().contains(q);
            if (!matchSlotName &&
                !matchSlotNumber &&
                !matchSlotLabel &&
                !matchHallName &&
                !matchHallLabel &&
                !matchTopic &&
                !matchSpeaker) {
              return false;
            }
          }
          return true;
        }).toList();

        if (matchingSlots.isEmpty) continue;

        if (!dayMap.containsKey(dayKey)) {
          dayMap[dayKey] = _GroupedDaySchedule(
            dayNumber: dayKey,
            date: day.scheduleDate,
            halls: [],
          );
        }
        dayMap[dayKey]!.halls.add(_GroupedHallTrack(
          hallId: track.hallId,
          hallName: track.hallName,
          hallLabel: track.hallLabel,
          scheduleDate: day.scheduleDate,
          scheduleDay: day.scheduleDay,
          slots: matchingSlots,
        ));
      }
    }

    final sortedDays = dayMap.values.toList();
    sortedDays.sort((a, b) {
      final da = int.tryParse(a.dayNumber) ?? 0;
      final db = int.tryParse(b.dayNumber) ?? 0;
      return da.compareTo(db);
    });
    return sortedDays;
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tracks = admin.hallTracks;
    final groupedDays = _buildFilteredGroupedDays(tracks);

    // Collect all available Days and Halls for filters
    final Set<String> allDaysSet = {};
    final Set<String> allHallsSet = {};
    for (final track in tracks) {
      final hallDisplay = track.hallLabel.trim().isNotEmpty
          ? track.hallLabel.trim()
          : (track.hallName.trim().isNotEmpty ? track.hallName.trim() : 'Hall ${track.hallId}');
      if (hallDisplay.isNotEmpty) allHallsSet.add(hallDisplay);
      for (final day in track.days) {
        if (day.scheduleDay.isNotEmpty) allDaysSet.add(day.scheduleDay);
      }
    }
    final sortedDaysList = allDaysSet.toList()..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    int totalSlots = 0;
    int bookedSlots = 0;
    int cancelledSlots = 0;
    for (final day in groupedDays) {
      for (final hall in day.halls) {
        totalSlots += hall.slots.length;
        for (final s in hall.slots) {
          final st = s.slotStatus.toUpperCase();
          if (st == 'CANCELLED' || s.isCancelled) {
            cancelledSlots++;
          } else if (st != 'FREE' && st != 'UNASSIGNED' && (st == 'BOOKED' || st == 'ASSIGNED' || st == 'ALLOCATED' || s.isAssigned)) {
            bookedSlots++;
          }
        }
      }
    }
    final freeSlots = (totalSlots - bookedSlots - cancelledSlots).clamp(0, totalSlots);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC7D2FE), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_view_week_rounded, size: 14, color: Color(0xFF4F46E5)),
                          SizedBox(width: 5),
                          Text(
                            'AGENDA SLOTS SCHEDULE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 14, color: Color(0xFFF1F5F9)),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                decoration: InputDecoration(
                  hintText: 'Search slot, hall, or speaker...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF64748B)),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Pills: Day Filter Only
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All Days',
                  isSelected: _selectedDay == 'All',
                  onTap: () => setState(() => _selectedDay = 'All'),
                ),
                for (final d in sortedDaysList) ...[
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: 'Day $d',
                    isSelected: _selectedDay == d,
                    onTap: () => setState(() => _selectedDay = d),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Overall Summary Counter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Row(
              children: [
                Text(
                  '$totalSlots TOTAL SLOTS',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF65A30D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$freeSlots Free',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4D8F14), fontWeight: FontWeight.bold),
                    ),
                    if (cancelledSlots > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$cancelledSlots Cancelled',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                      ),
                    ],
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$bookedSlots Booked',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // All Slots List (Grouped by Day and Hall)
          Expanded(
            child: admin.isLoadingSlots && tracks.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : tracks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 36, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 10),
                            const Text('No slots available', style: TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => admin.fetchSlots(auth.accessToken, forceRefresh: true),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                              child: const Text('Refresh', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : groupedDays.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.filter_alt_off_rounded, size: 36, color: Color(0xFF94A3B8)),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'No slots match your search or filters.',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 14),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchCtrl.clear();
                                        _searchQuery = '';
                                        _selectedDay = 'All';
                                        _selectedHall = 'All';
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF4F46E5),
                                      side: const BorderSide(color: Color(0xFF4F46E5)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Reset Filters'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: groupedDays.length,
                            itemBuilder: (context, dayIndex) {
                              final day = groupedDays[dayIndex];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFBFD),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFEEF2F6), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Day Header
                                    Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4F46E5),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'D${day.dayNumber}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Day ${day.dayNumber}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            if (day.date.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                day.date,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                    const SizedBox(height: 10),

                                    // Halls under this Day
                                    ...day.halls.asMap().entries.map((entry) {
                                      final hIdx = entry.key;
                                      final hall = entry.value;
                                      final hallTitle = hall.hallLabel.trim().isNotEmpty
                                          ? hall.hallLabel.trim()
                                          : (hall.hallName.trim().isNotEmpty ? hall.hallName.trim() : 'Hall ${hall.hallId}');

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 8),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.apartment_rounded,
                                                  size: 16,
                                                  color: Color(0xFF4F46E5),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    hallTitle.isNotEmpty ? hallTitle : 'Hall ${hall.hallId}',
                                                    style: const TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF4338CA),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Slots Wrap
                                          if (hall.slots.isEmpty)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              child: Text(
                                                'No slots configured for this hall',
                                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                              ),
                                            )
                                          else
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                final double itemWidth = constraints.maxWidth > 500
                                                    ? (constraints.maxWidth - (8 * 3)) / 4
                                                    : (constraints.maxWidth - (8 * 2)) / 3;

                                                return Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: hall.slots.map((slot) {
                                                    final cleanStatus = slot.slotStatus.toUpperCase();
                                                    final isCancelled = cleanStatus == 'CANCELLED' || slot.isCancelled;
                                                    final isBooked = !isCancelled && (cleanStatus == 'BOOKED' || cleanStatus == 'ASSIGNED' || cleanStatus == 'ALLOCATED' || slot.isAssigned);
                                                    final rawSlotTitle = slot.slotLabel.trim().isNotEmpty
                                                        ? slot.slotLabel.trim()
                                                        : (slot.slotName.trim().isNotEmpty ? slot.slotName.trim() : 'Slot ${slot.slotNumber}');

                                                    // Clean title for card display
                                                    String cardSlotTitle = rawSlotTitle;
                                                    for (final delimiter in ['#', '|', '–', '—', '-']) {
                                                      if (cardSlotTitle.contains(delimiter)) {
                                                        final prefix = cardSlotTitle.split(delimiter)[0].trim();
                                                        if (prefix.isNotEmpty && prefix.length <= 10) {
                                                          cardSlotTitle = prefix;
                                                          break;
                                                        }
                                                      }
                                                    }
                                                    cardSlotTitle = cardSlotTitle.replaceAll('#', '').trim();
                                                    if (cardSlotTitle.isEmpty && slot.slotNumber.isNotEmpty) {
                                                      cardSlotTitle = 'Slot ${slot.slotNumber}';
                                                    }

                                                    final formattedStart = TimeFormatter.formatTime(slot.startTime);
                                                    final formattedEnd = TimeFormatter.formatTime(slot.endTime);
                                                    final timeStr = (formattedStart.isNotEmpty && formattedEnd.isNotEmpty)
                                                        ? '$formattedStart - $formattedEnd'
                                                        : (formattedStart.isNotEmpty ? formattedStart : (slot.startTime.isNotEmpty ? slot.startTime : ''));

                                                    return Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () {
                                                          showAdminSlotDetailsModal(
                                                            context,
                                                            slotId: slot.slotId,
                                                            initialSlot: slot,
                                                            hallId: hall.hallId,
                                                            hallName: hall.hallName,
                                                            hallLabel: hall.hallLabel,
                                                            scheduleDate: hall.scheduleDate,
                                                            scheduleDay: hall.scheduleDay,
                                                          );
                                                        },
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: AnimatedContainer(
                                                          duration: const Duration(milliseconds: 150),
                                                          width: itemWidth,
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                                          decoration: BoxDecoration(
                                                            color: isCancelled
                                                                ? const Color(0xFFFEF2F2)
                                                                : (isBooked ? const Color(0xFFFFFBEB) : const Color(0xFFF1FCE8)),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: isCancelled
                                                                  ? const Color(0xFFFECACA)
                                                                  : (isBooked ? const Color(0xFFFDE68A) : const Color(0xFF84CC16)),
                                                              width: 1.1,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                cardSlotTitle,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: isCancelled
                                                                      ? const Color(0xFF991B1B)
                                                                      : (isBooked ? const Color(0xFF92400E) : const Color(0xFF2E6B08)),
                                                                ),
                                                                textAlign: TextAlign.center,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              if (timeStr.isNotEmpty) ...[
                                                                const SizedBox(height: 2),
                                                                Text(
                                                                  timeStr,
                                                                  style: TextStyle(
                                                                    fontSize: 8.5,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: isCancelled
                                                                        ? const Color(0xFFB91C1C)
                                                                        : (isBooked ? const Color(0xFF78350F) : const Color(0xFF3F6212)),
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ],
                                                              const SizedBox(height: 3),
                                                              Text(
                                                                isCancelled ? 'CANCELLED' : (isBooked ? 'BOOKED' : 'FREE'),
                                                                style: TextStyle(
                                                                  fontSize: 9.5,
                                                                  fontWeight: FontWeight.w800,
                                                                  color: isCancelled
                                                                      ? const Color(0xFFDC2626)
                                                                      : (isBooked ? const Color(0xFFD97706) : const Color(0xFF4D8F14)),
                                                                  letterSpacing: 0.4,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                );
                                              },
                                            ),
                                          if (hIdx < day.halls.length - 1)
                                            const SizedBox(height: 12),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = const Color(0xFF4F46E5),
    Color activeBgColor = const Color(0xFFEEF2FF),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _GroupedDaySchedule {
  final String dayNumber;
  final String date;
  final List<_GroupedHallTrack> halls;

  _GroupedDaySchedule({
    required this.dayNumber,
    required this.date,
    required this.halls,
  });
}

class _GroupedHallTrack {
  final String hallId;
  final String hallName;
  final String hallLabel;
  final String scheduleDate;
  final String scheduleDay;
  final List<AdminSlotItem> slots;

  _GroupedHallTrack({
    required this.hallId,
    required this.hallName,
    required this.hallLabel,
    required this.scheduleDate,
    required this.scheduleDay,
    required this.slots,
  });
}


// ==========================================
// SHARED HELPER WIDGETS FOR SHEETS
// ==========================================

Widget _buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 14, color: const Color(0xFF64748B)),
      const SizedBox(width: 6),
      Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
          color: Color(0xFF64748B),
        ),
      ),
    ],
  );
}

Widget _buildInfoCard(List<Widget> rows) {
  final validRows = rows.where((w) => w is! SizedBox).toList();
  if (validRows.isEmpty) return const SizedBox.shrink();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < validRows.length; i++) ...[
          validRows[i],
          if (i < validRows.length - 1) const Divider(height: 16, color: Color(0xFFF1F5F9)),
        ],
      ],
    ),
  );
}

Widget _buildInfoRow(String label, String? value, IconData icon, {bool copyable = false}) {
  if (value == null || value.trim().isEmpty || value.trim() == 'NA' || value.trim() == 'null') {
    return const SizedBox.shrink();
  }

  return Builder(
    builder: (context) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF94A3B8)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value.trim()));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied $label to clipboard'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      );
    },
  );
}

Widget _buildBadge(String text, Color textColor, Color bgColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    ),
  );
}

// ==========================================
// 8. FOOTFALL PARTICIPANT DETAILS BOTTOM SHEET
// ==========================================
class AdminFootfallParticipantDetailSheet extends StatelessWidget {
  final AdminFootfallParticipant participant;

  const AdminFootfallParticipantDetailSheet({
    super.key,
    required this.participant,
  });

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'DR';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'DR';
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$label copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(participant.name);
    final isSpeaker = participant.role.toUpperCase() == 'SK' ||
        participant.roleLabel.toLowerCase().contains('speaker');

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header with Avatar & Details
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSpeaker
                          ? [const Color(0xFF7C3AED), const Color(0xFF9333EA)]
                          : [const Color(0xFF0D9488), const Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSpeaker ? const Color(0xFF9333EA) : const Color(0xFF059669))
                            .withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.name.isNotEmpty ? participant.name : 'Attendee',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isSpeaker ? const Color(0xFFF3E8FF) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSpeaker ? const Color(0xFFD8B4FE) : const Color(0xFFA7F3D0),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              participant.roleLabel.isNotEmpty
                                  ? participant.roleLabel
                                  : (isSpeaker ? 'Speaker' : 'Delegate'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSpeaker ? const Color(0xFF7E22CE) : const Color(0xFF047857),
                              ),
                            ),
                          ),
                          if (participant.visitCount > 1) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
                              ),
                              child: Text(
                                '${participant.visitCount} Visits',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Visit Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          participant.boothLabel.isNotEmpty
                              ? 'Visited ${participant.boothLabel}${participant.boothNumber.isNotEmpty ? " (${participant.boothNumber})" : ""}'
                              : (participant.boothNumber.isNotEmpty
                                  ? 'Visited ${participant.boothNumber}'
                                  : 'Booth Footfall Recorded'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${TimeFormatter.formatDate(participant.visitedDate)} at ${TimeFormatter.formatTime(participant.visitedTime)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Professional Details Section
            const Text(
              'PROFESSIONAL DETAILS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildDetailRow('Designation', participant.designation, Icons.badge_outlined),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  _buildDetailRow('Organisation', participant.organisation, Icons.business_outlined),
                  if (participant.city.isNotEmpty) ...[
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('City', participant.city, Icons.location_on_outlined),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contact Details Section
            const Text(
              'CONTACT INFORMATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  if (participant.mobile.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mobile Number', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                              Text(participant.mobile, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
                          onPressed: () => _copyToClipboard(context, participant.mobile, 'Mobile number'),
                        ),
                      ],
                    ),
                  if (participant.mobile.isNotEmpty && participant.email.isNotEmpty)
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  if (participant.email.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.mail_outline_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email Address', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                              Text(participant.email, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
                          onPressed: () => _copyToClipboard(context, participant.email, 'Email address'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Not Provided',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
