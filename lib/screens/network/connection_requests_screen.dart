import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/network_provider.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  State<ConnectionRequestsScreen> createState() => _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final netProvider = Provider.of<NetworkProvider>(context, listen: false);
    if (auth.accessToken.isNotEmpty) {
      await netProvider.fetchPendingRequests(accessToken: auth.accessToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final netProvider = Provider.of<NetworkProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Connection Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (netProvider.requests.isNotEmpty)
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
      ),
      body: netProvider.isLoadingRequests && netProvider.requests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : netProvider.requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.person_add_disabled_outlined,
                        size: 48,
                        color: AppColors.textLight,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No connection requests pending',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(20),
                    itemCount: netProvider.requests.length,
                    itemBuilder: (context, index) {
                      final req = netProvider.requests[index];
                      final initials = NetworkProvider.getInitials(req.fullName);
                      final bg = NetworkProvider.getAvatarBg(req.connectionId);
                      final subtitleText = [
                        req.designation,
                        req.organisationName,
                        if (req.topicTitle != null) req.topicTitle
                      ].where((s) => s != null && s.isNotEmpty).join(' • ');

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.tileBorder, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipOval(
                                  child: req.profileImage != null && req.profileImage!.isNotEmpty
                                      ? Image.network(
                                          req.profileImage!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 48,
                                            height: 48,
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
                                          width: 48,
                                          height: 48,
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
                                      Text(
                                        req.fullName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (subtitleText.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          subtitleText,
                                          maxLines: 2,
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
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final success = await netProvider.respondConnectionRequest(
                                        connectionId: req.connectionId,
                                        action: 'ACCEPT',
                                        accessToken: authProvider.accessToken,
                                      );
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(success ? 'Connected with ${req.fullName}!' : 'Action failed'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                                    label: const Text(
                                      'Accept',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final success = await netProvider.respondConnectionRequest(
                                        connectionId: req.connectionId,
                                        action: 'REJECT',
                                        accessToken: authProvider.accessToken,
                                      );
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(success ? 'Request declined' : 'Action failed'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFDC2626)),
                                    label: const Text(
                                      'Decline',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFFEE2E2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(color: Color(0xFFFECDD3), width: 1),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
