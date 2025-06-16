import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class DesignDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> design;
  final Function(String, bool) onVote;
  final bool hasVoted;

  const DesignDetailBottomSheet({
    super.key,
    required this.design,
    required this.onVote,
    required this.hasVoted,
  });

  @override
  State<DesignDetailBottomSheet> createState() =>
      _DesignDetailBottomSheetState();
}

class _DesignDetailBottomSheetState extends State<DesignDetailBottomSheet> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days, ${duration.inHours % 24} hours remaining';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours, ${duration.inMinutes % 60} minutes remaining';
    } else {
      return '${duration.inMinutes} minutes remaining';
    }
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
    final timeRemaining = widget.design['timeRemaining'] as Duration;
    final voteCount = widget.design['voteCount'] as int;
    final title = widget.design['title'] as String;
    final creator = widget.design['creator'] as String;
    final creatorAvatar = widget.design['creatorAvatar'] as String;
    final description = widget.design['description'] as String;
    final category = widget.design['category'] as String;
    final location = widget.design['location'] as String;
    final comments = widget.design['comments'] as int;
    final views = widget.design['views'] as List;
    final implementationStatus =
        widget.design['implementationStatus'] as String;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getNeutralColor(true).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Design Details',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.getNeutralColor(true),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image carousel
                      SizedBox(
                        height: 250,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemCount: views.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CustomImageWidget(
                                    imageUrl: views[index] as String,
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                            // Page indicators
                            if (views.length > 1)
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    views.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: index == _currentImageIndex
                                            ? Colors.white
                                            : Colors.white
                                                .withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Title and status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          _buildStatusBadge(implementationStatus),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Location and category
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: AppTheme.getNeutralColor(true),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            location,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.getNeutralColor(true),
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Creator info
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomImageWidget(
                              imageUrl: creatorAvatar,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Created by',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.getNeutralColor(true),
                                  ),
                                ),
                                Text(
                                  creator,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Description
                      Text(
                        'Description',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Voting statistics
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voting Statistics',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    'Total Votes',
                                    voteCount.toString(),
                                    'how_to_vote',
                                    AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatItem(
                                    'Comments',
                                    comments.toString(),
                                    'comment',
                                    AppTheme.getAccentColor(true),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Time remaining
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getUrgencyColor(timeRemaining)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getUrgencyColor(timeRemaining),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'schedule',
                                    color: _getUrgencyColor(timeRemaining),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatTimeRemaining(timeRemaining),
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: _getUrgencyColor(timeRemaining),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      // Voting buttons
                      if (!widget.hasVoted) ...[
                        Text(
                          'Cast Your Vote',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLargeVoteButton(
                                'Not Suitable',
                                'thumb_down',
                                AppTheme.lightTheme.colorScheme.error,
                                false,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildLargeVoteButton(
                                'Great Idea!',
                                'thumb_up',
                                AppTheme.getSuccessColor(true),
                                true,
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.getSuccessColor(true)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.getSuccessColor(true),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'check_circle',
                                color: AppTheme.getSuccessColor(true),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Thank you for voting!',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppTheme.getSuccessColor(true),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;
    String badgeIcon;

    switch (status) {
      case 'approved':
        badgeColor = AppTheme.getSuccessColor(true);
        badgeText = 'APPROVED';
        badgeIcon = 'check_circle';
        break;
      case 'implemented':
        badgeColor = AppTheme.lightTheme.colorScheme.primary;
        badgeText = 'IMPLEMENTED';
        badgeIcon = 'verified';
        break;
      default:
        badgeColor = AppTheme.getWarningColor(true);
        badgeText = 'VOTING ACTIVE';
        badgeIcon = 'how_to_vote';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: badgeIcon,
            color: badgeColor,
            size: 14,
          ),
          SizedBox(width: 6),
          Text(
            badgeText,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String icon, Color color) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: color,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.getNeutralColor(true),
          ),
        ),
      ],
    );
  }

  Widget _buildLargeVoteButton(
      String text, String icon, Color color, bool isUpvote) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onVote(widget.design['id'] as String, isUpvote);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              text,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
