import 'package:flutter/material.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'history_management_page.dart';
import 'mission_vision_management_page.dart';
import 'committee_management_page.dart';
import 'anthem_management_page.dart';
import 'statutes_management_page.dart';
import 'gallery_management_page.dart';
import 'news_management_page.dart';

class InstitutionalManagementPage extends StatelessWidget {
  const InstitutionalManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'GESTION INSTITUTIONNELLE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Playfair Display',
                letterSpacing: 1,
              ),
            ),
            Text(
              'Console de gestion de contenu (CMS) - ISTM Mahagi',
              style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2D3E50),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentYellow),
              ),
              child: Row(
                children: const [
                  CircleAvatar(radius: 4, backgroundColor: AppColors.accentYellow),
                  SizedBox(width: 8),
                  Text(
                    'EN DIRECT',
                    style: TextStyle(color: AppColors.accentYellow, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 15 : 40,
          vertical: 30,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info Section
                _buildIntroBanner(isMobile),
                const SizedBox(height: 30),

                // Grid of Modules
                _buildGrid(context, isMobile),
                const SizedBox(height: 40),

                // Footer System Status
                _buildFooterStatus(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryBlue, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Administration du Portail Public',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textMain),
                ),
                SizedBox(height: 4),
                Text(
                  'Sélectionnez un module ci-dessous pour modifier les informations officielles (Historique, Mission, Comité de Gestion, Actualités, Galerie photo, Hymne et Statuts).',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, bool isMobile) {
    final modules = [
      {
        'title': 'Historique',
        'desc': 'Récit fondateur et évolution de l\'ISTM Mahagi',
        'icon': Icons.history_edu_rounded,
        'color': const Color(0xFFEA580C),
        'page': const HistoryManagementPage(),
      },
      {
        'title': 'Mission & Vision',
        'desc': 'Objectifs, vision stratégique et valeurs',
        'icon': Icons.track_changes_rounded,
        'color': const Color(0xFF0284C7),
        'page': const MissionVisionManagementPage(),
      },
      {
        'title': 'Comité de Gestion',
        'desc': 'Membres du COGE, fonctions et photos',
        'icon': Icons.groups_3_rounded,
        'color': const Color(0xFF0D9488),
        'page': const CommitteeManagementPage(),
      },
      {
        'title': 'Actualités',
        'desc': 'Communiqués, événements et articles',
        'icon': Icons.newspaper_rounded,
        'color': const Color(0xFFE11D48),
        'page': const NewsManagementPage(),
      },
      {
        'title': 'Hymne Institutionnel',
        'desc': 'Paroles et hymne officiel',
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFF9333EA),
        'page': const AnthemManagementPage(),
      },
      {
        'title': 'Statuts & Documents',
        'desc': 'Documents juridiques et arrêtés officiels',
        'icon': Icons.gavel_rounded,
        'color': const Color(0xFF475569),
        'page': const StatutesManagementPage(),
      },
      {
        'title': 'Galerie Photos',
        'desc': 'Photos des événements et de la vie du campus',
        'icon': Icons.photo_library_rounded,
        'color': const Color(0xFFD97706),
        'page': const GalleryManagementPage(),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 650) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 180,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final m = modules[index];
            return _buildCmsCard(
              context,
              m['title'] as String,
              m['desc'] as String,
              m['icon'] as IconData,
              m['color'] as Color,
              m['page'] as Widget,
            );
          },
        );
      },
    );
  }

  Widget _buildCmsCard(BuildContext context, String title, String desc, IconData icon, Color color, Widget targetPage) {
    return PremiumFadeIn(
      child: _HoverCard(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage)),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 16),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.textMain,
                            fontFamily: 'Playfair Display',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterStatus(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3E50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done_rounded, color: AppColors.accentYellow, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Synchronisation Firebase Cloud Active',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  'Les modifications sont publiées instantanément sur le site web et l\'application mobile.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}
