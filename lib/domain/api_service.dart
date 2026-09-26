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
    String citizenType = "INDIAN",
    Map<String, String> meta = defaultMeta,
  }) async {
    final url = Uri.parse(ApiUrls.sendOtp);
    final headers = {'Content-Type': 'application/json'};
    final requestBody = json.encode({
      "credentials": {
        "mobile": phoneNumber,
        "citizen_type": citizenType
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
    String citizenType = "INDIAN",
    Map<String, String> meta = defaultMeta,
  }) async {
    final url = Uri.parse(ApiUrls.verifyOtp);
    final headers = {'Content-Type': 'application/json'};
    final requestBody = json.encode({
      "credentials": {
        "mobile": phoneNumber,
        "otp": otpCode,
        "citizen_type": citizenType
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

  static Future<http.Response> loginPassword({
    required String mobile,
    required String password,
    String citizenType = "FOREIGN",
    Map<String, String> meta = defaultMeta,
  }) async {
    final url = Uri.parse(ApiUrls.loginPassword);
    final headers = {'Content-Type': 'application/json'};
    final requestBody = json.encode({
      "credentials": {
        "mobile": mobile,
        "password": password,
        "citizen_type": citizenType
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

  static Future<http.Response> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.changePassword);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "current_password": currentPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
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

  static Future<http.Response> deleteAccount({
    bool confirm = true,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.deleteAccount);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "confirm": confirm,
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
    dynamic topicId,
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
    if (topicId != null) bodyMap['topic_id'] = topicId;
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
      'assignment_id': assignmentId ?? 1,
      'group_name': groupName,
      'member_ids': memberIds,
    };
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
    List<int>? memberIds,
    dynamic userId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.removeMember);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final targetUserId = userId ?? (memberIds != null && memberIds.isNotEmpty ? memberIds.first : null);
    final Map<String, dynamic> bodyMap = {
      'conversation_id': conversationId,
      'user_id': targetUserId,
    };
    if (memberIds != null) {
      bodyMap['member_ids'] = memberIds;
    }

    final requestBody = json.encode(bodyMap);

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

  // ==========================================
  // Q&A Module APIs
  // ==========================================

  // 1. Q&A - Questions API
  static Future<http.Response> fetchQaQuestions({
    required dynamic assignmentId,
    int? beforeId,
    int limit = 20,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.qaQuestions);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'assignment_id': assignmentId is int ? assignmentId : int.tryParse(assignmentId.toString()) ?? assignmentId,
      'limit': limit,
    };
    if (beforeId != null) {
      bodyMap['before_id'] = beforeId;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 2. Q&A – Post Question API
  static Future<http.Response> postQaQuestion({
    required dynamic assignmentId,
    required String body,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.qaPostQuestion);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'assignment_id': assignmentId is int ? assignmentId : int.tryParse(assignmentId.toString()) ?? assignmentId,
      'body': body,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 3. Q&A – Post Reply API
  static Future<http.Response> postQaReply({
    required dynamic questionId,
    required String body,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.qaPostReply);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'question_id': questionId is int ? questionId : int.tryParse(questionId.toString()) ?? questionId,
      'body': body,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 4. Q&A – Question Detail API
  static Future<http.Response> fetchQaQuestionDetail({
    required dynamic questionId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.qaQuestionDetail);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'question_id': questionId is int ? questionId : int.tryParse(questionId.toString()) ?? questionId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 5. Q&A – Delete Question API
  static Future<http.Response> deleteQaQuestion({
    required dynamic questionId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.qaDeleteQuestion);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'question_id': questionId is int ? questionId : int.tryParse(questionId.toString()) ?? questionId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 6. Q&A – Delete Reply API
  static Future<http.Response> deleteQaReply({
    required dynamic replyId,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.qaDeleteReply);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      'reply_id': replyId is int ? replyId : int.tryParse(replyId.toString()) ?? replyId,
    });

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 7. Q&A – My Questions API
  static Future<http.Response> fetchMyQaQuestions({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.qaMyQuestions);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    const requestBody = '{}';

    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // 8. Q&A – Session Thread API
  static Future<http.Response> fetchQaSessionThread({
    required dynamic assignmentId,
    int? beforeId,
    int limit = 10,
    int? replyLimit,
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.qaSessionThread);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'assignment_id': assignmentId is int ? assignmentId : int.tryParse(assignmentId.toString()) ?? assignmentId,
      'limit': limit,
    };
    if (beforeId != null) {
      bodyMap['before_id'] = beforeId;
    }
    if (replyLimit != null) {
      bodyMap['reply_limit'] = replyLimit;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Utility: My QR API
  static Future<http.Response> fetchMyQr({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.myQr);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({});
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Utility: Get Venue Layouts API
  static Future<http.Response> fetchVenueLayouts({
    required String accessToken,
    dynamic summitId,
    String? layoutType,
  }) async {
    final url = Uri.parse(ApiUrls.venueLayouts);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {};
    if (summitId != null) {
      bodyMap['summit_id'] = summitId is int ? summitId : int.tryParse(summitId.toString()) ?? summitId;
    }
    if (layoutType != null && layoutType.isNotEmpty) {
      bodyMap['layout_type'] = layoutType;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Gallery Module APIs
  // ==========================================

  // Gallery – Get Faces API
  static Future<http.Response> fetchGalleryFaces({
    required String accessToken,
    String? search,
    int? page,
  }) async {
    final url = Uri.parse(ApiUrls.galleryFaces);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {};
    if (search != null && search.trim().isNotEmpty) {
      bodyMap['search'] = search.trim();
    }
    if (page != null) {
      bodyMap['page'] = page;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Gallery – Gallery Days API
  static Future<http.Response> fetchGalleryDays({
    required String accessToken,
    dynamic summitId = 1,
  }) async {
    final url = Uri.parse(ApiUrls.galleryDays);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'summit_id': summitId is int ? summitId : (int.tryParse(summitId.toString()) ?? 1),
    };

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Gallery – Gallery Images API
  static Future<http.Response> fetchGalleryImages({
    required String accessToken,
    dynamic galleryDayId,
    int? page,
  }) async {
    final url = Uri.parse(ApiUrls.galleryImages);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {};
    if (galleryDayId != null) {
      bodyMap['gallery_day_id'] = galleryDayId is int ? galleryDayId : (int.tryParse(galleryDayId.toString()) ?? galleryDayId);
    }
    if (page != null) {
      bodyMap['page'] = page;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Gallery – Gallery Face Match API
  static Future<http.Response> fetchGalleryMatch({
    required String accessToken,
    List<int>? userIds,
    bool requireAll = false,
  }) async {
    final url = Uri.parse(ApiUrls.galleryMatch);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      'require_all': requireAll,
    };
    if (userIds != null && userIds.isNotEmpty) {
      bodyMap['user_ids'] = userIds;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Admin Module API Calls
  // ==========================================

  // Admin – Dashboard Stats
  static Future<http.Response> fetchAdminDashboardStats({
    required String accessToken,
    int summitId = 1,
  }) async {
    final url = Uri.parse(ApiUrls.adminDashboardStats);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "summit_id": summitId,
    });
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Speakers
  static Future<http.Response> fetchAdminAllSpeakers({
    required String accessToken,
    int page = 1,
    int limit = 10,
    String? search,
    String? state,
    String? city,
    String? category,
    String? citizenType,
    String? qualification,
    String sortBy = 'full_name',
    String sortOrder = 'ASC',
  }) async {
    final url = Uri.parse(ApiUrls.adminAllSpeakers);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "page": page,
      "limit": limit,
      "sort_by": sortBy,
      "sort_order": sortOrder,
    };
    if (search != null && search.trim().isNotEmpty) bodyMap['search'] = search.trim();
    if (state != null && state.isNotEmpty) bodyMap['state'] = state;
    if (city != null && city.isNotEmpty) bodyMap['city'] = city;
    if (category != null && category.isNotEmpty) bodyMap['category'] = category;
    if (citizenType != null && citizenType.isNotEmpty) bodyMap['citizen_type'] = citizenType;
    if (qualification != null && qualification.isNotEmpty) bodyMap['qualification'] = qualification;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Speaker Details
  static Future<http.Response> fetchAdminSpeakerDetails({
    required String accessToken,
    required dynamic userId,
  }) async {
    final url = Uri.parse(ApiUrls.adminSpeakerDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "user_id": userId is int ? userId : (int.tryParse(userId.toString()) ?? userId),
    });
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Delegates
  static Future<http.Response> fetchAdminAllDelegates({
    required String accessToken,
    int page = 1,
    int limit = 10,
    String? search,
    String? state,
    String? city,
    String? category,
    String? citizenType,
    String? qualification,
    String sortBy = 'full_name',
    String sortOrder = 'ASC',
  }) async {
    final url = Uri.parse(ApiUrls.adminAllDelegates);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "page": page,
      "limit": limit,
      "sort_by": sortBy,
      "sort_order": sortOrder,
    };
    if (search != null && search.trim().isNotEmpty) bodyMap['search'] = search.trim();
    if (state != null && state.isNotEmpty) bodyMap['state'] = state;
    if (city != null && city.isNotEmpty) bodyMap['city'] = city;
    if (category != null && category.isNotEmpty) bodyMap['category'] = category;
    if (citizenType != null && citizenType.isNotEmpty) bodyMap['citizen_type'] = citizenType;
    if (qualification != null && qualification.isNotEmpty) bodyMap['qualification'] = qualification;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Delegate Details
  static Future<http.Response> fetchAdminDelegateDetails({
    required String accessToken,
    required dynamic userId,
  }) async {
    final url = Uri.parse(ApiUrls.adminDelegateDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "user_id": userId is int ? userId : (int.tryParse(userId.toString()) ?? userId),
    });
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Topics
  static Future<http.Response> fetchAdminAllTopics({
    required String accessToken,
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryOfSubmission,
    String? status,
    String? topicStatus,
    dynamic speakerId,
    int summitId = 1,
    String sortBy = 'created_on',
    String sortOrder = 'DESC',
  }) async {
    final url = Uri.parse(ApiUrls.adminAllTopics);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "page": page,
      "limit": limit,
      "summit_id": summitId,
      "sort_by": sortBy,
      "sort_order": sortOrder,
    };
    if (search != null && search.trim().isNotEmpty) bodyMap['search'] = search.trim();
    if (categoryOfSubmission != null && categoryOfSubmission.isNotEmpty) {
      bodyMap['category_of_submission'] = categoryOfSubmission;
    }
    if (status != null && status.isNotEmpty) bodyMap['status'] = status;
    if (topicStatus != null && topicStatus.isNotEmpty) bodyMap['topic_status'] = topicStatus;
    if (speakerId != null) {
      bodyMap['speaker_id'] = speakerId is int ? speakerId : (int.tryParse(speakerId.toString()) ?? speakerId);
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Topic Details
  static Future<http.Response> fetchAdminTopicDetails({
    required String accessToken,
    required dynamic topicId,
  }) async {
    final url = Uri.parse(ApiUrls.adminTopicDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "topic_id": topicId is int ? topicId : (int.tryParse(topicId.toString()) ?? topicId),
    });
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Topic Bookmarks
  static Future<http.Response> fetchAdminTopicBookmarks({
    required String accessToken,
    required dynamic topicId,
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse(ApiUrls.adminTopicBookmarks);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "topic_id": topicId is int ? topicId : (int.tryParse(topicId.toString()) ?? topicId),
      "page": page,
      "limit": limit,
    });
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Workshops
  static Future<http.Response> fetchAdminAllWorkshops({
    required String accessToken,
    int page = 1,
    int limit = 50,
    String? search,
    int? workshopStatus = 1,
    int summitId = 1,
    String sortBy = 'workshop_start',
    String sortOrder = 'ASC',
  }) async {
    final url = Uri.parse(ApiUrls.adminAllWorkshops);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "page": page,
      "limit": limit,
      "summit_id": summitId,
      "sort_by": sortBy,
      "sort_order": sortOrder,
      "workshop_status": workshopStatus ?? 1,
    };
    if (search != null && search.trim().isNotEmpty) bodyMap['search'] = search.trim();

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Workshop Participants
  static Future<http.Response> fetchAdminWorkshopParticipants({
    required String accessToken,
    required dynamic workshopId,
    int speakerPage = 1,
    int speakerLimit = 10,
    int delegatePage = 1,
    int delegateLimit = 10,
  }) async {
    final url = Uri.parse(ApiUrls.adminWorkshopParticipants);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "workshop_id": workshopId is int ? workshopId : (int.tryParse(workshopId.toString()) ?? workshopId),
      "speaker_page": speakerPage,
      "speaker_limit": speakerLimit,
      "delegate_page": delegatePage,
      "delegate_limit": delegateLimit,
    });
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Sponsors
  static Future<http.Response> fetchAdminAllSponsors({
    required String accessToken,
    int page = 1,
    int limit = 10,
    String? search,
    String? sponsorType,
    String? sponsorCategory,
    int? status = 1,
    int summitId = 1,
    String sortBy = 'company_name',
    String sortOrder = 'ASC',
  }) async {
    final url = Uri.parse(ApiUrls.adminAllSponsors);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "page": page,
      "limit": limit,
      "summit_id": summitId,
      "sort_by": sortBy,
      "sort_order": sortOrder,
    };
    if (search != null && search.trim().isNotEmpty) bodyMap['search'] = search.trim();
    if (sponsorType != null && sponsorType.isNotEmpty) bodyMap['sponsor_type'] = sponsorType;
    if (sponsorCategory != null && sponsorCategory.isNotEmpty) bodyMap['sponsor_category'] = sponsorCategory;
    if (status != null) bodyMap['status'] = status;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Sponsor Details
  static Future<http.Response> fetchAdminSponsorDetails({
    required String accessToken,
    required dynamic sponsorId,
    int summitId = 1,
  }) async {
    final url = Uri.parse(ApiUrls.adminSponsorDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({
      "sponsor_id": sponsorId is int ? sponsorId : (int.tryParse(sponsorId.toString()) ?? sponsorId),
      "summit_id": summitId,
    });
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Sponsor Categories
  static Future<http.Response> fetchAdminAllSponsorCategories({
    required String accessToken,
    int page = 1,
    int limit = 20,
    String? search,
    int? status = 1,
  }) async {
    final url = Uri.parse(ApiUrls.adminAllSponsorCategories);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "page": page,
      "limit": limit,
    };
    if (search != null && search.trim().isNotEmpty) bodyMap['search'] = search.trim();
    if (status != null) bodyMap['status'] = status;

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Booths
  static Future<http.Response> fetchAdminAllBooths({
    required String accessToken,
    int page = 1,
    int limit = 150,
    String search = '',
    dynamic sponsorId,
    String? boothType,
    int? status = 1,
    String? assignmentFilter,
    int summitId = 1,
  }) async {
    final url = Uri.parse(ApiUrls.adminAllBooths);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "page": page,
      "limit": limit,
      "search": search,
      "status": status ?? 1,
      "summit_id": summitId,
    };
    if (sponsorId != null) {
      bodyMap["sponsor_id"] = sponsorId is int ? sponsorId : int.tryParse(sponsorId.toString());
    }
    if (boothType != null && boothType.isNotEmpty) {
      bodyMap["booth_type"] = boothType;
    }
    if (assignmentFilter != null && assignmentFilter.isNotEmpty) {
      bodyMap["assignment_filter"] = assignmentFilter;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Sponsor Booths (Alias)
  static Future<http.Response> fetchAdminAllSponsorBooths({
    required String accessToken,
    int page = 1,
    int limit = 150,
    String search = '',
    dynamic sponsorId,
    String? boothType,
    int? status = 1,
    int summitId = 1,
  }) =>
      fetchAdminAllBooths(
        accessToken: accessToken,
        page: page,
        limit: limit,
        search: search,
        sponsorId: sponsorId,
        boothType: boothType,
        status: status,
        summitId: summitId,
      );

  // Admin – Booth Details
  static Future<http.Response> fetchAdminBoothDetails({
    required String accessToken,
    required dynamic boothId,
    int summitId = 1,
  }) async {
    final url = Uri.parse(ApiUrls.adminBoothDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "booth_id": boothId is int ? boothId : int.tryParse(boothId.toString()) ?? boothId,
      "summit_id": summitId,
    };

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – All Slots
  static Future<http.Response> fetchAdminAllSlots({
    required String accessToken,
    int summitId = 1,
    dynamic hallId,
    dynamic scheduleDay,
  }) async {
    final url = Uri.parse(ApiUrls.adminAllSlots);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "summit_id": summitId,
    };
    if (hallId != null) {
      bodyMap["hall_id"] = hallId is int ? hallId : int.tryParse(hallId.toString());
    }
    if (scheduleDay != null) {
      bodyMap["schedule_day"] = scheduleDay is int ? scheduleDay : int.tryParse(scheduleDay.toString());
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Slot Details
  static Future<http.Response> fetchAdminSlotDetails({
    required String accessToken,
    dynamic slotId,
    int summitId = 1,
    dynamic hallId,
    dynamic scheduleDay,
  }) async {
    final url = Uri.parse(ApiUrls.adminSlotDetails);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "summit_id": summitId,
    };
    if (slotId != null && slotId.toString().isNotEmpty) {
      bodyMap["slot_id"] = slotId is int ? slotId : int.tryParse(slotId.toString()) ?? slotId;
    }
    if (hallId != null && hallId.toString().isNotEmpty) {
      bodyMap["hall_id"] = hallId is int ? hallId : int.tryParse(hallId.toString()) ?? hallId;
    }
    if (scheduleDay != null && scheduleDay.toString().isNotEmpty) {
      bodyMap["schedule_day"] = scheduleDay is int ? scheduleDay : int.tryParse(scheduleDay.toString()) ?? scheduleDay;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Sponsor Booth Footfall Stats
  static Future<http.Response> fetchAdminSponsorBoothStats({
    required String accessToken,
    required dynamic sponsorId,
    dynamic summitId = 1,
    String? date,
  }) async {
    final url = Uri.parse(ApiUrls.adminSponsorBoothStats);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "sponsor_id": sponsorId is int ? sponsorId : (int.tryParse(sponsorId.toString()) ?? sponsorId),
    };
    if (summitId != null) {
      bodyMap["summit_id"] = summitId is int ? summitId : (int.tryParse(summitId.toString()) ?? 1);
    }
    if (date != null && date.trim().isNotEmpty) {
      bodyMap["date"] = date.trim();
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // Admin – Sponsor Footfall Participants
  static Future<http.Response> fetchAdminSponsorFootfallParticipants({
    required String accessToken,
    required dynamic sponsorId,
    dynamic summitId = 1,
    dynamic boothId,
    String? date,
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse(ApiUrls.adminSponsorFootfallParticipants);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> bodyMap = {
      "sponsor_id": sponsorId is int ? sponsorId : (int.tryParse(sponsorId.toString()) ?? sponsorId),
      "page": page,
      "limit": limit,
    };
    if (summitId != null) {
      bodyMap["summit_id"] = summitId is int ? summitId : (int.tryParse(summitId.toString()) ?? 1);
    }
    if (boothId != null && boothId.toString().trim().isNotEmpty && boothId.toString().trim() != '0') {
      bodyMap["booth_id"] = boothId is int ? boothId : (int.tryParse(boothId.toString()) ?? boothId);
    }
    if (date != null && date.trim().isNotEmpty) {
      bodyMap["date"] = date.trim();
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Utility – Documents API Call
  // ==========================================
  static Future<http.Response> fetchDocuments({
    required String accessToken,
  }) async {
    final url = Uri.parse(ApiUrls.getDocuments);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final requestBody = json.encode({});
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  // ==========================================
  // Exhibitor Module API Calls
  // ==========================================
  static Future<http.Response> getExhibitorCounts({
    required String accessToken,
    dynamic summitId = 1,
    String? date,
  }) async {
    final url = Uri.parse(ApiUrls.exhibitorCounts);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final bodyMap = <String, dynamic>{
      "summit_id": summitId is int ? summitId : int.tryParse(summitId.toString()) ?? 1,
    };
    if (date != null && date.trim().isNotEmpty) {
      bodyMap["date"] = date.trim();
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> getExhibitorParticipants({
    required String accessToken,
    dynamic summitId = 1,
    String? date,
    dynamic boothId,
  }) async {
    final url = Uri.parse(ApiUrls.exhibitorParticipants);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final bodyMap = <String, dynamic>{
      "summit_id": summitId is int ? summitId : int.tryParse(summitId.toString()) ?? 1,
    };
    if (date != null && date.trim().isNotEmpty) {
      bodyMap["date"] = date.trim();
    }
    if (boothId != null && boothId.toString().trim().isNotEmpty) {
      bodyMap["booth_id"] = boothId is int ? boothId : int.tryParse(boothId.toString()) ?? boothId;
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }

  static Future<http.Response> recordExhibitorScan({
    required String accessToken,
    required String qrData,
    dynamic boothId,
    String? remarks,
  }) async {
    final url = Uri.parse(ApiUrls.exhibitorScan);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final bodyMap = <String, dynamic>{
      "qr_data": qrData.trim(),
    };
    if (boothId != null && boothId.toString().trim().isNotEmpty && boothId.toString().trim() != '0') {
      bodyMap["booth_id"] = int.tryParse(boothId.toString()) ?? boothId;
    }
    if (remarks != null && remarks.trim().isNotEmpty) {
      bodyMap["remarks"] = remarks.trim();
    }

    final requestBody = json.encode(bodyMap);
    CustomLogger.logRequest('POST', url.toString(), headers: headers, body: requestBody);
    final response = await http.post(url, headers: headers, body: requestBody);
    CustomLogger.logResponse('POST', url.toString(), response.statusCode, response.body);
    return response;
  }
}




