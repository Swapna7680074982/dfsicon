import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../domain/qa_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/qa_provider.dart';
import '../../utils/time_formatter.dart';

class QaSectionWidget extends StatefulWidget {
  final dynamic assignmentId;
  final bool isEmbedded; // If true, renders as an inline section within session details

  const QaSectionWidget({
    super.key,
    required this.assignmentId,
    this.isEmbedded = true,
  });

  @override
  State<QaSectionWidget> createState() => _QaSectionWidgetState();
}

class _QaSectionWidgetState extends State<QaSectionWidget> {
  final TextEditingController _questionController = TextEditingController();
  bool _showMyQuestionsOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final qaProvider = Provider.of<QaProvider>(context, listen: false);
    if (widget.assignmentId != null) {
      qaProvider.fetchSessionThread(
        assignmentId: widget.assignmentId,
        accessToken: auth.accessToken,
        isRefresh: true,
      );
    }
  }

  void _showPostQuestionDialog(BuildContext context) {
    _questionController.clear();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final qaProvider = Provider.of<QaProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final safeBottom = MediaQuery.of(context).padding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomInset + (safeBottom > 0 ? safeBottom : 16) + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ask a Question',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _questionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your question clearly here...',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final text = _questionController.text.trim();
                    if (text.isEmpty) return;
                    Navigator.pop(context);
                    final success = await qaProvider.postQuestion(
                      assignmentId: widget.assignmentId,
                      bodyText: text,
                      accessToken: auth.accessToken,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Question posted successfully!' : (qaProvider.errorMessage ?? 'Failed to post question')),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Submit Question',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReplyDialog(BuildContext context, QaQuestion question) {
    final TextEditingController replyController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final qaProvider = Provider.of<QaProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final safeBottom = MediaQuery.of(context).padding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomInset + (safeBottom > 0 ? safeBottom : 16) + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Post Reply',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Q: "${question.body}"',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: replyController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your answer/reply...',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final text = replyController.text.trim();
                    if (text.isEmpty) return;
                    Navigator.pop(context);
                    final success = await qaProvider.postReply(
                      questionId: question.questionId,
                      bodyText: text,
                      accessToken: auth.accessToken,
                      assignmentId: widget.assignmentId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Reply posted successfully!' : (qaProvider.errorMessage ?? 'Failed to post reply')),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Post Reply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuestionDetailModal(BuildContext context, QaQuestion question) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final qaProvider = Provider.of<QaProvider>(context, listen: false);
    qaProvider.fetchQuestionDetail(
      questionId: question.questionId,
      accessToken: auth.accessToken,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<QaProvider>(
              builder: (context, qProvider, child) {
                final detail = qProvider.selectedQuestionDetail;
                final isLoading = qProvider.isLoadingDetail;
                final q = detail?.question ?? question;
                final replies = detail?.replies ?? question.replies;
                final safeBottom = MediaQuery.of(context).padding.bottom;

                return SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 20.0,
                      bottom: (safeBottom > 0 ? safeBottom : 16) + 16,
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Question Thread',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            children: [
                              _buildQuestionCard(context, q, isDetailView: true),
                              const SizedBox(height: 16),
                              Text(
                                'Replies (${replies.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              else if (replies.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Text(
                                      'No replies yet. Be the first to reply!',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              else
                                ...replies.map((r) => _buildReplyTile(context, r, q.questionId)).toList(),
                            ],
                          ),
                        ),
                        if (qProvider.currentContext?.canReply != false && qProvider.currentContext?.isReadOnly != true)
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.reply, color: Colors.white),
                              label: const Text(
                                'Reply to Question',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _showReplyDialog(context, q);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _confirmDeleteQuestion(BuildContext context, int questionId) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final qaProvider = Provider.of<QaProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await qaProvider.deleteQuestion(
                questionId: questionId,
                accessToken: auth.accessToken,
                assignmentId: widget.assignmentId,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Question deleted' : (qaProvider.errorMessage ?? 'Failed to delete')),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReply(BuildContext context, int replyId, int questionId) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final qaProvider = Provider.of<QaProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await qaProvider.deleteReply(
                replyId: replyId,
                questionId: questionId,
                accessToken: auth.accessToken,
                assignmentId: widget.assignmentId,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Reply deleted' : (qaProvider.errorMessage ?? 'Failed to delete')),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, QaQuestion q, {bool isDetailView = false}) {
    final contextInfo = Provider.of<QaProvider>(context, listen: false).currentContext;
    final canReply = (contextInfo?.canReply ?? true) && (contextInfo?.isReadOnly != true);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: q.isMine ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: q.isSpeakerPost ? AppColors.primary.withAlpha(80) : Colors.grey.shade200,
          width: q.isSpeakerPost ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withAlpha(30),
                backgroundImage: (q.authorImage != null && q.authorImage!.isNotEmpty)
                    ? NetworkImage(q.authorImage!)
                    : null,
                child: (q.authorImage == null || q.authorImage!.isEmpty)
                    ? Text(
                        q.authorName.isNotEmpty ? q.authorName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            q.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (q.isSpeakerPost) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Speaker',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        if (q.isMine) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (q.authorOrganisation != null && q.authorOrganisation!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        q.authorOrganisation!,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (q.canDelete || q.isMine)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _confirmDeleteQuestion(context, q.questionId),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.35,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: q.isAnswered ? Colors.green.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: q.isAnswered ? Colors.green.shade300 : Colors.amber.shade300,
                      ),
                    ),
                    child: Text(
                      q.isAnswered ? 'Answered (${q.replyCount})' : 'Unanswered (${q.replyCount})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: q.isAnswered ? Colors.green.shade800 : Colors.amber.shade900,
                      ),
                    ),
                  ),
                  if (q.createdAt != null && q.createdAt!.isNotEmpty)
                    Text(
                      TimeFormatter.formatRelativeTime(q.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                ],
              ),
              if (!isDetailView)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    if (canReply)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.reply, size: 16, color: AppColors.primary),
                        label: const Text(
                          'Reply',
                          style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _showReplyDialog(context, q),
                      ),
                    InkWell(
                      onTap: () => _showQuestionDetailModal(context, q),
                      child: const Text(
                        'View Replies',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (!isDetailView && q.replies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: q.replies.map((r) => _buildReplyTile(context, r, q.questionId)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyTile(BuildContext context, QaReply reply, int questionId) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: reply.isSpeakerAnswer ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: reply.isSpeakerAnswer ? Colors.amber.shade300 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withAlpha(20),
                backgroundImage: (reply.authorImage != null && reply.authorImage!.isNotEmpty)
                    ? NetworkImage(reply.authorImage!)
                    : null,
                child: (reply.authorImage == null || reply.authorImage!.isEmpty)
                    ? Text(
                        reply.authorName.isNotEmpty ? reply.authorName[0].toUpperCase() : 'R',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        reply.authorName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (reply.isSpeakerAnswer) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Speaker Answer',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    if (reply.isMine) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (reply.canDelete || reply.isMine)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                  onPressed: () => _confirmDeleteReply(context, reply.replyId, questionId),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reply.body,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          if (reply.createdAt != null && reply.createdAt!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              TimeFormatter.formatRelativeTime(reply.createdAt),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  void _openFullScreenQA(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QaFullScreenScreen(assignmentId: widget.assignmentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QaProvider>(
      builder: (context, qaProvider, child) {
        final isLoading = qaProvider.isLoadingThread;
        final questions = _showMyQuestionsOnly ? qaProvider.myQuestions : qaProvider.threadQuestions;
        final contextInfo = qaProvider.currentContext;

        if (widget.isEmbedded) {
          final displayQuestions = questions.take(1).toList();

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.tileBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Q&A Forum',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${questions.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _openFullScreenQA(context),
                          icon: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          label: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                        ),
                        if (contextInfo?.canReply != false && contextInfo?.isReadOnly != true)
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 26),
                            onPressed: () => _showPostQuestionDialog(context),
                            tooltip: 'Ask Question',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (questions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.question_answer_outlined, color: AppColors.textLight, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'No questions submitted for this session yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        if (contextInfo?.canReply != false && contextInfo?.isReadOnly != true)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                            label: const Text('Ask First Question', style: TextStyle(color: Colors.white, fontSize: 13)),
                            onPressed: () => _showPostQuestionDialog(context),
                          ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      ...displayQuestions.map((q) => _buildQuestionCard(context, q)).toList(),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary.withAlpha(120)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _openFullScreenQA(context),
                          icon: const Icon(Icons.fullscreen, color: AppColors.primary, size: 18),
                          label: Text(
                            'View All Questions (${questions.length})',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Q&A Forum',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (contextInfo?.myRole != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            contextInfo?.myRole ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          setState(() {
                            _showMyQuestionsOnly = !_showMyQuestionsOnly;
                          });
                          if (_showMyQuestionsOnly) {
                            qaProvider.fetchMyQuestions(accessToken: auth.accessToken);
                          }
                        },
                        child: Text(
                          _showMyQuestionsOnly ? 'All Questions' : 'My Questions',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      if (contextInfo?.canReply != false && contextInfo?.isReadOnly != true)
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                          onPressed: () => _showPostQuestionDialog(context),
                          tooltip: 'Ask Question',
                        ),
                    ],
                  ),
                ],
              ),
              if (contextInfo?.notice != null && (contextInfo?.notice?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          contextInfo?.notice ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (contextInfo?.isReadOnly == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This Q&A thread is currently in read-only mode.',
                          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (questions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.question_answer_outlined, color: AppColors.textLight, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _showMyQuestionsOnly ? 'You haven\'t asked any questions yet.' : 'No questions submitted for this session yet.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      if (contextInfo?.canReply != false && contextInfo?.isReadOnly != true)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          label: const Text('Ask First Question', style: TextStyle(color: Colors.white, fontSize: 13)),
                          onPressed: () => _showPostQuestionDialog(context),
                        ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    ...questions.map((q) => _buildQuestionCard(context, q)).toList(),
                    if (qaProvider.hasMoreThread && !_showMyQuestionsOnly) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            qaProvider.fetchSessionThread(
                              assignmentId: widget.assignmentId,
                              accessToken: auth.accessToken,
                              isRefresh: false,
                            );
                          },
                          child: const Text('Load More Questions', style: TextStyle(color: AppColors.primary)),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class QaFullScreenScreen extends StatelessWidget {
  final dynamic assignmentId;

  const QaFullScreenScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Q&A', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: QaSectionWidget(
            assignmentId: assignmentId,
            isEmbedded: false,
          ),
        ),
      ),
    );
  }
}
