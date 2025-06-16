import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/filter_controls_widget.dart';
import './widgets/hotspot_info_card_widget.dart';
import './widgets/map_hotspot_marker_widget.dart';
import './widgets/nearby_hotspots_sheet_widget.dart';

class InteractiveCityMap extends StatefulWidget {
  const InteractiveCityMap({super.key});

  @override
  State<InteractiveCityMap> createState() => _InteractiveCityMapState();
}

class _InteractiveCityMapState extends State<InteractiveCityMap>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late AnimationController _filterController;

  bool _showFilters = false;
  bool _showBottomSheet = false;
  String _selectedHotspotId = '';
  final double _mapZoom = 15.0;

  // Mock data for hotspots
  final List<Map<String, dynamic>> _hotspots = [
    {
      "id": "hotspot_1",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "status": "high", // red marker "pointPotential": 150,
      "recentActivity": "2 cleanups today",
      "distance": "0.2 km",
      "trashTypes": ["bottles", "cans", "paper"],
      "lastCleaned": "2 days ago",
      "communityRating": 4.2,
    },
    {
      "id": "hotspot_2",
      "latitude": 40.7589,
      "longitude": -73.9851,
      "status": "moderate", // yellow marker "pointPotential": 85,
      "recentActivity": "1 cleanup today",
      "distance": "0.8 km",
      "trashTypes": ["food_waste", "plastic"],
      "lastCleaned": "1 day ago",
      "communityRating": 3.8,
    },
    {
      "id": "hotspot_3",
      "latitude": 40.7505,
      "longitude": -73.9934,
      "status": "clean", // green marker "pointPotential": 25,
      "recentActivity": "Cleaned 3 hours ago",
      "distance": "1.2 km",
      "trashTypes": [],
      "lastCleaned": "3 hours ago",
      "communityRating": 4.8,
    },
    {
      "id": "hotspot_4",
      "latitude": 40.7282,
      "longitude": -73.7949,
      "status": "high",
      "pointPotential": 200,
      "recentActivity": "No recent activity",
      "distance": "2.1 km",
      "trashTypes": ["bottles", "cans", "cigarettes", "plastic"],
      "lastCleaned": "1 week ago",
      "communityRating": 2.5,
    },
  ];

  // Mock user location
  final Map<String, double> _userLocation = {
    "latitude": 40.7128,
    "longitude": -74.0060,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _onHotspotTapped(String hotspotId) {
    setState(() {
      _selectedHotspotId = hotspotId;
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    _showFilters ? _filterController.forward() : _filterController.reverse();
  }

  void _toggleBottomSheet() {
    setState(() {
      _showBottomSheet = !_showBottomSheet;
    });
  }

  void _navigateToARCamera() {
    Navigator.pushNamed(context, '/ar-camera-cleanup');
  }

  Color _getMarkerColor(String status) {
    switch (status) {
      case 'high':
        return AppTheme.lightTheme.colorScheme.error;
      case 'moderate':
        return AppTheme.getWarningColor(true);
      case 'clean':
        return AppTheme.getSuccessColor(true);
      default:
        return AppTheme.getNeutralColor(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'CitySpark Map',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFilters,
            icon: CustomIconWidget(
              iconName: 'tune',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Main map view
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  AppTheme.lightTheme.colorScheme.surface,
                ],
              ),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedHotspotId = '';
                });
              },
              onLongPress: () {
                // Show custom cleanup suggestion dialog
                _showCustomCleanupDialog();
              },
              child: Stack(
                children: [
                  // Map background simulation
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppTheme.lightTheme.colorScheme.surface,
                    child: CustomPaint(
                      painter: MapGridPainter(),
                    ),
                  ),

                  // User location indicator
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.5 - 12,
                    top: MediaQuery.of(context).size.height * 0.5 - 12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hotspot markers
                  ..._hotspots.map((hotspot) {
                    final isSelected = _selectedHotspotId == hotspot["id"];
                    return Positioned(
                      left: MediaQuery.of(context).size.width * 0.3 +
                          (_hotspots.indexOf(hotspot) * 60.0),
                      top: MediaQuery.of(context).size.height * 0.3 +
                          (_hotspots.indexOf(hotspot) * 80.0),
                      child: MapHotspotMarkerWidget(
                        hotspot: hotspot,
                        isSelected: isSelected,
                        onTap: () => _onHotspotTapped(hotspot["id"] as String),
                        markerColor:
                            _getMarkerColor(hotspot["status"] as String),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Filter controls overlay
          if (_showFilters)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _filterController,
                  curve: Curves.easeInOut,
                )),
                child: FilterControlsWidget(
                  onFilterChanged: (filters) {
                    // Handle filter changes
                  },
                ),
              ),
            ),

          // Selected hotspot info card
          if (_selectedHotspotId.isNotEmpty)
            Positioned(
              bottom: _showBottomSheet ? 300 : 120,
              left: 16,
              right: 16,
              child: HotspotInfoCardWidget(
                hotspot: _hotspots.firstWhere(
                  (h) => h["id"] == _selectedHotspotId,
                ),
                onClose: () {
                  setState(() {
                    _selectedHotspotId = '';
                  });
                },
                onNavigate: () {
                  // Handle navigation to hotspot
                },
              ),
            ),

          // Bottom sheet for nearby hotspots
          if (_showBottomSheet)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NearbyHotspotsSheetWidget(
                hotspots: _hotspots,
                onHotspotSelected: (hotspotId) {
                  _onHotspotTapped(hotspotId);
                  _toggleBottomSheet();
                },
                onClose: _toggleBottomSheet,
              ),
            ),

          // Floating AR camera button
          Positioned(
            bottom: _showBottomSheet ? 320 : 140,
            right: 16,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: FloatingActionButton(
                    onPressed: _navigateToARCamera,
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom sheet toggle handle
          Positioned(
            bottom: 80,
            left: MediaQuery.of(context).size.width * 0.5 - 20,
            child: GestureDetector(
              onTap: _toggleBottomSheet,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getNeutralColor(true),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'map',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              text: 'Map',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.getNeutralColor(true),
                size: 24,
              ),
              text: 'Camera',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.getNeutralColor(true),
                size: 24,
              ),
              text: 'Gallery',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.getNeutralColor(true),
                size: 24,
              ),
              text: 'Profile',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                // Already on map
                break;
              case 1:
                Navigator.pushNamed(context, '/ar-camera-cleanup');
                break;
              case 2:
                Navigator.pushNamed(context, '/community-voting-gallery');
                break;
              case 3:
                // Navigate to profile (not implemented)
                break;
            }
          },
        ),
      ),
    );
  }

  void _showCustomCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Suggest Cleanup Location',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create a custom cleanup suggestion for the community to vote on.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Location Description',
                hintText: 'e.g., Park entrance near fountain',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Estimated Points',
                hintText: 'e.g., 100',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle suggestion submission
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Cleanup suggestion submitted for community voting!'),
                  backgroundColor: AppTheme.getSuccessColor(true),
                ),
              );
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.getNeutralColor(true).withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    // Draw grid lines to simulate map
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw some "streets"
    final streetPaint = Paint()
      ..color = AppTheme.getNeutralColor(true).withValues(alpha: 0.2)
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      streetPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
