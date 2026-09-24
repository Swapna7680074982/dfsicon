class SummitDocument {
  final int documentId;
  final String documentName;
  final String documentUrl;
  final String uploadedOn;
  final String uploadedBy;
  final String visibility;
  final String visibilityLabel;

  SummitDocument({
    required this.documentId,
    required this.documentName,
    required this.documentUrl,
    required this.uploadedOn,
    required this.uploadedBy,
    required this.visibility,
    required this.visibilityLabel,
  });

  factory SummitDocument.fromJson(Map<String, dynamic> json) {
    final rawId = json['document_id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    return SummitDocument(
      documentId: id,
      documentName: json['document_name']?.toString().trim() ?? '',
      documentUrl: json['document_url']?.toString().trim() ?? '',
      uploadedOn: json['uploaded_on']?.toString().trim() ?? '',
      uploadedBy: json['uploaded_by']?.toString().trim() ?? '',
      visibility: json['visibility']?.toString().trim() ?? 'BOTH',
      visibilityLabel: json['visibility_label']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'document_id': documentId,
    'document_name': documentName,
    'document_url': documentUrl,
    'uploaded_on': uploadedOn,
    'uploaded_by': uploadedBy,
    'visibility': visibility,
    'visibility_label': visibilityLabel,
  };

  /// Check whether this document should be visible to a given role
  /// Roles: 'ADMIN', 'SPEAKER', 'DELEGATE'
  bool isVisibleForRole(String roleCode) {
    final normalizedRole = roleCode.toUpperCase().trim();
    if (normalizedRole == 'AD' || normalizedRole == 'ADMIN' || normalizedRole == 'ADMINISTRATOR') {
      return true;
    }

    final vis = visibility.toUpperCase().trim();
    final label = visibilityLabel.toLowerCase();

    if (vis == 'BOTH' || label.contains('both') || (label.contains('speaker') && label.contains('delegate'))) {
      return true;
    }

    if (normalizedRole == 'SK' || normalizedRole == 'SPEAKER') {
      return vis == 'SK' || vis == 'SPEAKER' || label.contains('speaker');
    }

    if (normalizedRole == 'DG' || normalizedRole == 'DELEGATE' || normalizedRole == 'DL') {
      return vis == 'DG' || vis == 'DELEGATE' || vis == 'DL' || label.contains('delegate');
    }

    return true;
  }

  /// Get file extension or default to pdf
  String get fileExtension {
    try {
      final uri = Uri.parse(documentUrl);
      final segs = uri.pathSegments;
      if (segs.isNotEmpty) {
        final last = segs.last;
        if (last.contains('.')) {
          return last.split('.').last.toLowerCase();
        }
      }
    } catch (_) {}
    return 'pdf';
  }

  /// Clean local filename
  String get localFileName {
    final cleanName = documentName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final ext = fileExtension;
    if (cleanName.toLowerCase().endsWith('.$ext')) {
      return cleanName;
    }
    return '${cleanName}_$documentId.$ext';
  }
}
