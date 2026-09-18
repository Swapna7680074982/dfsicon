import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sessions_provider.dart';
import '../providers/workshops_provider.dart';
import '../providers/admin_provider.dart';
import '../utils/time_formatter.dart';
import '../screens/calendar/event_calendar_screen.dart';

enum CalendarItemType {
  session,
  myPresentation,
  workshop,
  myWorkshop,
  freeSlot,
  freeTimeGap,
  cancelledSlot,
}

class CalendarEventItem {
  final String id;
  final String title;
  final CalendarItemType type;
  final String scheduleDate; // "YYYY-MM-DD"
  final String scheduleDay;  // "Workshops", "Day 1", "Day 2", "Day 3"
  final String startTime;    // "09:00 AM"
  final String endTime;      // "10:30 AM"
  final String? hallName;
  final String? hallCode;
  final String? speakerName;
  final String? speakerDesignation;
  final String? speakerProfileImage;
  final String? speakerInitials;
  final Color? speakerBg;
  final String? category;
  bool isBookmarked;
  bool isRegistered;
  final String? workshopCode;
  final String? fee;
  final String? description;
  final String? coordinatorName;
  final String? coordinatorPhone;
  final String? coordinatorEmail;
  final String? topicId;
  final String? assignmentId;
  final String? slotStatus;
  final List<String> targetRoles;

  CalendarEventItem({
    required this.id,
    required this.title,
    required this.type,
    required this.scheduleDate,
    required this.scheduleDay,
    required this.startTime,
    required this.endTime,
    this.hallName,
    this.hallCode,
    this.speakerName,
    this.speakerDesignation,
    this.speakerProfileImage,
    this.speakerInitials,
    this.speakerBg,
    this.category,
    this.isBookmarked = false,
    this.isRegistered = false,
    this.workshopCode,
    this.fee,
    this.description,
    this.coordinatorName,
    this.coordinatorPhone,
    this.coordinatorEmail,
    this.topicId,
    this.assignmentId,
    this.slotStatus,
    this.targetRoles = const ['admin', 'speaker', 'delegate'],
  });

  SessionItem toSessionItem() {
    return SessionItem(
      id: int.tryParse(id) ?? id.hashCode,
      title: title,
      speakerName: speakerName ?? 'Presenter',
      speakerTitle: speakerDesignation ?? category ?? '',
      speakerInitials: speakerInitials ?? (speakerName != null && speakerName!.isNotEmpty ? speakerName![0] : 'S'),
      speakerBg: speakerBg ?? const Color(0xFF1E3A8A),
      speakerProfileImage: speakerProfileImage,
      speakerDesignation: speakerDesignation,
      date: scheduleDate,
      time: '$startTime - $endTime',
      location: hallName ?? '',
      startTime: startTime,
      endTime: endTime,
      scheduleDate: scheduleDate,
      topicId: topicId,
      assignmentId: assignmentId,
      description: description,
      coordinatorName: coordinatorName,
      coordinatorPhone: coordinatorPhone,
      coordinatorEmail: coordinatorEmail,
      isBookmarked: isBookmarked,
    );
  }

  WorkshopItem toWorkshopItem() {
    return WorkshopItem(
      workshopId: id,
      workshopCode: workshopCode ?? 'WS-$id',
      workshopName: title,
      workshopType: category ?? 'Clinical Workshop',
      description: description ?? '',
      venueName: hallName ?? 'Workshop Arena',
      address: '',
      state: '',
      city: '',
      postalCode: '',
      maxCapacity: '50',
      registrationStart: '',
      registrationEnd: '',
      workshopStart: '$scheduleDate $startTime',
      workshopEnd: '$scheduleDate $endTime',
      fee: fee ?? '0.00',
      currency: 'INR',
      certificateAvailable: '1',
      status: 'Active',
      assignmentId: assignmentId ?? id,
      attendanceStatus: isRegistered ? 'Confirmed' : 'Pending',
      certificateGenerated: '0',
      feedbackSubmitted: '0',
      assignedOn: '',
      speakersCount: 1,
      delegatesCount: 0,
    );
  }
}

