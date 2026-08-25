import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../domain/networking_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/network_provider.dart';
import '../../providers/sessions_provider.dart';
import 'group_chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  final dynamic assignmentId;

  const CreateGroupScreen({super.key, this.assignmentId});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<MyConnectionItem> _selectedParticipants = [];
  String _searchQuery = '';
  bool _isCreateEnabled = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateCreateState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConnections();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConnections() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final netProvider = Provider.of<NetworkProvider>(context, listen: false);
    if (auth.accessToken.isNotEmpty) {
      await netProvider.fetchMyConnections(accessToken: auth.accessToken);
    }
  }

  void _updateCreateState() {
    setState(() {
      _isCreateEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  Future<void> _handleCreateGroup() async {
    if (!_isCreateEnabled || _isCreating) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final netProvider = Provider.of<NetworkProvider>(context, listen: false);
    final sessionsProvider = Provider.of<SessionsProvider>(context, listen: false);

    dynamic targetAssignmentId = widget.assignmentId;

    if (targetAssignmentId == null || targetAssignmentId.toString().isEmpty) {
      for (final p in _selectedParticipants) {
        if (p.assignmentId != null && p.assignmentId.toString().isNotEmpty) {
          targetAssignmentId = p.assignmentId;
          break;
        }
      }
    }

    if (targetAssignmentId == null || targetAssignmentId.toString().isEmpty) {
      for (final c in netProvider.myConnections) {
        if (c.assignmentId != null && c.assignmentId.toString().isNotEmpty) {
          targetAssignmentId = c.assignmentId;
          break;
        }
      }
    }

    if (targetAssignmentId == null || targetAssignmentId.toString().isEmpty) {
      if (sessionsProvider.mySessions.isNotEmpty) {
        targetAssignmentId = sessionsProvider.mySessions.first.assignmentId;
      } else if (sessionsProvider.sessions.isNotEmpty) {
        targetAssignmentId = sessionsProvider.sessions.first.assignmentId;
      }
    }

    targetAssignmentId ??= 1;

    setState(() {
      _isCreating = true;
    });

    final groupName = _nameController.text.trim();
    final description = _descController.text.trim();
    final memberIds = _selectedParticipants.map((p) => p.userId).toList();

    final newConvId = await netProvider.createGroup(
      assignmentId: targetAssignmentId,
      groupName: groupName,
      groupDescription: description,
      memberIds: memberIds,
      accessToken: auth.accessToken,
    );

    setState(() {
      _isCreating = false;
    });

    if (mounted) {
      if (newConvId != null) {
        final newConv = netProvider.conversations.firstWhere(
          (c) => c.conversationId == newConvId,
          orElse: () => ConversationItem(
            conversationId: newConvId,
            type: 'GROUP',
            title: groupName,
            subtitle: description,
            memberCount: memberIds.length + 1,
            isOwner: true,
          ),
        );

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupChatScreen(conversation: newConv),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create group')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final netProvider = Provider.of<NetworkProvider>(context);

    final allConnections = netProvider.myConnections;

    final filteredConnections = allConnections.where((p) {
      final matchesSearch = p.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.organisationName != null && p.organisationName!.toLowerCase().contains(_searchQuery.toLowerCase()));
      final isAlreadySelected = _selectedParticipants.any((sp) => sp.userId == p.userId);
      return matchesSearch && !isAlreadySelected;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Group',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: _isCreateEnabled && !_isCreating ? _handleCreateGroup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.grey.shade400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Name *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. MedCore Health Team',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Group Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Describe what this group is about...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Members (${_selectedParticipants.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedParticipants.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100, width: 1),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'No members selected yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _selectedParticipants.length,
                  itemBuilder: (context, index) {
                    final p = _selectedParticipants[index];
                    final initials = NetworkProvider.getInitials(p.fullName);
                    final bg = NetworkProvider.getAvatarBg(p.userId);

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEECF9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD1CBEF), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: p.profileImage != null && p.profileImage!.isNotEmpty
                                ? Image.network(
                                    p.profileImage!,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 24,
                                      height: 24,
                                      color: bg,
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 24,
                                    height: 24,
                                    color: bg,
                                    alignment: Alignment.center,
                                    child: Text(
                                      initials,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.fullName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedParticipants.removeAt(index);
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Add Members from Connections',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textLight, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search connections...',
                        hintStyle: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            netProvider.isLoadingConnections && allConnections.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredConnections.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text(
                            allConnections.isEmpty ? 'No connections found' : 'No matching connections',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredConnections.length,
                        itemBuilder: (context, index) {
                          final p = filteredConnections[index];
                          final initials = NetworkProvider.getInitials(p.fullName);
                          final bg = NetworkProvider.getAvatarBg(p.userId);
                          final subtitleText = [p.designation, p.organisationName].where((s) => s != null && s.isNotEmpty).join(', ');

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.tileBorder, width: 1),
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: p.profileImage != null && p.profileImage!.isNotEmpty
                                      ? Image.network(
                                          p.profileImage!,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 44,
                                            height: 44,
                                            color: bg,
                                            alignment: Alignment.center,
                                            child: Text(
                                              initials,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 44,
                                          height: 44,
                                          color: bg,
                                          alignment: Alignment.center,
                                          child: Text(
                                            initials,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.fullName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (subtitleText.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitleText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedParticipants.add(p);
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
