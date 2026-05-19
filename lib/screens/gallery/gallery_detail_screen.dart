import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import '../../constants/colors.dart';
import '../../utils/gallery_helper.dart';

class GalleryDetailScreen extends StatefulWidget {
  final String title;
  final List<String> photos;

  const GalleryDetailScreen({
    super.key,
    required this.title,
    required this.photos,
  });

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  // Mode control
  bool _isGridView = true;
  bool _isSelectMode = false;
  
  // Carousel active index (when in carousel view)
  int _activeIndex = 0;
  
  // Set of selected photo URLs
  final Set<String> _selectedPhotos = {};

  @override
  void initState() {
    super.initState();
  }

  void _toggleSelectPhoto(String url) {
    setState(() {
      if (_selectedPhotos.contains(url)) {
        _selectedPhotos.remove(url);
        if (_selectedPhotos.isEmpty) {
          _isSelectMode = false;
        }
      } else {
        _selectedPhotos.add(url);
      }
    });
  }

  void _enterSelectMode(String url) {
    setState(() {
      _isSelectMode = true;
      _selectedPhotos.clear();
      _selectedPhotos.add(url);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _isSelectMode = false;
      _selectedPhotos.clear();
    });
  }

  void _selectAllPhotos() {
    setState(() {
      _selectedPhotos.clear();
      _selectedPhotos.addAll(widget.photos);
    });
  }

