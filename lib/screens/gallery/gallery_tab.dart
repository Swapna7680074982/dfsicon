import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
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
  final Set<PersonGallery> _selectedPeople = {};

  void _toggleSelectPerson(PersonGallery p) {
    setState(() {
      if (_selectedPeople.contains(p)) {
        _selectedPeople.remove(p);
        if (_selectedPeople.isEmpty) {
          _isPeopleSelectMode = false;
        }
      } else {
        _selectedPeople.add(p);
      }
    });
  }

  void _enterPeopleSelectMode(PersonGallery p) {
    setState(() {
      _isPeopleSelectMode = true;
      _selectedPeople.clear();
      _selectedPeople.add(p);
    });
  }

  void _exitPeopleSelectMode() {
    setState(() {
      _isPeopleSelectMode = false;
      _selectedPeople.clear();
    });
  }

  void _selectAllPeople(List<PersonGallery> allPeople) {
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

  List<String> _getCommonPhotos(List<PersonGallery> selected) {
    if (selected.isEmpty) return [];
    
    // Start with the first person's photos
    Set<String> common = selected.first.photos.toSet();
    
    // Intersect with each subsequent person's photos
    for (int i = 1; i < selected.length; i++) {
      common = common.intersection(selected[i].photos.toSet());
    }
    
    return common.toList();
  }

  List<String> _getUnionPhotos(List<PersonGallery> selected) {
    if (selected.isEmpty) return [];
    
    Set<String> union = {};
    for (var p in selected) {
      union.addAll(p.photos);
    }
    return union.toList();
  }

  String _getFilteredTitle(List<PersonGallery> selected) {
    if (selected.isEmpty) return 'Filtered Photos';
    if (selected.length == 1) return selected.first.name;
    
    // Clean names to first names for a compact, neat display
    final firstNames = selected.map((p) {
      final cleanName = p.name.replaceAll(RegExp(r'^(Dr\.\s*|Prof\.\s*)'), '');
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
              // Tab segment selector
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSegment = 0;
                          _exitPeopleSelectMode(); // Exit people selection when switching segments
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
    ),);
  }

  // --- AppBar Handler ---
  PreferredSizeWidget _buildAppBar(GalleryProvider galProvider) {
    if (_isPeopleSelectMode && _selectedSegment == 1) {
      final allSelected = _selectedPeople.length == galProvider.people.length;
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
                _selectAllPeople(galProvider.people);
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
              // Button to enter Multi-Select Mode in People tab
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

  // --- Sessions List Builder ---
  Widget _buildSessionsList(GalleryProvider galProvider) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: galProvider.sessions.length,
      itemBuilder: (context, index) {
        final s = galProvider.sessions[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GalleryDetailScreen(
                  title: s.title,
                  photos: s.photos,
                ),
              ),
            );
          },
          child: Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.tileBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
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
                  s.imageUrl,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(160),
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
                        s.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${s.date}   -   ${s.photoCount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- People Grid Builder (With Multi-Selection Overlays) ---
  Widget _buildPeopleGrid(GalleryProvider galProvider) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.72,
      ),
      itemCount: galProvider.people.length,
      itemBuilder: (context, index) {
        final p = galProvider.people[index];
        final isSelected = _selectedPeople.contains(p);

        return GestureDetector(
          onTap: () {
            if (_isPeopleSelectMode) {
              _toggleSelectPerson(p);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryDetailScreen(
                    title: p.name,
                    photos: p.photos,
                  ),
                ),
              );
            }
          },
          onLongPress: () {
            if (!_isPeopleSelectMode) {
              _enterPeopleSelectMode(p);
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
                            color: Colors.black.withAlpha(isSelected ? 10 : 2),
                            blurRadius: isSelected ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Avatar Photo
                            Image.network(
                              p.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.person, color: Colors.grey),
                              ),
                            ),
                            // Selection dark overlay
                            if (_isPeopleSelectMode)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                color: isSelected 
                                    ? AppColors.primary.withAlpha(35) 
                                    : Colors.black.withAlpha(60),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Small Checkmark Bubble - Positioned OUTSIDE ClipOval
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
              const SizedBox(height: 10),
              Text(
                p.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.photoCount,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
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
                        count >= 2 ? 'Find photos with both' : 'Select at least 2 people',
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
                
                // Cancel
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
                
                // Filter Action Button
                ElevatedButton.icon(
                  onPressed: count >= 2 ? _filterPhotosBySelectedPeople : null,
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

  // --- Filtering Execution ---
  void _filterPhotosBySelectedPeople() {
    final list = _selectedPeople.toList();
    if (list.length < 2) return;

    // Calculate URL intersection
    final commonPhotos = _getCommonPhotos(list);
    final title = _getFilteredTitle(list);

    if (commonPhotos.isNotEmpty) {
      // 1. Navigate to GalleryDetailScreen with common photos!
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryDetailScreen(
            title: title,
            photos: commonPhotos,
          ),
        ),
      );
    } else {
      // 2. No common photos found. Show a beautiful glassmorphic choice dialog!
      showDialog(
        context: context,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.face_retouching_natural_outlined, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'No Common Photos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Text(
              'We couldn\'t find any single photo where all ${list.length} selected individuals are present together.\n\nWould you like to adjust your selection or view all photos of these individuals jointly?',
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
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  final unionPhotos = _getUnionPhotos(list);
                  final unionTitle = 'ALL PHOTOS: ${list.length} PEOPLE';
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GalleryDetailScreen(
                        title: unionTitle,
                        photos: unionPhotos,
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
                  'VIEW ALL JOINTLY',
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
