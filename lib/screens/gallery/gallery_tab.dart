import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gallery_provider.dart';
import 'gallery_detail_screen.dart';
import '../../widgets/water_droplets_background.dart';

class GalleryTab extends StatefulWidget {
  final bool isStandalone;
  const GalleryTab({super.key, this.isStandalone = false});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  int _selectedSegment = 0;
  
  // People selection states
  bool _isPeopleSelectMode = false;
  final Set<GalleryFace> _selectedPeople = {};

  // Search state for People tab
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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

  void _loadData({bool force = false}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final galProvider = Provider.of<GalleryProvider>(context, listen: false);
    if (authProvider.accessToken.isNotEmpty) {
      galProvider.fetchGalleryDays(accessToken: authProvider.accessToken, forceRefresh: force);
      galProvider.fetchGalleryFaces(accessToken: authProvider.accessToken, forceRefresh: force);
    }
  }

  void _onSearchFaces(String query) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final galProvider = Provider.of<GalleryProvider>(context, listen: false);
    if (authProvider.accessToken.isNotEmpty) {
      galProvider.fetchGalleryFaces(
        accessToken: authProvider.accessToken,
        search: query,
        forceRefresh: true,
      );
    }
  }

  void _toggleSelectPerson(GalleryFace f) {
    setState(() {
      if (_selectedPeople.contains(f)) {
        _selectedPeople.remove(f);
        if (_selectedPeople.isEmpty) {
          _isPeopleSelectMode = false;
        }
      } else {
        _selectedPeople.add(f);
      }
    });
  }

  void _enterPeopleSelectMode(GalleryFace f) {
    setState(() {
      _isPeopleSelectMode = true;
      _selectedPeople.clear();
      _selectedPeople.add(f);
    });
  }

  void _exitPeopleSelectMode() {
    setState(() {
      _isPeopleSelectMode = false;
      _selectedPeople.clear();
    });
  }

  void _selectAllPeople(List<GalleryFace> allPeople) {
    setState(() {
      _selectedPeople.clear();
      _selectedPeople.addAll(allPeople);
    });
  }

  void _deselectAllPeople() {
    setState(() {
      _selectedPeople.clear();
    });
  }

  String _getFilteredTitle(List<GalleryFace> selected) {
    if (selected.isEmpty) return 'Filtered Photos';
    if (selected.length == 1) return selected.first.fullName;
    
    final firstNames = selected.map((p) {
      final cleanName = p.fullName.replaceAll(RegExp(r'^(Dr\.\s*|Prof\.\s*)'), '');
      return cleanName.split(' ').first;
    }).toList();

    if (selected.length == 2) {
      return '${firstNames[0]} & ${firstNames[1]}';
    }
    return '${firstNames[0]}, ${firstNames[1]} & ${selected.length - 2} more';
  }

  @override
  Widget build(BuildContext context) {
    final galProvider = Provider.of<GalleryProvider>(context);
    final isSessions = _selectedSegment == 0;

    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(galProvider),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Segment selector & search bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSegment = 0;
                                _exitPeopleSelectMode();
                                _isSearching = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSessions ? AppColors.primary : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Sessions',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSessions ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSegment = 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: !isSessions ? AppColors.primary : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'People',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: !isSessions ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isSessions && _isSearching) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search people by name...',
                            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchFaces('');
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: _onSearchFaces,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Segment lists
                Expanded(
                  child: isSessions
                      ? _buildSessionsList(galProvider)
                      : _buildPeopleGrid(galProvider),
                ),
                
                // Reserve bottom space for people selection bar
                if (_isPeopleSelectMode && !isSessions) const SizedBox(height: 90),
              ],
            ),
            
            // Floating Bottom Filter Action Bar
            if (_isPeopleSelectMode && !isSessions) _buildPeopleBottomBar(galProvider),
          ],
        ),
      ),
    );
  }

  // --- AppBar Handler ---
  PreferredSizeWidget _buildAppBar(GalleryProvider galProvider) {
    if (_isPeopleSelectMode && _selectedSegment == 1) {
      final allSelected = _selectedPeople.length == galProvider.faces.length;
      return AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 2.0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _exitPeopleSelectMode,
        ),
        title: Text(
          '${_selectedPeople.length} Selected',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (allSelected) {
                _deselectAllPeople();
              } else {
                _selectAllPeople(galProvider.faces);
              }
            },
            child: Text(
              allSelected ? 'Deselect All' : 'Select All',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1E3D), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 2.0,
      automaticallyImplyLeading: widget.isStandalone,
      leading: widget.isStandalone
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: const Text(
        'Gallery',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: false,
      actions: _selectedSegment == 1
          ? [
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.search_off : Icons.search,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: 'Search People',
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _onSearchFaces('');
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.library_add_check_outlined, color: Colors.white, size: 22),
                tooltip: 'Select Multiple People',
                onPressed: () {
                  setState(() {
                    _isPeopleSelectMode = true;
                    _selectedPeople.clear();
                  });
                },
              ),
              const SizedBox(width: 8),
            ]
          : null,
    );
  }

  // --- Sessions / Days List Builder ---
  Widget _buildSessionsList(GalleryProvider galProvider) {
    if (galProvider.isLoadingDays && galProvider.days.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (galProvider.days.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _loadData(force: true),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 400,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  galProvider.daysError ?? 'No Gallery Days Available',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _loadData(force: true),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(force: true),
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(20),
        itemCount: galProvider.days.length,
        itemBuilder: (context, index) {
          final day = galProvider.days[index];
          return GestureDetector(
            onTap: () => _openDayGallery(day),
            child: Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    day.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(170),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.dayTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${day.galleryDate}   •   ${day.totalImages} Photos',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withAlpha(220),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (day.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            day.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- People Grid Builder ---
  Widget _buildPeopleGrid(GalleryProvider galProvider) {
    if (galProvider.isLoadingFaces && galProvider.faces.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (galProvider.faces.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _loadData(force: true),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 400,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  galProvider.facesError ?? 'No People Found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _loadData(force: true),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(force: true),
      color: AppColors.primary,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 0.70,
        ),
        itemCount: galProvider.faces.length,
        itemBuilder: (context, index) {
          final f = galProvider.faces[index];
          final isSelected = _selectedPeople.contains(f);

          return GestureDetector(
            onTap: () {
              if (_isPeopleSelectMode) {
                _toggleSelectPerson(f);
              } else {
                _openFaceGallery(f);
              }
            },
            onLongPress: () {
              if (!_isPeopleSelectMode) {
                _enterPeopleSelectMode(f);
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Avatar Circle Frame
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade200,
                            width: isSelected ? 3.5 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isSelected ? 15 : 4),
                              blurRadius: isSelected ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                f.photoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.person, color: Colors.grey),
                                ),
                              ),
                              if (_isPeopleSelectMode)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  color: isSelected
                                      ? AppColors.primary.withAlpha(45)
                                      : Colors.black.withAlpha(60),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Badge for "ME"
                      if (f.isMe)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      // Selection Checkmark
                      if (_isPeopleSelectMode)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary : Colors.white.withAlpha(180),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 12)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  f.fullName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  f.designation.isNotEmpty
                      ? f.designation
                      : (f.roleCode == 'SK' ? 'Speaker' : 'Delegate'),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Glassmorphic Bottom Action Bar for Multi-People Selection ---
  Widget _buildPeopleBottomBar(GalleryProvider galProvider) {
    final count = _selectedPeople.length;

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withAlpha(160), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count Person${count == 1 ? '' : 's'} Selected',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count >= 1 ? 'Find photos with selected' : 'Select at least 1 person',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _exitPeopleSelectMode,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: count >= 1 ? _filterPhotosBySelectedPeople : null,
                  icon: const Icon(Icons.filter_alt, size: 16),
                  label: const Text(
                    'Find Photos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- API Triggers ---
  void _openDayGallery(GalleryDay day) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final galProvider = Provider.of<GalleryProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    final images = await galProvider.fetchGalleryImages(
      accessToken: authProvider.accessToken,
      galleryDayId: day.galleryDayId,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loader

    final photoUrls = images.map((e) => e.imageUrl).where((url) => url.isNotEmpty).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryDetailScreen(
          title: day.dayTitle,
          photos: photoUrls,
        ),
      ),
    );
  }

  void _openFaceGallery(GalleryFace face) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final galProvider = Provider.of<GalleryProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    final images = await galProvider.fetchGalleryMatch(
      accessToken: authProvider.accessToken,
      userIds: [face.userId],
      requireAll: true,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loader

    final photoUrls = images.map((e) => e.imageUrl).where((url) => url.isNotEmpty).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryDetailScreen(
          title: face.fullName,
          photos: photoUrls,
        ),
      ),
    );
  }

  void _filterPhotosBySelectedPeople() async {
    final list = _selectedPeople.toList();
    if (list.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final galProvider = Provider.of<GalleryProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    final userIds = list.map((f) => f.userId).toList();
    final images = await galProvider.fetchGalleryMatch(
      accessToken: authProvider.accessToken,
      userIds: userIds,
      requireAll: true,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loader

    final photoUrls = images.map((e) => e.imageUrl).where((url) => url.isNotEmpty).toList();
    final title = _getFilteredTitle(list);

    if (photoUrls.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryDetailScreen(
            title: title,
            photos: photoUrls,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            title: const Row(
              children: [
                Icon(Icons.face_retouching_natural_outlined, color: AppColors.primary, size: 28),
                SizedBox(width: 10),
                Text(
                  'No Common Photos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Text(
              'We couldn\'t find photos where all ${list.length} selected individuals are present together.\n\nWould you like to view photos containing any of these individuals?',
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ADJUST SELECTION',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );

                  final anyMatchImages = await galProvider.fetchGalleryMatch(
                    accessToken: authProvider.accessToken,
                    userIds: userIds,
                    requireAll: false,
                  );

                  if (!mounted) return;
                  Navigator.pop(context); // Close loader

                  final anyUrls = anyMatchImages.map((e) => e.imageUrl).where((url) => url.isNotEmpty).toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GalleryDetailScreen(
                        title: 'ALL PHOTOS: ${list.length} PEOPLE',
                        photos: anyUrls,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  elevation: 0,
                ),
                child: const Text(
                  'VIEW ANY MATCH',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
