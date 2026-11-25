import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/core/widgets/premium_fade_in.dart';
import 'package:istm_mahagi/features/info/presentation/providers/info_providers.dart';
import 'package:istm_mahagi/features/info/domain/entities/calendar_event_entity.dart';
import 'package:istm_mahagi/features/auth/presentation/providers/auth_provider.dart';
import 'package:istm_mahagi/features/auth/domain/entities/admin_entity.dart';
import 'package:istm_mahagi/features/auth/domain/entities/staff_entity.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  String _selectedAnneeAcad = '2025-2026';
  bool _isTableView = true; // True for structured table, false for cards

  final List<String> _availableAnneeAcads = ['2025-2026', '2026-2027', '2024-2025'];
  final List<String> _categories = [
    'Tous',
    'Inscriptions & Rentrée',
    'Examens & Jury',
    'Congés & Fériés',
    'Activités & Colloques',
  ];

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(calendarEventsProvider);
    final isMobile = Responsive.isMobile(context);
    final userEntity = ref.watch(authEntityProvider);
    final bool isAdmin = userEntity is AdminEntity || userEntity is StaffEntity;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showAddEventDialog,
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('NOUVEL ÉVÉNEMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // Header Banner Top
          _buildHeroHeader(context, isMobile),

          // Search & Filter Toolbar
          SliverToBoxAdapter(
            child: _buildFilterBar(isMobile),
          ),

          // Main Calendar Content
          calendarAsync.when(
            data: (events) {
              // Combine Firestore events and Default ISTM Mahagi Calendar
              final List<CalendarEventEntity> allEvents = _getCombinedEvents(events);

              // Filter by Academic Year, Search, and Category
              final filteredEvents = allEvents.where((e) {
                final matchAnnee = e.anneeAcad == _selectedAnneeAcad;
                final matchQuery = _searchQuery.isEmpty ||
                    e.titreEvent.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    e.descriptionEvent.toLowerCase().contains(_searchQuery.toLowerCase());

                bool matchCategory = true;
                if (_selectedCategory == 'Inscriptions & Rentrée') {
                  matchCategory = e.titreEvent.toLowerCase().contains('inscription') || e.titreEvent.toLowerCase().contains('rentrée');
                } else if (_selectedCategory == 'Examens & Jury') {
                  matchCategory = e.titreEvent.toLowerCase().contains('examen') || e.titreEvent.toLowerCase().contains('jury') || e.titreEvent.toLowerCase().contains('délibération');
                } else if (_selectedCategory == 'Congés & Fériés') {
                  matchCategory = e.titreEvent.toLowerCase().contains('férié') || e.titreEvent.toLowerCase().contains('vacance') || e.titreEvent.toLowerCase().contains('pâques') || e.titreEvent.toLowerCase().contains('noël');
                } else if (_selectedCategory == 'Activités & Colloques') {
                  matchCategory = e.titreEvent.toLowerCase().contains('colloque') || e.titreEvent.toLowerCase().contains('scientifique') || e.titreEvent.toLowerCase().contains('excursion');
                }

                return matchAnnee && matchQuery && matchCategory;
              }).toList();

              if (filteredEvents.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(60),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.event_busy_rounded, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun événement trouvé pour l\'année académique $_selectedAnneeAcad.',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group events by Month
              final groupedEvents = <String, List<CalendarEventEntity>>{};
              for (final event in filteredEvents) {
                final monthYear = DateFormat('MMMM yyyy', 'fr_FR').format(event.dateDebut).toUpperCase();
                groupedEvents.putIfAbsent(monthYear, () => []).add(event);
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40, vertical: 30),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final monthName = groupedEvents.keys.elementAt(index);
                      final monthEvents = groupedEvents[monthName]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthHeaderBlock(monthName),
                          const SizedBox(height: 15),
                          _isTableView
                              ? _buildMonthTable(monthEvents, isMobile)
                              : _buildMonthCardsGrid(monthEvents, isMobile),
                          const SizedBox(height: 45),
                        ],
                      );
                    },
                    childCount: groupedEvents.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Erreur : $err', style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 180.0 : 220.0,
      pinned: true,
      backgroundColor: const Color(0xFF2D3E50),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CALENDRIER ACADÉMIQUE ISTM MAHAGI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.white,
                fontSize: isMobile ? 14 : 18,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 50,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Année Académique $_selectedAnneeAcad",
              style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2D3E50),
          ),
          child: Center(
            child: Icon(
              Icons.calendar_month_rounded,
              size: 100,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 30, vertical: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              Wrap(
                spacing: 15,
                runSpacing: 15,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Academic Year Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3E50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, color: AppColors.accentYellow, size: 18),
                        const SizedBox(width: 8),
                        const Text('Année : ', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: _selectedAnneeAcad,
                          dropdownColor: const Color(0xFF2D3E50),
                          underline: const SizedBox.shrink(),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedAnneeAcad = val);
                          },
                          items: _availableAnneeAcads.map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  Container(
                    width: isMobile ? double.infinity : 320,
                    height: 42,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un événement...',
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryBlue),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      ),
                    ),
                  ),

                  // Display View Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.table_rows_rounded, color: _isTableView ? AppColors.primaryBlue : Colors.grey),
                          tooltip: 'Vue Tableau Officiel',
                          onPressed: () => setState(() => _isTableView = true),
                        ),
                        IconButton(
                          icon: Icon(Icons.grid_view_rounded, color: !_isTableView ? AppColors.primaryBlue : Colors.grey),
                          tooltip: 'Vue Cartes Interactives',
                          onPressed: () => setState(() => _isTableView = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final bool isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textMain,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          fontSize: 11,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeaderBlock(String monthName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0088FF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0088FF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        monthName.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          fontFamily: 'Playfair Display',
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildMonthTable(List<CalendarEventEntity> events, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
        itemBuilder: (context, index) {
          final e = events[index];
          final dateStr = _formatEventDateRange(e);

          return Padding(
            padding: const EdgeInsets.all(18),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateBadge(dateStr, isMobile),
                      const SizedBox(height: 10),
                      Text(
                        e.titreEvent,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain),
                      ),
                      if (e.descriptionEvent.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          e.descriptionEvent,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 220,
                        child: _buildDateBadge(dateStr, isMobile),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.titreEvent,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textMain),
                            ),
                            if (e.descriptionEvent.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                e.descriptionEvent,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildDateBadge(String dateStr, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        dateStr,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMonthCardsGrid(List<CalendarEventEntity> events, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 650;

        if (isSmall) {
          return Column(
            children: events.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildCardItem(e),
            )).toList(),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 600,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 180,
          ),
          itemCount: events.length,
          itemBuilder: (context, i) => _buildCardItem(events[i]),
        );
      },
    );
  }

  Widget _buildCardItem(CalendarEventEntity e) {
    return PremiumFadeIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateBadge(_formatEventDateRange(e), false),
            const SizedBox(height: 12),
            Text(
              e.titreEvent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                e.descriptionEvent,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatEventDateRange(CalendarEventEntity e) {
    final startDay = e.dateDebut.day.toString().padLeft(2, '0');
    final startMonth = DateFormat('MMM', 'fr_FR').format(e.dateDebut);

    if (e.dateDebut.day == e.dateFin.day && e.dateDebut.month == e.dateFin.month) {
      return "${_getWeekdayName(e.dateDebut.weekday)} $startDay $startMonth";
    }

    final endDay = e.dateFin.day.toString().padLeft(2, '0');
    final endMonth = DateFormat('MMM', 'fr_FR').format(e.dateFin);

    if (e.dateDebut.month == e.dateFin.month) {
      return "Du $startDay au $endDay $startMonth";
    }

    return "Du $startDay $startMonth au $endDay $endMonth";
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
  }

  List<CalendarEventEntity> _getCombinedEvents(List<CalendarEventEntity> firestoreEvents) {
    final List<CalendarEventEntity> combined = [...firestoreEvents];

    // Check if default calendar is already present
    if (combined.isEmpty) {
      combined.addAll(_getDefaultIstmCalendar());
    }

    return combined;
  }

  List<CalendarEventEntity> _getDefaultIstmCalendar() {
    return [
      // SEPTEMBRE 2025
      CalendarEventEntity(
        id: 'def_1',
        titreEvent: 'Inscriptions & Réinscriptions',
        descriptionEvent: 'Début des Inscriptions des nouveaux étudiants et des Réinscriptions des anciens étudiants (Commission des Inscriptions).',
        dateDebut: DateTime(2025, 9, 8),
        dateFin: DateTime(2025, 9, 30),
        anneeAcad: '2025-2026',
      ),

      // OCTOBRE 2025
      CalendarEventEntity(
        id: 'def_2',
        titreEvent: 'Ouverture Solennelle de l\'Année Académique',
        descriptionEvent: 'Rentrée académique à l’ISTM Mahagi avec Messe du Saint-Esprit, Leçon inaugurale et allocutions de circonstance.',
        dateDebut: DateTime(2025, 10, 22),
        dateFin: DateTime(2025, 10, 22),
        anneeAcad: '2025-2026',
      ),
      CalendarEventEntity(
        id: 'def_3',
        titreEvent: 'Encadrement Pédagogique des Nouveaux Étudiants',
        descriptionEvent: 'Séances d\'orientation pédagogique, visite des laboratoires et bibliothèques.',
        dateDebut: DateTime(2025, 10, 23),
        dateFin: DateTime(2025, 10, 25),
        anneeAcad: '2025-2026',
      ),
      CalendarEventEntity(
        id: 'def_4',
        titreEvent: 'Début des Apprentissages du 1er Semestre',
        descriptionEvent: 'Début effectif des cours, travaux pratiques et laboratoires dans toutes les promotions.',
        dateDebut: DateTime(2025, 10, 27),
        dateFin: DateTime(2025, 10, 31),
        anneeAcad: '2025-2026',
      ),

      // NOVEMBRE 2025
      CalendarEventEntity(
        id: 'def_5',
        titreEvent: 'Clôture des Inscriptions & Réorientations',
        descriptionEvent: 'Fin des inscriptions académiques et fin des changements de filières.',
        dateDebut: DateTime(2025, 11, 6),
        dateFin: DateTime(2025, 11, 6),
        anneeAcad: '2025-2026',
      ),
      CalendarEventEntity(
        id: 'def_6',
        titreEvent: 'Concours d\'Admission',
        descriptionEvent: 'Épreuves de Français, Anglais, Culture Générale et Mathématiques pour les candidats.',
        dateDebut: DateTime(2025, 11, 7),
        dateFin: DateTime(2025, 11, 8),
        anneeAcad: '2025-2026',
      ),

      // DÉCEMBRE 2025
      CalendarEventEntity(
        id: 'def_7',
        titreEvent: 'Accueil & Intégration des Nouveaux Étudiants',
        descriptionEvent: 'Journée d\'intégration organisée par la Direction et le Comité Estudiantin.',
        dateDebut: DateTime(2025, 12, 5),
        dateFin: DateTime(2025, 12, 5),
        anneeAcad: '2025-2026',
      ),
      CalendarEventEntity(
        id: 'def_8',
        titreEvent: 'Vacances de Noël et Nouvel An',
        descriptionEvent: 'Suspension des cours pour les festivités de fin d\'année.',
        dateDebut: DateTime(2025, 12, 24),
        dateFin: DateTime(2026, 1, 5),
        anneeAcad: '2025-2026',
      ),

      // JANVIER 2026
      CalendarEventEntity(
        id: 'def_9',
        titreEvent: 'Reprise des Enseignements du 1er Semestre',
        descriptionEvent: 'Reprise effective des cours et travaux pratiques.',
        dateDebut: DateTime(2026, 1, 6),
        dateFin: DateTime(2026, 1, 31),
        anneeAcad: '2025-2026',
      ),

      // FÉVRIER 2026
      CalendarEventEntity(
        id: 'def_10',
        titreEvent: 'Fin des Cours du 1er Semestre & Enrôlement aux Examens',
        descriptionEvent: 'Période de révisions, arrêt des enseignements et enrôlement au Bureau du Jury.',
        dateDebut: DateTime(2026, 2, 9),
        dateFin: DateTime(2026, 2, 14),
        anneeAcad: '2025-2026',
      ),
      CalendarEventEntity(
        id: 'def_11',
        titreEvent: 'Session d\'Examens du 1er Semestre',
        descriptionEvent: 'Passation des épreuves de la première session du premier semestre.',
        dateDebut: DateTime(2026, 2, 16),
        dateFin: DateTime(2026, 2, 26),
        anneeAcad: '2025-2026',
      ),

      // MARS 2026
      CalendarEventEntity(
        id: 'def_12',
        titreEvent: 'Délibérations & Proclamation du 1er Semestre',
        descriptionEvent: 'Proclamation des résultats de la première session et examen des recours.',
        dateDebut: DateTime(2026, 3, 2),
        dateFin: DateTime(2026, 3, 4),
        anneeAcad: '2025-2026',
      ),
      CalendarEventEntity(
        id: 'def_13',
        titreEvent: 'Début des Cours du 2nd Semestre',
        descriptionEvent: 'Lancement officiel des enseignements du deuxième semestre.',
        dateDebut: DateTime(2026, 3, 17),
        dateFin: DateTime(2026, 3, 31),
        anneeAcad: '2025-2026',
      ),

      // AVRIL 2026
      CalendarEventEntity(
        id: 'def_14',
        titreEvent: 'Vacances de Pâques',
        descriptionEvent: 'Interruption des cours pour le triduum pascal et Pâques.',
        dateDebut: DateTime(2026, 4, 2),
        dateFin: DateTime(2026, 4, 12),
        anneeAcad: '2025-2026',
      ),

      // MAI 2026
      CalendarEventEntity(
        id: 'def_15',
        titreEvent: 'Colloque Scientifique & Journées de la Recherche',
        descriptionEvent: 'Conférences scientifiques, présentations des travaux de recherche et ateliers.',
        dateDebut: DateTime(2026, 5, 15),
        dateFin: DateTime(2026, 5, 16),
        anneeAcad: '2025-2026',
      ),

      // JUIN 2026
      CalendarEventEntity(
        id: 'def_16',
        titreEvent: 'Dépôt des Travaux de Fin d\'Études (TFC / Mémoires)',
        descriptionEvent: 'Dépôt officiel des TFC et mémoires aux Décanats pour évaluation.',
        dateDebut: DateTime(2026, 6, 23),
        dateFin: DateTime(2026, 6, 29),
        anneeAcad: '2025-2026',
      ),

      // JUILLET 2026
      CalendarEventEntity(
        id: 'def_17',
        titreEvent: 'Session d\'Examens du 2nd Semestre',
        descriptionEvent: 'Épreuves d\'évaluations de fin d\'année académique.',
        dateDebut: DateTime(2026, 7, 1),
        dateFin: DateTime(2026, 7, 13),
        anneeAcad: '2025-2026',
      ),
      CalendarEventEntity(
        id: 'def_18',
        titreEvent: 'Soutenances Publiques des TFC & Mémoires',
        descriptionEvent: 'Défenses publiques devant les jurys académiques.',
        dateDebut: DateTime(2026, 7, 14),
        dateFin: DateTime(2026, 7, 16),
        anneeAcad: '2025-2026',
      ),
      CalendarEventEntity(
        id: 'def_19',
        titreEvent: 'Collation des Grades & Clôture de l\'Année Académique',
        descriptionEvent: 'Cérémonie solennelle de collation des grades académiques et clôture officielle de l\'année 2025-2026.',
        dateDebut: DateTime(2026, 7, 31),
        dateFin: DateTime(2026, 7, 31),
        anneeAcad: '2025-2026',
      ),
    ];
  }

  void _showAddEventDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String dialogAnneeAcad = _selectedAnneeAcad;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.event_available_rounded, color: AppColors.primaryBlue),
              SizedBox(width: 10),
              Text('Ajouter un Événement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: dialogAnneeAcad,
                    decoration: const InputDecoration(
                      labelText: 'Année Académique',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableAnneeAcads.map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => dialogAnneeAcad = val);
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Titre de l\'Événement',
                      hintText: 'ex: Examens de la 1ère Session',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Détails',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text("Début: ${DateFormat('dd/MM/yyyy').format(startDate)}", style: const TextStyle(fontSize: 11)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setDialogState(() => startDate = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text("Fin: ${DateFormat('dd/MM/yyyy').format(endDate)}", style: const TextStyle(fontSize: 11)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setDialogState(() => endDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ANNULER', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;

                final newEvent = CalendarEventEntity(
                  id: '',
                  titreEvent: titleCtrl.text.trim(),
                  descriptionEvent: descCtrl.text.trim(),
                  dateDebut: startDate,
                  dateFin: endDate,
                  anneeAcad: dialogAnneeAcad,
                );

                await ref.read(infoRepositoryProvider).addCalendarEvent(newEvent);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Événement ajouté avec succès au calendrier !'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              child: const Text('ENREGISTRER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
