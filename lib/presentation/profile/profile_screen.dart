import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/api_service.dart';
import '../../shared/providers/app_settings_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppSettingsProvider _s = AppSettingsProvider();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getMe();
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _user = response.data['data']['user'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _s.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _s.borderColor, width: 0.5),
        ),
        title: Text(
          'Log Out',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            color: _s.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.sourceSans3(
            fontSize: 14, color: _s.textMutedColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.sourceSans3(color: _s.textFaintColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) context.go('/login');
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.sourceSans3(
                color: const Color(0xFFE05555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _s,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _s.bgColor,
          body: SafeArea(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: _s.currentAccentColor, strokeWidth: 2,
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadProfile,
              color: _s.currentAccentColor,
              backgroundColor: _s.surfaceColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProfileCard(),
                    _buildStatsGrid(),
                    _buildAccountOptions(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: _s.textColor,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _s.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: _s.borderColor, width: 0.5),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: _s.textMutedColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final name = _user?['name'] ?? 'Reader';
    final email = _user?['email'] ?? '';
    final role = _user?['role'] ?? 'reader';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _s.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _s.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _s.currentAccentColor.withOpacity(0.6),
                      _s.currentAccentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push('/profile/edit'),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _s.currentAccentColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _s.surfaceColor, width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.black87,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: _s.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.sourceSans3(
              fontSize: 13, color: _s.textMutedColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 5,
            ),
            decoration: BoxDecoration(
              color: role == 'writer'
                  ? _s.currentAccentColor.withOpacity(0.15)
                  : role == 'admin'
                  ? const Color(0xFF3AAA6A).withOpacity(0.15)
                  : _s.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: role == 'writer'
                    ? _s.currentAccentColor.withOpacity(0.3)
                    : role == 'admin'
                    ? const Color(0xFF3AAA6A).withOpacity(0.3)
                    : _s.borderColor,
                width: 0.5,
              ),
            ),
            child: Text(
              role == 'writer'
                  ? '✍️ Verified Writer'
                  : role == 'admin'
                  ? '⚡ Admin'
                  : '📖 Reader',
              style: GoogleFonts.sourceSans3(
                fontSize: 11,
                color: role == 'writer'
                    ? _s.currentAccentColor
                    : role == 'admin'
                    ? const Color(0xFF3AAA6A)
                    : _s.textFaintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileStat('0', 'Following'),
              Container(
                width: 0.5, height: 36, color: _s.borderColor,
              ),
              _buildProfileStat('0', 'Followers'),
              Container(
                width: 0.5, height: 36, color: _s.borderColor,
              ),
              _buildProfileStat('0', 'Books Read'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: _s.textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 11, color: _s.textFaintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'label': 'Books Read', 'value': '0', 'icon': '📚'},
      {'label': 'Hours Read', 'value': '0', 'icon': '⏱️'},
      {'label': 'Chapters', 'value': '0', 'icon': '📖'},
      {'label': 'Day Streak', 'value': '0', 'icon': '🔥'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: stats.map((stat) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _s.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _s.borderColor, width: 0.5),
            ),
            child: Row(
              children: [
                Text(
                  stat['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['value']!,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _s.textColor,
                      ),
                    ),
                    Text(
                      stat['label']!,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 10, color: _s.textFaintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountOptions() {
    final role = _user?['role'] ?? 'reader';
    final options = [
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Edit Profile',
        'onTap': () => context.push('/profile/edit'),
      },
      if (role == 'reader')
        {
          'icon': Icons.create_outlined,
          'label': 'Become a Writer',
          'onTap': () => context.push('/writer/apply'),
          'isAccent': true,
        },
      if (role == 'writer' || role == 'admin')
        {
          'icon': Icons.dashboard_outlined,
          'label': 'Writer Dashboard',
          'onTap': () => context.push('/writer/dashboard'),
          'isAccent': true,
        },
      {
        'icon': Icons.lock_outline_rounded,
        'label': 'Change Password',
        'onTap': () => context.push('/settings/password'),
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'label': 'Privacy Policy',
        'onTap': () => context.push('/settings/privacy'),
      },
      {
        'icon': Icons.info_outline_rounded,
        'label': 'About LitNOVA',
        'onTap': () => context.push('/settings/about'),
      },
      {
        'icon': Icons.logout_rounded,
        'label': 'Log Out',
        'onTap': _logout,
        'isDanger': true,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: _s.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _s.borderColor, width: 0.5),
      ),
      child: Column(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isLast = index == options.length - 1;
          final isAccent = option['isAccent'] == true;
          final isDanger = option['isDanger'] == true;

          return GestureDetector(
            onTap: option['onTap'] as VoidCallback,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDanger
                              ? const Color(0xFFE05555).withOpacity(0.1)
                              : isAccent
                              ? _s.currentAccentColor.withOpacity(0.1)
                              : _s.cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          option['icon'] as IconData,
                          color: isDanger
                              ? const Color(0xFFE05555)
                              : isAccent
                              ? _s.currentAccentColor
                              : _s.textMutedColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option['label'] as String,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 14,
                            color: isDanger
                                ? const Color(0xFFE05555)
                                : isAccent
                                ? _s.currentAccentColor
                                : _s.textSecondaryColor,
                            fontWeight: isAccent
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDanger
                            ? const Color(0xFFE05555).withOpacity(0.5)
                            : _s.textGhostColor,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.only(left: 66),
                    color: _s.borderColor,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
