class QaContext {
  final int? assignmentId;
  final String? topicTitle;
  final String? myRole;
  final bool isReadOnly;
  final bool canReply;
  final String? notice;
  final int? replyLimit;

  QaContext({
    this.assignmentId,
    this.topicTitle,
    this.myRole,
    this.isReadOnly = false,
    this.canReply = true,
    this.notice,
    this.replyLimit,
  });

  factory QaContext.fromJson(Map<String, dynamic> json) {
    return QaContext(
      assignmentId: json['assignment_id'] is int
          ? json['assignment_id']
          : int.tryParse(json['assignment_id']?.toString() ?? ''),
      topicTitle: json['topic_title']?.toString(),
      myRole: json['my_role']?.toString(),
      isReadOnly: json['is_read_only'] == true || json['is_read_only'] == 1 || json['is_read_only'] == 'true',
      canReply: json['can_reply'] == true || json['can_reply'] == 1 || json['can_reply'] == 'true',
      notice: json['notice']?.toString(),
      replyLimit: json['reply_limit'] is int
          ? json['reply_limit']
          : int.tryParse(json['reply_limit']?.toString() ?? ''),
    );
  }
}

class QaReply {
  final int replyId;
  final int? questionId;
  final String body;
  final int authorId;
  final String authorName;
  final String? authorRole;
  final String? authorDesignation;
  final String? authorOrganisation;
  final String? authorImage;
  final bool isSpeakerAnswer;
  final bool isMine;
  final bool canDelete;
  final String? createdAt;

  QaReply({
    required this.replyId,
    this.questionId,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.authorRole,
    this.authorDesignation,
    this.authorOrganisation,
    this.authorImage,
    this.isSpeakerAnswer = false,
    this.isMine = false,
    this.canDelete = false,
    this.createdAt,
  });

