import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dfsicon/constants/api_urls.dart';
import 'package:dfsicon/utils/custom_logger.dart';

class ApiService {
  ApiService._();

  static const Map<String, String> defaultMeta = {
    "device_id": "ANDROID_123",
    "device_name": "Samsung S24",
    "device_type": "Android",
    "app_version": "1.0.0",
    "latitude": "",
    "longitude": "",
    "fcmToken": ""
  };

  // ==========================================
  // Authentication / Login API Calls
  // ==========================================

  static Future<http.Response> sendOtp({
    required String phoneNumber,
    Map<String, String> meta = defaultMeta,
  }) async {
    final url = Uri.parse(ApiUrls.sendOtp);
    final headers = {'Content-Type': 'application/json'};
    final requestBody = json.encode({
      "credentials": {
        "mobile": phoneNumber
      },
      "meta": meta
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    Map<String, String> meta = defaultMeta,
  }) async {
    final url = Uri.parse(ApiUrls.verifyOtp);
    final headers = {'Content-Type': 'application/json'};
    final requestBody = json.encode({
      "credentials": {
        "mobile": phoneNumber,
        "otp": otpCode
      },
      "meta": meta
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> refreshSessionToken({
    required String refreshToken,
    Map<String, String> meta = defaultMeta,
  }) async {
    final url = Uri.parse(ApiUrls.refreshToken);
    final headers = {'Content-Type': 'application/json'};
    final requestBody = json.encode({
      "refresh_token": refreshToken,
      "device_id": meta["device_id"],
      "device_name": meta["device_name"],
      "device_type": meta["device_type"],
      "app_version": meta["app_version"],
      "latitude": meta["latitude"],
      "longitude": meta["longitude"],
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> logout({
    required String refreshToken,
    Map<String, String> meta = defaultMeta,
  }) async {
    final url = Uri.parse(ApiUrls.logout);
    final headers = {'Content-Type': 'application/json'};
    final requestBody = json.encode({
      "refresh_token": refreshToken,
      "latitude": meta["latitude"],
      "longitude": meta["longitude"]
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Abstract API Calls
  // ==========================================

  static Future<http.Response> fetchMyAbstracts({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.myAbstracts);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('POST', url.toString(), headers: headers);

    final response = await http.post(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchAbstractDetails({
    required String abstractId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.abstractDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'abstract_id': abstractId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: body);

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchSummits({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.getSummits);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('GET', url.toString(), headers: headers);

    final response = await http.get(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchConfirmedSessions({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.getConfirmedSessions);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('GET', url.toString(), headers: headers);

    final response = await http.get(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> submitAbstract({
    required String summitId,
    required String title,
    required String description,
    required String keywords,
    required String presentationType,
    required File file,
    File? thumbnail,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.submitAbstract);
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['summit_id'] = summitId;
    request.fields['abstract_title'] = title;
    request.fields['abstract_description'] = description;
    request.fields['keywords'] = keywords;
    request.fields['presentation_type'] = presentationType;

    final fileExtension = file.path.split('.').last.toLowerCase();
    final mimeType = _getMimeTypeForExtension(fileExtension);

    request.files.add(
      await http.MultipartFile.fromPath(
        'abstract_file',
        file.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    if (thumbnail != null) {
      final thumbExt = thumbnail.path.split('.').last.toLowerCase();
      final thumbMime = _getMimeTypeForExtension(thumbExt);
      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnail.path,
          contentType: MediaType.parse(thumbMime),
        ),
      );
    }

    CustomLogger.logRequest(
      'POST (Multipart)',
      url.toString(),
      headers: request.headers,
      body: 'Fields: ${request.fields}, File Path: ${file.path}, Thumbnail Path: ${thumbnail?.path}',
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> resubmitAbstract({
    required String abstractId,
    required String title,
    required String description,
    required String keywords,
    required File file,
    File? thumbnail,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.resubmitAbstract);
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['abstract_id'] = abstractId;
    request.fields['abstract_title'] = title;
    request.fields['abstract_description'] = description;
    request.fields['keywords'] = keywords;

    final fileExtension = file.path.split('.').last.toLowerCase();
    final mimeType = _getMimeTypeForExtension(fileExtension);

    request.files.add(
      await http.MultipartFile.fromPath(
        'abstract_file',
        file.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    if (thumbnail != null) {
      final thumbExt = thumbnail.path.split('.').last.toLowerCase();
      final thumbMime = _getMimeTypeForExtension(thumbExt);
      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnail.path,
          contentType: MediaType.parse(thumbMime),
        ),
      );
    }

    CustomLogger.logRequest(
      'POST (Multipart)',
      url.toString(),
      headers: request.headers,
      body: 'Fields: ${request.fields}, File Path: ${file.path}, Thumbnail Path: ${thumbnail?.path}',
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Photo Upload API Call
  // ==========================================

  static Future<http.Response> uploadPhoto({
    required String imagePath,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.uploadProfilePicture);
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';
    final fileExtension = imagePath.split('.').last.toLowerCase();
    
    String mimeType = 'image/jpeg';
    if (fileExtension == 'png') {
      mimeType = 'image/png';
    } else if (fileExtension == 'webp') {
      mimeType = 'image/webp';
    } else if (fileExtension == 'gif') {
      mimeType = 'image/gif';
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture',
        imagePath,
        contentType: MediaType.parse(mimeType),
      ),
    );

    CustomLogger.logRequest(
      'POST (Multipart)',
      url.toString(),
      headers: request.headers,
      body: 'File path: $imagePath',
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Sponsors API Call
  // ==========================================

  static Future<http.Response> fetchSponsors({
    required String summitId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.getSponsors);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "summit_id": summitId
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: body);

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchVenueAndHalls({
    required String summitId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.getVenueAndHalls);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "summit_id": summitId
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: body);

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchSummitBooths({
    required String summitId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.getSummitBooths);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "summit_id": summitId
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: body);

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Workshops API Call
  // ==========================================
  static Future<http.Response> fetchMyWorkshops({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.myWorkshops);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('GET', url.toString(), headers: headers);

    final response = await http.get(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> viewWorkshopParticipants({
    required String workshopId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.viewWorkshopParticipants);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'workshop_id': workshopId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: body);

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Speaker Topics API Calls
  // ==========================================
  static Future<http.Response> fetchSpeakerMyTopics({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.speakerMyTopics);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('GET', url.toString(), headers: headers);

    final response = await http.get(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchSpeakerTopicDetails({
    required String topicId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.speakerTopicDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'topic_id': topicId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: body);

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> updateSpeakerTopicDetails({
    required Map<String, dynamic> body,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.speakerUpdateTopicDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode(body);

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Delegate, Speaker & Utility API Calls
  // ==========================================

  static Future<http.Response> bookmarkSession({
    required String assignmentId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.bookmarkSession);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "assignment_id": assignmentId
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> unbookmarkSession({
    required String assignmentId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.unbookmarkSession);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "assignment_id": assignmentId
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchMyBookmarks({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.myBookmarks);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('GET', url.toString(), headers: headers);

    final response = await http.get(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> viewSessionParticipants({
    String? assignmentId,
    String? topicId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.viewSessionParticipants);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBodyMap = <String, dynamic>{};
    if (assignmentId != null) {
      requestBodyMap['assignment_id'] = assignmentId;
    }
    if (topicId != null) {
      requestBodyMap['topic_id'] = topicId;
    }
    final requestBody = json.encode(requestBodyMap);

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchSummitStats({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.summitStats);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('GET', url.toString(), headers: headers);

    final response = await http.get(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchInvitedSpeakers({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.invitedSpeakers);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('GET', url.toString(), headers: headers);

    final response = await http.get(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchMyProfile({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.myProfile);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('GET', url.toString(), headers: headers);

    final response = await http.get(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('GET', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> updateProfile({
    required Map<String, String> fields,
    File? profileImage,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.updateProfile);
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';
    
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    if (profileImage != null) {
      final fileExtension = profileImage.path.split('.').last.toLowerCase();
      final mimeType = _getMimeTypeForExtension(fileExtension);
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          profileImage.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    CustomLogger.logRequest(
      'POST (Multipart)',
      url.toString(),
      headers: request.headers,
      body: 'Fields: ${request.fields}, Image: ${profileImage?.path}',
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> updatePrivacySettings({
    required Map<String, String> settings,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.updatePrivacySettings);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode(settings);

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> fetchMyNotifications({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.myNotifications);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('POST', url.toString(), headers: headers);

    final response = await http.post(
      url,
      headers: headers,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> markNotificationRead({
    required String accessToken,
    String? notificationId,
  }) async {
    final url = Uri.parse(ApiUrls.markNotificationRead);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'notification_id': notificationId ?? '',
    };
    final requestBody = json.encode(bodyMap);

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> registerFcmToken({
    required String fcmToken,
    required String accessToken,
    String? deviceType,
    String? deviceId,
  }) async {
    final url = Uri.parse(ApiUrls.registerToken);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "fcm_token": fcmToken,
      "device_type": deviceType ?? (Platform.isAndroid ? "android" : (Platform.isIOS ? "ios" : "android")),
      "device_id": deviceId ?? "android_123",
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(
      url,
      headers: headers,
      body: requestBody,
    );

    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Helper
  static String _getMimeTypeForExtension(String fileExtension) {
    String mimeType = 'application/octet-stream';
    if (fileExtension == 'pdf') {
      mimeType = 'application/pdf';
    } else if (fileExtension == 'doc') {
      mimeType = 'application/msword';
    } else if (fileExtension == 'docx') {
      mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    } else if (fileExtension == 'png') {
      mimeType = 'image/png';
    } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
      mimeType = 'image/jpeg';
    } else if (fileExtension == 'ppt') {
      mimeType = 'application/vnd.ms-powerpoint';
    } else if (fileExtension == 'pptx') {
      mimeType = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    } else if (fileExtension == 'xls') {
      mimeType = 'application/vnd.ms-excel';
    } else if (fileExtension == 'xlsx') {
      mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    } else if (fileExtension == 'txt') {
      mimeType = 'text/plain';
    }
    return mimeType;
  }

  // ==========================================
  // Networking Module APIs
  // ==========================================

  // 1. Session Participants API
  static Future<http.Response> fetchNetworkSessionParticipants({
    dynamic assignmentId,
    String? search,
    int page = 1,
    int limit = 20,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.sessionParticipants);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'page': page,
      'limit': limit,
    };
    if (assignmentId != null) bodyMap['assignment_id'] = assignmentId;
    if (search != null && search.isNotEmpty) bodyMap['search'] = search;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 2. Send Request API
  static Future<http.Response> sendNetworkRequest({
    dynamic assignmentId,
    required dynamic targetId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.sendRequest);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'target_id': targetId,
    };
    if (assignmentId != null) bodyMap['assignment_id'] = assignmentId;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);

    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 3. Pending Requests API
  static Future<http.Response> fetchNetworkPendingRequests({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.pendingRequests);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('POST', url.toString(), headers: headers);
    final response = await http.post(url, headers: headers, body: json.encode({}));
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 4. Respond Request API (action = "ACCEPT" or "REJECT")
  static Future<http.Response> respondNetworkRequest({
    required dynamic connectionId,
    required String action,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.respondRequest);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'connection_id': connectionId,
      'action': action,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 5. Disconnect API
  static Future<http.Response> disconnectNetworkConnection({
    required dynamic connectionId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.disconnect);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'connection_id': connectionId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 6. Cancel Request API
  static Future<http.Response> cancelNetworkRequest({
    required dynamic connectionId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.cancelRequest);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'connection_id': connectionId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 7. My Connections API
  static Future<http.Response> fetchMyNetworkConnections({
    dynamic assignmentId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.myConnections);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {};
    if (assignmentId != null) bodyMap['assignment_id'] = assignmentId;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 8. Send Message API - Text
  static Future<http.Response> sendNetworkMessageText({
    required dynamic conversationId,
    required String body,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.sendMessage);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'conversation_id': conversationId,
      'body': body,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 8. Send Message API - Attachment (Multipart)
  static Future<http.Response> sendNetworkMessageAttachment({
    required dynamic conversationId,
    String? body,
    required File attachmentFile,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.sendMessage);
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['conversation_id'] = conversationId.toString();
    if (body != null && body.isNotEmpty) {
      request.fields['body'] = body;
    }

    final fileExtension = attachmentFile.path.split('.').last.toLowerCase();
    final mimeTypeStr = _getMimeTypeForExtension(fileExtension);
    final mimeParts = mimeTypeStr.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'attachment',
        attachmentFile.path,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      ),
    );

    CustomLogger.logRequest('POST (Multipart)', url.toString(), headers: request.headers, body: request.fields.toString());
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    CustomLogger.logResponse('POST (Multipart)', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 9. Messages API
  static Future<http.Response> fetchNetworkMessages({
    required dynamic conversationId,
    dynamic beforeId,
    int limit = 30,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.messages);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'conversation_id': conversationId,
      'limit': limit,
    };
    if (beforeId != null) bodyMap['before_id'] = beforeId;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 10. Mark as Read API
  static Future<http.Response> markNetworkRead({
    required dynamic conversationId,
    dynamic uptoMessageId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.markRead);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'conversation_id': conversationId,
    };
    if (uptoMessageId != null) bodyMap['upto_message_id'] = uptoMessageId;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 11. Un-read Count API
  static Future<http.Response> fetchNetworkUnreadCount({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.unreadCount);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    CustomLogger.logRequest('POST', url.toString(), headers: headers);
    final response = await http.post(url, headers: headers, body: json.encode({}));
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 12. Create Group API
  static Future<http.Response> createNetworkGroup({
    dynamic assignmentId,
    required String groupName,
    String? groupDescription,
    required List<int> memberIds,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.createGroup);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'group_name': groupName,
      'member_ids': memberIds,
    };
    if (assignmentId != null) bodyMap['assignment_id'] = assignmentId;
    if (groupDescription != null && groupDescription.isNotEmpty) {
      bodyMap['group_description'] = groupDescription;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 13. Group Details API
  static Future<http.Response> fetchNetworkGroupDetails({
    required dynamic conversationId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.groupDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'conversation_id': conversationId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 14. Add Member(s) in Group API
  static Future<http.Response> addNetworkGroupMembers({
    required dynamic conversationId,
    required List<int> memberIds,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.addMembers);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'conversation_id': conversationId,
      'member_ids': memberIds,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 15. Remove Member(s) in Group API
  static Future<http.Response> removeNetworkGroupMember({
    required dynamic conversationId,
    required List<int> memberIds,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.removeMember);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'conversation_id': conversationId,
      'member_ids': memberIds,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 16. Leave Group API
  static Future<http.Response> leaveNetworkGroup({
    required dynamic conversationId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.leaveGroup);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'conversation_id': conversationId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 17. Conversations API
  static Future<http.Response> fetchNetworkConversations({
    String? type, // "DIRECT" or "GROUP"
    String? search,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.conversations);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {};
    if (type != null && type.isNotEmpty) bodyMap['type'] = type;
    if (search != null && search.isNotEmpty) bodyMap['search'] = search;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }
}
