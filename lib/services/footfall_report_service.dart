import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border;
import '../constants/colors.dart';
import '../models/exhibitor_models.dart';
import '../providers/admin_provider.dart';
import '../utils/custom_logger.dart';
import '../utils/time_formatter.dart';
import 'documents_service.dart';

enum FootfallReportFilter { all, speakers, delegates }

class FootfallReportService {
  FootfallReportService._();

  /// Generate and download Excel (.xlsx) report for Exhibitor Portal participants
  static Future<File?> downloadExhibitorReport({
    required BuildContext context,
    required List<ExhibitorParticipant> participants,
    required FootfallReportFilter filter,
    String? companyName,
    String? boothLabel,
  }) async {
    final filtered = participants.where((p) {
      final isSpeaker = p.role.toUpperCase() == 'SK' || p.roleLabel.toLowerCase().contains('speaker');
      if (filter == FootfallReportFilter.speakers) return isSpeaker;
      if (filter == FootfallReportFilter.delegates) return !isSpeaker;
      return true;
    }).toList();

    return _generateAndSaveXlsx(
      context: context,
      titlePrefix: companyName?.isNotEmpty == true ? companyName! : 'Exhibitor',
      filter: filter,
      rows: filtered.map((p) => [
        p.name,
        p.roleLabel.isNotEmpty ? p.roleLabel : (p.role == 'SK' ? 'Speaker' : 'Delegate'),
        p.designation,
        p.organisation,
        p.city,
        p.mobile,
        p.email,
        p.boothLabel.isNotEmpty ? p.boothLabel : (boothLabel ?? ''),
        p.boothNumber,
        p.visitedDate.isNotEmpty ? TimeFormatter.formatDate(p.visitedDate) : '',
        p.visitedTime.isNotEmpty ? TimeFormatter.formatTime(p.visitedTime) : '',
        p.visitCount.toString(),
      ]).toList(),
    );
  }

  /// Generate and download Excel (.xlsx) report for Admin Footfall participants
  static Future<File?> downloadAdminFootfallReport({
    required BuildContext context,
    required List<AdminFootfallParticipant> participants,
    required FootfallReportFilter filter,
    String? sponsorName,
  }) async {
    final filtered = participants.where((p) {
      final isSpeaker = p.role.toUpperCase() == 'SK' || p.roleLabel.toLowerCase().contains('speaker');
      if (filter == FootfallReportFilter.speakers) return isSpeaker;
      if (filter == FootfallReportFilter.delegates) return !isSpeaker;
      return true;
    }).toList();

    return _generateAndSaveXlsx(
      context: context,
      titlePrefix: sponsorName?.isNotEmpty == true ? sponsorName! : 'DFSICON_Admin',
      filter: filter,
      rows: filtered.map((p) => [
        p.name,
        p.roleLabel.isNotEmpty ? p.roleLabel : (p.role == 'SK' ? 'Speaker' : 'Delegate'),
        p.designation,
        p.organisation,
        p.city,
        p.mobile,
        p.email,
        p.boothLabel,
        p.boothNumber,
        p.visitedDate.isNotEmpty ? TimeFormatter.formatDate(p.visitedDate) : '',
        p.visitedTime.isNotEmpty ? TimeFormatter.formatTime(p.visitedTime) : '',
        p.visitCount.toString(),
      ]).toList(),
    );
  }

  static Future<File?> _generateAndSaveXlsx({
    required BuildContext context,
    required String titlePrefix,
    required FootfallReportFilter filter,
    required List<List<String>> rows,
  }) async {
    try {
      final filterLabel = filter == FootfallReportFilter.speakers
          ? 'Speakers'
          : (filter == FootfallReportFilter.delegates ? 'Delegates' : 'All_Visitors');

      final now = DateTime.now();
      final dateSlug = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final cleanPrefix = titlePrefix.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'\s+'), '_');
      final fileName = '${cleanPrefix}_Footfall_${filterLabel}_$dateSlug.xlsx';

