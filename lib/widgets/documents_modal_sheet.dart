import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/summit_document.dart';
import '../providers/auth_provider.dart';
import '../services/documents_service.dart';

class DocumentsModalSheet extends StatefulWidget {
  final String roleCode;

  const DocumentsModalSheet({
    super.key,
    required this.roleCode,
  });

  static Future<void> show(BuildContext context, {required String roleCode}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => DocumentsModalSheet(roleCode: roleCode),
    );
  }

  @override
  State<DocumentsModalSheet> createState() => _DocumentsModalSheetState();
}

class _DocumentsModalSheetState extends State<DocumentsModalSheet> {
  bool _isLoading = true;
  List<SummitDocument> _documents = [];
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<int, bool> _downloadedMap = {};
  final Map<int, double> _downloadProgressMap = {};
  final Set<int> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final docs = await DocumentsService.fetchDocuments(
        accessToken: auth.accessToken,
        roleCode: widget.roleCode,
      );

      if (mounted) {
        setState(() {
          _documents = docs;
          _isLoading = false;
        });
      }

      // Check local download statuses in background
      try {
        for (final doc in docs) {
          final isDownloaded = await DocumentsService.isDocumentDownloaded(doc);
          if (mounted) {
            setState(() {
              _downloadedMap[doc.documentId] = isDownloaded;
            });
          }
        }
      } catch (e) {
        debugPrint('⚠️ [DocumentsModalSheet] Background check error: $e');
      }
    } catch (e) {
      debugPrint('❌ [DocumentsModalSheet] Error initializing data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.tryParse(raw);
      if (dt != null) {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final monthName = months[dt.month - 1];
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final minStr = dt.minute.toString().padLeft(2, '0');
        return '$monthName ${dt.day}, ${dt.year} • $hour:$minStr $ampm';
      }
    } catch (_) {}
    return raw;
  }

  String _getRoleLabel() {
    final r = widget.roleCode.toUpperCase();
    if (r == 'AD' || r == 'ADMIN') return 'Admin View (All Documents)';
    if (r == 'SK' || r == 'SPEAKER') return 'Speaker Resources';
    if (r == 'EX' || r == 'EXHIBITOR') return 'Exhibitor Documents';
    return 'Delegate Documents';
  }

  Future<void> _startDownload(SummitDocument doc) async {
    final docId = doc.documentId;
    if (_downloadingIds.contains(docId)) return;

    setState(() {
      _downloadingIds.add(docId);
      _downloadProgressMap[docId] = 0.05;
    });

    try {
      final file = await DocumentsService.downloadDocument(
        doc,
        onProgress: (prog) {
          if (mounted) {
            setState(() {
              _downloadProgressMap[docId] = prog;
            });
          }
        },
      );

      if (file != null && await file.exists()) {
        if (mounted) {
          setState(() {
            _downloadedMap[docId] = true;
            _downloadingIds.remove(docId);
            _downloadProgressMap.remove(docId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saved "${doc.documentName}" to Downloads > DFSICON',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _downloadingIds.remove(docId);
            _downloadProgressMap.remove(docId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download document. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadingIds.remove(docId);
          _downloadProgressMap.remove(docId);
        });
      }
    }
  }

  void _showDocumentActionDialog(SummitDocument doc) {
    final isDownloaded = _downloadedMap[doc.documentId] ?? false;
    final isDownloading = _downloadingIds.contains(doc.documentId);
    final progress = _downloadProgressMap[doc.documentId] ?? 0.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.documentName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Visibility: ${doc.visibilityLabel.isNotEmpty ? doc.visibilityLabel : doc.visibility}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Document Details Box (No raw path)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (doc.uploadedOn.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Text(
                                'Uploaded on: ${_formatDateTime(doc.uploadedOn)}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (isDownloading) ...[
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Downloading document...',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progress > 0 ? progress : null,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.primary,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // View Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            DocumentsService.openDocument(context, doc);
                          },
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          label: const Text(
                            'View Document',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A1E3D),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Download Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isDownloading
                              ? null
                              : () {
                                  Navigator.pop(ctx);
                                  _startDownload(doc);
                                },
                          icon: Icon(
                            isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
                            size: 18,
                            color: isDownloaded ? const Color(0xFF0F766E) : AppColors.primary,
                          ),
                          label: Text(
                            isDownloaded ? 'Re-Download' : 'Download',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isDownloaded ? const Color(0xFF0F766E) : AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDownloaded ? const Color(0xFF0F766E) : AppColors.primary,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.toLowerCase().trim();
    final filtered = _documents.where((doc) {
      if (query.isEmpty) return true;
      return doc.documentName.toLowerCase().contains(query) ||
          doc.uploadedBy.toLowerCase().contains(query) ||
          doc.visibilityLabel.toLowerCase().contains(query);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 42,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A1E3D).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.folder_shared_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conference Documents',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getRoleLabel(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          if (!_isLoading)
                            Text(
                              '${_documents.length} available',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _initData,
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 22),
                  tooltip: 'Refresh',
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Search Box & Storage Info
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search documents by name or keyword...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_outlined, size: 16, color: Color(0xFF15803D)),
                      const SizedBox(width: 8),
                      const Text(
                        'Download Path:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF166534),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
                          ),
                          child: const Text(
                            'Downloads > DFSICON',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF14532D),
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Document List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF0A1E3D), strokeWidth: 3),
                        SizedBox(height: 14),
                        Text(
                          'Loading conference documents...',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _searchQuery.isNotEmpty
                                      ? Icons.search_off_rounded
                                      : Icons.folder_open_rounded,
                                  size: 44,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No documents matching "$_searchQuery"'
                                    : 'No documents available for your role',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try checking for typos or searching with different keywords.'
                                    : 'Conference organizers have not uploaded documents for this category yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                        itemBuilder: (ctx, index) {
                          final doc = filtered[index];
                          final isDownloaded = _downloadedMap[doc.documentId] ?? false;
                          final isDownloading = _downloadingIds.contains(doc.documentId);
                          final progress = _downloadProgressMap[doc.documentId] ?? 0.0;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDownloaded
                                    ? const Color(0xFF10B981).withValues(alpha: 0.35)
                                    : const Color(0xFFE2E8F0),
                                width: isDownloaded ? 1.4 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showDocumentActionDialog(doc),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // PDF Icon badge
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isDownloaded
                                                    ? [const Color(0xFF059669), const Color(0xFF047857)]
                                                    : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (isDownloaded
                                                          ? const Color(0xFF059669)
                                                          : const Color(0xFFEF4444))
                                                      .withValues(alpha: 0.28),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    isDownloaded
                                                        ? Icons.check_circle_outline_rounded
                                                        : Icons.picture_as_pdf_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(height: 1),
                                                  Text(
                                                    doc.fileExtension.toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Title & Metadata
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  doc.documentName,
                                                  style: const TextStyle(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                if (doc.uploadedOn.isNotEmpty)
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.access_time_rounded,
                                                        size: 12,
                                                        color: Color(0xFF94A3B8),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _formatDateTime(doc.uploadedOn),
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Color(0xFF64748B),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                const SizedBox(height: 6),
                                                Wrap(
                                                  spacing: 6,
                                                  runSpacing: 4,
                                                  children: [
                                                    // Visibility pill
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 6.5, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF1F5F9),
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(
                                                            color: const Color(0xFFCBD5E1), width: 0.6),
                                                      ),
                                                      child: Text(
                                                        doc.visibilityLabel.isNotEmpty
                                                            ? doc.visibilityLabel
                                                            : 'Visible: ${doc.visibility}',
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF334155),
                                                        ),
                                                      ),
                                                    ),
                                                    // Downloaded pill
                                                    if (isDownloaded)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 6.5, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFD1FAE5),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.check,
                                                                size: 10, color: Color(0xFF047857)),
                                                            SizedBox(width: 3),
                                                            Text(
                                                              'Saved Locally',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFF047857),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Action button / menu
                                          IconButton(
                                            onPressed: () => _showDocumentActionDialog(doc),
                                            icon: const Icon(Icons.more_vert_rounded,
                                                color: Color(0xFF64748B)),
                                            tooltip: 'Options',
                                          ),
                                        ],
                                      ),
                                      if (isDownloading) ...[
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress > 0 ? progress : null,
                                            backgroundColor: Colors.grey.shade100,
                                            color: AppColors.primary,
                                            minHeight: 4,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
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
}
