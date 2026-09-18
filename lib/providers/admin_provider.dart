import 'dart:convert';
import 'package:flutter/material.dart';
import '../domain/api_service.dart';
import '../utils/custom_logger.dart';

// ==========================================
// Admin Models
// ==========================================

class AdminDashboardStats {
  final int totalSpeakers;
  final int totalDelegates;
  final int totalTopics;
  final int confirmedTopics;
  final int totalExhibitors;
  final int totalBooths;
  final int totalAssignedBooths;
  final int totalWorkshops;
  final int totalSlots;
  final int availableSlots;

  const AdminDashboardStats({
    this.totalSpeakers = 0,
    this.totalDelegates = 0,
    this.totalTopics = 0,
    this.confirmedTopics = 0,
    this.totalExhibitors = 0,
    this.totalBooths = 0,
    this.totalAssignedBooths = 0,
    this.totalWorkshops = 0,
    this.totalSlots = 0,
    this.availableSlots = 0,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return AdminDashboardStats(
      totalSpeakers: parseInt(json['total_speakers']),
      totalDelegates: parseInt(json['total_delegates']),
      totalTopics: parseInt(json['total_topics']),
      confirmedTopics: parseInt(json['confirmed_topics']),
      totalExhibitors: parseInt(json['total_exhibitors']),
      totalBooths: parseInt(json['total_booths']),
      totalAssignedBooths: parseInt(json['total_assigned_booths']),
      totalWorkshops: parseInt(json['total_workshops']),
      totalSlots: parseInt(json['total_slots']),
      availableSlots: parseInt(json['available_slots']),
    );
  }
}

class AdminPagination {
  final int totalRecords;
  final int currentPage;
  final int perPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const AdminPagination({
    this.totalRecords = 0,
    this.currentPage = 1,
    this.perPage = 10,
    this.totalPages = 1,
    this.hasNext = false,
    this.hasPrev = false,
  });

  factory AdminPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AdminPagination();
    int parseInt(dynamic val, int def) {
      if (val == null) return def;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? def;
    }

    return AdminPagination(
      totalRecords: parseInt(json['total_records'], 0),
      currentPage: parseInt(json['current_page'], 1),
      perPage: parseInt(json['per_page'], 10),
      totalPages: parseInt(json['total_pages'], 1),
      hasNext: json['has_next'] == true,
      hasPrev: json['has_prev'] == true,
    );
  }
}

class AdminSpeaker {
  final String userId;
  final String fullName;
  final String mobile;
  final String email;
  final String citizenType;
  final String state;
  final String city;
  final String category;
  final String qualification;
  final String organisationName;
  final String designation;
  final String status;
  final String createdAt;

  const AdminSpeaker({
    this.userId = '',
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.citizenType = '',
    this.state = '',
    this.city = '',
    this.category = '',
    this.qualification = '',
    this.organisationName = '',
    this.designation = '',
    this.status = '',
    this.createdAt = '',
  });

