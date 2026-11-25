import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'course_management_page.dart';
import '../providers/academic_providers.dart';
import '../../domain/entities/horaire_entity.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/cours_entity.dart';

class ScheduleManagementPage extends ConsumerStatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  ConsumerState<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends ConsumerState<ScheduleManagementPage> {
  String? _selectedPromoId;
  String? _selectedCourseId;
  DateTime? _selectedDate;
  String _selectedDay = 'Lundi';
  final TextEditingController _hDebutController = TextEditingController();
  final TextEditingController _hFinController = TextEditingController();
  final TextEditingController _salleController = TextEditingController();

  Future<void> _addSession() async {
    if (_selectedPromoId == null || _selectedCourseId == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner le cours et la date de la séance."), backgroundColor: Colors.orange),
      );
      return;
    }

    final schedule = HoraireEntity(
      id: '',
      idPromo: _selectedPromoId!,
      idCours: _selectedCourseId!,
      dateCours: _selectedDate!,
      jour: _selectedDay,
      heureDebut: _hDebutController.text.trim(),
      heureFin: _hFinController.text.trim(),
      salle: _salleController.text.trim(),
    );

    await ref.read(academicRepositoryProvider).addSchedule(schedule);

    _salleController.clear();
    _hDebutController.clear();
    _hFinController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Séance ajoutée à l'emploi du temps !"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(promotionsProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final schedulesAsync = _selectedPromoId != null ? ref.watch(schedulesProvider(_selectedPromoId)) : null;
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'GESTION DES EMPLOIS DU TEMPS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Playfair Display',
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFF2D3E50),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40, vertical: 30),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromoSelector(promosAsync),
                const SizedBox(height: 25),
                if (_selectedPromoId != null) ...[
                  _buildAddForm(promosAsync, coursesAsync, isMobile),
                  const SizedBox(height: 35),
                  _buildScheduleTable(schedulesAsync, coursesAsync),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoSelector(AsyncValue<List<PromotionEntity>> promosAsync) {
    return Container(
      padding: const EdgeInsets.all(25),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.school_rounded, color: AppColors.primaryBlue, size: 22),
              SizedBox(width: 10),
              Text(
                'SÉLECTIONNER LA PROMOTION CIBLE :',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain),
              ),
            ],
          ),
          const SizedBox(height: 15),
          promosAsync.when(
            data: (list) => DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedPromoId,
              hint: const Text('-- Choisissez une promotion (ex: L1 LABO) --', style: TextStyle(fontSize: 13)),
              items: list.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(
                value: p.id,
                child: Text(p.nomPromo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              )).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedPromoId = v;
                  _selectedCourseId = null; // Reset course selection when promotion changes
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm(AsyncValue<List<PromotionEntity>> promosAsync, AsyncValue<List<CoursEntity>> coursesAsync, bool isMobile) {
    final listPromos = promosAsync.value ?? [];
    final selectedPromoEntity = listPromos.firstWhere(
      (p) => p.id == _selectedPromoId,
      orElse: () => PromotionEntity(id: '', nomPromo: '', idDept: '', idPromoAlt: '', seuilFinance: 0),
    );

    return Container(
      padding: const EdgeInsets.all(25),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                'PROGRAMMER UNE SÉANCE - ${selectedPromoEntity.nomPromo}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain),
              ),
            ],
          ),
          const SizedBox(height: 20),

          coursesAsync.when(
            data: (listCourses) {
              // Flexible course matching by ID or Promotion Name (e.g. L1 LABO)
              final promoCourses = listCourses.where((c) {
                if (c.idPromo == _selectedPromoId) return true;
                if (selectedPromoEntity.nomPromo.isNotEmpty &&
                    (c.idPromo.toLowerCase() == selectedPromoEntity.nomPromo.toLowerCase() ||
                        c.idPromo.toLowerCase() == selectedPromoEntity.id.toLowerCase())) {
                  return true;
                }
                return false;
              }).toList();

              if (promoCourses.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Aucun cours n'est actuellement attribué à la promotion '${selectedPromoEntity.nomPromo}'. Cliquez sur le bouton ci-contre pour créer un cours.",
                          style: const TextStyle(color: Color(0xFF78350F), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseManagementPage())),
                        icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        label: const Text('Créer un cours', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0088FF)),
                      ),
                    ],
                  ),
                );
              }

              return Wrap(
                spacing: 15,
                runSpacing: 15,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Select Course Dropdown
                  Container(
                    width: isMobile ? double.infinity : 280,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedCourseId,
                      hint: const Text('-- Choisir le cours --', style: TextStyle(fontSize: 12)),
                      items: promoCourses.map<DropdownMenuItem<String>>((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text("${c.codeCours} - ${c.intituleCours}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedCourseId = v),
                      decoration: _inputDeco(),
                    ),
                  ),

                  // Pick Date
                  Container(
                    width: isMobile ? double.infinity : 180,
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      child: InputDecorator(
                        decoration: _inputDeco(hint: 'Date'),
                        child: Text(
                          _selectedDate == null ? 'Choisir la Date' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  // Day Dropdown
                  Container(
                    width: isMobile ? double.infinity : 140,
                    child: DropdownButtonFormField<String>(
                      value: _selectedDay,
                      items: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
                          .map<DropdownMenuItem<String>>((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDay = v!),
                      decoration: _inputDeco(),
                    ),
                  ),

                  // Hours & Room
                  Container(width: isMobile ? 100 : 100, child: TextField(controller: _hDebutController, decoration: _inputDeco(hint: 'Début (ex: 08:00)'))),
                  Container(width: isMobile ? 100 : 100, child: TextField(controller: _hFinController, decoration: _inputDeco(hint: 'Fin (ex: 12:00)'))),
                  Container(width: isMobile ? double.infinity : 150, child: TextField(controller: _salleController, decoration: _inputDeco(hint: 'Auditoire / Salle'))),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _addSession,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text('AJOUTER À L\'HORAIRE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0088FF),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur chargement cours: $e', style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(AsyncValue<List<HoraireEntity>>? schedulesAsync, AsyncValue<List<CoursEntity>> coursesAsync) {
    if (schedulesAsync == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HORAIRE ACTUELLEMENT PROGRAMMÉ',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: 1),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
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
          child: schedulesAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(
                    child: Text(
                      'Aucune séance programmée pour cette promotion.',
                      style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('JOUR')),
                    DataColumn(label: Text('HEURES')),
                    DataColumn(label: Text('ENSEIGNEMENT (COURS)')),
                    DataColumn(label: Text('AUDITOIRE')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: list.map((s) {
                    final course = coursesAsync.value?.firstWhere(
                      (c) => c.id == s.idCours,
                      orElse: () => CoursEntity(id: '', idCours: 0, codeCours: '', intituleCours: 'Non défini', credits: 0, idEns: '', idPromo: ''),
                    );

                    return DataRow(
                      cells: [
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                          child: Text(DateFormat('dd/MM/yyyy').format(s.dateCours), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        )),
                        DataCell(Text(s.jour, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${s.heureDebut} - ${s.heureFin}')),
                        DataCell(Text(course?.intituleCours ?? 'Non défini', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(s.salle.isNotEmpty ? s.salle : '-')),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () => ref.read(academicRepositoryProvider).deleteSchedule(s.id),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
            error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.redAccent)),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco({String? hint}) => InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      );
}