class CalendarDataService {
  /// Cleans hall names by stripping venue / hotel / hilton prefixes or suffixes.
  static String cleanHallName(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    String text = raw.trim();
    text = text.replaceAll(RegExp(r'\b(hilton\s*(chennai|hotel|garden\s*inn)?|hotel\s*hilton|hotel|venue)\b', caseSensitive: false), '').trim();
    text = text.replaceAll(RegExp(r'^[,–—\-\s:|]+|[,–—\-\s:|]+$'), '').trim();
    return text.isNotEmpty ? text : raw.trim();
  }

  /// Fetches live calendar events from admin APIs for ALL roles.
  /// Admin master data (hallTracks + workshops) is always fetched.
  /// Speaker: additionally fetches their confirmed session topics.
  /// Delegate: additionally fetches their registered workshops.
  static Future<List<CalendarEventItem>> fetchCalendarEvents({
    required BuildContext context,
    required CalendarRole role,
    bool forceRefresh = false,
  }) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final adminProv = Provider.of<AdminProvider>(context, listen: false);
    final workshopsProv = Provider.of<WorkshopsProvider>(context, listen: false);
    final sessionsProv = Provider.of<SessionsProvider>(context, listen: false);
    final token = auth.accessToken;
    final isUserAdmin = auth.isAdmin || auth.roleCode == 'AD' || role == CalendarRole.admin;
    final isUserSpeaker = auth.isSpeaker || auth.roleCode == 'SK' || role == CalendarRole.speaker;

    if (token.isNotEmpty) {
      final futures = <Future>[];

      // ✅ ALWAYS fetch master admin data for ALL roles
      futures.add(adminProv.fetchSlots(token, forceRefresh: forceRefresh));
      futures.add(adminProv.fetchWorkshops(token, forceRefresh: forceRefresh));

      // For non-admin (speaker & delegate): fetch registered workshops & confirmed sessions
      if (!isUserAdmin) {
        futures.add(workshopsProv.fetchMyWorkshops(token, forceRefresh: forceRefresh));
        futures.add(sessionsProv.fetchConfirmedSessions(token, forceRefresh: forceRefresh));
      }

      // For speaker: fetch their personally confirmed sessions to mark "My Presentation"
      if (isUserSpeaker && !isUserAdmin) {
        futures.add(sessionsProv.fetchMyConfirmedSessions(token, forceRefresh: forceRefresh));
      }

      await Future.wait(futures).catchError((_) => <dynamic>[]);
    }

