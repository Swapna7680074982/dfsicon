import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exhibitor_provider.dart';
import '../../providers/home_provider.dart';

class ExhibitorLiveScannerScreen extends StatefulWidget {
  final dynamic defaultBoothId;
  final String? defaultBoothLabel;

  const ExhibitorLiveScannerScreen({
    super.key,
    this.defaultBoothId,
    this.defaultBoothLabel,
  });

  @override
  State<ExhibitorLiveScannerScreen> createState() => _ExhibitorLiveScannerScreenState();
}

class _ExhibitorLiveScannerScreenState extends State<ExhibitorLiveScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _controller;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  late AnimationController _laserAnimCtrl;
  late Animation<double> _laserAnim;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _laserAnim = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserAnimCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserAnimCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    _controller.toggleTorch();
  }

  Future<void> _handleBarcodeDetected(String rawCode) async {
    if (_isProcessing || !mounted) return;
    final cleanCode = rawCode.trim();
    if (cleanCode.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.heavyImpact();

    // Show popup with scan details and Submit option (don't submit directly)
    await _showScanConfirmationModal(cleanCode);
  }

  Widget _buildFormattedScannedText(String code) {
    final lines = code.split('\n');
    final bool hasKeyValues = lines.any((l) => l.contains(':'));

    if (!hasKeyValues) {
      return Text(
        code,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
          letterSpacing: 0.2,
          height: 1.35,
        ),
      );
    }

    final List<Widget> items = [];
    bool inSummitSection = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        if (!inSummitSection) {
          items.add(const SizedBox(height: 8));
          items.add(const Divider(height: 1, color: Color(0xFFE2E8F0)));
          items.add(const SizedBox(height: 8));
          inSummitSection = true;
        }
        continue;
      }

      final colonIdx = line.indexOf(':');
      if (colonIdx > 0) {
        final key = line.substring(0, colonIdx).trim();
        final value = line.substring(colonIdx + 1).trim();
        final lowerKey = key.toLowerCase();

        Color keyColor = const Color(0xFF475569);
        Color valColor = const Color(0xFF0F172A);
        IconData? icon;

        if (lowerKey.contains('name')) {
          keyColor = const Color(0xFF1E293B);
          valColor = const Color(0xFF0F172A);
          icon = Icons.person_rounded;
        } else if (lowerKey.contains('mobile') || lowerKey.contains('phone')) {
          keyColor = const Color(0xFF475569);
          valColor = const Color(0xFF2563EB);
          icon = Icons.phone_android_rounded;
        } else if (lowerKey.contains('country')) {
          keyColor = const Color(0xFF475569);
          valColor = const Color(0xFF0F172A);
          icon = Icons.public_rounded;
        } else if (lowerKey.contains('role')) {
          keyColor = const Color(0xFF475569);
          icon = Icons.badge_outlined;
        } else if (lowerKey.contains('user id') || lowerKey == 'id') {
          keyColor = const Color(0xFF64748B);
          valColor = const Color(0xFF334155);
          icon = Icons.tag_rounded;
        } else if (lowerKey.contains('qr data') || lowerKey.contains('badge')) {
          keyColor = const Color(0xFF4F46E5);
          valColor = const Color(0xFF4338CA);
          icon = Icons.qr_code_2_rounded;
        } else if (lowerKey.contains('summit')) {
          keyColor = const Color(0xFF1E293B);
          valColor = const Color(0xFF0F172A);
          icon = Icons.apartment_rounded;
        } else if (lowerKey.contains('date')) {
          keyColor = const Color(0xFF64748B);
          valColor = const Color(0xFF059669);
          icon = Icons.event_note_rounded;
        }

        Widget valueWidget;
        if (lowerKey.contains('role')) {
          final r = value.toLowerCase();
          Color rBg = const Color(0xFFEEF2FF);
          Color rColor = const Color(0xFF4F46E5);
          Color rBorder = const Color(0xFFC7D2FE);
          if (r.contains('speaker')) {
            rBg = const Color(0xFFF5F3FF);
            rColor = const Color(0xFF7C3AED);
            rBorder = const Color(0xFFDDD6FE);
          } else if (r.contains('delegate') || r.contains('attendee')) {
            rBg = const Color(0xFFECFDF5);
            rColor = const Color(0xFF059669);
            rBorder = const Color(0xFFA7F3D0);
          } else if (r.contains('exhibitor') || r.contains('sponsor')) {
            rBg = const Color(0xFFFFFBEB);
            rColor = const Color(0xFFD97706);
            rBorder = const Color(0xFFFDE68A);
          } else if (r.contains('faculty') || r.contains('vip')) {
            rBg = const Color(0xFFFEF2F2);
            rColor = const Color(0xFFDC2626);
            rBorder = const Color(0xFFFECDD3);
          }
          valueWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: rBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: rBorder),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: rColor,
              ),
            ),
          );
        } else if (lowerKey.contains('qr data')) {
          valueWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4F46E5),
                letterSpacing: 0.3,
              ),
            ),
          );
        } else {
          valueWidget = Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valColor,
              height: 1.25,
            ),
          );
        }

        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 6),
                    child: Icon(icon, size: 14, color: keyColor.withValues(alpha: 0.8)),
                  ),
                ],
                SizedBox(
                  width: 76,
                  child: Text(
                    key,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: keyColor,
                    ),
                  ),
                ),
                const Text(
                  ' :  ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Expanded(child: valueWidget),
              ],
            ),
          ),
        );
      } else {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              line,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Future<void> _showScanConfirmationModal(String scannedCode) async {
    final exhibitor = Provider.of<ExhibitorProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);

    final String boothDisplay = widget.defaultBoothLabel ??
        (widget.defaultBoothId != null ? 'Booth #${widget.defaultBoothId}' : 'Default Booth');
    final remarksCtrl = TextEditingController();
    bool isSubmitting = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFC7D2FE)),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 24,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Badge Scanned',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Verify details before recording visit',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: isSubmitting ? null : () => Navigator.pop(ctx, false),
                              icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                              splashRadius: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Scanned Code Detail Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SCANNED DATA / BADGE ID',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildFormattedScannedText(scannedCode),
                              if (boothDisplay.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFFD97706)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Booth: $boothDisplay',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Optional Remarks
                        TextField(
                          controller: remarksCtrl,
                          decoration: InputDecoration(
                            labelText: 'Notes / Remarks (Optional)',
                            hintText: 'e.g. Requested catalog, Product interest...',
                            hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.note_alt_outlined, size: 18, color: Color(0xFF64748B)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons (Submit & Cancel)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSubmitting ? null : () => Navigator.pop(ctx, false),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        setModalState(() => isSubmitting = true);
                                        final summitId = home.summits.isNotEmpty
                                            ? home.summits.first['summit_id'] ?? 1
                                            : 1;

                                        final result = await exhibitor.recordScan(
                                          auth.accessToken,
                                          qrData: scannedCode,
                                          boothId: widget.defaultBoothId ?? exhibitor.selectedBoothId,
                                          remarks: remarksCtrl.text.trim(),
                                          summitId: summitId,
                                        );

                                        if (mounted) {
                                          Navigator.pop(ctx, true);
                                          _showAutoSuccessModal(result, scannedCode);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  elevation: 2,
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                                          SizedBox(width: 6),
                                          Text(
                                            'Submit & Record',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true && mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showAutoSuccessModal(Map<String, dynamic> result, String scannedText) {
    final bool isOffline = result['isOffline'] == true;
    final bool isSuccess = result['status'] == true;
    final data = result['data'] is Map<String, dynamic> ? result['data'] as Map<String, dynamic> : null;
    final String rawMsg = result['message']?.toString() ?? '';
    final bool isDuplicate = data?['duplicate'] == true ||
        rawMsg.toLowerCase().contains('already') ||
        rawMsg.toLowerCase().contains('duplicate');

    final String message = rawMsg.isNotEmpty
        ? rawMsg
        : (isOffline
            ? 'Visit saved offline. Will sync automatically when network connects.'
            : (isDuplicate
                ? 'Already scanned moments ago'
                : (isSuccess ? 'Scan recorded successfully!' : 'Could not record visitor')));

    final String? visitorName = data?['visitor_name']?.toString();
    final String? visitorRole = data?['visitor_role']?.toString();

    final iconColor = isOffline
        ? const Color(0xFFD97706)
        : (isDuplicate
            ? const Color(0xFFD97706)
            : (isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444)));
    final bgColor = isOffline
        ? const Color(0xFFFFFBEB)
        : (isDuplicate
            ? const Color(0xFFFFFBEB)
            : (isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2)));
    final borderColor = isOffline
        ? const Color(0xFFFDE68A)
        : (isDuplicate
            ? const Color(0xFFFDE68A)
            : (isSuccess ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3)));
    final icon = isOffline
        ? Icons.cloud_done_rounded
        : (isDuplicate
            ? Icons.info_outline_rounded
            : (isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded));
    final title = isOffline
        ? 'Saved Offline'
        : (isDuplicate
            ? 'Already Scanned'
            : (isSuccess ? 'Scan Recorded!' : 'Notice'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success/Notice Indicator Icon
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                      border: Border.all(
                        color: borderColor,
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOffline || isDuplicate
                            ? const Color(0xFFB45309)
                            : (isSuccess ? const Color(0xFF047857) : const Color(0xFFB91C1C)),
                        height: 1.35,
                      ),
                    ),
                  ),

                  // If visitor details returned from API
                  if (visitorName != null && visitorName.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCFCE7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF16A34A)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  visitorName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                if (visitorRole != null && visitorRole.isNotEmpty)
                                  Text(
                                    'Role: $visitorRole',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    // Scanned payload pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              scannedText.replaceAll('\n', ' ').trim(),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Action Buttons (Scan Next / Done)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context); // Exit scanner
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          ),
                          child: const Text(
                            'View History',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _isProcessing = false; // Resume scanning immediately
                            });
                          },
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: Colors.white),
                          label: const Text(
                            'Scan Next',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showManualEntryModal() {
    final textCtrl = TextEditingController();
    bool isSubmitting = false;
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.phone_android_rounded, color: Color(0xFF4F46E5), size: 22),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Manual Mobile Entry',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter attendee 10-digit mobile number to log their visit manually.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: textCtrl,
                          autofocus: true,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          decoration: InputDecoration(
                            hintText: 'e.g. 9876543210',
                            hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF4F46E5), size: 20),
                            errorText: errorText,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                            ),
                          ),
                          onChanged: (val) {
                            if (errorText != null) {
                              setModalState(() => errorText = null);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final query = textCtrl.text.trim();
                                    if (query.isEmpty) {
                                      setModalState(() {
                                        errorText = 'Please enter mobile number';
                                      });
                                      return;
                                    }
                                    setModalState(() {
                                      isSubmitting = true;
                                    });
                                    Navigator.pop(ctx);
                                    await _handleBarcodeDetected(query);
                                  },
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check_circle_rounded, size: 18),
                            label: Text(
                              isSubmitting ? 'Recording...' : 'Record Visit',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanWindowSize = size.width * 0.74;
    final bottomNavInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera Stream
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              if (_isProcessing) return;
              for (final barcode in capture.barcodes) {
                final String? code = barcode.rawValue;
                if (code != null && code.isNotEmpty) {
                  _handleBarcodeDetected(code);
                  break;
                }
              }
            },
          ),

          // Transparent Cutout Overlay (Reliable CustomPainter)
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                scanWindowSize: scanWindowSize,
                borderRadius: 24.0,
                overlayColor: Colors.black.withValues(alpha: 0.65),
              ),
            ),
          ),

          // Viewfinder Frame & Animated Laser
          Center(
            child: SizedBox(
              width: scanWindowSize,
              height: scanWindowSize,
              child: Stack(
                children: [
                  // Corner accents
                  Positioned(top: 0, left: 0, child: _buildCorner(isTop: true, isLeft: true)),
                  Positioned(top: 0, right: 0, child: _buildCorner(isTop: true, isLeft: false)),
                  Positioned(bottom: 0, left: 0, child: _buildCorner(isTop: false, isLeft: true)),
                  Positioned(bottom: 0, right: 0, child: _buildCorner(isTop: false, isLeft: false)),

                  // Animated Scanning Laser Line
                  AnimatedBuilder(
                    animation: _laserAnim,
                    builder: (context, child) {
                      return Positioned(
                        top: _laserAnim.value * scanWindowSize,
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF6366F1), Color(0xFF38BDF8)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.9),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  if (_isProcessing)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B981),
                          strokeWidth: 3.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Top App Bar Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront_rounded, size: 15, color: Color(0xFF818CF8)),
                        const SizedBox(width: 6),
                        Text(
                          widget.defaultBoothLabel ?? 'DFSICON Booth',
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _showManualEntryModal,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.keyboard_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleTorch,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isTorchOn ? const Color(0xFFFBBF24) : Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: _isTorchOn ? Colors.black : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Instruction & Manual Entry Bar
          Positioned(
            bottom: 24 + bottomNavInset,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.center_focus_strong_rounded, color: Color(0xFF818CF8), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Align QR code inside frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _showManualEntryModal,
                    icon: const Icon(Icons.dialpad_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'Manual Entry (Mobile No)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFF818CF8), width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFF818CF8), width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFF818CF8), width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFF818CF8), width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}

/// Overlay painter that draws a dimmed black background with a rounded transparent cutout
class ScannerOverlayPainter extends CustomPainter {
  final double scanWindowSize;
  final double borderRadius;
  final Color overlayColor;

  ScannerOverlayPainter({
    required this.scanWindowSize,
    required this.borderRadius,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanRect,
          Radius.circular(borderRadius),
        ),
      );

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindowSize != scanWindowSize ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.overlayColor != overlayColor;
  }
}
