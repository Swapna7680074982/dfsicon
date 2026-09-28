class ExhibitorSummary {
  final int totalVisits;
  final int uniqueVisitors;

  ExhibitorSummary({
    required this.totalVisits,
    required this.uniqueVisitors,
  });

  factory ExhibitorSummary.fromJson(Map<String, dynamic> json) {
    return ExhibitorSummary(
      totalVisits: int.tryParse(json['total_visits']?.toString() ?? '0') ?? 0,
      uniqueVisitors: int.tryParse(json['unique_visitors']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_visits': totalVisits,
    'unique_visitors': uniqueVisitors,
  };
}

class BoothDayCount {
  final dynamic boothId;
  final String boothNumber;
  final String boothLabel;
  final String visitedDate;
  final int totalVisits;
  final int uniqueVisitors;

  BoothDayCount({
    required this.boothId,
    required this.boothNumber,
    required this.boothLabel,
    required this.visitedDate,
    required this.totalVisits,
    required this.uniqueVisitors,
  });

  factory BoothDayCount.fromJson(Map<String, dynamic> json) {
    return BoothDayCount(
      boothId: json['booth_id'],
      boothNumber: json['booth_number']?.toString() ?? '',
      boothLabel: json['booth_label']?.toString() ?? '',
      visitedDate: json['visited_date']?.toString() ?? '',
      totalVisits: int.tryParse(json['total_visits']?.toString() ?? '0') ?? 0,
      uniqueVisitors: int.tryParse(json['unique_visitors']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'booth_id': boothId,
    'booth_number': boothNumber,
    'booth_label': boothLabel,
    'visited_date': visitedDate,
    'total_visits': totalVisits,
    'unique_visitors': uniqueVisitors,
  };
}

class ExhibitorCountsData {
  final ExhibitorSummary summary;
  final List<BoothDayCount> byBoothDay;

  ExhibitorCountsData({
    required this.summary,
    required this.byBoothDay,
  });

  factory ExhibitorCountsData.fromJson(Map<String, dynamic> json) {
    return ExhibitorCountsData(
      summary: json['summary'] != null
          ? ExhibitorSummary.fromJson(Map<String, dynamic>.from(json['summary']))
          : ExhibitorSummary(totalVisits: 0, uniqueVisitors: 0),
      byBoothDay: (json['by_booth_day'] as List<dynamic>?)
              ?.map((e) => BoothDayCount.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'summary': summary.toJson(),
    'by_booth_day': byBoothDay.map((e) => e.toJson()).toList(),
  };
}

class ExhibitorParticipant {
  final dynamic footfallId;
  final dynamic userId;
  final String name;
  final String role;
  final String roleLabel;
  final String designation;
  final String organisation;
  final String city;
  final String mobile;
  final String email;
  final dynamic boothId;
  final String boothNumber;
  final String boothLabel;
  final String visitedDate;
  final String visitedTime;
  final int visitCount;

  ExhibitorParticipant({
    required this.footfallId,
    required this.userId,
    required this.name,
    required this.role,
    required this.roleLabel,
    required this.designation,
    required this.organisation,
    required this.city,
    required this.mobile,
    required this.email,
    required this.boothId,
    required this.boothNumber,
    this.boothLabel = '',
    required this.visitedDate,
    required this.visitedTime,
    required this.visitCount,
  });

  factory ExhibitorParticipant.fromJson(Map<String, dynamic> json) {
    return ExhibitorParticipant(
      footfallId: json['footfall_id'],
      userId: json['user_id'],
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      roleLabel: json['role_label']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      organisation: json['organisation']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      boothId: json['booth_id'],
      boothNumber: (json['booth_number'] ?? json['booth_no'] ?? '').toString(),
      boothLabel: (json['booth_label'] ?? json['label'] ?? json['booth_name'] ?? '').toString().trim(),
      visitedDate: json['visited_date']?.toString() ?? '',
      visitedTime: json['visited_time']?.toString() ?? '',
      visitCount: int.tryParse(json['visit_count']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'footfall_id': footfallId,
    'user_id': userId,
    'name': name,
    'role': role,
    'role_label': roleLabel,
    'designation': designation,
    'organisation': organisation,
    'city': city,
    'mobile': mobile,
    'email': email,
    'booth_id': boothId,
    'booth_number': boothNumber,
    'booth_label': boothLabel,
    'visited_date': visitedDate,
    'visited_time': visitedTime,
    'visit_count': visitCount,
  };
}

class SponsorQrData {
  final int qrId;
  final int sponsorId;
  final String companyName;
  final String contactPerson;
  final String qrReference;
  final String qrText;
  final String fileName;
  final String qrImagePath;
  final String qrImageUrl;
  final String generatedOn;

  SponsorQrData({
    required this.qrId,
    required this.sponsorId,
    this.companyName = '',
    this.contactPerson = '',
    this.qrReference = '',
    this.qrText = '',
    this.fileName = '',
    this.qrImagePath = '',
    this.qrImageUrl = '',
    this.generatedOn = '',
  });

  factory SponsorQrData.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['qr_image_url']?.toString() ??
        json['qr_image']?.toString() ??
        json['url']?.toString() ??
        '';
    if (rawUrl.contains('/./')) {
      rawUrl = rawUrl.replaceAll('/./', '/');
    }
    if (rawUrl.isNotEmpty && !rawUrl.startsWith('http')) {
      if (rawUrl.startsWith('./')) {
        rawUrl = 'https://services.heterohcl.com/dfs-icon/${rawUrl.substring(2)}';
      } else if (rawUrl.startsWith('/')) {
        rawUrl = 'https://services.heterohcl.com/dfs-icon/${rawUrl.substring(1)}';
      } else {
        rawUrl = 'https://services.heterohcl.com/dfs-icon/$rawUrl';
      }
    }

    return SponsorQrData(
      qrId: int.tryParse(json['qr_id']?.toString() ?? '') ?? 0,
      sponsorId: int.tryParse(json['sponsor_id']?.toString() ?? '') ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      contactPerson: json['contact_person']?.toString() ?? '',
      qrReference: json['qr_reference']?.toString() ?? '',
      qrText: json['qr_text']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      qrImagePath: json['qr_image_path']?.toString() ?? '',
      qrImageUrl: rawUrl,
      generatedOn: json['generated_on']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'qr_id': qrId,
    'sponsor_id': sponsorId,
    'company_name': companyName,
    'contact_person': contactPerson,
    'qr_reference': qrReference,
    'qr_text': qrText,
    'file_name': fileName,
    'qr_image_path': qrImagePath,
    'qr_image_url': qrImageUrl,
    'generated_on': generatedOn,
  };
}