  factory QaReply.fromJson(Map<String, dynamic> json) {
    String? img = json['author_image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }
    return QaReply(
      replyId: json['reply_id'] is int
          ? json['reply_id']
          : int.tryParse(json['reply_id']?.toString() ?? '0') ?? 0,
      questionId: json['question_id'] is int
          ? json['question_id']
          : int.tryParse(json['question_id']?.toString() ?? ''),
      body: json['body']?.toString() ?? '',
      authorId: json['author_id'] is int
          ? json['author_id']
          : int.tryParse(json['author_id']?.toString() ?? '0') ?? 0,
      authorName: json['author_name']?.toString() ?? '',
      authorRole: json['author_role']?.toString(),
      authorDesignation: json['author_designation']?.toString(),
      authorOrganisation: json['author_organisation']?.toString(),
      authorImage: img,
      isSpeakerAnswer: json['is_speaker_answer'] == true ||
          json['is_speaker_answer'] == 1 ||
          json['is_speaker_answer'] == 'true',
      isMine: json['is_mine'] == true || json['is_mine'] == 1 || json['is_mine'] == 'true',
      canDelete: json['can_delete'] == true || json['can_delete'] == 1 || json['can_delete'] == 'true',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class QaQuestion {
  final int questionId;
  final int? assignmentId;
  final String? topicTitle;
  final String body;
  final int authorId;
  final String authorName;
  final String? authorRole;
  final String? authorDesignation;
  final String? authorOrganisation;
  final String? authorImage;
  final bool isSpeakerPost;
  final bool isMine;
  final int replyCount;
  final bool isAnswered;
  final String? lastReplyAt;
  final String? lastReplyName;
  final bool canDelete;
  final String? createdAt;
  final List<QaReply> replies;
  final int? repliesShown;
  final bool hasMoreReplies;

  QaQuestion({
    required this.questionId,
    this.assignmentId,
    this.topicTitle,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.authorRole,
    this.authorDesignation,
    this.authorOrganisation,
    this.authorImage,
    this.isSpeakerPost = false,
    this.isMine = false,
    this.replyCount = 0,
    this.isAnswered = false,
    this.lastReplyAt,
    this.lastReplyName,
    this.canDelete = false,
    this.createdAt,
    this.replies = const [],
    this.repliesShown,
    this.hasMoreReplies = false,
  });

  factory QaQuestion.fromJson(Map<String, dynamic> json) {
    String? img = json['author_image']?.toString();
    if (img != null && img.contains('/./')) {
      img = img.replaceAll('/./', '/');
    }

    List<QaReply> replyList = [];
    if (json['replies'] is List) {
      replyList = (json['replies'] as List)
          .map((r) => QaReply.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return QaQuestion(
      questionId: json['question_id'] is int
          ? json['question_id']
          : int.tryParse(json['question_id']?.toString() ?? '0') ?? 0,
      assignmentId: json['assignment_id'] is int
          ? json['assignment_id']
          : int.tryParse(json['assignment_id']?.toString() ?? ''),
      topicTitle: json['topic_title']?.toString(),
      body: json['body']?.toString() ?? '',
      authorId: json['author_id'] is int
          ? json['author_id']
          : int.tryParse(json['author_id']?.toString() ?? '0') ?? 0,
      authorName: json['author_name']?.toString() ?? '',
      authorRole: json['author_role']?.toString(),
      authorDesignation: json['author_designation']?.toString(),
      authorOrganisation: json['author_organisation']?.toString(),
      authorImage: img,
      isSpeakerPost: json['is_speaker_post'] == true ||
          json['is_speaker_post'] == 1 ||
          json['is_speaker_post'] == 'true',
      isMine: json['is_mine'] == true || json['is_mine'] == 1 || json['is_mine'] == 'true',
      replyCount: json['reply_count'] is int
          ? json['reply_count']
          : int.tryParse(json['reply_count']?.toString() ?? '0') ?? 0,
      isAnswered: json['is_answered'] == true || json['is_answered'] == 1 || json['is_answered'] == 'true',
      lastReplyAt: json['last_reply_at']?.toString(),
      lastReplyName: json['last_reply_name']?.toString(),
      canDelete: json['can_delete'] == true || json['can_delete'] == 1 || json['can_delete'] == 'true',
      createdAt: json['created_at']?.toString(),
      replies: replyList,
      repliesShown: json['replies_shown'] is int
          ? json['replies_shown']
          : int.tryParse(json['replies_shown']?.toString() ?? ''),
      hasMoreReplies: json['has_more_replies'] == true ||
          json['has_more_replies'] == 1 ||
          json['has_more_replies'] == 'true',
    );
  }
}

class QaThreadResponse {
  final bool status;
  final String message;
  final QaContext? context;
  final int total;
  final bool hasMore;
  final int? nextBeforeId;
  final List<QaQuestion> data;

  QaThreadResponse({
    required this.status,
    required this.message,
    this.context,
    this.total = 0,
    this.hasMore = false,
    this.nextBeforeId,
    this.data = const [],
  });

  factory QaThreadResponse.fromJson(Map<String, dynamic> json) {
    List<QaQuestion> list = [];
    if (json['data'] is List) {
      list = (json['data'] as List)
          .map((q) => QaQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    }
    return QaThreadResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      context: json['context'] is Map<String, dynamic>
          ? QaContext.fromJson(json['context'] as Map<String, dynamic>)
          : null,
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      hasMore: json['has_more'] == true || json['has_more'] == 'true',
      nextBeforeId: json['next_before_id'] is int
          ? json['next_before_id']
          : int.tryParse(json['next_before_id']?.toString() ?? ''),
      data: list,
    );
  }
}

class QaQuestionsResponse {
  final bool status;
  final String message;
  final QaContext? context;
  final int total;
  final bool hasMore;
  final int? nextBeforeId;
  final List<QaQuestion> data;

  QaQuestionsResponse({
    required this.status,
    required this.message,
    this.context,
    this.total = 0,
    this.hasMore = false,
    this.nextBeforeId,
    this.data = const [],
  });

  factory QaQuestionsResponse.fromJson(Map<String, dynamic> json) {
    List<QaQuestion> list = [];
    if (json['data'] is List) {
      list = (json['data'] as List)
          .map((q) => QaQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    }
    return QaQuestionsResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      context: json['context'] is Map<String, dynamic>
          ? QaContext.fromJson(json['context'] as Map<String, dynamic>)
          : null,
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      hasMore: json['has_more'] == true || json['has_more'] == 'true',
      nextBeforeId: json['next_before_id'] is int
          ? json['next_before_id']
          : int.tryParse(json['next_before_id']?.toString() ?? ''),
      data: list,
    );
  }
}

class QaDetailResponse {
  final bool status;
  final String message;
  final QaContext? context;
  final QaQuestion? question;
  final List<QaReply> replies;

  QaDetailResponse({
    required this.status,
    required this.message,
    this.context,
    this.question,
    this.replies = const [],
  });

  factory QaDetailResponse.fromJson(Map<String, dynamic> json) {
    List<QaReply> replyList = [];
    if (json['replies'] is List) {
      replyList = (json['replies'] as List)
          .map((r) => QaReply.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    return QaDetailResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      context: json['context'] is Map<String, dynamic>
          ? QaContext.fromJson(json['context'] as Map<String, dynamic>)
          : null,
      question: json['question'] is Map<String, dynamic>
          ? QaQuestion.fromJson(json['question'] as Map<String, dynamic>)
          : null,
      replies: replyList,
    );
  }
}

class QaMyQuestionsResponse {
  final bool status;
  final String message;
  final int count;
  final List<QaQuestion> data;

  QaMyQuestionsResponse({
    required this.status,
    required this.message,
    this.count = 0,
    this.data = const [],
  });

  factory QaMyQuestionsResponse.fromJson(Map<String, dynamic> json) {
    List<QaQuestion> list = [];
    if (json['data'] is List) {
      list = (json['data'] as List)
          .map((q) => QaQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    }
    return QaMyQuestionsResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      data: list,
    );
  }
}
