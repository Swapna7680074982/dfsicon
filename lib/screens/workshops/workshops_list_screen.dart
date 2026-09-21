import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workshops_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/water_droplets_background.dart';
import 'workshop_details_screen.dart';

class WorkshopsListScreen extends StatefulWidget {
  const WorkshopsListScreen({super.key});

  @override
  State<WorkshopsListScreen> createState() => _WorkshopsListScreenState();
}

class _WorkshopsListScreenState extends State<WorkshopsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0: My Workshops, 1: All Workshops

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWorkshops(forceRefresh: false);
    });
  }

  Future<void> _fetchWorkshops({bool forceRefresh = false}) async {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final workshopsProvider = Provider.of<WorkshopsProvider>(context, listen: false);
    final adminProv = Provider.of<AdminProvider>(context, listen: false);
    await Future.wait([
      workshopsProvider.fetchMyWorkshops(auth.accessToken, forceRefresh: forceRefresh),
      adminProv.fetchWorkshops(auth.accessToken, forceRefresh: forceRefresh),
    ]).catchError((_) => <dynamic>[]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateString(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.tryParse(dateStr);
      if (dateTime == null) return dateStr;
      
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthStr = months[dateTime.month - 1];
      final dayStr = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;
      
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      
      return '$dayStr $monthStr $year, $formattedHour:$minute $period';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workshopsProvider = Provider.of<WorkshopsProvider>(context);
    final adminProv = Provider.of<AdminProvider>(context);

    final myWorkshops = workshopsProvider.workshops;
    final allAdminWorkshops = adminProv.workshops.map((w) => w.toWorkshopItem()).toList();
    final allWorkshops = allAdminWorkshops.isNotEmpty ? allAdminWorkshops : myWorkshops;

    final activeList = _selectedTabIndex == 0 ? myWorkshops : allWorkshops;

    final filtered = activeList.where((w) {
      final name = w.workshopName.toLowerCase();
      final code = w.workshopCode.toLowerCase();
      final type = w.workshopType.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query) || type.contains(query);
    }).toList();

    final isLoading = _selectedTabIndex == 0 ? workshopsProvider.isLoading : (adminProv.isLoadingWorkshops && allAdminWorkshops.isEmpty);

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
            'Workshops',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                children: [
                  // Tab Toggle: My Workshops vs All Workshops
                  _buildTabToggle(),
                  const SizedBox(height: 10),
                  // Search Box
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _selectedTabIndex == 0 ? 'SEARCH MY WORKSHOPS...' : 'SEARCH ALL WORKSHOPS...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textLight),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchWorkshops(forceRefresh: true),
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.assignment_late_outlined,
                                        size: 48,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _selectedTabIndex == 0
                                            ? (workshopsProvider.errorMessage ?? (_searchQuery.isEmpty
                                                ? 'No workshops registered yet'
                                                : 'No workshops found matching "$_searchQuery"'))
                                            : (adminProv.workshopsError ?? (_searchQuery.isEmpty
                                                ? 'No workshops available'
                                                : 'No workshops found matching "$_searchQuery"')),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final w = filtered[index];
                              return _buildWorkshopCard(context, w);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'My Workshops',
              icon: Icons.assignment_turned_in_rounded,
              isSelected: _selectedTabIndex == 0,
              onTap: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              title: 'All Workshops',
              icon: Icons.science_rounded,
              isSelected: _selectedTabIndex == 1,
              onTap: () => setState(() => _selectedTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A1E3D) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF0A1E3D).withAlpha(30), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopCard(BuildContext context, WorkshopItem w) {
    final formattedStart = _formatDateString(w.workshopStart);
    final formattedEnd = _formatDateString(w.workshopEnd);
    final isMyWorkshops = _selectedTabIndex == 0;

    return GestureDetector(
      onTap: isMyWorkshops
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkshopDetailsScreen(workshop: w),
                ),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.tileBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(2),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    w.workshopType.isNotEmpty ? w.workshopType : 'WORKSHOP',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (w.workshopCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'Code: ${w.workshopCode}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              w.workshopName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            if (w.description.isNotEmpty && w.description.toLowerCase() != 'null' && w.description.toLowerCase() != 'na') ...[
              const SizedBox(height: 8),
              Text(
                w.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            if (w.venueName.isNotEmpty || w.city.isNotEmpty || w.address.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.location_on_outlined, size: 15, color: AppColors.textLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [
                        if (w.venueName.isNotEmpty) w.venueName,
                        if (w.address.isNotEmpty) w.address,
                        if (w.city.isNotEmpty) w.city,
                        if (w.state.isNotEmpty) w.state,
                      ].join(', '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (formattedStart.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.access_time_rounded, size: 15, color: AppColors.textLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formattedEnd.isNotEmpty && formattedEnd != formattedStart
                          ? '$formattedStart – $formattedEnd'
                          : formattedStart,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (isMyWorkshops) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.tileBorder),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
