class MyQrData {
  final bool isGenerated;
  final String qrImage;
  final String fileName;
  final String qrText;
  final String roleCode;
  final dynamic summitId;
  final String summitTitle;
  final String summitDates;
  final String generatedOn;

  MyQrData({
    required this.isGenerated,
    required this.qrImage,
    required this.fileName,
    required this.qrText,
    required this.roleCode,
    required this.summitId,
    required this.summitTitle,
    required this.summitDates,
    required this.generatedOn,
  });

  factory MyQrData.fromJson(Map<String, dynamic> json) {
    return MyQrData(
      isGenerated: json['is_generated'] ?? true,
      qrImage: json['qr_image']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      qrText: json['qr_text']?.toString() ?? '',
      roleCode: json['role_code']?.toString() ?? '',
      summitId: json['summit_id'],
      summitTitle: json['summit_title']?.toString() ?? '',
      summitDates: json['summit_dates']?.toString() ?? '',
      generatedOn: json['generated_on']?.toString() ?? '',
    );
  }
}

class VenueLayoutItem {
  final dynamic layoutId;
  final String layoutType;
  final String typeLabel;
  final String title;
  final String fileUrl;
  final String fileType;
  final String fileName;
  final dynamic fileSize;
  final dynamic venueId;
  final String venueName;
  final String uploadedOn;

  VenueLayoutItem({
    required this.layoutId,
    required this.layoutType,
    required this.typeLabel,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    required this.fileName,
    required this.fileSize,
    required this.venueId,
    required this.venueName,
    required this.uploadedOn,
  });

  factory VenueLayoutItem.fromJson(Map<String, dynamic> json) {
    return VenueLayoutItem(
      layoutId: json['layout_id'],
      layoutType: json['layout_type']?.toString() ?? '',
      typeLabel: json['type_label']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      fileType: json['file_type']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileSize: json['file_size'],
      venueId: json['venue_id'],
      venueName: json['venue_name']?.toString() ?? '',
      uploadedOn: json['uploaded_on']?.toString() ?? '',
    );
  }

  String get fullFileUrl {
    if (fileUrl.trim().isEmpty) return '';
    if (fileUrl.startsWith('http')) return fileUrl;
    String cleanPath = fileUrl.trim();
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  String get formattedFileSize {
    if (fileSize == null) return '';
    final int size = int.tryParse(fileSize.toString()) ?? 0;
    if (size <= 0) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class DelegateStallVisit {
  final int boothId;
  final String boothNumber;
  final String boothLabel;
  final String? boothType;
  final int summitId;
  final String companyName;
  final String? logo;
  final String contactPerson;
  final String mobile;
  final String email;
  final int visitCount;
  final String lastVisitedAt;

  DelegateStallVisit({
    required this.boothId,
    required this.boothNumber,
    required this.boothLabel,
    this.boothType,
    required this.summitId,
    required this.companyName,
    this.logo,
    required this.contactPerson,
    required this.mobile,
    required this.email,
    required this.visitCount,
    required this.lastVisitedAt,
  });

  factory DelegateStallVisit.fromJson(Map<String, dynamic> json) {
    final sponsor = json['sponsor'] as Map<String, dynamic>? ?? {};
    return DelegateStallVisit(
      boothId: int.tryParse(json['booth_id']?.toString() ?? '0') ?? 0,
      boothNumber: json['booth_number']?.toString() ?? '',
      boothLabel: json['booth_label']?.toString() ?? '',
      boothType: json['booth_type']?.toString(),
      summitId: int.tryParse(json['summit_id']?.toString() ?? '0') ?? 0,
      companyName: sponsor['company_name']?.toString() ?? '',
      logo: sponsor['logo']?.toString(),
      contactPerson: sponsor['contact_person']?.toString() ?? '',
      mobile: sponsor['mobile']?.toString() ?? '',
      email: sponsor['email']?.toString() ?? '',
      visitCount: int.tryParse(json['visit_count']?.toString() ?? '1') ?? 1,
      lastVisitedAt: json['last_visited_at']?.toString() ?? '',
    );
  }

  String get fullLogoUrl {
    if (logo == null || logo!.trim().isEmpty || logo == 'null' || logo == 'NA') {
      return '';
    }
    String cleanPath = logo!.trim();
    if (cleanPath.startsWith('http')) return cleanPath;
    if (cleanPath.startsWith('./')) {
      cleanPath = cleanPath.substring(2);
    } else if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return 'https://services.heterohcl.com/dfs-icon/$cleanPath';
  }

  String get displayStallName {
    if (boothLabel.isNotEmpty && boothNumber.isNotEmpty && boothLabel != boothNumber) {
      return '$boothLabel ($boothNumber)';
    }
    if (boothLabel.isNotEmpty) return boothLabel;
    if (boothNumber.isNotEmpty) return boothNumber;
    return 'Booth #$boothId';
  }
}
