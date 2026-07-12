import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/explore_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/water_droplets_background.dart';

class InvitedSpeakersScreen extends StatefulWidget {
  const InvitedSpeakersScreen({super.key});

  @override
  State<InvitedSpeakersScreen> createState() => _InvitedSpeakersScreenState();
}

class _InvitedSpeakersScreenState extends State<InvitedSpeakersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isUpdatingPrivacy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ExploreProvider>(context, listen: false).fetchInvitedSpeakers(auth.accessToken);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'SP';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  static Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final exploreProvider = Provider.of<ExploreProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isSearching = _searchQuery.isNotEmpty;
    final currentUserId = authProvider.profileData['user_id']?.toString() ?? '';

    // Filter speakers
    final filteredSpeakers = exploreProvider.invitedSpeakers.where((speaker) {
      final name = (speaker['full_name'] ?? '').toString().toLowerCase();
      final designation = (speaker['designation'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || designation.contains(query);
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Invited Speakers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.tileBorder,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textLight, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'SEARCH SPEAKERS BY NAME...',
                              hintStyle: TextStyle(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        if (isSearching)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Icon(Icons.clear, color: AppColors.textLight, size: 20),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: exploreProvider.isLoadingSpeakers
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : exploreProvider.speakersError != null
                            ? Center(
                                child: Text(
                                  exploreProvider.speakersError!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : filteredSpeakers.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          size: 48,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          isSearching
                                              ? 'No speakers match "$_searchQuery"'
                                              : 'No speakers available',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: filteredSpeakers.length,
                                    itemBuilder: (context, index) {
                                      final speaker = filteredSpeakers[index];
                                      final fullName = speaker['full_name']?.toString() ?? 'Speaker';
                                      final designation = speaker['designation']?.toString() ?? 'Specialist';
                                      final profilePic = speaker['profile_image']?.toString() ?? '';
                                      final speakerUserId = speaker['user_id']?.toString() ?? '';
                                      final isSelf = speakerUserId.isNotEmpty && speakerUserId == currentUserId;
                                      
                                      final mobile = speaker['mobile']?.toString() ?? '';
                                      final email = speaker['email']?.toString() ?? '';
                                      final bool isMobilePrivate = mobile.toLowerCase().contains('private') || mobile.isEmpty;
                                      final bool isEmailPrivate = email.toLowerCase().contains('private') || email.isEmpty;

                                      final initials = _getInitials(fullName);
                                      final bg = _getColorForIndex(index);

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(18.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: isSelf ? AppColors.primary.withAlpha(100) : AppColors.tileBorder,
                                            width: isSelf ? 2.0 : 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: bg,
                                                shape: BoxShape.circle,
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              alignment: Alignment.center,
                                              child: profilePic.isNotEmpty && profilePic != 'NA'
                                                  ? Image.network(
                                                      profilePic.startsWith('http')
                                                          ? profilePic
                                                          : 'https://services.heterohcl.com/dfs-icon/$profilePic',
                                                      fit: BoxFit.cover,
                                                      width: 60,
                                                      height: 60,
                                                      errorBuilder: (c, o, s) => Text(
                                                        initials,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      initials,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    fullName.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    designation.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textSecondary,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.phone_outlined, size: 12, color: AppColors.textLight),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        isMobilePrivate ? 'Private (Hidden)' : mobile,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: isMobilePrivate ? Colors.grey.shade400 : AppColors.textSecondary,
                                                          fontStyle: isMobilePrivate ? FontStyle.italic : FontStyle.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.mail_outline_rounded, size: 12, color: AppColors.textLight),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        isEmailPrivate ? 'Private (Hidden)' : email,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: isEmailPrivate ? Colors.grey.shade400 : AppColors.textSecondary,
                                                          fontStyle: isEmailPrivate ? FontStyle.italic : FontStyle.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (isSelf) ...[
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEFF6FF),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: const Text(
                                                        'YOU',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  if (isSelf && (isMobilePrivate || isEmailPrivate)) ...[
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.info_outline, size: 10, color: Colors.blue.shade700),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            'Your contact details are private. Use the toggles on the right to unhide.',
                                                            style: TextStyle(
                                                              fontSize: 9,
                                                              color: Colors.blue.shade700,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            if (isSelf) ...[
                                              const SizedBox(width: 8),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'MOBILE',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.textSecondary,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      SizedBox(
                                                        height: 28,
                                                        width: 44,
                                                        child: FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: Switch(
                                                            value: authProvider.showMobile,
                                                            onChanged: (val) async {
                                                              setState(() {
                                                                _isUpdatingPrivacy = true;
                                                              });
                                                              await authProvider.updatePrivacySettings(
                                                                showMobile: val ? '1' : '0',
                                                                showEmail: authProvider.showEmail ? '1' : '0',
                                                                showOrganisation: authProvider.showOrganisation ? '1' : '0',
                                                                showDesignation: authProvider.showDesignation ? '1' : '0',
                                                              );
                                                              setState(() {
                                                                _isUpdatingPrivacy = false;
                                                              });
                                                            },
                                                            activeColor: AppColors.primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'EMAIL',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.textSecondary,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      SizedBox(
                                                        height: 28,
                                                        width: 44,
                                                        child: FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: Switch(
                                                            value: authProvider.showEmail,
                                                            onChanged: (val) async {
                                                              setState(() {
                                                                _isUpdatingPrivacy = true;
                                                              });
                                                              await authProvider.updatePrivacySettings(
                                                                showMobile: authProvider.showMobile ? '1' : '0',
                                                                showEmail: val ? '1' : '0',
                                                                showOrganisation: authProvider.showOrganisation ? '1' : '0',
                                                                showDesignation: authProvider.showDesignation ? '1' : '0',
                                                              );
                                                              setState(() {
                                                                _isUpdatingPrivacy = false;
                                                              });
                                                            },
                                                            activeColor: AppColors.primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
            if (_isUpdatingPrivacy)
              Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
