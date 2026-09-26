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

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final exhibitor = Provider.of<ExhibitorProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);

    final summitId = home.summits.isNotEmpty
        ? home.summits.first['summit_id'] ?? 1
        : 1;

    final result = await exhibitor.recordScan(
      auth.accessToken,
      qrData: cleanCode,
      boothId: widget.defaultBoothId ?? exhibitor.selectedBoothId,
      summitId: summitId,
    );

    if (!mounted) return;

    _showAutoSuccessModal(result, cleanCode);
  }

  void _showAutoSuccessModal(Map<String, dynamic> result, String scannedText) {
    final bool isOffline = result['isOffline'] == true;
    final bool isSuccess = result['status'] == true;
    final String message = result['message']?.toString() ??
        (isOffline
            ? 'Visit saved offline. Will sync automatically when network connects.'
            : (isSuccess ? 'Scan recorded successfully!' : 'Could not record visitor'));

    final data = result['data'] is Map<String, dynamic> ? result['data'] as Map<String, dynamic> : null;
    final String? visitorName = data?['visitor_name']?.toString();
    final String? visitorRole = data?['visitor_role']?.toString();

    final iconColor = isOffline
        ? const Color(0xFFD97706)
        : (isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444));
    final bgColor = isOffline
        ? const Color(0xFFFFFBEB)
        : (isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2));
    final borderColor = isOffline
        ? const Color(0xFFFDE68A)
        : (isSuccess ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3));
    final icon = isOffline
        ? Icons.cloud_done_rounded
        : (isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded);
    final title = isOffline
        ? 'Saved Offline'
        : (isSuccess ? 'Scan Recorded!' : 'Notice');

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).padding.bottom;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, 28 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

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
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isOffline ? const Color(0xFFB45309) : (isSuccess ? const Color(0xFF047857) : AppColors.textSecondary),
                  height: 1.35,
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManualEntryModal() {
    final textCtrl = TextEditingController();
    bool isSubmitting = false;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final navInset = MediaQuery.of(context).padding.bottom;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset + navInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
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
                  const SizedBox(height: 6),
                  const Text(
                    'Enter attendee 10-digit mobile number to log their visit manually.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 18),
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