  void _deselectAllPhotos() {
    setState(() {
      _selectedPhotos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No photos available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              Expanded(
                child: _isGridView ? _buildGridView() : _buildCarouselView(),
              ),
              // Reserve spacing at the bottom for multi-select glassmorphic action bar
              if (_isSelectMode) const SizedBox(height: 90),
            ],
          ),
          
          // Glassmorphic bottom action bar for multi-selection
          if (_isSelectMode) _buildBottomActionBar(),
        ],
      ),
    );
  }

  // --- App Bar ---
  PreferredSizeWidget _buildAppBar() {
    if (_isSelectMode) {
      final allSelected = _selectedPhotos.length == widget.photos.length;
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: _exitSelectMode,
        ),
        title: Text(
          '${_selectedPhotos.length} Selected',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: allSelected ? _deselectAllPhotos : _selectAllPhotos,
            child: Text(
              allSelected ? 'Deselect All' : 'Select All',
              style: const TextStyle(
                color: AppColors.primary,
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
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        // View Toggle (Grid / Carousel)
        IconButton(
          icon: Icon(
            _isGridView ? Icons.view_carousel_outlined : Icons.grid_view_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
          tooltip: _isGridView ? 'Switch to Carousel' : 'Switch to Grid',
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
              // Reset index if switching to carousel
              if (!_isGridView) {
                _activeIndex = 0;
              }
            });
          },
        ),
        // Multi-select toggle button
        IconButton(
          icon: const Icon(
            Icons.library_add_check_outlined,
            color: AppColors.textPrimary,
            size: 22,
          ),
          tooltip: 'Select Multiple',
          onPressed: () {
            setState(() {
              _isSelectMode = true;
              _selectedPhotos.clear();
            });
          },
        ),
        // Fast download-all button
        IconButton(
          icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.primary, size: 22),
          tooltip: 'Download All',
          onPressed: () {
            _selectAllPhotos();
            _isSelectMode = true;
            _startDownloadFlow();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // --- Grid View Mode ---
  Widget _buildGridView() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        final photoUrl = widget.photos[index];
        final isSelected = _selectedPhotos.contains(photoUrl);

        return GestureDetector(
          onTap: () {
            if (_isSelectMode) {
              _toggleSelectPhoto(photoUrl);
            } else {
              _openFullScreenViewer(index);
            }
          },
          onLongPress: () {
            if (!_isSelectMode) {
              _enterSelectMode(photoUrl);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 3)
                  : Border.all(color: Colors.transparent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isSelected ? 20 : 5),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Net Image
                  Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                  
                  // Selection Overlay
                  if (_isSelectMode) ...[
                    // Transparent dark shade for unselected items in select mode to highlight selection
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: isSelected 
                          ? Colors.black.withAlpha(30)
                          : Colors.black.withAlpha(80),
                    ),
                    // Checkmark Indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.white.withAlpha(160),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Carousel / Classic Single Photo View Mode ---
  Widget _buildCarouselView() {
    final activePhoto = widget.photos[_activeIndex];

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _openFullScreenViewer(_activeIndex),
              child: Hero(
                tag: 'carousel_photo_$_activeIndex',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      activePhoto,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Single Photo Download Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedPhotos.clear();
                _selectedPhotos.add(activePhoto);
              });
              _startDownloadFlow();
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text(
              'Download Active Photo',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Thumbnail Carousel Scroller
        Container(
          height: 100,
          padding: const EdgeInsets.only(bottom: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              final isSelected = index == _activeIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2.5)
                        : Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      widget.photos[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Glassmorphic Bottom Action Bar for Multi-Selection ---
  Widget _buildBottomActionBar() {
    final count = _selectedPhotos.length;
    final hasSelection = count > 0;

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
                        '$count Photo${count == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasSelection ? 'Ready to download' : 'Select photos',
                        style: const TextStyle(
                          fontSize: 12,
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
                  onPressed: _exitSelectMode,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                
                // Download Button
                ElevatedButton.icon(
                  onPressed: hasSelection ? _startDownloadFlow : null,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text(
                    'Download',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

  // --- Full Screen Photo Viewer (Swipe & Pinch Zoom) ---
  void _openFullScreenViewer(int initialIndex) {
    int activeViewerIndex = initialIndex;
    final PageController pageController = PageController(initialPage: initialIndex);

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return StatefulBuilder(
            builder: (context, setStateBuilder) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Immersive PageView with Interactive Pinch-to-Zoom
                    PageView.builder(
                      controller: pageController,
                      itemCount: widget.photos.length,
                      onPageChanged: (index) {
                        setStateBuilder(() {
                          activeViewerIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          clipBehavior: Clip.none,
                          maxScale: 4.0,
                          minScale: 1.0,
                          child: Center(
                            child: Image.network(
                              widget.photos[index],
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),

                    // Top Bar (Back & Download Actions)
                    Positioned(
                      top: 40,
                      left: 10,
                      right: 10,
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Immersive Transparent Back Icon
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            
                            // Immersive Header Title
                            Text(
                              '${activeViewerIndex + 1} of ${widget.photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            
                            // Download Icon
                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.white, size: 24),
                              onPressed: () {
                                final activeUrl = widget.photos[activeViewerIndex];
                                // We download this single photo
                                Navigator.pop(context); // Close full screen first
                                setState(() {
                                  _selectedPhotos.clear();
                                  _selectedPhotos.add(activeUrl);
                                });
                                _startDownloadFlow();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Thumbnail Slider for Immersive Navigation
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 64,
                              alignment: Alignment.center,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: widget.photos.length,
                                itemBuilder: (context, index) {
                                  final isCurrent = index == activeViewerIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      pageController.animateToPage(
                                        index,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      width: 44,
                                      margin: const EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: isCurrent
                                            ? Border.all(color: Colors.white, width: 2)
                                            : Border.all(color: Colors.white.withAlpha(80), width: 1),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          widget.photos[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // --- Premium Stateful Progress & Completion Flow ---
  Future<void> _startDownloadFlow() async {
    final targetUrls = _selectedPhotos.toList();
    if (targetUrls.isEmpty) return;

    // 1. Check and request Gallery access permission
    final hasAccess = await GalleryHelper.hasGalleryAccess();
    if (!hasAccess) {
      final requestSuccess = await GalleryHelper.requestGalleryAccess();
      if (!requestSuccess) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    // 2. Open stateful progress modal dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        double percent = 0.0;
        int currentCount = 0;
        int totalCount = targetUrls.length;
        bool isDone = false;
        int successCount = 0;
        int failCount = 0;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Trigger actual sequential downloads asynchronously on the first frame of this dialog
            if (currentCount == 0 && !isDone) {
              Future.microtask(() async {
                final albumName = widget.title.replaceAll(RegExp(r'[^\w\s\-]'), '');
                
                for (int i = 0; i < totalCount; i++) {
                  setDialogState(() {
                    currentCount = i + 1;
                    percent = i / totalCount;
                  });

                  final success = await GalleryHelper.downloadAndSaveToGallery(
                    targetUrls[i], 
                    album: albumName.isNotEmpty ? albumName : 'DFSIcon',
                  );

                  if (success) {
                    successCount++;
                  } else {
                    failCount++;
                  }
                  
                  // Small delay to make UX smooth and visible
                  await Future.delayed(const Duration(milliseconds: 300));
                }

                setDialogState(() {
                  percent = 1.0;
                  isDone = true;
                });
              });
            }

            return PopScope(
              canPop: isDone, // Block close until completed
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isDone) ...[
                          // Downloading Status
                          const SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Downloading to Gallery...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Processing photo $currentCount of $totalCount',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Premium linear progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(percent * 100).toInt()}% Completed',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ] else ...[
                          // Completion Success Screen
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Downloads Completed!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            failCount == 0
                                ? 'Successfully saved all $successCount photo${successCount == 1 ? '' : 's'} to your device album: "${widget.title}"!'
                                : 'Saved $successCount photo${successCount == 1 ? '' : 's'} successfully. ($failCount failed)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_library_outlined, size: 18, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Visible in Google Photos & Gallery',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    Navigator.pop(context); // Close dialog
                                    _exitSelectMode();     // Exit multi-selection mode
                                    await Gal.open();      // Open native gallery application!
                                  },
                                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                                  label: const Text(
                                    'View Gallery',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    _exitSelectMode();     // Exit multi-selection mode
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Done',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Permission Denied Warning Dialog ---
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text(
              'Permission Required',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'To save images directly to your mobile photo library or Google Photos, this app needs gallery write access. Please enable photo/storage permission in your device system settings.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
