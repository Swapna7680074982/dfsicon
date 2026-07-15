import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/abstract_provider.dart';
import 'abstract_detail_screen.dart';
import '../../widgets/water_droplets_background.dart';
import '../../utils/time_formatter.dart';

class SpeakerAbstractTab extends StatefulWidget {
  const SpeakerAbstractTab({super.key});

  @override
  State<SpeakerAbstractTab> createState() => _SpeakerAbstractTabState();
}

class _SpeakerAbstractTabState extends State<SpeakerAbstractTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'All'; // 'All', 'Approved', or 'Confirmed'
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTopics(forceRefresh: false);
    });
  }

  Future<void> _fetchTopics({bool forceRefresh = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final abstractProvider = Provider.of<AbstractProvider>(context, listen: false);
    await abstractProvider.fetchMyTopics(auth.accessToken, forceRefresh: forceRefresh);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime? _parseDateTime(String str) {
    str = str.trim();
    if (str.isEmpty) return null;
    
    final parsed = DateTime.tryParse(str);
    if (parsed != null) return parsed;
    
    try {
      final parts = str.split(RegExp(r'[-/ ]'));
      if (parts.length >= 3) {
        if (parts[0].length <= 2 && parts[2].length >= 4) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2].substring(0, 4));
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
        if (parts[0].length == 4 && parts[2].length <= 2) {
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final day = int.tryParse(parts[2].substring(0, 2));
          if (year != null && month != null && day != null) {
            return DateTime(year, month, day);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final abstractProvider = Provider.of<AbstractProvider>(context);

    final filtered = abstractProvider.myTopics.where((abs) {
      final title = (abs['title'] ?? '').toString().toLowerCase();
      final status = (abs['status'] ?? '').toString();
      
      final matchesSearch = title.contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatusFilter.toLowerCase() == 'all' ||
          status.toLowerCase() == _selectedStatusFilter.toLowerCase();
      
      bool matchesDate = true;
      if (_selectedDate != null) {
        final dateStr = (abs['created_on'] ?? '').toString().trim();
        final parsedDate = _parseDateTime(dateStr);
        if (parsedDate != null) {
          matchesDate = parsedDate.year == _selectedDate!.year &&
              parsedDate.month == _selectedDate!.month &&
              parsedDate.day == _selectedDate!.day;
        } else {
          final yyyymmdd = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
          final ddmmyyyy = "${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}";
          final slashFormat = "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";
          matchesDate = dateStr.contains(yyyymmdd) || dateStr.contains(ddmmyyyy) || dateStr.contains(slashFormat);
        }
      }
      
      return matchesSearch && matchesStatus && matchesDate;
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
          title: const Text(
            'My Topics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'SEARCH TOPICS...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                              prefixIcon: Icon(Icons.search, color: AppColors.textLight),
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: Colors.white,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedDate != null ? AppColors.primary : Colors.grey.shade200,
                              width: _selectedDate != null ? 1.5 : 1,
                            ),
                            color: _selectedDate != null ? const Color(0xFFF5F3FF) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: _selectedDate != null ? AppColors.primary : AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(
                      'DATE: ${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    backgroundColor: const Color(0xFFF5F3FF),
                    deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
                    onDeleted: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFE0DBFC)),
                    ),
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Text(
                'MY TOPICS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: abstractProvider.isLoadingTopicsList
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        await auth.refreshSessionToken();
                        await _fetchTopics(forceRefresh: true);
                      },
                      color: AppColors.primary,
                      child: filtered.isEmpty
                          ? ListView(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                                const Center(
                                  child: Text(
                                    'No topics found in this category',
                                    style: TextStyle(color: AppColors.textLight),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final abs = filtered[index];
                                return _buildAbstractItemCard(context, abs);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAbstractItemCard(BuildContext context, Map<String, dynamic> abs) {
    final status = (abs['status'] ?? 'Approved').toString();
    Color badgeBgColor;
    Color badgeTextColor;
    IconData? badgeIcon;

    if (status == 'Confirmed') {
      badgeBgColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF10B981);
      badgeIcon = Icons.check;
    } else {
      badgeBgColor = const Color(0xFFEFF6FF);
      badgeTextColor = const Color(0xFF3B82F6);
      badgeIcon = Icons.check_circle_outline;
    }

    final String displayVersion = "ID: ${abs['topic_id']}";
    final String displayDate = abs['created_on'] ?? '';
    final String displayCategory = abs['category_of_submission'] ?? 'Oral Presentation';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AbstractDetailScreen(
              abstractId: abs['topic_id'].toString(),
              initialTitle: (abs['title'] ?? '').toString(),
              initialStatus: status,
              initialTopic: displayCategory,
              initialDate: displayDate,
            ),
          ),
        ).then((_) {
          _fetchTopics();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.tileBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEEECF9),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEECF9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          displayVersion,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              badgeIcon,
                              color: badgeTextColor,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (abs['title'] ?? '').toString().toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${displayCategory.toUpperCase()} · ${TimeFormatter.formatString(displayDate)}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_outlined,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
