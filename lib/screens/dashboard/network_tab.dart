import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/network_provider.dart';
import '../chat/chat_detail_screen.dart';
import '../chat/group_chat_screen.dart';
import '../chat/create_group_screen.dart';
import '../network/connection_requests_screen.dart';
import '../../widgets/water_droplets_background.dart';

class NetworkTab extends StatefulWidget {
  const NetworkTab({super.key});

  @override
  State<NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends State<NetworkTab> {
  int _selectedSegment = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final netProvider = Provider.of<NetworkProvider>(context, listen: false);
    if (auth.accessToken.isNotEmpty) {
      await Future.wait([
        netProvider.fetchConversations(accessToken: auth.accessToken),
        netProvider.fetchPendingRequests(accessToken: auth.accessToken),
        netProvider.fetchUnreadCount(accessToken: auth.accessToken),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final netProvider = Provider.of<NetworkProvider>(context);
    final isChats = _selectedSegment == 0;

    final conversations = isChats
        ? netProvider.conversations
        : netProvider.groupChats;

    final filteredConversations = conversations.where((c) {
      final matchesSearch = c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.subtitle != null && c.subtitle!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (c.lastMessage != null && c.lastMessage!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesSearch;
    }).toList();

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 2,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Networking',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!isChats)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
                    ).then((_) => _loadData());
                  },
                  icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                  label: const Text(
                    'NEW GROUP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
            ],
          ),
          centerTitle: false,
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSegment = 0;
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isChats ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: isChats
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(8),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'CHATS',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isChats ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSegment = 1;
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isChats ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: !isChats
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(8),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'GROUPS',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: !isChats ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: isChats ? 'SEARCH CONVERSATIONS...' : 'SEARCH GROUPS...',
                                hintStyle: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: netProvider.isLoadingConversations && netProvider.conversations.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        children: [
                          if (isChats && netProvider.requests.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'CONNECTION REQUESTS',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${netProvider.requests.length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ConnectionRequestsScreen(),
                                        ),
                                      ).then((_) => _loadData());
                                    },
                                    child: const Text(
                                      'VIEW ALL',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...netProvider.requests.map((req) {
                              final initials = NetworkProvider.getInitials(req.fullName);
                              final bg = NetworkProvider.getAvatarBg(req.connectionId);
                              final subtitleText = [
                                req.designation,
                                req.organisationName
                              ].where((s) => s != null && s.isNotEmpty).join(', ');

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.tileBorder, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: req.profileImage != null && req.profileImage!.isNotEmpty
                                          ? Image.network(
                                              req.profileImage!,
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
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
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
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            req.fullName,
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
                                    ElevatedButton(
                                      onPressed: () async {
                                        final success = await netProvider.respondConnectionRequest(
                                          connectionId: req.connectionId,
                                          action: 'ACCEPT',
                                          accessToken: authProvider.accessToken,
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(success ? 'Connected with ${req.fullName}!' : 'Action failed'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.person_add_alt_1_outlined, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            'ACCEPT',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Container(
                                height: 1,
                                color: AppColors.tileBorder,
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Text(
                              isChats ? 'CONVERSATIONS' : 'GROUPS',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (filteredConversations.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      isChats ? Icons.chat_bubble_outline : Icons.group_outlined,
                                      size: 48,
                                      color: AppColors.textLight,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      isChats ? 'No conversations found' : 'No groups found',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...filteredConversations.map((conv) {
                              final initials = NetworkProvider.getInitials(conv.title);
                              final bg = NetworkProvider.getAvatarBg(conv.conversationId);

                              return GestureDetector(
                                onTap: () {
                                  netProvider.markAsRead(
                                    conversationId: conv.conversationId,
                                    accessToken: authProvider.accessToken,
                                  );
                                  if (conv.isGroup) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupChatScreen(conversation: conv),
                                      ),
                                    ).then((_) => _loadData());
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatDetailScreen(conversation: conv),
                                      ),
                                    ).then((_) => _loadData());
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.tileBorder, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: conv.image != null && conv.image!.isNotEmpty
                                            ? Image.network(
                                                conv.image!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: bg,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    initials,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                width: 50,
                                                height: 50,
                                                color: bg,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  initials,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    conv.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                if (conv.lastMessageAt != null && conv.lastMessageAt!.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    conv.lastMessageAt!,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textLight,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    conv.isGroup
                                                        ? 'Group · ${conv.memberCount} members · ${conv.lastMessage ?? ""}'
                                                        : (conv.lastMessage ?? conv.subtitle ?? ''),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: conv.unreadCount > 0
                                                          ? FontWeight.w700
                                                          : FontWeight.w400,
                                                      color: conv.unreadCount > 0
                                                          ? AppColors.textPrimary
                                                          : AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                                if (conv.unreadCount > 0) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF1E1B4B),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Text(
                                                      '${conv.unreadCount}',
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (!isChats && conv.isGroup) ...[
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '${conv.memberCount} members',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textLight,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 32,
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        netProvider.markAsRead(
                                                          conversationId: conv.conversationId,
                                                          accessToken: authProvider.accessToken,
                                                        );
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => GroupChatScreen(conversation: conv),
                                                          ),
                                                        ).then((_) => _loadData());
                                                      },
                                                      style: OutlinedButton.styleFrom(
                                                        backgroundColor: const Color(0xFFF5F3FF),
                                                        foregroundColor: AppColors.primary,
                                                        side: BorderSide.none,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: const [
                                                          Icon(Icons.chat_bubble_outline, size: 12),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'OPEN CHAT',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 20),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