  factory AdminSpeaker.fromJson(Map<String, dynamic> json) {
    return AdminSpeaker(
      userId: (json['user_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      citizenType: (json['citizen_type'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      category: (json['category'] ?? '').toString().trim(),
      qualification: (json['qualification'] ?? '').toString().trim(),
      organisationName: (json['organisation_name'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      createdAt: (json['created_at'] ?? '').toString().trim(),
    );
  }
}

class AdminDelegate {
  final String userId;
  final String fullName;
  final String mobile;
  final String email;
  final String citizenType;
  final String state;
  final String city;
  final String category;
  final String qualification;
  final String organisationName;
  final String designation;
  final String status;
  final String createdAt;

  const AdminDelegate({
    this.userId = '',
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.citizenType = '',
    this.state = '',
    this.city = '',
    this.category = '',
    this.qualification = '',
    this.organisationName = '',
    this.designation = '',
    this.status = '',
    this.createdAt = '',
  });

  factory AdminDelegate.fromJson(Map<String, dynamic> json) {
    return AdminDelegate(
      userId: (json['user_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      citizenType: (json['citizen_type'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      category: (json['category'] ?? '').toString().trim(),
      qualification: (json['qualification'] ?? '').toString().trim(),
      organisationName: (json['organisation_name'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      createdAt: (json['created_at'] ?? '').toString().trim(),
    );
  }
}

class AdminSpeakerDetail {
  final String userId;
  final String fullName;
  final String mobile;
  final String email;
  final String citizenType;
  final String state;
  final String city;
  final String category;
  final String qualification;
  final String organisationName;
  final String designation;
  final String status;
  final String createdAt;
  final String gender;
  final String specialization;
  final String experienceYears;
  final String medicalRegistrationNumber;

  const AdminSpeakerDetail({
    this.userId = '',
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.citizenType = '',
    this.state = '',
    this.city = '',
    this.category = '',
    this.qualification = '',
    this.organisationName = '',
    this.designation = '',
    this.status = '',
    this.createdAt = '',
    this.gender = '',
    this.specialization = '',
    this.experienceYears = '',
    this.medicalRegistrationNumber = '',
  });

  factory AdminSpeakerDetail.fromJson(Map<String, dynamic> json) {
    return AdminSpeakerDetail(
      userId: (json['user_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      citizenType: (json['citizen_type'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      category: (json['category'] ?? '').toString().trim(),
      qualification: (json['qualification'] ?? '').toString().trim(),
      organisationName: (json['organisation_name'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      createdAt: (json['created_at'] ?? '').toString().trim(),
      gender: (json['gender'] ?? '').toString().trim(),
      specialization: (json['specialization'] ?? '').toString().trim(),
      experienceYears: (json['experience_years'] ?? '').toString().trim(),
      medicalRegistrationNumber: (json['medical_registration_number'] ?? '').toString().trim(),
    );
  }
}

class AdminDelegateDetail {
  final String userId;
  final String fullName;
  final String mobile;
  final String email;
  final String citizenType;
  final String state;
  final String city;
  final String category;
  final String qualification;
  final String organisationName;
  final String designation;
  final String status;
  final String createdAt;
  final String gender;
  final String specialization;
  final String experienceYears;
  final String medicalRegistrationNumber;

  const AdminDelegateDetail({
    this.userId = '',
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.citizenType = '',
    this.state = '',
    this.city = '',
    this.category = '',
    this.qualification = '',
    this.organisationName = '',
    this.designation = '',
    this.status = '',
    this.createdAt = '',
    this.gender = '',
    this.specialization = '',
    this.experienceYears = '',
    this.medicalRegistrationNumber = '',
  });

  factory AdminDelegateDetail.fromJson(Map<String, dynamic> json) {
    return AdminDelegateDetail(
      userId: (json['user_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      citizenType: (json['citizen_type'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      category: (json['category'] ?? '').toString().trim(),
      qualification: (json['qualification'] ?? '').toString().trim(),
      organisationName: (json['organisation_name'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      createdAt: (json['created_at'] ?? '').toString().trim(),
      gender: (json['gender'] ?? '').toString().trim(),
      specialization: (json['specialization'] ?? '').toString().trim(),
      experienceYears: (json['experience_years'] ?? '').toString().trim(),
      medicalRegistrationNumber: (json['medical_registration_number'] ?? '').toString().trim(),
    );
  }
}

class AdminTopic {
  final String topicId;
  final String speakerId;
  final String title;
  final String speakerName;
  final String categoryOfSubmission;
  final String status;
  final String topicStatus;
  final String isPublished;
  final String createdBy;
  final String createdByName;
  final String createdOn;
  final String updatedBy;
  final String updatedByName;
  final String updatedOn;

  // Slot timing & schedule fields
  final String slotId;
  final String slotName;
  final String slotLabel;
  final String startTime;
  final String endTime;
  final String scheduleDate;
  final String scheduleDay;
  final String hallId;
  final String hallName;
  final String hallLabel;

  const AdminTopic({
    this.topicId = '',
    this.speakerId = '',
    this.title = '',
    this.speakerName = '',
    this.categoryOfSubmission = '',
    this.status = '',
    this.topicStatus = '',
    this.isPublished = '',
    this.createdBy = '',
    this.createdByName = '',
    this.createdOn = '',
    this.updatedBy = '',
    this.updatedByName = '',
    this.updatedOn = '',
    this.slotId = '',
    this.slotName = '',
    this.slotLabel = '',
    this.startTime = '',
    this.endTime = '',
    this.scheduleDate = '',
    this.scheduleDay = '',
    this.hallId = '',
    this.hallName = '',
    this.hallLabel = '',
  });

  factory AdminTopic.fromJson(Map<String, dynamic> json) {
    // Check direct fields or nested slot/session/hall
    final Map<String, dynamic>? slotMap = json['slot'] is Map ? (json['slot'] as Map<String, dynamic>) : null;
    final Map<String, dynamic>? hallMap = json['hall'] is Map ? (json['hall'] as Map<String, dynamic>) : null;
    final Map<String, dynamic>? sessionMap = json['session'] is Map
        ? (json['session'] as Map<String, dynamic>)
        : (json['session_details'] is Map ? json['session_details'] as Map<String, dynamic> : null);

    final rawSlotId = json['slot_id'] ?? slotMap?['slot_id'] ?? sessionMap?['slot_id'] ?? '';
    final rawSlotName = json['slot_name'] ?? slotMap?['slot_name'] ?? sessionMap?['slot_name'] ?? '';
    final rawSlotLabel = json['slot_label'] ?? slotMap?['slot_label'] ?? sessionMap?['slot_label'] ?? '';
    final rawStartTime = json['start_time'] ?? json['from_time'] ?? json['slot_start_time'] ?? slotMap?['start_time'] ?? sessionMap?['start_time'] ?? json['time'] ?? '';
    final rawEndTime = json['end_time'] ?? json['to_time'] ?? json['slot_end_time'] ?? slotMap?['end_time'] ?? sessionMap?['end_time'] ?? '';
    final rawScheduleDate = json['schedule_date'] ?? json['session_date'] ?? json['date'] ?? slotMap?['schedule_date'] ?? sessionMap?['schedule_date'] ?? '';
    final rawScheduleDay = json['schedule_day'] ?? json['day'] ?? slotMap?['schedule_day'] ?? sessionMap?['schedule_day'] ?? '';
    final rawHallId = json['hall_id'] ?? hallMap?['hall_id'] ?? slotMap?['hall_id'] ?? sessionMap?['hall_id'] ?? '';
    final rawHallName = json['hall_name'] ?? hallMap?['hall_name'] ?? slotMap?['hall_name'] ?? sessionMap?['hall_name'] ?? '';
    final rawHallLabel = json['hall_label'] ?? hallMap?['hall_label'] ?? slotMap?['hall_label'] ?? sessionMap?['hall_label'] ?? '';

    return AdminTopic(
      topicId: (json['topic_id'] ?? '').toString(),
      speakerId: (json['speaker_id'] ?? '').toString(),
      title: (json['title'] ?? json['abstract_title'] ?? '').toString().trim(),
      speakerName: (json['speaker_name'] ?? json['speaker_full_name'] ?? json['full_name'] ?? '').toString().trim(),
      categoryOfSubmission: (json['category_of_submission'] ?? json['category'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      topicStatus: (json['topic_status'] ?? '').toString().trim(),
      isPublished: (json['is_published'] ?? '').toString().trim(),
      createdBy: (json['created_by'] ?? '').toString().trim(),
      createdByName: (json['created_by_name'] ?? '').toString().trim(),
      createdOn: (json['created_on'] ?? '').toString().trim(),
      updatedBy: (json['updated_by'] ?? '').toString().trim(),
      updatedByName: (json['updated_by_name'] ?? '').toString().trim(),
      updatedOn: (json['updated_on'] ?? '').toString().trim(),
      slotId: rawSlotId.toString().trim(),
      slotName: rawSlotName.toString().trim(),
      slotLabel: rawSlotLabel.toString().trim(),
      startTime: rawStartTime.toString().trim(),
      endTime: rawEndTime.toString().trim(),
      scheduleDate: rawScheduleDate.toString().trim(),
      scheduleDay: rawScheduleDay.toString().trim(),
      hallId: rawHallId.toString().trim(),
      hallName: rawHallName.toString().trim(),
      hallLabel: rawHallLabel.toString().trim(),
    );
  }
}

class AdminTopicDetail {
  final String topicId;
  final String speakerId;
  final String title;
  final String speakerName;
  final String speakerEmail;
  final String contributingAuthor1Name;
  final String contributingAuthor2Name;
  final String categoryOfSubmission;
  final String presentationFormat;
  final String backgroundIntroduction;
  final String aimsObjectives;
  final String materialsMethods;
  final String results;
  final String conclusion;
  final String keywords;
  final String status;
  final String topicStatus;
  final String isPublished;
  final String createdBy;
  final String createdByName;
  final String createdOn;
  final String updatedBy;
  final String updatedByName;
  final String updatedOn;

  // Slot timing & schedule fields
  final String slotId;
  final String slotName;
  final String slotLabel;
  final String startTime;
  final String endTime;
  final String scheduleDate;
  final String scheduleDay;
  final String hallId;
  final String hallName;
  final String hallLabel;
  final String venueName;

  const AdminTopicDetail({
    this.topicId = '',
    this.speakerId = '',
    this.title = '',
    this.speakerName = '',
    this.speakerEmail = '',
    this.contributingAuthor1Name = '',
    this.contributingAuthor2Name = '',
    this.categoryOfSubmission = '',
    this.presentationFormat = '',
    this.backgroundIntroduction = '',
    this.aimsObjectives = '',
    this.materialsMethods = '',
    this.results = '',
    this.conclusion = '',
    this.keywords = '',
    this.status = '',
    this.topicStatus = '',
    this.isPublished = '',
    this.createdBy = '',
    this.createdByName = '',
    this.createdOn = '',
    this.updatedBy = '',
    this.updatedByName = '',
    this.updatedOn = '',
    this.slotId = '',
    this.slotName = '',
    this.slotLabel = '',
    this.startTime = '',
    this.endTime = '',
    this.scheduleDate = '',
    this.scheduleDay = '',
    this.hallId = '',
    this.hallName = '',
    this.hallLabel = '',
    this.venueName = '',
  });

  factory AdminTopicDetail.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? slotMap = json['slot'] is Map ? (json['slot'] as Map<String, dynamic>) : null;
    final Map<String, dynamic>? hallMap = json['hall'] is Map ? (json['hall'] as Map<String, dynamic>) : null;
    final Map<String, dynamic>? sessionMap = json['session'] is Map
        ? (json['session'] as Map<String, dynamic>)
        : (json['session_details'] is Map ? json['session_details'] as Map<String, dynamic> : null);

    final rawSlotId = json['slot_id'] ?? slotMap?['slot_id'] ?? sessionMap?['slot_id'] ?? '';
    final rawSlotName = json['slot_name'] ?? slotMap?['slot_name'] ?? sessionMap?['slot_name'] ?? '';
    final rawSlotLabel = json['slot_label'] ?? slotMap?['slot_label'] ?? sessionMap?['slot_label'] ?? '';
    final rawStartTime = json['start_time'] ?? json['from_time'] ?? json['slot_start_time'] ?? slotMap?['start_time'] ?? sessionMap?['start_time'] ?? json['time'] ?? '';
    final rawEndTime = json['end_time'] ?? json['to_time'] ?? json['slot_end_time'] ?? slotMap?['end_time'] ?? sessionMap?['end_time'] ?? '';
    final rawScheduleDate = json['schedule_date'] ?? json['session_date'] ?? json['date'] ?? slotMap?['schedule_date'] ?? sessionMap?['schedule_date'] ?? '';
    final rawScheduleDay = json['schedule_day'] ?? json['day'] ?? slotMap?['schedule_day'] ?? sessionMap?['schedule_day'] ?? '';
    final rawHallId = json['hall_id'] ?? hallMap?['hall_id'] ?? slotMap?['hall_id'] ?? sessionMap?['hall_id'] ?? '';
    final rawHallName = json['hall_name'] ?? hallMap?['hall_name'] ?? slotMap?['hall_name'] ?? sessionMap?['hall_name'] ?? '';
    final rawHallLabel = json['hall_label'] ?? hallMap?['hall_label'] ?? slotMap?['hall_label'] ?? sessionMap?['hall_label'] ?? '';
    final rawVenueName = json['venue_name'] ?? slotMap?['venue_name'] ?? sessionMap?['venue_name'] ?? '';

    return AdminTopicDetail(
      topicId: (json['topic_id'] ?? '').toString(),
      speakerId: (json['speaker_id'] ?? '').toString(),
      title: (json['title'] ?? json['abstract_title'] ?? '').toString().trim(),
      speakerName: (json['speaker_name'] ?? json['speaker_full_name'] ?? json['full_name'] ?? '').toString().trim(),
      speakerEmail: (json['speaker_email'] ?? json['email'] ?? '').toString().trim(),
      contributingAuthor1Name: (json['contributing_author1_name'] ?? '').toString().trim(),
      contributingAuthor2Name: (json['contributing_author2_name'] ?? '').toString().trim(),
      categoryOfSubmission: (json['category_of_submission'] ?? json['category'] ?? '').toString().trim(),
      presentationFormat: (json['presentation_format'] ?? '').toString().trim(),
      backgroundIntroduction: (json['background_introduction'] ?? '').toString().trim(),
      aimsObjectives: (json['aims_objectives'] ?? '').toString().trim(),
      materialsMethods: (json['materials_methods'] ?? '').toString().trim(),
      results: (json['results'] ?? '').toString().trim(),
      conclusion: (json['conclusion'] ?? '').toString().trim(),
      keywords: (json['keywords'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      topicStatus: (json['topic_status'] ?? '').toString().trim(),
      isPublished: (json['is_published'] ?? '').toString().trim(),
      createdBy: (json['created_by'] ?? '').toString().trim(),
      createdByName: (json['created_by_name'] ?? '').toString().trim(),
      createdOn: (json['created_on'] ?? '').toString().trim(),
      updatedBy: (json['updated_by'] ?? '').toString().trim(),
      updatedByName: (json['updated_by_name'] ?? '').toString().trim(),
      updatedOn: (json['updated_on'] ?? '').toString().trim(),
      slotId: rawSlotId.toString().trim(),
      slotName: rawSlotName.toString().trim(),
      slotLabel: rawSlotLabel.toString().trim(),
      startTime: rawStartTime.toString().trim(),
      endTime: rawEndTime.toString().trim(),
      scheduleDate: rawScheduleDate.toString().trim(),
      scheduleDay: rawScheduleDay.toString().trim(),
      hallId: rawHallId.toString().trim(),
      hallName: rawHallName.toString().trim(),
      hallLabel: rawHallLabel.toString().trim(),
      venueName: rawVenueName.toString().trim(),
    );
  }
}

class AdminTopicBookmarkItem {
  final String bookmarkId;
  final String userId;
  final String candidateName;
  final String role;
  final String designation;
  final String organisationName;
  final String bookmarkedOn;

  const AdminTopicBookmarkItem({
    this.bookmarkId = '',
    this.userId = '',
    this.candidateName = '',
    this.role = '',
    this.designation = '',
    this.organisationName = '',
    this.bookmarkedOn = '',
  });

  factory AdminTopicBookmarkItem.fromJson(Map<String, dynamic> json) {
    return AdminTopicBookmarkItem(
      bookmarkId: (json['bookmark_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      candidateName: (json['candidate_name'] ?? '').toString().trim(),
      role: (json['role'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      organisationName: (json['organisation_name'] ?? '').toString().trim(),
      bookmarkedOn: (json['bookmarked_on'] ?? '').toString().trim(),
    );
  }
}

class AdminWorkshop {
  final String workshopId;
  final String workshopCode;
  final String workshopName;
  final String workshopType;
  final String venueName;
  final String state;
  final String city;
  final String maxCapacity;
  final String registrationStart;
  final String registrationEnd;
  final String workshopStart;
  final String workshopEnd;
  final String status;
  final String workshopStatus;
  final String speakersCount;
  final String delegatesCount;

  const AdminWorkshop({
    this.workshopId = '',
    this.workshopCode = '',
    this.workshopName = '',
    this.workshopType = '',
    this.venueName = '',
    this.state = '',
    this.city = '',
    this.maxCapacity = '',
    this.registrationStart = '',
    this.registrationEnd = '',
    this.workshopStart = '',
    this.workshopEnd = '',
    this.status = '',
    this.workshopStatus = '',
    this.speakersCount = '0',
    this.delegatesCount = '0',
  });

  factory AdminWorkshop.fromJson(Map<String, dynamic> json) {
    return AdminWorkshop(
      workshopId: (json['workshop_id'] ?? '').toString(),
      workshopCode: (json['workshop_code'] ?? '').toString().trim(),
      workshopName: (json['workshop_name'] ?? '').toString().trim(),
      workshopType: (json['workshop_type'] ?? '').toString().trim(),
      venueName: (json['venue_name'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      maxCapacity: (json['max_capacity'] ?? '').toString().trim(),
      registrationStart: (json['registration_start'] ?? '').toString().trim(),
      registrationEnd: (json['registration_end'] ?? '').toString().trim(),
      workshopStart: (json['workshop_start'] ?? '').toString().trim(),
      workshopEnd: (json['workshop_end'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      workshopStatus: (json['workshop_status'] ?? '').toString().trim(),
      speakersCount: (json['speakers_count'] ?? '0').toString().trim(),
      delegatesCount: (json['delegates_count'] ?? '0').toString().trim(),
    );
  }
}

class AdminWorkshopParticipant {
  final String userId;
  final String fullName;
  final String mobile;
  final String email;
  final String designation;
  final String organisationName;
  final String? role;
  final String attendanceStatus;
  final String certificateGenerated;
  final String feedbackSubmitted;
  final String assignedOn;

  const AdminWorkshopParticipant({
    this.userId = '',
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.designation = '',
    this.organisationName = '',
    this.role,
    this.attendanceStatus = '',
    this.certificateGenerated = '0',
    this.feedbackSubmitted = '0',
    this.assignedOn = '',
  });

  factory AdminWorkshopParticipant.fromJson(Map<String, dynamic> json) {
    return AdminWorkshopParticipant(
      userId: (json['user_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      organisationName: (json['organisation_name'] ?? '').toString().trim(),
      role: json['role']?.toString().trim(),
      attendanceStatus: (json['attendance_status'] ?? 'Pending').toString().trim(),
      certificateGenerated: (json['certificate_generated'] ?? '0').toString(),
      feedbackSubmitted: (json['feedback_submitted'] ?? '0').toString(),
      assignedOn: (json['assigned_on'] ?? '').toString().trim(),
    );
  }
}

class AdminWorkshopParticipantsData {
  final AdminWorkshop workshop;
  final List<AdminWorkshopParticipant> speakers;
  final List<AdminWorkshopParticipant> delegates;

  const AdminWorkshopParticipantsData({
    this.workshop = const AdminWorkshop(),
    this.speakers = const [],
    this.delegates = const [],
  });

  factory AdminWorkshopParticipantsData.fromJson(Map<String, dynamic> json) {
    final workshopMap = json['workshop'] is Map ? json['workshop'] as Map<String, dynamic> : <String, dynamic>{};
    final speakersMap = json['speakers'] is Map ? json['speakers'] as Map<String, dynamic> : <String, dynamic>{};
    final delegatesMap = json['delegates'] is Map ? json['delegates'] as Map<String, dynamic> : <String, dynamic>{};

    final List speakersList = speakersMap['data'] is List ? speakersMap['data'] : [];
    final List delegatesList = delegatesMap['data'] is List ? delegatesMap['data'] : [];

    return AdminWorkshopParticipantsData(
      workshop: AdminWorkshop.fromJson(workshopMap),
      speakers: speakersList.map((e) => AdminWorkshopParticipant.fromJson(e)).toList(),
      delegates: delegatesList.map((e) => AdminWorkshopParticipant.fromJson(e)).toList(),
    );
  }
}

class AdminSponsorCategory {
  final String categoryId;
  final String categoryName;
  final String status;
  final String createdAt;

  const AdminSponsorCategory({
    this.categoryId = '',
    this.categoryName = '',
    this.status = '',
    this.createdAt = '',
  });

  factory AdminSponsorCategory.fromJson(Map<String, dynamic> json) {
    return AdminSponsorCategory(
      categoryId: (json['category_id'] ?? '').toString(),
      categoryName: (json['category_name'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      createdAt: (json['created_at'] ?? '').toString().trim(),
    );
  }
}

class AdminSponsorBoothAssignment {
  final String assignmentId;
  final String boothId;
  final String boothNumber;
  final String boothLabel;
  final String? boothType;
  final String? sizeSqft;
  final String? price;
  final String summitId;
  final String assignedAt;

  const AdminSponsorBoothAssignment({
    this.assignmentId = '',
    this.boothId = '',
    this.boothNumber = '',
    this.boothLabel = '',
    this.boothType,
    this.sizeSqft,
    this.price,
    this.summitId = '',
    this.assignedAt = '',
  });

  factory AdminSponsorBoothAssignment.fromJson(Map<String, dynamic> json) {
    return AdminSponsorBoothAssignment(
      assignmentId: (json['assignment_id'] ?? '').toString(),
      boothId: (json['booth_id'] ?? '').toString(),
      boothNumber: (json['booth_number'] ?? '').toString().trim(),
      boothLabel: (json['booth_label'] ?? '').toString().trim(),
      boothType: json['booth_type']?.toString(),
      sizeSqft: json['size_sqft']?.toString(),
      price: json['price']?.toString(),
      summitId: (json['summit_id'] ?? '').toString(),
      assignedAt: (json['assigned_at'] ?? '').toString().trim(),
    );
  }
}

class AdminSponsorDetail {
  final String sponsorId;
  final String sponsorType;
  final String sponsorCategory;
  final String companyName;
  final String contactPerson;
  final String designation;
  final String email;
  final String mobile;
  final String website;
  final String companyDescription;
  final String? logo;
  final String? bannerImage;
  final String? brochureFile;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<dynamic> media;
  final List<AdminSponsorBoothAssignment> booths;

  const AdminSponsorDetail({
    this.sponsorId = '',
    this.sponsorType = '',
    this.sponsorCategory = '',
    this.companyName = '',
    this.contactPerson = '',
    this.designation = '',
    this.email = '',
    this.mobile = '',
    this.website = '',
    this.companyDescription = '',
    this.logo,
    this.bannerImage,
    this.brochureFile,
    this.status = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.media = const [],
    this.booths = const [],
  });

  factory AdminSponsorDetail.fromJson(Map<String, dynamic> json) {
    final rawBooths = json['booths'] is List ? json['booths'] as List : [];
    return AdminSponsorDetail(
      sponsorId: (json['sponsor_id'] ?? '').toString(),
      sponsorType: (json['sponsor_type'] ?? '').toString().trim(),
      sponsorCategory: (json['sponsor_category'] ?? '').toString().trim(),
      companyName: (json['company_name'] ?? '').toString().trim(),
      contactPerson: (json['contact_person'] ?? json['contact_psponsor_id'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      website: (json['website'] ?? '').toString().trim(),
      companyDescription: (json['company_description'] ?? '').toString().trim(),
      logo: json['logo']?.toString(),
      bannerImage: json['banner_image']?.toString(),
      brochureFile: json['brochure_file']?.toString(),
      status: (json['status'] ?? '').toString().trim(),
      createdAt: (json['created_at'] ?? '').toString().trim(),
      updatedAt: (json['updated_at'] ?? '').toString().trim(),
      media: json['media'] is List ? json['media'] as List : const [],
      booths: rawBooths.map((e) => AdminSponsorBoothAssignment.fromJson(e)).toList(),
    );
  }
}

class AdminSponsor {
  final String sponsorId;
  final String sponsorType;
  final String sponsorCategory;
  final String companyName;
  final String contactPerson;
  final String designation;
  final String email;
  final String mobile;
  final String website;
  final String companyDescription;
  final String? logo;
  final String? bannerImage;
  final String? brochureFile;
  final String status;
  final String createdAt;
  final String boothCount;

  const AdminSponsor({
    this.sponsorId = '',
    this.sponsorType = '',
    this.sponsorCategory = '',
    this.companyName = '',
    this.contactPerson = '',
    this.designation = '',
    this.email = '',
    this.mobile = '',
    this.website = '',
    this.companyDescription = '',
    this.logo,
    this.bannerImage,
    this.brochureFile,
    this.status = '',
    this.createdAt = '',
    this.boothCount = '0',
  });

  factory AdminSponsor.fromJson(Map<String, dynamic> json) {
    return AdminSponsor(
      sponsorId: (json['sponsor_id'] ?? '').toString(),
      sponsorType: (json['sponsor_type'] ?? '').toString().trim(),
      sponsorCategory: (json['sponsor_category'] ?? '').toString().trim(),
      companyName: (json['company_name'] ?? '').toString().trim(),
      contactPerson: (json['contact_person'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      website: (json['website'] ?? '').toString().trim(),
      companyDescription: (json['company_description'] ?? '').toString().trim(),
      logo: json['logo']?.toString(),
      bannerImage: json['banner_image']?.toString(),
      brochureFile: json['brochure_file']?.toString(),
      status: (json['status'] ?? '').toString().trim(),
      createdAt: (json['created_at'] ?? '').toString().trim(),
      boothCount: (json['booth_count'] ?? '0').toString().trim(),
    );
  }
}

class AdminBooth {
  final String assignmentId;
  final String boothId;
  final String boothNumber;
  final String boothLabel;
  final String? boothType;
  final String? sizeSqft;
  final String? price;
  final String sponsorId;
  final String companyName;
  final String contactPerson;
  final String mobile;
  final String email;
  final String status;
  final String assignedAt;
  final bool isAssigned;

  const AdminBooth({
    this.assignmentId = '',
    this.boothId = '',
    this.boothNumber = '',
    this.boothLabel = '',
    this.boothType,
    this.sizeSqft,
    this.price,
    this.sponsorId = '',
    this.companyName = '',
    this.contactPerson = '',
    this.mobile = '',
    this.email = '',
    this.status = '',
    this.assignedAt = '',
    this.isAssigned = false,
  });

  factory AdminBooth.fromJson(Map<String, dynamic> json) {
    final rawIsAssigned = json['is_assigned'];
    final bool assignedFlag = rawIsAssigned == true ||
        rawIsAssigned == 1 ||
        rawIsAssigned == '1' ||
        rawIsAssigned == 'true';
    final bool assignedStatus = (json['assignment_status'] ?? '').toString().toLowerCase() == 'assigned';
    final bool hasCompany = (json['company_name'] ?? '').toString().trim().isNotEmpty;
    final bool hasSponsor = (json['sponsor_id'] ?? '').toString().trim().isNotEmpty && (json['sponsor_id'] ?? '').toString().trim() != '0';
    final bool hasAssignment = (json['assignment_id'] ?? '').toString().trim().isNotEmpty && (json['assignment_id'] ?? '').toString().trim() != '0';
    final String st = (json['status'] ?? '').toString().trim().toUpperCase();
    final bool statusAssigned = st == 'ASSIGNED' || st == 'BOOKED' || st == 'ALLOCATED';

    final bool isAssigned = assignedFlag || assignedStatus || hasCompany || hasSponsor || hasAssignment || statusAssigned;

    return AdminBooth(
      assignmentId: (json['assignment_id'] ?? '').toString(),
      boothId: (json['booth_id'] ?? '').toString(),
      boothNumber: (json['booth_number'] ?? '').toString().trim(),
      boothLabel: (json['booth_label'] ?? '').toString().trim(),
      boothType: json['booth_type']?.toString(),
      sizeSqft: json['size_sqft']?.toString(),
      price: json['price']?.toString(),
      sponsorId: (json['sponsor_id'] ?? '').toString(),
      companyName: (json['company_name'] ?? '').toString().trim(),
      contactPerson: (json['contact_person'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      assignedAt: (json['assigned_at'] ?? '').toString().trim(),
      isAssigned: isAssigned,
    );
  }
}

class AdminBoothDetail {
  final String boothId;
  final String summitId;
  final String boothNumber;
  final String boothLabel;
  final String? boothType;
  final String? sizeSqft;
  final String? price;
  final String status;
  final bool isAssigned;
  final AdminSponsor? sponsor;

  const AdminBoothDetail({
    this.boothId = '',
    this.summitId = '',
    this.boothNumber = '',
    this.boothLabel = '',
    this.boothType,
    this.sizeSqft,
    this.price,
    this.status = '',
    this.isAssigned = false,
    this.sponsor,
  });

  factory AdminBoothDetail.fromJson(Map<String, dynamic> json) {
    return AdminBoothDetail(
      boothId: (json['booth_id'] ?? '').toString(),
      summitId: (json['summit_id'] ?? '').toString(),
      boothNumber: (json['booth_number'] ?? '').toString().trim(),
      boothLabel: (json['booth_label'] ?? '').toString().trim(),
      boothType: json['booth_type']?.toString(),
      sizeSqft: json['size_sqft']?.toString(),
      price: json['price']?.toString(),
      status: (json['status'] ?? '').toString().trim(),
      isAssigned: json['is_assigned'] == true || json['is_assigned'] == 1 || json['is_assigned'] == '1',
      sponsor: json['sponsor'] is Map ? AdminSponsor.fromJson(json['sponsor']) : null,
    );
  }
}

class AdminSlotItem {
  final String slotId;
  final String slotName;
  final String slotLabel;
  final String slotNumber;
  final String startTime;
  final String endTime;
  final String slotStatus;
  final bool isAssigned;
  final String? topicId;
  final String? topicTitle;
  final String? speakerName;
  final String? assignmentId;

  bool get isCancelled => slotStatus.toUpperCase() == 'CANCELLED';

  const AdminSlotItem({
    this.slotId = '',
    this.slotName = '',
    this.slotLabel = '',
    this.slotNumber = '',
    this.startTime = '',
    this.endTime = '',
    this.slotStatus = 'FREE',
    this.isAssigned = false,
    this.topicId,
    this.topicTitle,
    this.speakerName,
    this.assignmentId,
  });

  factory AdminSlotItem.fromJson(Map<String, dynamic> json) {
    String? rawTopicId = json['topic_id']?.toString();
    String? rawTopicTitle = json['topic_title']?.toString() ?? json['title']?.toString() ?? json['topic_name']?.toString();
    String? rawSpeakerName = json['speaker_name']?.toString() ?? json['full_name']?.toString() ?? json['speaker_full_name']?.toString() ?? json['candidate_name']?.toString();
    String? rawAssignmentId = (json['assignment_id'] ?? json['session_assignment_id'] ?? json['slot_assignment_id'])?.toString();

    // Check nested topic map
    if (json['topic'] is Map) {
      final t = json['topic'] as Map<String, dynamic>;
      rawTopicId ??= t['topic_id']?.toString() ?? t['id']?.toString();
      rawTopicTitle ??= t['title']?.toString() ?? t['topic_title']?.toString() ?? t['topic_name']?.toString();
      rawSpeakerName ??= t['speaker_name']?.toString() ?? t['full_name']?.toString();
    }

    // Check nested speaker map
    if (json['speaker'] is Map) {
      final s = json['speaker'] as Map<String, dynamic>;
      rawSpeakerName ??= s['full_name']?.toString() ?? s['speaker_name']?.toString() ?? s['name']?.toString();
    }

    // Check nested sessions list
    if (json['sessions'] is List && (json['sessions'] as List).isNotEmpty) {
      final firstSess = (json['sessions'] as List).first;
      if (firstSess is Map<String, dynamic>) {
        if (firstSess['topic'] is Map) {
          final t = firstSess['topic'] as Map<String, dynamic>;
          rawTopicId ??= t['topic_id']?.toString() ?? t['id']?.toString();
          rawTopicTitle ??= t['title']?.toString() ?? t['topic_title']?.toString();
        } else {
          rawTopicId ??= firstSess['topic_id']?.toString();
          rawTopicTitle ??= firstSess['topic_title']?.toString() ?? firstSess['title']?.toString();
        }

        if (firstSess['speaker'] is Map) {
          final s = firstSess['speaker'] as Map<String, dynamic>;
          rawSpeakerName ??= s['full_name']?.toString() ?? s['speaker_name']?.toString();
        } else {
          rawSpeakerName ??= firstSess['speaker_name']?.toString() ?? firstSess['full_name']?.toString();
        }
      }
    } else if (json['session'] is Map) {
      final sMap = json['session'] as Map<String, dynamic>;
      if (sMap['topic'] is Map) {
        final t = sMap['topic'] as Map<String, dynamic>;
        rawTopicId ??= t['topic_id']?.toString() ?? t['id']?.toString();
        rawTopicTitle ??= t['title']?.toString() ?? t['topic_title']?.toString();
      } else {
        rawTopicId ??= sMap['topic_id']?.toString();
        rawTopicTitle ??= sMap['topic_title']?.toString() ?? sMap['title']?.toString();
      }

      if (sMap['speaker'] is Map) {
        final sp = sMap['speaker'] as Map<String, dynamic>;
        rawSpeakerName ??= sp['full_name']?.toString() ?? sp['speaker_name']?.toString();
      } else {
        rawSpeakerName ??= sMap['speaker_name']?.toString() ?? sMap['full_name']?.toString();
      }
    }

    if (rawTopicId != null && (rawTopicId.isEmpty || rawTopicId == 'null')) rawTopicId = null;
    if (rawTopicTitle != null && (rawTopicTitle.isEmpty || rawTopicTitle == 'null')) rawTopicTitle = null;
    if (rawSpeakerName != null && (rawSpeakerName.isEmpty || rawSpeakerName == 'null')) rawSpeakerName = null;

    final String rawStatus = (json['slot_status'] ?? json['status'] ?? '').toString().trim();
    final String upperStatus = rawStatus.toUpperCase();
    final bool isCancelled = upperStatus == 'CANCELLED';

    final bool hasAssignedTopic = (rawTopicId != null && rawTopicId.isNotEmpty && rawTopicId != '0') ||
        (rawTopicTitle != null && rawTopicTitle.isNotEmpty);

    final bool statusIsAssigned = upperStatus == 'ASSIGNED' || upperStatus == 'BOOKED' || upperStatus == 'ALLOCATED';

    final bool explicitAssigned = json['is_assigned'] == true ||
        json['is_assigned'] == 1 ||
        json['is_assigned'] == '1';

    final bool isAssigned = !isCancelled && (statusIsAssigned || (explicitAssigned && hasAssignedTopic) || (upperStatus.isNotEmpty && upperStatus != 'FREE' && upperStatus != 'UNASSIGNED'));

    final String finalSlotStatus = rawStatus.isNotEmpty
        ? rawStatus
        : (isAssigned ? 'ASSIGNED' : 'FREE');

    final rawStartTime = (json['start_time'] ?? json['from_time'] ?? json['slot_start_time'] ?? json['start'] ?? json['schedule_time'] ?? json['time'] ?? json['slot_time'] ?? json['time_slot'] ?? '').toString().trim();
    final rawEndTime = (json['end_time'] ?? json['to_time'] ?? json['slot_end_time'] ?? json['end'] ?? '').toString().trim();

    String finalStartTime = rawStartTime;
    String finalEndTime = rawEndTime;
    if (finalEndTime.isEmpty && (finalStartTime.contains('-') || finalStartTime.contains('–'))) {
      final parts = finalStartTime.split(RegExp(r'[-–]'));
      if (parts.length >= 2) {
        finalStartTime = parts[0].trim();
        finalEndTime = parts[1].trim();
      }
    }

    return AdminSlotItem(
      slotId: (json['slot_id'] ?? json['id'] ?? '').toString(),
      slotName: (json['slot_name'] ?? '').toString().trim(),
      slotLabel: (json['slot_label'] ?? '').toString().trim(),
      slotNumber: (json['slot_number'] ?? '').toString().trim(),
      startTime: finalStartTime,
      endTime: finalEndTime,
      slotStatus: finalSlotStatus,
      isAssigned: isAssigned,
      topicId: isCancelled ? null : rawTopicId,
      topicTitle: isCancelled ? null : rawTopicTitle,
      speakerName: isCancelled ? null : rawSpeakerName,
      assignmentId: rawAssignmentId,
    );
  }
}

class AdminSlotScheduleDay {
  final String scheduleDay;
  final String scheduleDate;
  final List<AdminSlotItem> slots;

  const AdminSlotScheduleDay({
    this.scheduleDay = '',
    this.scheduleDate = '',
    this.slots = const [],
  });

  factory AdminSlotScheduleDay.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'] is List ? json['slots'] as List : [];
    return AdminSlotScheduleDay(
      scheduleDay: (json['schedule_day'] ?? '').toString().trim(),
      scheduleDate: (json['schedule_date'] ?? '').toString().trim(),
      slots: rawSlots.map((e) => AdminSlotItem.fromJson(e)).toList(),
    );
  }
}

class AdminHallTrack {
  final String hallId;
  final String hallName;
  final String hallLabel;
  final List<AdminSlotScheduleDay> days;

  const AdminHallTrack({
    this.hallId = '',
    this.hallName = '',
    this.hallLabel = '',
    this.days = const [],
  });

  factory AdminHallTrack.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] is List ? json['days'] as List : [];
    return AdminHallTrack(
      hallId: (json['hall_id'] ?? '').toString(),
      hallName: (json['hall_name'] ?? '').toString().trim(),
      hallLabel: (json['hall_label'] ?? '').toString().trim(),
      days: rawDays.map((e) => AdminSlotScheduleDay.fromJson(e)).toList(),
    );
  }
}

class AdminSlotDetailTopic {
  final String topicId;
  final String title;
  final String categoryOfSubmission;
  final String presentationFormat;
  final String status;
  final String topicStatus;

  const AdminSlotDetailTopic({
    this.topicId = '',
    this.title = '',
    this.categoryOfSubmission = '',
    this.presentationFormat = '',
    this.status = '',
    this.topicStatus = '',
  });

  factory AdminSlotDetailTopic.fromJson(Map<String, dynamic> json) {
    return AdminSlotDetailTopic(
      topicId: (json['topic_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString().trim(),
      categoryOfSubmission: (json['category_of_submission'] ?? '').toString().trim(),
      presentationFormat: (json['presentation_format'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      topicStatus: (json['topic_status'] ?? '').toString().trim(),
    );
  }
}

class AdminSlotDetailSpeaker {
  final String speakerId;
  final String fullName;
  final String mobile;
  final String email;
  final String designation;
  final String organisation;

  const AdminSlotDetailSpeaker({
    this.speakerId = '',
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.designation = '',
    this.organisation = '',
  });

  factory AdminSlotDetailSpeaker.fromJson(Map<String, dynamic> json) {
    return AdminSlotDetailSpeaker(
      speakerId: (json['speaker_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString().trim(),
      mobile: (json['mobile'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      designation: (json['designation'] ?? '').toString().trim(),
      organisation: (json['organisation'] ?? '').toString().trim(),
    );
  }
}

class AdminSlotSessionAssignment {
  final String assignmentId;
  final AdminSlotDetailTopic? topic;
  final AdminSlotDetailSpeaker? speaker;
  final String assignmentStatus;
  final String remarks;
  final String assignedOn;

  const AdminSlotSessionAssignment({
    this.assignmentId = '',
    this.topic,
    this.speaker,
    this.assignmentStatus = '',
    this.remarks = '',
    this.assignedOn = '',
  });

  factory AdminSlotSessionAssignment.fromJson(Map<String, dynamic> json) {
    return AdminSlotSessionAssignment(
      assignmentId: (json['assignment_id'] ?? '').toString(),
      topic: json['topic'] is Map ? AdminSlotDetailTopic.fromJson(json['topic']) : null,
      speaker: json['speaker'] is Map ? AdminSlotDetailSpeaker.fromJson(json['speaker']) : null,
      assignmentStatus: (json['assignment_status'] ?? '').toString().trim(),
      remarks: (json['remarks'] ?? '').toString().trim(),
      assignedOn: (json['assigned_on'] ?? '').toString().trim(),
    );
  }
}

class AdminSlotDetail {
  final String slotId;
  final String venueId;
  final String venueName;
  final String hallId;
  final String hallName;
  final String hallLabel;
  final String summitId;
  final String scheduleDate;
  final String scheduleDay;
  final String slotName;
  final String slotLabel;
  final String slotNumber;
  final String startTime;
  final String endTime;
  final String slotStatus;
  final String status;
  final bool isAssigned;
  final List<AdminSlotSessionAssignment> sessions;
  final AdminSlotDetailTopic? topic;
  final AdminSlotDetailSpeaker? speaker;

  bool get isCancelled => slotStatus.toUpperCase() == 'CANCELLED' || status.toUpperCase() == 'CANCELLED';

  const AdminSlotDetail({
    this.slotId = '',
    this.venueId = '',
    this.venueName = '',
    this.hallId = '',
    this.hallName = '',
    this.hallLabel = '',
    this.summitId = '',
    this.scheduleDate = '',
    this.scheduleDay = '',
    this.slotName = '',
    this.slotLabel = '',
    this.slotNumber = '',
    this.startTime = '',
    this.endTime = '',
    this.slotStatus = 'FREE',
    this.status = '',
    this.isAssigned = false,
    this.sessions = const [],
    this.topic,
    this.speaker,
  });

  factory AdminSlotDetail.fromJson(Map<String, dynamic> json) {
    List<AdminSlotSessionAssignment> sessionsList = [];
    if (json['sessions'] is List) {
      sessionsList = (json['sessions'] as List)
          .whereType<Map<String, dynamic>>()
          .map((s) => AdminSlotSessionAssignment.fromJson(s))
          .toList();
    }

    AdminSlotDetailTopic? directTopic =
        json['topic'] is Map ? AdminSlotDetailTopic.fromJson(json['topic']) : null;
    AdminSlotDetailSpeaker? directSpeaker =
        json['speaker'] is Map ? AdminSlotDetailSpeaker.fromJson(json['speaker']) : null;

    if (directTopic == null && sessionsList.isNotEmpty) {
      directTopic = sessionsList.first.topic;
    }
    if (directSpeaker == null && sessionsList.isNotEmpty) {
      directSpeaker = sessionsList.first.speaker;
    }

    final rawSlotStatus = (json['slot_status'] ?? '').toString().trim();
    final rawGeneralStatus = (json['status'] ?? '').toString().trim();
    final bool isCancelled = rawSlotStatus.toUpperCase() == 'CANCELLED' || rawGeneralStatus.toUpperCase() == 'CANCELLED';

    final bool isAssigned = !isCancelled && (
        json['is_assigned'] == true ||
        json['is_assigned'] == 1 ||
        json['is_assigned'] == '1' ||
        rawSlotStatus.toUpperCase() == 'ASSIGNED' ||
        rawSlotStatus.toUpperCase() == 'BOOKED' ||
        rawSlotStatus.toUpperCase() == 'ALLOCATED' ||
        (sessionsList.isNotEmpty && !isCancelled)
    );

    final rawStartTime = (json['start_time'] ?? json['from_time'] ?? json['slot_start_time'] ?? json['start'] ?? json['schedule_time'] ?? json['time'] ?? json['slot_time'] ?? json['time_slot'] ?? '').toString().trim();
    final rawEndTime = (json['end_time'] ?? json['to_time'] ?? json['slot_end_time'] ?? json['end'] ?? '').toString().trim();

    String finalStartTime = rawStartTime;
    String finalEndTime = rawEndTime;
    if (finalEndTime.isEmpty && (finalStartTime.contains('-') || finalStartTime.contains('–'))) {
      final parts = finalStartTime.split(RegExp(r'[-–]'));
      if (parts.length >= 2) {
        finalStartTime = parts[0].trim();
        finalEndTime = parts[1].trim();
      }
    }

    return AdminSlotDetail(
      slotId: (json['slot_id'] ?? '').toString(),
      venueId: (json['venue_id'] ?? '').toString(),
      venueName: (json['venue_name'] ?? '').toString().trim(),
      hallId: (json['hall_id'] ?? '').toString(),
      hallName: (json['hall_name'] ?? '').toString().trim(),
      hallLabel: (json['hall_label'] ?? '').toString().trim(),
      summitId: (json['summit_id'] ?? '').toString(),
      scheduleDate: (json['schedule_date'] ?? '').toString().trim(),
      scheduleDay: (json['schedule_day'] ?? '').toString().trim(),
      slotName: (json['slot_name'] ?? '').toString().trim(),
      slotLabel: (json['slot_label'] ?? '').toString().trim(),
      slotNumber: (json['slot_number'] ?? '').toString().trim(),
      startTime: finalStartTime,
      endTime: finalEndTime,
      slotStatus: rawSlotStatus.isNotEmpty ? rawSlotStatus : (isAssigned ? 'ASSIGNED' : 'FREE'),
      status: rawGeneralStatus,
      isAssigned: isAssigned,
      sessions: isCancelled ? const [] : sessionsList,
      topic: isCancelled ? null : directTopic,
      speaker: isCancelled ? null : directSpeaker,
    );
  }
}

// ==========================================
// Admin Provider
// ==========================================

class AdminProvider with ChangeNotifier {
  // Stats
  AdminDashboardStats? _stats;
  bool _isLoadingStats = false;
  String? _statsError;

  // Speakers
  List<AdminSpeaker> _speakers = [];
  AdminPagination _speakersPagination = const AdminPagination();
  bool _isLoadingSpeakers = false;
  bool _isLoadingMoreSpeakers = false;
  String? _speakersError;
  String _speakerSearch = '';

  // Delegates
  List<AdminDelegate> _delegates = [];
  AdminPagination _delegatesPagination = const AdminPagination();
  bool _isLoadingDelegates = false;
  bool _isLoadingMoreDelegates = false;
  String? _delegatesError;
  String _delegateSearch = '';

  // Topics
  List<AdminTopic> _topics = [];
  AdminPagination _topicsPagination = const AdminPagination();
  bool _isLoadingTopics = false;
  bool _isLoadingMoreTopics = false;
  String? _topicsError;
  String _topicSearch = '';

  // Workshops
  List<AdminWorkshop> _workshops = [];
  AdminPagination _workshopsPagination = const AdminPagination();
  bool _isLoadingWorkshops = false;
  bool _isLoadingMoreWorkshops = false;
  String? _workshopsError;
  String _workshopSearch = '';

  // Sponsors
  List<AdminSponsor> _sponsors = [];
  AdminPagination _sponsorsPagination = const AdminPagination();
  bool _isLoadingSponsors = false;
  bool _isLoadingMoreSponsors = false;
  String? _sponsorsError;
  String _sponsorSearch = '';

  // Sponsor Categories
  List<AdminSponsorCategory> _sponsorCategories = [];
  bool _isLoadingSponsorCategories = false;
  String? _sponsorCategoriesError;

  // Booths
  List<AdminBooth> _booths = [];
  AdminPagination _boothsPagination = const AdminPagination();
  bool _isLoadingBooths = false;
  bool _isLoadingMoreBooths = false;
  String? _boothsError;
  String _boothSearch = '';

  // Slots
  List<AdminHallTrack> _hallTracks = [];
  bool _isLoadingSlots = false;
  String? _slotsError;

  // Getters
  AdminDashboardStats? get stats => _stats;
  bool get isLoadingStats => _isLoadingStats;
  String? get statsError => _statsError;

  List<AdminSpeaker> get speakers => _speakers;
  AdminPagination get speakersPagination => _speakersPagination;
  bool get isLoadingSpeakers => _isLoadingSpeakers;
  bool get isLoadingMoreSpeakers => _isLoadingMoreSpeakers;
  String? get speakersError => _speakersError;
  String get speakerSearch => _speakerSearch;

  List<AdminDelegate> get delegates => _delegates;
  AdminPagination get delegatesPagination => _delegatesPagination;
  bool get isLoadingDelegates => _isLoadingDelegates;
  bool get isLoadingMoreDelegates => _isLoadingMoreDelegates;
  String? get delegatesError => _delegatesError;
  String get delegateSearch => _delegateSearch;

  List<AdminTopic> get topics => _topics;
  AdminPagination get topicsPagination => _topicsPagination;
  bool get isLoadingTopics => _isLoadingTopics;
  bool get isLoadingMoreTopics => _isLoadingMoreTopics;
  String? get topicsError => _topicsError;
  String get topicSearch => _topicSearch;

  List<AdminWorkshop> get workshops => _workshops;
  AdminPagination get workshopsPagination => _workshopsPagination;
  bool get isLoadingWorkshops => _isLoadingWorkshops;
  bool get isLoadingMoreWorkshops => _isLoadingMoreWorkshops;
  String? get workshopsError => _workshopsError;
  String get workshopSearch => _workshopSearch;

  List<AdminSponsor> get sponsors => _sponsors;
  AdminPagination get sponsorsPagination => _sponsorsPagination;
  bool get isLoadingSponsors => _isLoadingSponsors;
  bool get isLoadingMoreSponsors => _isLoadingMoreSponsors;
  String? get sponsorsError => _sponsorsError;
  String get sponsorSearch => _sponsorSearch;

  List<AdminSponsorCategory> get sponsorCategories => _sponsorCategories;
  bool get isLoadingSponsorCategories => _isLoadingSponsorCategories;
  String? get sponsorCategoriesError => _sponsorCategoriesError;

  List<AdminBooth> get booths => _booths;
  AdminPagination get boothsPagination => _boothsPagination;
  bool get isLoadingBooths => _isLoadingBooths;
  bool get isLoadingMoreBooths => _isLoadingMoreBooths;
  String? get boothsError => _boothsError;
  String get boothSearch => _boothSearch;

  List<AdminHallTrack> get hallTracks => _hallTracks;
  bool get isLoadingSlots => _isLoadingSlots;
  String? get slotsError => _slotsError;

  // ==========================================
  // Fetch All Initial Admin Data
  // ==========================================
  Future<void> fetchAllAdminData(String accessToken, {int summitId = 1, bool forceRefresh = false}) async {
    if (accessToken.isEmpty) return;

    await Future.wait([
      fetchDashboardStats(accessToken, summitId: summitId, forceRefresh: forceRefresh),
      fetchSpeakers(accessToken, forceRefresh: forceRefresh),
      fetchDelegates(accessToken, forceRefresh: forceRefresh),
      fetchTopics(accessToken, summitId: summitId, forceRefresh: forceRefresh),
      fetchWorkshops(accessToken, summitId: summitId, forceRefresh: forceRefresh),
      fetchSponsors(accessToken, summitId: summitId, forceRefresh: forceRefresh),
      fetchSponsorCategories(accessToken, forceRefresh: forceRefresh),
      fetchBooths(accessToken, summitId: summitId, forceRefresh: forceRefresh),
      fetchSlots(accessToken, summitId: summitId, forceRefresh: forceRefresh),
    ]);
    _enrichTopicsWithSlotSchedule();
    notifyListeners();
  }

  // ==========================================
  // Dashboard Stats
  // ==========================================
  Future<void> fetchDashboardStats(String accessToken, {int summitId = 1, bool forceRefresh = false}) async {
    if (accessToken.isEmpty) return;
    if (!forceRefresh && _stats != null) return;

    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchAdminDashboardStats(
        accessToken: accessToken,
        summitId: summitId,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          _stats = AdminDashboardStats.fromJson(body['data']);
        } else {
          _statsError = body['message']?.toString() ?? 'Failed to load stats';
        }
      } else {
        _statsError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin stats failed', e, stack);
      _statsError = e.toString();
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Speakers
  // ==========================================
  Future<void> fetchSpeakers(
    String accessToken, {
    bool loadMore = false,
    String? search,
    String? category,
    String? citizenType,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;

    if (search != null) {
      _speakerSearch = search;
    }

    if (loadMore) {
      if (_isLoadingMoreSpeakers || !_speakersPagination.hasNext) return;
      _isLoadingMoreSpeakers = true;
      notifyListeners();
    } else {
      if (!forceRefresh && _speakers.isNotEmpty && search == null && category == null) return;
      _isLoadingSpeakers = true;
      _speakersError = null;
      notifyListeners();
    }

    final targetPage = loadMore ? _speakersPagination.currentPage + 1 : 1;

    try {
      final response = await ApiService.fetchAdminAllSpeakers(
        accessToken: accessToken,
        page: targetPage,
        limit: 10,
        search: _speakerSearch.isNotEmpty ? _speakerSearch : null,
        category: category,
        citizenType: citizenType,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final List rawList = body['data'] is List ? body['data'] : [];
          final newSpeakers = rawList.map((e) => AdminSpeaker.fromJson(e)).toList();

          if (loadMore) {
            _speakers.addAll(newSpeakers);
          } else {
            _speakers = newSpeakers;
          }

          if (body['pagination'] != null) {
            _speakersPagination = AdminPagination.fromJson(body['pagination']);
          }
        } else {
          _speakersError = body['message']?.toString() ?? 'Failed to load speakers';
        }
      } else {
        _speakersError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin speakers failed', e, stack);
      _speakersError = e.toString();
    } finally {
      _isLoadingSpeakers = false;
      _isLoadingMoreSpeakers = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Delegates
  // ==========================================
  Future<void> fetchDelegates(
    String accessToken, {
    bool loadMore = false,
    String? search,
    String? category,
    String? citizenType,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;

    if (search != null) {
      _delegateSearch = search;
    }

    if (loadMore) {
      if (_isLoadingMoreDelegates || !_delegatesPagination.hasNext) return;
      _isLoadingMoreDelegates = true;
      notifyListeners();
    } else {
      if (!forceRefresh && _delegates.isNotEmpty && search == null && category == null) return;
      _isLoadingDelegates = true;
      _delegatesError = null;
      notifyListeners();
    }

    final targetPage = loadMore ? _delegatesPagination.currentPage + 1 : 1;

    try {
      final response = await ApiService.fetchAdminAllDelegates(
        accessToken: accessToken,
        page: targetPage,
        limit: 10,
        search: _delegateSearch.isNotEmpty ? _delegateSearch : null,
        category: category,
        citizenType: citizenType,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final List rawList = body['data'] is List ? body['data'] : [];
          final newDelegates = rawList.map((e) => AdminDelegate.fromJson(e)).toList();

          if (loadMore) {
            _delegates.addAll(newDelegates);
          } else {
            _delegates = newDelegates;
          }

          if (body['pagination'] != null) {
            _delegatesPagination = AdminPagination.fromJson(body['pagination']);
          }
        } else {
          _delegatesError = body['message']?.toString() ?? 'Failed to load delegates';
        }
      } else {
        _delegatesError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin delegates failed', e, stack);
      _delegatesError = e.toString();
    } finally {
      _isLoadingDelegates = false;
      _isLoadingMoreDelegates = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Topics
  // ==========================================
  Future<void> fetchTopics(
    String accessToken, {
    bool loadMore = false,
    String? search,
    String? categoryOfSubmission,
    String? status,
    int summitId = 1,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;

    if (search != null) {
      _topicSearch = search;
    }

    if (loadMore) {
      if (_isLoadingMoreTopics || !_topicsPagination.hasNext) return;
      _isLoadingMoreTopics = true;
      notifyListeners();
    } else {
      if (!forceRefresh && _topics.isNotEmpty && search == null && categoryOfSubmission == null && status == null) return;
      _isLoadingTopics = true;
      _topicsError = null;
      notifyListeners();
    }

    final targetPage = loadMore ? _topicsPagination.currentPage + 1 : 1;

    try {
      final response = await ApiService.fetchAdminAllTopics(
        accessToken: accessToken,
        page: targetPage,
        limit: 100,
        summitId: summitId,
        search: _topicSearch.isNotEmpty ? _topicSearch : null,
        categoryOfSubmission: categoryOfSubmission,
        status: status,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final List rawList = body['data'] is List ? body['data'] : [];
          final newTopics = rawList.map((e) => AdminTopic.fromJson(e)).toList();

          if (loadMore) {
            _topics.addAll(newTopics);
          } else {
            _topics = newTopics;
          }
          _enrichTopicsWithSlotSchedule();

          if (body['pagination'] != null) {
            _topicsPagination = AdminPagination.fromJson(body['pagination']);
          }
        } else {
          _topicsError = body['message']?.toString() ?? 'Failed to load topics';
        }
      } else {
        _topicsError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin topics failed', e, stack);
      _topicsError = e.toString();
    } finally {
      _isLoadingTopics = false;
      _isLoadingMoreTopics = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Workshops
  // ==========================================
  Future<void> fetchWorkshops(
    String accessToken, {
    bool loadMore = false,
    String? search,
    int summitId = 1,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;

    if (search != null) {
      _workshopSearch = search;
    }

    if (loadMore) {
      if (_isLoadingMoreWorkshops || !_workshopsPagination.hasNext) return;
      _isLoadingMoreWorkshops = true;
      notifyListeners();
    } else {
      if (!forceRefresh && _workshops.isNotEmpty && search == null) return;
      _isLoadingWorkshops = true;
      _workshopsError = null;
      notifyListeners();
    }

    final targetPage = loadMore ? _workshopsPagination.currentPage + 1 : 1;

    try {
      final response = await ApiService.fetchAdminAllWorkshops(
        accessToken: accessToken,
        page: targetPage,
        limit: 50,
        workshopStatus: 1,
        summitId: summitId,
        search: _workshopSearch.isNotEmpty ? _workshopSearch : null,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final List rawList = body['data'] is List ? body['data'] : [];
          final newWorkshops = rawList.map((e) => AdminWorkshop.fromJson(e)).toList();

          if (loadMore) {
            _workshops.addAll(newWorkshops);
          } else {
            _workshops = newWorkshops;
          }

          if (body['pagination'] != null) {
            _workshopsPagination = AdminPagination.fromJson(body['pagination']);
          }
        } else {
          _workshopsError = body['message']?.toString() ?? 'Failed to load workshops';
        }
      } else {
        _workshopsError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin workshops failed', e, stack);
      _workshopsError = e.toString();
    } finally {
      _isLoadingWorkshops = false;
      _isLoadingMoreWorkshops = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Sponsors
  // ==========================================
  Future<void> fetchSponsors(
    String accessToken, {
    bool loadMore = false,
    String? search,
    String? sponsorType,
    String? sponsorCategory,
    int summitId = 1,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;

    if (search != null) {
      _sponsorSearch = search;
    }

    if (loadMore) {
      if (_isLoadingMoreSponsors || !_sponsorsPagination.hasNext) return;
      _isLoadingMoreSponsors = true;
      notifyListeners();
    } else {
      if (!forceRefresh && _sponsors.isNotEmpty && search == null && sponsorType == null && sponsorCategory == null) return;
      _isLoadingSponsors = true;
      _sponsorsError = null;
      notifyListeners();
    }

    final targetPage = loadMore ? _sponsorsPagination.currentPage + 1 : 1;

    try {
      final response = await ApiService.fetchAdminAllSponsors(
        accessToken: accessToken,
        page: targetPage,
        limit: 50,
        summitId: summitId,
        search: _sponsorSearch.isNotEmpty ? _sponsorSearch : null,
        sponsorType: sponsorType,
        sponsorCategory: sponsorCategory,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final List rawList = body['data'] is List ? body['data'] : [];
          final newSponsors = rawList.map((e) => AdminSponsor.fromJson(e)).toList();

          if (loadMore) {
            _sponsors.addAll(newSponsors);
          } else {
            _sponsors = newSponsors;
          }

          if (body['pagination'] != null) {
            _sponsorsPagination = AdminPagination.fromJson(body['pagination']);
          }
        } else {
          _sponsorsError = body['message']?.toString() ?? 'Failed to load sponsors';
        }
      } else {
        _sponsorsError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin sponsors failed', e, stack);
      _sponsorsError = e.toString();
    } finally {
      _isLoadingSponsors = false;
      _isLoadingMoreSponsors = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Sponsor Categories
  // ==========================================
  Future<void> fetchSponsorCategories(
    String accessToken, {
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;
    if (!forceRefresh && _sponsorCategories.isNotEmpty) return;

    _isLoadingSponsorCategories = true;
    _sponsorCategoriesError = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchAdminAllSponsorCategories(
        accessToken: accessToken,
        page: 1,
        limit: 50,
        status: 1,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] is List) {
          final List rawList = body['data'];
          _sponsorCategories = rawList.map((e) => AdminSponsorCategory.fromJson(e)).toList();
        } else {
          _sponsorCategoriesError = body['message']?.toString() ?? 'Failed to load sponsor categories';
        }
      } else {
        _sponsorCategoriesError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin sponsor categories failed', e, stack);
      _sponsorCategoriesError = e.toString();
    } finally {
      _isLoadingSponsorCategories = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Booths
  // ==========================================
  Future<void> fetchBooths(
    String accessToken, {
    bool loadMore = false,
    String search = '',
    int summitId = 1,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;

    _boothSearch = search;

    if (loadMore) {
      if (_isLoadingMoreBooths || !_boothsPagination.hasNext) return;
      _isLoadingMoreBooths = true;
      notifyListeners();
    } else {
      if (_isLoadingBooths) return;
      if (!forceRefresh && _booths.isNotEmpty && search == _boothSearch) return;
      _isLoadingBooths = true;
      _boothsError = null;
      notifyListeners();
    }

    _boothSearch = search;
    final targetPage = loadMore ? _boothsPagination.currentPage + 1 : 1;

    try {
      final response = await ApiService.fetchAdminAllBooths(
        accessToken: accessToken,
        page: targetPage,
        limit: 150,
        summitId: summitId,
        search: _boothSearch,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final List rawList = body['data'] is List ? body['data'] : [];
          final List<AdminBooth> fetchedBooths = rawList.map((e) => AdminBooth.fromJson(e)).toList();

          if (body['pagination'] != null) {
            _boothsPagination = AdminPagination.fromJson(body['pagination']);
          }

          // Auto-fetch remaining pages on initial load if backend paginated the 102 records
          if (!loadMore && _boothsPagination.hasNext) {
            int nextPage = _boothsPagination.currentPage + 1;
            while (_boothsPagination.hasNext && nextPage <= _boothsPagination.totalPages) {
              final nextResp = await ApiService.fetchAdminAllBooths(
                accessToken: accessToken,
                page: nextPage,
                limit: 150,
                summitId: summitId,
                search: _boothSearch,
              );
              if (nextResp.statusCode == 200) {
                final nextBody = json.decode(nextResp.body);
                if (nextBody['status'] == true && nextBody['data'] != null) {
                  final List nextList = nextBody['data'] is List ? nextBody['data'] : [];
                  final moreBooths = nextList.map((e) => AdminBooth.fromJson(e)).toList();
                  fetchedBooths.addAll(moreBooths);
                  if (nextBody['pagination'] != null) {
                    _boothsPagination = AdminPagination.fromJson(nextBody['pagination']);
                  } else {
                    break;
                  }
                  nextPage++;
                } else {
                  break;
                }
              } else {
                break;
              }
            }
          }

          // Deduplicate by boothId / boothNumber to always guarantee exact 102 records
          final uniqueMap = <String, AdminBooth>{};
          if (loadMore) {
            for (final b in _booths) {
              final key = b.boothId.isNotEmpty ? b.boothId : b.boothNumber;
              uniqueMap[key] = b;
            }
          }
          for (final b in fetchedBooths) {
            final key = b.boothId.isNotEmpty ? b.boothId : b.boothNumber;
            uniqueMap[key] = b;
          }
          _booths = uniqueMap.values.toList();
        } else {
          _boothsError = body['message']?.toString() ?? 'Failed to load booths';
        }
      } else {
        _boothsError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin booths failed', e, stack);
      _boothsError = e.toString();
    } finally {
      _isLoadingBooths = false;
      _isLoadingMoreBooths = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Detailed Entity Fetchers
  // ==========================================

  // Fetch Speaker Details
  Future<AdminSpeakerDetail?> fetchSpeakerDetails(String accessToken, dynamic userId) async {
    if (accessToken.isEmpty) return null;
    try {
      final response = await ApiService.fetchAdminSpeakerDetails(
        accessToken: accessToken,
        userId: userId,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return AdminSpeakerDetail.fromJson(body['data']);
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin speaker details failed', e, stack);
    }
    return null;
  }

  // Fetch Delegate Details
  Future<AdminDelegateDetail?> fetchDelegateDetails(String accessToken, dynamic userId) async {
    if (accessToken.isEmpty) return null;
    try {
      final response = await ApiService.fetchAdminDelegateDetails(
        accessToken: accessToken,
        userId: userId,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return AdminDelegateDetail.fromJson(body['data']);
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin delegate details failed', e, stack);
    }
    return null;
  }

  // Fetch Topic Details
  Future<AdminTopicDetail?> fetchTopicDetails(String accessToken, dynamic topicId) async {
    if (accessToken.isEmpty) return null;
    try {
      final response = await ApiService.fetchAdminTopicDetails(
        accessToken: accessToken,
        topicId: topicId,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return AdminTopicDetail.fromJson(body['data']);
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin topic details failed', e, stack);
    }
    return null;
  }

  // Fetch Topic Bookmarks
  Future<List<AdminTopicBookmarkItem>> fetchTopicBookmarks(String accessToken, dynamic topicId, {int page = 1, int limit = 20}) async {
    if (accessToken.isEmpty) return [];
    try {
      final response = await ApiService.fetchAdminTopicBookmarks(
        accessToken: accessToken,
        topicId: topicId,
        page: page,
        limit: limit,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] is List) {
          return (body['data'] as List).map((e) => AdminTopicBookmarkItem.fromJson(e)).toList();
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin topic bookmarks failed', e, stack);
    }
    return [];
  }

  // Fetch Workshop Participants
  Future<AdminWorkshopParticipantsData?> fetchWorkshopParticipants(
    String accessToken,
    dynamic workshopId, {
    int speakerPage = 1,
    int speakerLimit = 50,
    int delegatePage = 1,
    int delegateLimit = 50,
  }) async {
    if (accessToken.isEmpty) return null;
    try {
      final response = await ApiService.fetchAdminWorkshopParticipants(
        accessToken: accessToken,
        workshopId: workshopId,
        speakerPage: speakerPage,
        speakerLimit: speakerLimit,
        delegatePage: delegatePage,
        delegateLimit: delegateLimit,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return AdminWorkshopParticipantsData.fromJson(body['data']);
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin workshop participants failed', e, stack);
    }
    return null;
  }

  // Fetch Sponsor Details
  Future<AdminSponsorDetail?> fetchSponsorDetails(
    String accessToken,
    dynamic sponsorId, {
    int summitId = 1,
  }) async {
    if (accessToken.isEmpty) return null;
    try {
      final response = await ApiService.fetchAdminSponsorDetails(
        accessToken: accessToken,
        sponsorId: sponsorId,
        summitId: summitId,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return AdminSponsorDetail.fromJson(body['data']);
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin sponsor details failed', e, stack);
    }
    return null;
  }

  // Fetch Booth Details
  Future<AdminBoothDetail?> fetchBoothDetails(
    String accessToken,
    dynamic boothId, {
    int summitId = 1,
  }) async {
    if (accessToken.isEmpty) return null;
    try {
      final response = await ApiService.fetchAdminBoothDetails(
        accessToken: accessToken,
        boothId: boothId,
        summitId: summitId,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return AdminBoothDetail.fromJson(body['data']);
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin booth details failed', e, stack);
    }
    return null;
  }

  // ==========================================
  // Slots
  // ==========================================
  Future<void> fetchSlots(
    String accessToken, {
    int summitId = 1,
    dynamic hallId,
    dynamic scheduleDay,
    bool forceRefresh = false,
  }) async {
    if (accessToken.isEmpty) return;
    if (!forceRefresh && _hallTracks.isNotEmpty && hallId == null && scheduleDay == null) return;

    _isLoadingSlots = true;
    _slotsError = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchAdminAllSlots(
        accessToken: accessToken,
        summitId: summitId,
        hallId: hallId,
        scheduleDay: scheduleDay,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] is List) {
          final List rawList = body['data'];
          _hallTracks = rawList.map((e) => AdminHallTrack.fromJson(e)).toList();
          _enrichTopicsWithSlotSchedule();
        } else {
          _slotsError = body['message']?.toString() ?? 'Failed to load slots';
        }
      } else {
        _slotsError = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin slots failed', e, stack);
      _slotsError = e.toString();
    } finally {
      _isLoadingSlots = false;
      notifyListeners();
    }
  }

  // Fetch Slot Details
  Future<AdminSlotDetail?> fetchSlotDetails(
    String accessToken,
    dynamic slotId, {
    int summitId = 1,
    dynamic hallId,
    dynamic scheduleDay,
  }) async {
    if (accessToken.isEmpty) return null;
    try {
      final response = await ApiService.fetchAdminSlotDetails(
        accessToken: accessToken,
        slotId: slotId,
        summitId: summitId,
        hallId: hallId,
        scheduleDay: scheduleDay,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['data'] != null) {
          return AdminSlotDetail.fromJson(body['data']);
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('Fetch admin slot details failed', e, stack);
    }
    return null;
  }

  // Helper to look up slot & schedule details for a given topicId across loaded tracks
  Map<String, String>? getTopicScheduleInfo(String topicId, {String? topicTitle}) {
    final targetId = topicId.trim();
    final targetTitle = topicTitle?.trim().toLowerCase();

    for (final track in _hallTracks) {
      for (final day in track.days) {
        for (final slot in day.slots) {
          if (slot.isCancelled) continue;
          bool isMatch = false;
          if (targetId.isNotEmpty && slot.topicId != null && slot.topicId.toString().trim() == targetId) {
            isMatch = true;
          } else if (targetTitle != null && targetTitle.isNotEmpty && slot.topicTitle != null && slot.topicTitle!.trim().toLowerCase() == targetTitle) {
            isMatch = true;
          }

          if (isMatch) {
            return {
              'slot_id': slot.slotId,
              'slot_name': slot.slotName,
              'slot_label': slot.slotLabel,
              'start_time': slot.startTime,
              'end_time': slot.endTime,
              'schedule_date': day.scheduleDate,
              'schedule_day': day.scheduleDay,
              'hall_id': track.hallId,
              'hall_name': track.hallName,
              'hall_label': track.hallLabel,
              'speaker_name': slot.speakerName ?? '',
              'topic_title': slot.topicTitle ?? '',
            };
          }
        }
      }
    }
    return null;
  }

  // Cross-reference and enrich all loaded topics with slot timings and schedule data
  void _enrichTopicsWithSlotSchedule() {
    if (_topics.isEmpty || _hallTracks.isEmpty) return;
    for (int i = 0; i < _topics.length; i++) {
      final t = _topics[i];
      final info = getTopicScheduleInfo(t.topicId, topicTitle: t.title);
      if (info != null) {
        final finalSlotId = t.slotId.isNotEmpty ? t.slotId : (info['slot_id'] ?? '');
        final finalSlotName = t.slotName.isNotEmpty ? t.slotName : (info['slot_name'] ?? '');
        final finalSlotLabel = t.slotLabel.isNotEmpty ? t.slotLabel : (info['slot_label'] ?? '');
        final finalStartTime = t.startTime.isNotEmpty ? t.startTime : (info['start_time'] ?? '');
        final finalEndTime = t.endTime.isNotEmpty ? t.endTime : (info['end_time'] ?? '');
        final finalScheduleDate = t.scheduleDate.isNotEmpty ? t.scheduleDate : (info['schedule_date'] ?? '');
        final finalScheduleDay = t.scheduleDay.isNotEmpty ? t.scheduleDay : (info['schedule_day'] ?? '');
        final finalHallId = t.hallId.isNotEmpty ? t.hallId : (info['hall_id'] ?? '');
        final finalHallName = t.hallName.isNotEmpty ? t.hallName : (info['hall_name'] ?? '');
        final finalHallLabel = t.hallLabel.isNotEmpty ? t.hallLabel : (info['hall_label'] ?? '');

        _topics[i] = AdminTopic(
          topicId: t.topicId,
          speakerId: t.speakerId,
          title: t.title,
          speakerName: t.speakerName,
          categoryOfSubmission: t.categoryOfSubmission,
          status: t.status.isNotEmpty ? t.status : 'confirmed',
          topicStatus: t.topicStatus.isNotEmpty ? t.topicStatus : 'confirmed',
          isPublished: t.isPublished,
          createdBy: t.createdBy,
          createdByName: t.createdByName,
          createdOn: t.createdOn,
          updatedBy: t.updatedBy,
          updatedByName: t.updatedByName,
          updatedOn: t.updatedOn,
          slotId: finalSlotId,
          slotName: finalSlotName,
          slotLabel: finalSlotLabel,
          startTime: finalStartTime,
          endTime: finalEndTime,
          scheduleDate: finalScheduleDate,
          scheduleDay: finalScheduleDay,
          hallId: finalHallId,
          hallName: finalHallName,
          hallLabel: finalHallLabel,
        );
      }
    }
  }
}
