import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/api_service.dart';
import '../domain/qa_models.dart';

class QaProvider with ChangeNotifier {
  bool _isLoadingThread = false;
  bool _isPostingQuestion = false;
  bool _isPostingReply = false;
  bool _isDeleting = false;
  bool _isLoadingMyQuestions = false;
  bool _isLoadingDetail = false;

  String? _errorMessage;
  QaContext? _currentContext;
  List<QaQuestion> _threadQuestions = [];
  List<QaQuestion> _myQuestions = [];
  QaDetailResponse? _selectedQuestionDetail;
  bool _hasMoreThread = false;
  int? _nextBeforeId;

  bool get isLoadingThread => _isLoadingThread;
  bool get isPostingQuestion => _isPostingQuestion;
  bool get isPostingReply => _isPostingReply;
  bool get isDeleting => _isDeleting;
  bool get isLoadingMyQuestions => _isLoadingMyQuestions;
  bool get isLoadingDetail => _isLoadingDetail;

  String? get errorMessage => _errorMessage;
  QaContext? get currentContext => _currentContext;
  List<QaQuestion> get threadQuestions => List.unmodifiable(_threadQuestions);
  List<QaQuestion> get myQuestions => List.unmodifiable(_myQuestions);
  QaDetailResponse? get selectedQuestionDetail => _selectedQuestionDetail;
  bool get hasMoreThread => _hasMoreThread;
  int? get nextBeforeId => _nextBeforeId;

  // 1. Fetch Session Thread
  Future<void> fetchSessionThread({
    required dynamic assignmentId,
    required String accessToken,
    bool isRefresh = true,
    int limit = 10,
  }) async {
    if (isRefresh) {
      _isLoadingThread = true;
      _errorMessage = null;
      _nextBeforeId = null;
      notifyListeners();
    }

    try {
      final response = await ApiService.fetchQaSessionThread(
        assignmentId: assignmentId,
        beforeId: isRefresh ? null : _nextBeforeId,
        limit: limit,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final threadResp = QaThreadResponse.fromJson(body);
        if (threadResp.status) {
          _currentContext = threadResp.context ?? _currentContext;
          _hasMoreThread = threadResp.hasMore;
          _nextBeforeId = threadResp.nextBeforeId;

          if (isRefresh) {
            _threadQuestions = threadResp.data;
          } else {
            _threadQuestions.addAll(threadResp.data);
          }
        } else {
          _errorMessage = threadResp.message.isNotEmpty ? threadResp.message : 'Failed to fetch thread';
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingThread = false;
      notifyListeners();
    }
  }

  // 2. Post Question
  Future<bool> postQuestion({
    required dynamic assignmentId,
    required String bodyText,
    required String accessToken,
  }) async {
    _isPostingQuestion = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.postQaQuestion(
        assignmentId: assignmentId,
        body: bodyText,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == true) {
          // Refetch thread to show new question
          await fetchSessionThread(
            assignmentId: assignmentId,
            accessToken: accessToken,
            isRefresh: true,
          );
          return true;
        } else {
          _errorMessage = body['message']?.toString() ?? 'Failed to post question';
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isPostingQuestion = false;
      notifyListeners();
    }
    return false;
  }

  // 3. Post Reply
  Future<bool> postReply({
    required dynamic questionId,
    required String bodyText,
    required String accessToken,
    dynamic assignmentId,
  }) async {
    _isPostingReply = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.postQaReply(
        questionId: questionId,
        body: bodyText,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == true) {
          if (assignmentId != null) {
            await fetchSessionThread(
              assignmentId: assignmentId,
              accessToken: accessToken,
              isRefresh: true,
            );
          }
          await fetchQuestionDetail(
            questionId: questionId,
            accessToken: accessToken,
          );
          return true;
        } else {
          _errorMessage = body['message']?.toString() ?? 'Failed to post reply';
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isPostingReply = false;
      notifyListeners();
    }
    return false;
  }

  // 4. Question Detail
  Future<void> fetchQuestionDetail({
    required dynamic questionId,
    required String accessToken,
  }) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchQaQuestionDetail(
        questionId: questionId,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        _selectedQuestionDetail = QaDetailResponse.fromJson(body);
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // 5. Delete Question
  Future<bool> deleteQuestion({
    required dynamic questionId,
    required String accessToken,
    dynamic assignmentId,
  }) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.deleteQaQuestion(
        questionId: questionId,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == true) {
          int qIdInt = questionId is int ? questionId : int.tryParse(questionId.toString()) ?? 0;
          _threadQuestions.removeWhere((q) => q.questionId == qIdInt);
          _myQuestions.removeWhere((q) => q.questionId == qIdInt);
          if (assignmentId != null) {
            await fetchSessionThread(
              assignmentId: assignmentId,
              accessToken: accessToken,
              isRefresh: true,
            );
          }
          return true;
        } else {
          _errorMessage = body['message']?.toString() ?? 'Failed to delete question';
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
    return false;
  }

  // 6. Delete Reply
  Future<bool> deleteReply({
    required dynamic replyId,
    required dynamic questionId,
    required String accessToken,
    dynamic assignmentId,
  }) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.deleteQaReply(
        replyId: replyId,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == true) {
          if (assignmentId != null) {
            await fetchSessionThread(
              assignmentId: assignmentId,
              accessToken: accessToken,
              isRefresh: true,
            );
          }
          await fetchQuestionDetail(
            questionId: questionId,
            accessToken: accessToken,
          );
          return true;
        } else {
          _errorMessage = body['message']?.toString() ?? 'Failed to delete reply';
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
    return false;
  }

  // 7. My Questions
  Future<void> fetchMyQuestions({
    required String accessToken,
  }) async {
    _isLoadingMyQuestions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchMyQaQuestions(
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final myResp = QaMyQuestionsResponse.fromJson(body);
        if (myResp.status) {
          _myQuestions = myResp.data;
        } else {
          _errorMessage = myResp.message.isNotEmpty ? myResp.message : 'Failed to fetch your questions';
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMyQuestions = false;
      notifyListeners();
    }
  }

  void clearDetail() {
    _selectedQuestionDetail = null;
    notifyListeners();
  }
}
