import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/source_model.dart';
import '../../data/services/source_manager.dart';

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SourceManager _sourceManager = SourceManager();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _sourceManager.addListener(_onSourceManagerChanged);
  }

  void _onSourceManagerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sourceManager.removeListener(_onSourceManagerChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInstalledSources(),
                  _buildAvailableSources(),
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
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sources',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF0D9B5),
                ),
              ),
              Text(
                '${_sourceManager.installedSources.length} active',
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  color: const Color(0xFF5A4535),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
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
      tabs: const [
        Tab(text: 'Installed'),
        Tab(text: 'Available'),
      ],
    );
  }

  Widget _buildInstalledSources() {
    final installed = _sourceManager.installedSources;

    if (installed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📦', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No sources active',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                color: const Color(0xFF5A4535),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Install sources from the Available tab',
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFF3D2E1E),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Active sources for your feed',
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            color: const Color(0xFF5A4535),
          ),
        ),
        const SizedBox(height: 12),
        ...installed.map((source) => _buildSourceCard(
          source,
          isInstalled: true,
        )),
      ],
    );
  }

  Widget _buildAvailableSources() {
    final all = _sourceManager.allSources;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Enable sources to populate your home screen',
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            color: const Color(0xFF5A4535),
          ),
        ),
        const SizedBox(height: 12),
        ...all.map((source) => _buildSourceCard(
          source,
          isInstalled: _sourceManager.isInstalled(source.id),
        )),
      ],
    );
  }

  Widget _buildSourceCard(SourceModel source, {required bool isInstalled}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1610),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isInstalled
              ? const Color(0xFFC8823A).withOpacity(0.3)
              : const Color(0xFF2E2018),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF241A11),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3D2E1E), width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                source.iconEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF0D9B5),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  source.description,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 11,
                    color: const Color(0xFF5A4535),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: source.contentTypes.map((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF241A11),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF3D2E1E), width: 0.5,
                        ),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 9,
                          color: const Color(0xFF8A6A4A),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (source.id == 'mangadex') return; 
              
              if (isInstalled) {
                _sourceManager.uninstallSource(source.id);
              } else {
                _sourceManager.installSource(source.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isInstalled
                    ? source.id == 'mangadex'
                        ? const Color(0xFF241A11)
                        : const Color(0xFFE05555).withOpacity(0.1)
                    : const Color(0xFFC8823A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isInstalled
                      ? source.id == 'mangadex'
                          ? const Color(0xFF3D2E1E)
                          : const Color(0xFFE05555).withOpacity(0.3)
                      : const Color(0xFFC8823A),
                  width: 0.5,
                ),
              ),
              child: Text(
                isInstalled
                    ? source.id == 'mangadex'
                        ? 'Mandatory'
                        : 'Remove'
                    : 'Install',
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isInstalled
                      ? source.id == 'mangadex'
                          ? const Color(0xFF5A4535)
                          : const Color(0xFFE05555)
                      : const Color(0xFF1C1510),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
