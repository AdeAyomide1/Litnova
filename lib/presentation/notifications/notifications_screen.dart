import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allNotifications = [
    {
      'type': 'new_chapter',
      'title': 'New Chapter Available',
      'body': 'Chapter 15 of The Ember Throne is now available to read!',
      'time': '2 min ago',
      'isRead': false,
      'icon': Icons.book_rounded,
      'color': const Color(0xFFC8823A),
      'bookId': '1',
    },
    {
      'type': 'new_chapter',
      'title': 'New Chapter Available',
      'body': 'Void Samurai Chapter 39 has just dropped. Continue the journey!',
      'time': '1 hour ago',
      'isRead': false,
      'icon': Icons.auto_stories_rounded,
      'color': const Color(0xFF5B9BD5),
      'bookId': '2',
    },
    {
      'type': 'achievement',
      'title': 'Achievement Unlocked!',
      'body': 'You earned the "Night Owl" badge for reading after midnight.',
      'time': '3 hours ago',
      'isRead': false,
      'icon': Icons.military_tech_rounded,
      'color': const Color(0xFFC8823A),
      'bookId': null,
    },
    {
      'type': 'recommendation',
      'title': 'Recommended For You',
      'body': 'Based on your reading history, you might love Shadow Meridian.',
      'time': '5 hours ago',
      'isRead': true,
      'icon': Icons.recommend_rounded,
      'color': const Color(0xFF7AB648),
      'bookId': '10',
    },
    {
      'type': 'new_chapter',
      'title': 'New Chapter Available',
      'body': 'Crimson Empire Chapter 22 is live. Don\'t miss it!',
      'time': 'Yesterday',
      'isRead': true,
      'icon': Icons.book_rounded,
      'color': const Color(0xFFC8823A),
      'bookId': '3',
    },
    {
      'type': 'streak',
      'title': '14 Day Reading Streak!',
      'body': 'Amazing! You\'ve been reading every day for 14 days. Keep it up!',
      'time': 'Yesterday',
      'isRead': true,
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFE05555),
      'bookId': null,
    },
    {
      'type': 'recommendation',
      'title': 'Trending in Fantasy',
      'body': 'The Last Grove is trending in your favorite genre. Check it out!',
      'time': '2 days ago',
      'isRead': true,
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF7AB648),
      'bookId': '5',
    },
    {
      'type': 'achievement',
      'title': 'Achievement Unlocked!',
      'body': 'You earned the "Speed Reader" badge for finishing a book in one day.',
      'time': '3 days ago',
      'isRead': true,
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFFC8823A),
      'bookId': null,
    },
    {
      'type': 'new_chapter',
      'title': 'New Chapter Available',
      'body': 'Stars of Orion Chapter 8 is now available. The story continues!',
      'time': '4 days ago',
      'isRead': true,
      'icon': Icons.book_rounded,
      'color': const Color(0xFF5B9BD5),
      'bookId': '4',
    },
    {
      'type': 'streak',
      'title': '7 Day Reading Streak!',
      'body': 'You\'ve been reading for 7 days straight. You\'re on fire!',
      'time': '1 week ago',
      'isRead': true,
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFE05555),
      'bookId': null,
    },
  ];

  List<Map<String, dynamic>> get _unreadNotifications =>
      _allNotifications.where((n) => !(n['isRead'] as bool)).toList();

  int get _unreadCount => _unreadNotifications.length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _allNotifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _markAsRead(int index) {
    setState(() {
      _allNotifications[index]['isRead'] = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _allNotifications.removeAt(index);
    });
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    final bookId = notification['bookId'] as String?;
    if (bookId != null) {
      context.go('/book/$bookId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationsList(_allNotifications, showIndex: true),
                  _buildNotificationsList(_unreadNotifications,
                      showIndex: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1610),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2E2018), width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFFA08060),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Notifications',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF0D9B5),
                ),
              ),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8823A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1510),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  color: const Color(0xFFC8823A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFFC8823A),
      indicatorWeight: 2,
      labelColor: const Color(0xFFC8823A),
      unselectedLabelColor: const Color(0xFF5A4535),
      labelStyle: GoogleFonts.sourceSans3(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.sourceSans3(fontSize: 13),
      dividerColor: const Color(0xFF2E2018),
      tabs: [
        const Tab(text: 'All'),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Unread'),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8823A).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 10,
                      color: const Color(0xFFC8823A),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(
      List<Map<String, dynamic>> notifications, {
        required bool showIndex,
      }) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_rounded,
              color: Color(0xFF3D2E1E),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: const Color(0xFF5A4535),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFF3D2E1E),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final globalIndex = showIndex
            ? index
            : _allNotifications.indexOf(notification);
        return _buildNotificationCard(notification, globalIndex);
      },
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification,
      int globalIndex,
      ) {
    final isRead = notification['isRead'] as bool;
    return Dismissible(
      key: Key('notification_$globalIndex'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF6A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFE05555),
          size: 22,
        ),
      ),
      onDismissed: (_) => _deleteNotification(globalIndex),
      child: GestureDetector(
        onTap: () {
          _markAsRead(globalIndex);
          _onNotificationTap(notification);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead
                ? const Color(0xFF1E1610)
                : const Color(0xFFC8823A).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRead
                  ? const Color(0xFF2E2018)
                  : const Color(0xFFC8823A).withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (notification['color'] as Color).withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: notification['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: GoogleFonts.sourceSans3(
                              fontSize: 13,
                              fontWeight: isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: isRead
                                  ? const Color(0xFFC4A882)
                                  : const Color(0xFFF0D9B5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notification['time'] as String,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 10,
                            color: const Color(0xFF3D2E1E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['body'] as String,
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        color: isRead
                            ? const Color(0xFF5A4535)
                            : const Color(0xFF8A6A4A),
                        height: 1.5,
                      ),
                    ),
                    if (!isRead) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC8823A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'New',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 10,
                              color: const Color(0xFFC8823A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