      final dir = await DocumentsService.getDocumentsDirectory();
      if (dir == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not access storage directory')),
          );
        }
        return null;
      }

      final filePath = '${dir.path}/$fileName';
      final targetFile = File(filePath);

      // Create Excel Workbook (.xlsx)
      final excel = Excel.createExcel();
      const sheetName = 'Footfall_Report';
      final sheet = excel[sheetName];
      excel.setDefaultSheet(sheetName);
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Append Header Row
      final headers = [
        'S.No',
        'Attendee Name',
        'Role',
        'Designation',
        'Hospital / Organisation',
        'City',
        'Mobile Number',
        'Email Address',
        'Booth Label',
        'Booth Number',
        'Visit Date',
        'Visit Time',
        'Visit Count',
      ];

      sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

      // Append Data Rows
      for (int i = 0; i < rows.length; i++) {
        final r = rows[i];
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(r[0]),
          TextCellValue(r[1]),
          TextCellValue(r[2]),
          TextCellValue(r[3]),
          TextCellValue(r[4]),
          TextCellValue(r[5]),
          TextCellValue(r[6]),
          TextCellValue(r[7]),
          TextCellValue(r[8]),
          TextCellValue(r[9]),
          TextCellValue(r[10]),
          IntCellValue(int.tryParse(r[11]) ?? 1),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Failed to encode Excel file');
      }

      await targetFile.writeAsBytes(bytes);

      // On Android, also write copy to /storage/emulated/0/Download/ so it appears in phone's main Downloads
      if (Platform.isAndroid) {
        try {
          final mainDownload = File('/storage/emulated/0/Download/$fileName');
          await mainDownload.writeAsBytes(bytes);
        } catch (_) {}
      }

      CustomLogger.logInfo('Saved Footfall Excel Report to: $filePath');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Excel Report Downloaded successfully',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      return targetFile;
    } catch (e, stack) {
      CustomLogger.logError('FootfallReportService', 'Error saving report: $e', stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate Excel report: $e')),
        );
      }
      return null;
    }
  }

  /// Show the Report Selection Bottom Sheet with Download option
  static void showDownloadReportModal({
    required BuildContext context,
    required int totalCount,
    required int speakersCount,
    required int delegatesCount,
    required Future<void> Function(FootfallReportFilter selectedFilter) onDownload,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        FootfallReportFilter selected = FootfallReportFilter.all;
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomNavInset = MediaQuery.of(context).padding.bottom;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomNavInset),
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
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.table_chart_rounded, color: Color(0xFF059669), size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Footfall Reports (Excel)',
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
                    'Export attendees in Microsoft Excel (.xlsx) format directly to your device downloads.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Storage Path Card inside report screen
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open_rounded, size: 16, color: Color(0xFF059669)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            Platform.isAndroid
                                ? 'Path: Download/DFSICON/ (Excel .xlsx)'
                                : 'Path: On My Device/DFSICON/ (Excel .xlsx)',
                            style: const TextStyle(
                              fontSize: 11.5,
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
                  const SizedBox(height: 14),

                  // Option 1: Both (All)
                  _buildReportOption(
                    title: 'All Attendees (Speakers & Delegates)',
                    count: totalCount,
                    isSelected: selected == FootfallReportFilter.all,
                    icon: Icons.groups_rounded,
                    accentColor: const Color(0xFF4F46E5),
                    bgColor: const Color(0xFFEEF2FF),
                    onTap: () => setModalState(() => selected = FootfallReportFilter.all),
                  ),
                  const SizedBox(height: 10),

                  // Option 2: Speakers Only
                  _buildReportOption(
                    title: 'Speakers Only',
                    count: speakersCount,
                    isSelected: selected == FootfallReportFilter.speakers,
                    icon: Icons.record_voice_over_rounded,
                    accentColor: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                    onTap: () => setModalState(() => selected = FootfallReportFilter.speakers),
                  ),
                  const SizedBox(height: 10),

                  // Option 3: Delegates Only
                  _buildReportOption(
                    title: 'Delegates Only',
                    count: delegatesCount,
                    isSelected: selected == FootfallReportFilter.delegates,
                    icon: Icons.badge_outlined,
                    accentColor: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                    onTap: () => setModalState(() => selected = FootfallReportFilter.delegates),
                  ),

                  const SizedBox(height: 20),

                  // Single Download Action Button (Full Width)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: (isProcessing || totalCount == 0)
                          ? null
                          : () async {
                              setModalState(() => isProcessing = true);
                              Navigator.pop(ctx);
                              await onDownload(selected);
                            },
                      icon: isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.file_download_rounded, size: 20),
                      label: Text(
                        isProcessing ? 'Downloading...' : 'Download Report (.xlsx)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
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

  static Widget _buildReportOption({
    required String title,
    required int count,
    required bool isSelected,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? bgColor.withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? accentColor : AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? accentColor : const Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