    return buildEventsFromProviders(context, role: role);
  }

  /// Builds calendar events synchronously from the current state of providers.
  /// This guarantees immediate rendering if providers already have data.
  static List<CalendarEventItem> buildEventsFromProviders(
    BuildContext context, {
    CalendarRole? role,
  }) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final adminProv = Provider.of<AdminProvider>(context, listen: false);
    final workshopsProv = Provider.of<WorkshopsProvider>(context, listen: false);
    final sessionsProv = Provider.of<SessionsProvider>(context, listen: false);

    final resolvedRole = role ?? (auth.isAdmin || auth.roleCode == 'AD'
        ? CalendarRole.admin
        : (auth.isSpeaker || auth.roleCode == 'SK'
            ? CalendarRole.speaker
            : CalendarRole.delegate));

    final isUserAdmin = auth.isAdmin || auth.roleCode == 'AD' || resolvedRole == CalendarRole.admin;
    final isUserSpeaker = auth.isSpeaker || auth.roleCode == 'SK' || resolvedRole == CalendarRole.speaker;

    return _buildCalendarEvents(
      role: resolvedRole,
      adminProv: adminProv,
      sessionsProv: sessionsProv,
      workshopsProv: workshopsProv,
      isAdmin: isUserAdmin,
      isSpeaker: isUserSpeaker,
      currentUserName: auth.userName,
    );
  }

  /// Backward-compatible wrapper
  static Future<List<CalendarEventItem>> getCalendarEvents({
    required CalendarRole role,
    BuildContext? context,
    String? token,
    bool forceRefresh = false,
  }) async {
    if (context != null) {
      return fetchCalendarEvents(context: context, role: role, forceRefresh: forceRefresh);
    }
    return [];
  }

  /// Builds all calendar events from loaded providers.
  static List<CalendarEventItem> _buildCalendarEvents({
    required CalendarRole role,
    required AdminProvider adminProv,
    required SessionsProvider sessionsProv,
    required WorkshopsProvider workshopsProv,
    required bool isAdmin,
    required bool isSpeaker,
    String? currentUserName,
  }) {
    final List<CalendarEventItem> result = [];
    final Set<String> addedKeys = {};

    final cleanCurrentName = (currentUserName ?? '').trim().toLowerCase();

    // Build sets of speaker's own topics/sessions for quick lookup
    final myTopicIds = sessionsProv.mySessions
        .where((m) => m.topicId != null && m.topicId!.isNotEmpty)
        .map((m) => m.topicId!.trim())
        .toSet();
    final mySessionTitles = sessionsProv.mySessions
        .map((m) => m.title.trim().toLowerCase())
        .toSet();

    // Build sets of bookmarked sessions
    final bookmarkedTopicIds = sessionsProv.sessions
        .where((s) => s.isBookmarked && s.topicId != null)
        .map((s) => s.topicId!.trim())
        .toSet();
    final bookmarkedTitles = sessionsProv.sessions
        .where((s) => s.isBookmarked)
        .map((s) => s.title.trim().toLowerCase())
        .toSet();

    // Build sets of personally registered workshops
    final myWorkshopIds = workshopsProv.workshops
        .map((w) => w.workshopId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final myWorkshopCodes = workshopsProv.workshops
        .map((w) => w.workshopCode.trim().toUpperCase())
        .where((c) => c.isNotEmpty)
        .toSet();

    // =========================================================
    // 1. Master Workshops from Admin API (Oct 1 - Workshops Day)
    // =========================================================
    for (final ws in adminProv.workshops) {
      final dateStr = _extractDate(ws.workshopStart, defaultDate: '2026-10-01');
      final startTimeStr = _extractTime(ws.workshopStart);
      final endTimeStr = _extractTime(ws.workshopEnd);

      final isMyWs = !isAdmin && (
        myWorkshopIds.contains(ws.workshopId.trim()) ||
        myWorkshopCodes.contains(ws.workshopCode.trim().toUpperCase()) ||
        ws.workshopStatus.toLowerCase() == 'confirmed'
      );

      final key = 'ws-${ws.workshopId}-${ws.workshopCode}-$dateStr';
      if (addedKeys.contains(key)) continue;
      addedKeys.add(key);

      final cleanHall = cleanHallName(ws.venueName.isNotEmpty ? ws.venueName : 'Workshop Arena');

      result.add(CalendarEventItem(
        id: ws.workshopId.isNotEmpty ? ws.workshopId : 'ws-${ws.workshopCode}',
        title: ws.workshopName,
        type: isMyWs ? CalendarItemType.myWorkshop : CalendarItemType.workshop,
        scheduleDate: dateStr,
        scheduleDay: _determineScheduleDay(dateStr),
        startTime: startTimeStr.isNotEmpty ? startTimeStr : '08:30 AM',
        endTime: endTimeStr.isNotEmpty ? endTimeStr : '06:00 PM',
        hallName: cleanHall,
        hallCode: ws.workshopCode,
        category: ws.workshopType.isNotEmpty ? ws.workshopType : 'Hands-on Workshop',
        workshopCode: ws.workshopCode,
        fee: '0.00',
        description: ws.venueName.isNotEmpty ? '${ws.venueName}, ${ws.city}' : '',
        isRegistered: isMyWs,
        isBookmarked: false,
        targetRoles: const ['admin', 'speaker', 'delegate'],
      ));
    }

    // ================================================================
    // 2. Personal & Utility Workshops from /api/utility/my_workshops
    //    Included for ALL roles to guarantee complete workshop availability
    // ================================================================
    for (final ws in workshopsProv.workshops) {
      final dateStr = _extractDate(ws.workshopStart, defaultDate: '2026-10-01');
      final startTimeStr = _extractTime(ws.workshopStart);
      final endTimeStr = _extractTime(ws.workshopEnd);

      final isRegisteredWs = !isAdmin && (
        ws.attendanceStatus.toLowerCase() == 'confirmed' ||
        ws.assignmentId.isNotEmpty ||
        myWorkshopIds.contains(ws.workshopId.trim()) ||
        myWorkshopCodes.contains(ws.workshopCode.trim().toUpperCase())
      );

      final key = 'ws-${ws.workshopId}-${ws.workshopCode}-$dateStr';
      if (addedKeys.contains(key)) {
        // Already added from admin list — update isRegistered flag & extra details
        final idx = result.indexWhere((e) => e.id == ws.workshopId || e.workshopCode == ws.workshopCode);
        if (idx != -1) {
          final existing = result[idx];
          result[idx] = CalendarEventItem(
            id: existing.id,
            title: existing.title.isNotEmpty ? existing.title : ws.workshopName,
            type: isRegisteredWs ? CalendarItemType.myWorkshop : CalendarItemType.workshop,
            scheduleDate: existing.scheduleDate,
            scheduleDay: existing.scheduleDay,
            startTime: existing.startTime,
            endTime: existing.endTime,
            hallName: existing.hallName,
            hallCode: existing.hallCode,
            category: existing.category,
            workshopCode: existing.workshopCode,
            fee: ws.fee,
            description: ws.description.isNotEmpty ? ws.description : existing.description,
            isRegistered: isRegisteredWs,
            isBookmarked: existing.isBookmarked,
            topicId: existing.topicId,
            assignmentId: ws.assignmentId.isNotEmpty ? ws.assignmentId : existing.assignmentId,
            targetRoles: existing.targetRoles,
          );
        }
        continue;
      }
      addedKeys.add(key);

      final cleanHall = cleanHallName(ws.venueName.isNotEmpty ? ws.venueName : 'Workshop Arena');

      result.add(CalendarEventItem(
        id: ws.workshopId.isNotEmpty ? ws.workshopId : 'ws-${ws.workshopCode}',
        title: ws.workshopName,
        type: isRegisteredWs ? CalendarItemType.myWorkshop : CalendarItemType.workshop,
        scheduleDate: dateStr,
        scheduleDay: _determineScheduleDay(dateStr),
        startTime: startTimeStr.isNotEmpty ? startTimeStr : '08:30 AM',
        endTime: endTimeStr.isNotEmpty ? endTimeStr : '06:00 PM',
        hallName: cleanHall,
        hallCode: ws.workshopCode,
        category: ws.workshopType.isNotEmpty ? ws.workshopType : 'Hands-on Workshop',
        workshopCode: ws.workshopCode,
        fee: ws.fee,
        description: ws.description,
        isRegistered: isRegisteredWs,
        isBookmarked: false,
        assignmentId: ws.assignmentId,
        targetRoles: const ['admin', 'speaker', 'delegate'],
      ));
    }

    // ================================================================
    // 3. Admin Hall Tracks (all slots for Days 1, 2, 3)
    //    This is the PRIMARY source for sessions/slots for ALL roles
    // ================================================================
    for (final track in adminProv.hallTracks) {
      final rawHall = track.hallLabel.trim().isNotEmpty ? track.hallLabel.trim() : track.hallName.trim();
      final cleanHall = cleanHallName(rawHall);

      for (final day in track.days) {
        final dateStr = _extractDate(day.scheduleDate,
            scheduleDay: day.scheduleDay, defaultDate: '2026-10-02');

        for (final slot in day.slots) {
          final isCancelled = slot.isCancelled || slot.slotStatus.toUpperCase() == 'CANCELLED';

          final startTimeStr = TimeFormatter.formatTime(slot.startTime);
          final endTimeStr = TimeFormatter.formatTime(slot.endTime);
          final st = slot.slotStatus.toUpperCase();
          final slotTopicTitle = (slot.topicTitle ?? '').trim();
          final hasTopic = slotTopicTitle.isNotEmpty;
          final rawLabel = slot.slotLabel.trim();
          final effectiveSpeaker = _extractSpeakerFromLabel(slot.speakerName, rawLabel);
          final slotSpeakerLower = effectiveSpeaker.toLowerCase();

          // Check if this is the speaker's own presentation
          final isSpeakerMySession = !isAdmin && isSpeaker && (
            (slot.topicId != null && myTopicIds.contains(slot.topicId!.trim())) ||
            (hasTopic && mySessionTitles.contains(slotTopicTitle.toLowerCase())) ||
            (cleanCurrentName.isNotEmpty && slotSpeakerLower.isNotEmpty &&
                (slotSpeakerLower.contains(cleanCurrentName) || cleanCurrentName.contains(slotSpeakerLower))) ||
            (cleanCurrentName.isNotEmpty && rawLabel.toLowerCase().contains(cleanCurrentName)) ||
            slotSpeakerLower.contains('you')
          );

          // Check if bookmarked
          final isBookmarked = !isAdmin && (
            (slot.topicId != null && bookmarkedTopicIds.contains(slot.topicId!.trim())) ||
            (hasTopic && bookmarkedTitles.contains(slotTopicTitle.toLowerCase()))
          );

          final cleanSlotStatus = st.trim();
          final bool isExplicitlyFree = cleanSlotStatus == 'FREE' ||
              cleanSlotStatus == 'AVAILABLE' ||
              cleanSlotStatus == 'UNASSIGNED' ||
              rawLabel.toUpperCase() == 'FREE' ||
              rawLabel.toUpperCase() == 'FREE SLOT' ||
              rawLabel.toUpperCase() == 'AVAILABLE' ||
              (!slot.isAssigned && !hasTopic && cleanSlotStatus != 'BOOKED' && cleanSlotStatus != 'ASSIGNED' && cleanSlotStatus != 'ALLOCATED' && cleanSlotStatus != 'CONFIRMED');

          final hasContentInLabel = rawLabel.isNotEmpty &&
              rawLabel.toUpperCase() != 'FREE' &&
              rawLabel.toUpperCase() != 'AVAILABLE' &&
              rawLabel.toUpperCase() != 'UNASSIGNED' &&
              rawLabel.toUpperCase() != 'FREE SLOT' &&
              rawLabel.toUpperCase() != 'CANCELLED';

          final isActualSession = !isCancelled && !isExplicitlyFree && (
              hasTopic ||
              slot.isAssigned ||
              cleanSlotStatus == 'BOOKED' ||
              cleanSlotStatus == 'ASSIGNED' ||
              cleanSlotStatus == 'ALLOCATED' ||
              cleanSlotStatus == 'CONFIRMED' ||
              (hasContentInLabel && cleanSlotStatus != 'FREE')
          );
          final isTrulyFree = !isCancelled && (isExplicitlyFree || !isActualSession);

          String eventTitle = _extractTitleFromSlot(
              slot.topicTitle, rawLabel, slot.slotName, slot.slotNumber);

          // Find matching SessionItem from sessionsProv for accurate assignmentId & details
          SessionItem? matchedSession;
          for (final s in sessionsProv.sessions) {
            if (slot.topicId != null && s.topicId != null && slot.topicId!.trim() == s.topicId!.trim()) {
              matchedSession = s;
              break;
            }
            if (hasTopic && s.title.trim().toLowerCase() == slotTopicTitle.toLowerCase()) {
              matchedSession = s;
              break;
            }
          }
          if (matchedSession == null) {
            for (final s in sessionsProv.mySessions) {
              if (slot.topicId != null && s.topicId != null && slot.topicId!.trim() == s.topicId!.trim()) {
                matchedSession = s;
                break;
              }
              if (hasTopic && s.title.trim().toLowerCase() == slotTopicTitle.toLowerCase()) {
                matchedSession = s;
                break;
              }
            }
          }

          String? topicCategory;
          if (slot.topicId != null && slot.topicId!.isNotEmpty) {
            for (final t in adminProv.topics) {
              if (t.topicId.trim() == slot.topicId!.trim()) {
                if (t.categoryOfSubmission.isNotEmpty) {
                  topicCategory = t.categoryOfSubmission;
                }
                break;
              }
            }
          }
          if (topicCategory == null && hasTopic) {
            for (final t in adminProv.topics) {
              if (t.title.trim().toLowerCase() == slotTopicTitle.toLowerCase()) {
                if (t.categoryOfSubmission.isNotEmpty) {
                  topicCategory = t.categoryOfSubmission;
                }
                break;
              }
            }
          }

          final effectiveAssignmentId = slot.assignmentId ?? matchedSession?.assignmentId ?? (matchedSession?.id.toString()) ?? slot.slotId;

          final key = 'slot-${slot.slotId}-${slot.slotNumber}-$dateStr-${track.hallId}';
          if (addedKeys.contains(key)) continue;
          addedKeys.add(key);

          CalendarItemType itemType;
          if (isCancelled) {
            itemType = CalendarItemType.cancelledSlot;
          } else if (isTrulyFree) {
            itemType = CalendarItemType.freeSlot;
          } else if (isSpeakerMySession) {
            itemType = CalendarItemType.myPresentation;
          } else {
            itemType = CalendarItemType.session;
          }

          result.add(CalendarEventItem(
            id: slot.slotId.isNotEmpty ? slot.slotId : 'slot-${slot.slotNumber}',
            title: eventTitle,
            type: itemType,
            scheduleDate: dateStr,
            scheduleDay: day.scheduleDay.isNotEmpty ? day.scheduleDay : _determineScheduleDay(dateStr),
            startTime: startTimeStr,
            endTime: endTimeStr,
            hallName: cleanHall,
            hallCode: cleanHallName(track.hallName),
            speakerName: effectiveSpeaker.isNotEmpty ? effectiveSpeaker : null,
            slotStatus: isCancelled ? 'CANCELLED' : slot.slotStatus,
            isBookmarked: isBookmarked,
            topicId: slot.topicId ?? matchedSession?.topicId,
            assignmentId: effectiveAssignmentId,
            description: matchedSession?.description,
            coordinatorName: matchedSession?.coordinatorName,
            coordinatorPhone: matchedSession?.coordinatorPhone,
            coordinatorEmail: matchedSession?.coordinatorEmail,
            category: isCancelled
                ? 'Cancelled Slot'
                : (isTrulyFree
                    ? 'Available Slot'
                    : (topicCategory ?? (isSpeakerMySession ? 'My Presentation' : 'Scientific Session'))),
            targetRoles: const ['admin', 'speaker', 'delegate'],
          ));
        }
      }
    }

    // ================================================================
    // 4. Ensure speaker's confirmed mySessions are present
    //    (In case slot data didn't include timing for their topic)
    // ================================================================
    if (isSpeaker && !isAdmin) {
      for (final my in sessionsProv.mySessions) {
        final dateStr = _extractDate(my.scheduleDate ?? my.date, defaultDate: '2026-10-02');
        final startTimeStr = my.startTime?.isNotEmpty == true
            ? TimeFormatter.formatTime(my.startTime!)
            : _extractStartTimeFromRange(my.time);
        final endTimeStr = my.endTime?.isNotEmpty == true
            ? TimeFormatter.formatTime(my.endTime!)
            : _extractEndTimeFromRange(my.time);

        // Check if already added from hallTracks
        final alreadyAdded = result.any((r) =>
            (my.topicId != null && my.topicId!.isNotEmpty && r.topicId == my.topicId) ||
            (r.title.trim().toLowerCase() == my.title.trim().toLowerCase() && r.scheduleDate == dateStr));

        if (!alreadyAdded) {
          final key = 'my-ses-${my.id}-${my.title}-$dateStr';
          if (addedKeys.contains(key)) continue;
          addedKeys.add(key);

          result.add(CalendarEventItem(
            id: my.id.toString(),
            title: my.title,
            type: CalendarItemType.myPresentation,
            scheduleDate: dateStr,
            scheduleDay: _determineScheduleDay(dateStr),
            startTime: startTimeStr,
            endTime: endTimeStr,
            hallName: cleanHallName(my.location),
            speakerName: my.speakerName.isNotEmpty ? my.speakerName : 'You',
            speakerDesignation: my.speakerDesignation ?? my.speakerTitle,
            speakerProfileImage: my.speakerProfileImage,
            speakerInitials: my.speakerInitials,
            speakerBg: my.speakerBg,
            category: 'My Presentation',
            isBookmarked: my.isBookmarked,
            topicId: my.topicId,
            assignmentId: my.assignmentId,
            description: my.description,
            coordinatorName: my.coordinatorName,
            coordinatorPhone: my.coordinatorPhone,
            coordinatorEmail: my.coordinatorEmail,
            targetRoles: const ['speaker'],
          ));
        } else {
          // Upgrade type to myPresentation if already added as session
          final idx = result.indexWhere((r) =>
              (my.topicId != null && my.topicId!.isNotEmpty && r.topicId == my.topicId) ||
              (r.title.trim().toLowerCase() == my.title.trim().toLowerCase() && r.scheduleDate == dateStr));
          if (idx != -1 && result[idx].type == CalendarItemType.session) {
            final existing = result[idx];
            result[idx] = CalendarEventItem(
              id: existing.id,
              title: existing.title,
              type: CalendarItemType.myPresentation,
              scheduleDate: existing.scheduleDate,
              scheduleDay: existing.scheduleDay,
              startTime: existing.startTime,
              endTime: existing.endTime,
              hallName: existing.hallName,
              hallCode: existing.hallCode,
              speakerName: existing.speakerName ?? (my.speakerName.isNotEmpty ? my.speakerName : 'You'),
              speakerDesignation: existing.speakerDesignation ?? my.speakerDesignation,
              speakerProfileImage: existing.speakerProfileImage ?? my.speakerProfileImage,
              speakerInitials: existing.speakerInitials ?? my.speakerInitials,
              speakerBg: existing.speakerBg ?? my.speakerBg,
              category: 'My Presentation',
              isBookmarked: existing.isBookmarked || my.isBookmarked,
              isRegistered: existing.isRegistered,
              workshopCode: existing.workshopCode,
              fee: existing.fee,
              description: existing.description ?? my.description,
              coordinatorName: existing.coordinatorName ?? my.coordinatorName,
              coordinatorPhone: existing.coordinatorPhone ?? my.coordinatorPhone,
              coordinatorEmail: existing.coordinatorEmail ?? my.coordinatorEmail,
              topicId: existing.topicId ?? my.topicId,
              assignmentId: existing.assignmentId ?? my.assignmentId,
              slotStatus: existing.slotStatus,
              targetRoles: existing.targetRoles,
            );
          }
        }
      }
    }

    return result;
  }

  // ==========================================
  // Helper Date & Time Extractors
  // ==========================================
  static String _extractDate(String? raw, {String? scheduleDay, String defaultDate = '2026-10-01'}) {
    if (raw == null || raw.trim().isEmpty) {
      return _dayToDate(scheduleDay, defaultDate);
    }
    final clean = raw.trim();

    // 1. ISO YYYY-MM-DD
    final isoMatch = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})').firstMatch(clean);
    if (isoMatch != null) {
      final y = isoMatch.group(1)!;
      final m = isoMatch.group(2)!.padLeft(2, '0');
      final d = isoMatch.group(3)!.padLeft(2, '0');
      return '$y-$m-$d';
    }

    // 2. DMY DD-MM-YYYY
    final dmyMatch = RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})').firstMatch(clean);
    if (dmyMatch != null) {
      final d = dmyMatch.group(1)!.padLeft(2, '0');
      final m = dmyMatch.group(2)!.padLeft(2, '0');
      final y = dmyMatch.group(3)!;
      return '$y-$m-$d';
    }

    // 3. Textual month "01 Oct 2026"
    final textMatch = RegExp(r'(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})').firstMatch(clean);
    if (textMatch != null) {
      final d = textMatch.group(1)!.padLeft(2, '0');
      final monthStr = textMatch.group(2)!.toLowerCase();
      final y = textMatch.group(3)!;
      final m = _monthNameToNum(monthStr);
      return '$y-$m-$d';
    }

    try {
      final dt = DateTime.tryParse(clean);
      if (dt != null) {
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}

    return _dayToDate(scheduleDay, defaultDate);
  }

  static String _dayToDate(String? scheduleDay, String fallback) {
    if (scheduleDay != null && scheduleDay.trim().isNotEmpty) {
      final s = scheduleDay.trim().toLowerCase();
      if (s == 'workshops' || s == 'workshop' || s == '0') return '2026-10-01';
      if (s == '1' || s == 'day 1' || s == 'day1') return '2026-10-02';
      if (s == '2' || s == 'day 2' || s == 'day2') return '2026-10-03';
      if (s == '3' || s == 'day 3' || s == 'day3') return '2026-10-04';
    }
    return fallback;
  }

  static String _monthNameToNum(String name) {
    const months = {
      'jan': '01', 'january': '01',
      'feb': '02', 'february': '02',
      'mar': '03', 'march': '03',
      'apr': '04', 'april': '04',
      'may': '05',
      'jun': '06', 'june': '06',
      'jul': '07', 'july': '07',
      'aug': '08', 'august': '08',
      'sep': '09', 'september': '09',
      'oct': '10', 'october': '10',
      'nov': '11', 'november': '11',
      'dec': '12', 'december': '12',
    };
    return months[name.toLowerCase()] ?? '10';
  }

  static String _extractTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final clean = raw.trim();
    if (clean.contains(' ')) {
      final parts = clean.split(' ');
      if (parts.length > 1) {
        final timePart = parts.sublist(1).join(' ');
        return TimeFormatter.formatTime(timePart);
      }
    }
    return TimeFormatter.formatTime(clean);
  }

  static String _extractStartTimeFromRange(String? range) {
    if (range == null || range.trim().isEmpty) return '';
    final parts = range.split(RegExp(r'[-–]'));
    if (parts.isNotEmpty) {
      return TimeFormatter.formatTime(parts[0].trim());
    }
    return '';
  }

  static String _extractEndTimeFromRange(String? range) {
    if (range == null || range.trim().isEmpty) return '';
    final parts = range.split(RegExp(r'[-–]'));
    if (parts.length > 1) {
      return TimeFormatter.formatTime(parts[1].trim());
    }
    return '';
  }

  static String _extractSpeakerFromLabel(String? speakerName, String slotLabel) {
    if (speakerName != null &&
        speakerName.trim().isNotEmpty &&
        speakerName.trim().toUpperCase() != 'NA') {
      return speakerName.trim();
    }
    if (slotLabel.isEmpty) return '';

    final speakerRegex = RegExp(r'(?:Speakers?|Chairpersons?|Faculty)\s*[-:]\s*([^|]+)', caseSensitive: false);
    final match = speakerRegex.firstMatch(slotLabel);
    if (match != null) {
      return match.group(1)!.trim();
    }

    if (slotLabel.contains('|')) {
      final parts = slotLabel.split('|');
      if (parts.length > 1) {
        final lastPart = parts.last.trim();
        if (lastPart.isNotEmpty &&
            !lastPart.toLowerCase().startsWith('slot') &&
            !lastPart.toLowerCase().startsWith('chairperson')) {
          return lastPart;
        }
      }
    }

    return '';
  }

  static String _extractTitleFromSlot(
      String? topicTitle, String slotLabel, String slotName, String slotNumber) {
    String title = '';
    if (topicTitle != null && topicTitle.trim().isNotEmpty) {
      title = topicTitle.trim();
    } else if (slotLabel.isNotEmpty) {
      if (slotLabel.contains('#')) {
        final parts = slotLabel.split('#');
        final suffix = parts.sublist(1).join(' ').trim();
        final prefix = parts[0].trim();
        title = suffix.isNotEmpty ? suffix : prefix;
      } else {
        title = slotLabel;
      }
    } else if (slotName.isNotEmpty) {
      if (slotName.contains('#')) {
        final parts = slotName.split('#');
        final suffix = parts.sublist(1).join(' ').trim();
        final prefix = parts[0].trim();
        title = suffix.isNotEmpty ? suffix : prefix;
      } else {
        title = slotName;
      }
    } else {
      title = 'Slot $slotNumber';
    }
    return title.replaceAll('#', '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _determineScheduleDay(String dateStr) {
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        if (dt.month == 10 && dt.day == 1) return 'Workshops';
        if (dt.month == 10 && dt.day == 2) return 'Day 1';
        if (dt.month == 10 && dt.day == 3) return 'Day 2';
        if (dt.month == 10 && dt.day == 4) return 'Day 3';
      }
    } catch (_) {}
    return 'Day 1';
  }
}
