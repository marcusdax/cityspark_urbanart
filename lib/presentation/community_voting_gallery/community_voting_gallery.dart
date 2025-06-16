import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/design_card_widget.dart';
import './widgets/design_detail_bottom_sheet.dart';
import './widgets/filter_bar_widget.dart';

class CommunityVotingGallery extends StatefulWidget {
  const CommunityVotingGallery({super.key});

  @override
  State<CommunityVotingGallery> createState() => _CommunityVotingGalleryState();
}

class _CommunityVotingGalleryState extends State<CommunityVotingGallery>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshController;
  String _selectedFilter = 'Most Recent';
  bool _isRefreshing = false;
  final Set<String> _votedDesigns = <String>{};

  final List<Map<String, dynamic>> _mockDesigns = [
    {
      "id": "design_001",
      "title": "Urban Garden Mural",
      "creator": "Sarah Chen",
      "creatorAvatar":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
      "imageUrl":
          "https://images.pexels.com/photos/1070945/pexels-photo-1070945.jpeg?auto=compress&cs=tinysrgb&w=800",
      "description":
          "A vibrant mural celebrating urban biodiversity with native plants and wildlife integrated into geometric patterns.",
      "voteCount": 127,
      "timeRemaining": Duration(days: 3, hours: 14),
      "category": "Mural",
      "location": "Downtown Park Wall",
      "submittedAt": DateTime.now().subtract(Duration(days: 2)),
      "implementationStatus": "pending",
      "views": [
        "https://images.pexels.com/photos/1070945/pexels-photo-1070945.jpeg?auto=compress&cs=tinysrgb&w=800",
        "https://images.pexels.com/photos/1109541/pexels-photo-1109541.jpeg?auto=compress&cs=tinysrgb&w=800",
      ],
      "comments": 23,
      "hasVoted": false,
    },
    {
      "id": "design_002",
      "title": "Recycled Sculpture Park",
      "creator": "Marcus Rodriguez",
      "creatorAvatar":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "imageUrl":
          "https://images.pexels.com/photos/1109541/pexels-photo-1109541.jpeg?auto=compress&cs=tinysrgb&w=800",
      "description":
          "Interactive sculptures made from collected plastic waste, featuring AR elements that tell environmental stories.",
      "voteCount": 89,
      "timeRemaining": Duration(days: 1, hours: 8),
      "category": "Sculpture",
      "location": "Central Plaza",
      "submittedAt": DateTime.now().subtract(Duration(days: 4)),
      "implementationStatus": "pending",
      "views": [
        "https://images.pexels.com/photos/1109541/pexels-photo-1109541.jpeg?auto=compress&cs=tinysrgb&w=800",
        "https://images.pexels.com/photos/1070945/pexels-photo-1070945.jpeg?auto=compress&cs=tinysrgb&w=800",
      ],
      "comments": 15,
      "hasVoted": false,
    },
    {
      "id": "design_003",
      "title": "Community Message Board",
      "creator": "Elena Vasquez",
      "creatorAvatar":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "imageUrl":
          "https://images.pixabay.com/photo/2017/08/06/12/06/people-2591874_1280.jpg",
      "description":
          "Digital-physical hybrid board where community members can leave messages, announcements, and artwork.",
      "voteCount": 156,
      "timeRemaining": Duration(hours: 18),
      "category": "Interactive",
      "location": "Community Center",
      "submittedAt": DateTime.now().subtract(Duration(days: 6)),
      "implementationStatus": "approved",
      "views": [
        "https://images.pixabay.com/photo/2017/08/06/12/06/people-2591874_1280.jpg",
        "https://images.pexels.com/photos/1070945/pexels-photo-1070945.jpeg?auto=compress&cs=tinysrgb&w=800",
      ],
      "comments": 31,
      "hasVoted": false,
    },
    {
      "id": "design_004",
      "title": "Solar Charging Station",
      "creator": "David Kim",
      "creatorAvatar":
          "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400",
      "imageUrl":
          "https://images.unsplash.com/photo-1509391366360-2e959784a276?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
      "description":
          "Eco-friendly charging station with integrated seating and plant walls, powered by solar panels.",
      "voteCount": 203,
      "timeRemaining": Duration(days: 5, hours: 22),
      "category": "Utility",
      "location": "Transit Hub",
      "submittedAt": DateTime.now().subtract(Duration(days: 1)),
      "implementationStatus": "pending",
      "views": [
        "https://images.unsplash.com/photo-1509391366360-2e959784a276?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "https://images.pexels.com/photos/1109541/pexels-photo-1109541.jpeg?auto=compress&cs=tinysrgb&w=800",
      ],
      "comments": 42,
      "hasVoted": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    _refreshController.forward();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    _refreshController.reset();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallery refreshed with latest submissions'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleVote(String designId, bool isUpvote) {
    if (_votedDesigns.contains(designId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already voted on this design'),
          backgroundColor: AppTheme.getWarningColor(true),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _votedDesigns.add(designId);
      final designIndex =
          _mockDesigns.indexWhere((design) => design['id'] == designId);
      if (designIndex != -1) {
        _mockDesigns[designIndex]['voteCount'] += isUpvote ? 1 : -1;
        _mockDesigns[designIndex]['hasVoted'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isUpvote
            ? 'Vote submitted! Thanks for participating.'
            : 'Feedback recorded.'),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _showDesignDetail(Map<String, dynamic> design) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DesignDetailBottomSheet(
        design: design,
        onVote: _handleVote,
        hasVoted: _votedDesigns.contains(design['id']),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredDesigns() {
    List<Map<String, dynamic>> filtered = List.from(_mockDesigns);

    switch (_selectedFilter) {
      case 'Most Recent':
        filtered.sort((a, b) => (b['submittedAt'] as DateTime)
            .compareTo(a['submittedAt'] as DateTime));
        break;
      case 'Most Voted':
        filtered.sort(
            (a, b) => (b['voteCount'] as int).compareTo(a['voteCount'] as int));
        break;
      case 'Ending Soon':
        filtered.sort((a, b) => (a['timeRemaining'] as Duration)
            .compareTo(b['timeRemaining'] as Duration));
        break;
    }

    return filtered;
  }

  Color _getUrgencyColor(Duration timeRemaining) {
    if (timeRemaining.inHours <= 24) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (timeRemaining.inDays <= 2) {
      return AppTheme.getWarningColor(true);
    }
    return AppTheme.getSuccessColor(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Community Gallery',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/interactive-city-map');
            },
            icon: CustomIconWidget(
              iconName: 'map',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'camera_alt',
                    color: _tabController.index == 0
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.getNeutralColor(true),
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text('Camera'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'photo_library',
                    color: _tabController.index == 1
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.getNeutralColor(true),
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text('Gallery'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'view_in_ar',
                    color: _tabController.index == 2
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.getNeutralColor(true),
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text('3D Builder'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'map',
                    color: _tabController.index == 3
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.getNeutralColor(true),
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text('Map'),
                ],
              ),
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/ar-camera-cleanup');
                break;
              case 1:
                // Current screen - do nothing
                break;
              case 2:
                Navigator.pushNamed(context, '/3d-design-builder');
                break;
              case 3:
                Navigator.pushNamed(context, '/interactive-city-map');
                break;
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Camera tab placeholder
          Center(child: Text('Camera View')),

          // Gallery tab - main content
          Column(
            children: [
              FilterBarWidget(
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  child: _getFilteredDesigns().isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _getFilteredDesigns().length,
                          itemBuilder: (context, index) {
                            final design = _getFilteredDesigns()[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: DesignCardWidget(
                                design: design,
                                onVote: _handleVote,
                                onTap: () => _showDesignDetail(design),
                                hasVoted: _votedDesigns.contains(design['id']),
                                urgencyColor:
                                    _getUrgencyColor(design['timeRemaining']),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),

          // 3D Builder tab placeholder
          Center(child: Text('3D Builder View')),

          // Map tab placeholder
          Center(child: Text('Map View')),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/3d-design-builder');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
              label: Text(
                'Create Design',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'photo_library',
              color: AppTheme.getNeutralColor(true),
              size: 64,
            ),
            SizedBox(height: 24),
            Text(
              'No Designs Yet',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.getNeutralColor(true),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Be the first to submit a design and inspire your community!',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getNeutralColor(true),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/3d-design-builder');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Create Your Design'),
            ),
          ],
        ),
      ),
    );
  }
}
