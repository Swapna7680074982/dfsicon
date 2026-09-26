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
