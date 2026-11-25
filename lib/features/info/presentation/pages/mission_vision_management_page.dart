import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/mission_vision_entity.dart';

class MissionVisionManagementPage extends ConsumerStatefulWidget {
  const MissionVisionManagementPage({super.key});

  @override
  ConsumerState<MissionVisionManagementPage> createState() => _MissionVisionManagementPageState();
}

class _MissionVisionManagementPageState extends ConsumerState<MissionVisionManagementPage> {
  final TextEditingController _missionController = TextEditingController();
  final TextEditingController _visionController = TextEditingController();
  final TextEditingController _valeursController = TextEditingController();
  String _currentId = "";

  void _save() async {
    final mv = MissionVisionEntity(
      id: _currentId,
      mission: _missionController.text.trim(),
      vision: _visionController.text.trim(),
      valeurs: _valeursController.text.trim(),
    );

    try {
      await ref.read(infoRepositoryProvider).updateMissionVision(mv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mission, Vision & Valeurs enregistrées en ligne !"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mvAsync = ref.watch(missionVisionProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'CMS : MISSION & VISION',
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
      body: mvAsync.when(
        data: (mv) {
          if (mv != null && _currentId.isEmpty) {
            _currentId = mv.id;
            _missionController.text = mv.mission;
            _visionController.text = mv.vision;
            _valeursController.text = mv.valeurs;
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 15 : 40,
              vertical: 30,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildFieldCard("NOTRE MISSION", _missionController, 4, Icons.flag_rounded, const Color(0xFF0284C7)),
                    const SizedBox(height: 20),
                    _buildFieldCard("NOTRE VISION", _visionController, 4, Icons.visibility_rounded, const Color(0xFFD97706)),
                    const SizedBox(height: 20),
                    _buildFieldCard("NOS VALEURS", _valeursController, 4, Icons.stars_rounded, const Color(0xFF0D9488)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'ENREGISTRER ET PUBLIER',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0088FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (e, _) => Center(child: Text("Erreur : $e", style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildFieldCard(String label, TextEditingController controller, int lines, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            maxLines: lines,
            style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.5),
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
        ],
      ),
    );
  }
}
