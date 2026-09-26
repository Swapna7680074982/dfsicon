import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exhibitor_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/home_provider.dart';

class ExhibitorScannerModal extends StatefulWidget {
  final dynamic defaultBoothId;
  final String? defaultBoothLabel;

  const ExhibitorScannerModal({
    super.key,
    this.defaultBoothId,
    this.defaultBoothLabel,
  });

  static Future<void> show(
    BuildContext context, {
    dynamic defaultBoothId,
    String? defaultBoothLabel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExhibitorScannerModal(
        defaultBoothId: defaultBoothId,
        defaultBoothLabel: defaultBoothLabel,
      ),
    );
  }

  @override
  State<ExhibitorScannerModal> createState() => _ExhibitorScannerModalState();
}

class _ExhibitorScannerModalState extends State<ExhibitorScannerModal>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  final TextEditingController _inputCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animCtrl;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCaptureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        // When photo is captured, prompt user or auto-verify badge
        _showQuickVerificationPrompt(photo.name);
      }
    } catch (e) {
      debugPrint('Error picking camera image: $e');
    }
  }

  void _showQuickVerificationPrompt(String filename) {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Badge Scanned', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the attendee mobile number or Badge ID from the scanned badge to record footfall:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. 9951335682 or 2',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = ctrl.text.trim();
                Navigator.pop(ctx);
                if (text.isNotEmpty) {
                  _processAttendeeCheckIn(text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Record Visit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processAttendeeCheckIn(String rawValue, {dynamic delegateUserId}) async {
    if (_isProcessing || !mounted) return;
    if (rawValue.trim().isEmpty && delegateUserId == null) return;

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final exhibitor = Provider.of<ExhibitorProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);

    final summitId = home.summits.isNotEmpty
        ? home.summits.first['summit_id'] ?? 1
        : 1;

    dynamic parsedUserId = delegateUserId;
    String cleanText = rawValue.trim();

    final result = await exhibitor.recordScan(
      auth.accessToken,
      summitId: summitId,
      boothId: widget.defaultBoothId ?? exhibitor.selectedBoothId,
      qrData: cleanText.isNotEmpty ? cleanText : (parsedUserId?.toString() ?? ''),
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    _showScanResultDialog(result, cleanText.isNotEmpty ? cleanText : 'Delegate ID: $parsedUserId');
  }

  void _showScanResultDialog(Map<String, dynamic> result, String scannedText) {
    final bool isOffline = result['isOffline'] == true;
    final bool isSuccess = result['status'] == true;
    final String message = result['message']?.toString() ??
        (isOffline
            ? 'Visit saved offline. Will sync when network connects.'
            : (isSuccess ? 'Visitor check-in recorded successfully!' : 'Could not record visitor'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final iconColor = isOffline
            ? const Color(0xFFD97706)
            : (isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444));
        final bgColor = isOffline
            ? const Color(0xFFFFFBEB)
            : (isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2));
        final icon = isOffline
            ? Icons.cloud_done_rounded
            : (isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded);
        final title = isOffline
            ? 'Saved Offline'
            : (isSuccess ? 'Check-in Recorded!' : 'Check-in Notice');

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor,
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.badge_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          scannedText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _inputCtrl.clear();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Scan Next',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final admin = Provider.of<AdminProvider>(context);

    return Container(
      height: size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle & Top Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Color(0xFF818CF8),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Record Visitor Check-In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.defaultBoothLabel != null
                                  ? 'Booth: ${widget.defaultBoothLabel}'
                                  : 'Log attendee footfall & view visited profile',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Viewfinder HUD Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155), width: 1.2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Corner accents
                Positioned(top: 14, left: 14, child: _buildCorner(isTop: true, isLeft: true)),
                Positioned(top: 14, right: 14, child: _buildCorner(isTop: true, isLeft: false)),
                Positioned(bottom: 14, left: 14, child: _buildCorner(isTop: false, isLeft: true)),
                Positioned(bottom: 14, right: 14, child: _buildCorner(isTop: false, isLeft: false)),

                // Animated Laser line
                AnimatedBuilder(
                  animation: _laserAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 20 + (_laserAnimation.value * 150),
                      left: 30,
                      right: 30,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF818CF8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Center Icon & Instructions
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Color(0xFF818CF8),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready to Record Attendee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enter mobile, badge code, or pick photo below',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                // Camera Pick Button Top Right
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: _handleCaptureFromCamera,
                    icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF818CF8), size: 22),
                    tooltip: 'Capture Badge Photo',
                  ),
                ),
              ],
            ),
          ),

          // Input Form Box
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        _processAttendeeCheckIn(val);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Mobile No or Attendee ID...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF818CF8), size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF818CF8), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            final text = _inputCtrl.text.trim();
                            if (text.isNotEmpty) {
                              _processAttendeeCheckIn(text);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Check-In',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Delegate Directory Lookup
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'QUICK SELECT ATTENDEE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  '${admin.delegates.length} Available',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: admin.delegates.take(15).length,
              itemBuilder: (context, index) {
                final del = admin.delegates[index];
                final initials = del.fullName.trim().isNotEmpty
                    ? del.fullName.trim().split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join().toUpperCase()
                    : 'DL';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
                      ),
                    ),
                    title: Text(
                      del.fullName.isNotEmpty ? del.fullName : 'Delegate',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      [del.designation, del.organisationName, del.city].where((s) => s.isNotEmpty).join(' • '),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                              _processAttendeeCheckIn(
                                del.mobile.isNotEmpty ? del.mobile : del.userId.toString(),
                                delegateUserId: del.userId,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                        foregroundColor: const Color(0xFF818CF8),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Record', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFF818CF8), width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFF818CF8), width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFF818CF8), width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFF818CF8), width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
