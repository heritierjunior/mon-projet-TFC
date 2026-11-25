import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/history_entity.dart';

class HistoryManagementPage extends ConsumerStatefulWidget {
  const HistoryManagementPage({super.key});

  @override
  ConsumerState<HistoryManagementPage> createState() => _HistoryManagementPageState();
}

class _HistoryManagementPageState extends ConsumerState<HistoryManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _currentId = "";

  void _save() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    final history = HistoryEntity(
      id: _currentId,
      titre: _titleController.text.trim(),
      contenu: _contentController.text.trim(),
      dateMaj: DateTime.now(),
    );

    try {
      await ref.read(infoRepositoryProvider).updateHistory(history);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Historique synchronisé et publié en ligne !"),
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
    final historyAsync = ref.watch(historyProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'CMS : HISTORIQUE INSTITUTIONNEL',
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
      body: historyAsync.when(
        data: (history) {
          if (history != null && _currentId.isEmpty) {
            _currentId = history.id;
            _titleController.text = history.titre;
            _contentController.text = history.contenu;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildForm(),
                    const SizedBox(height: 30),
                    if (history != null) _buildCurrentVersionPreview(history),
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

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(28),
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
              Icon(Icons.history_edu_rounded, color: AppColors.primaryBlue, size: 24),
              SizedBox(width: 10),
              Text(
                "MISE À JOUR DE L'HISTORIQUE",
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textMain, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Titre de la section',
              hintText: 'ex: Origine et Fondations de l\'ISTM Mahagi',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _contentController,
            maxLines: 12,
            style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.5),
            decoration: InputDecoration(
              labelText: 'Récit Historique Complet',
              hintText: 'Saisissez l\'histoire officielle de l\'établissement...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 25),
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
    );
  }

  Widget _buildCurrentVersionPreview(HistoryEntity h) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircleAvatar(radius: 3, backgroundColor: Colors.green),
                    SizedBox(width: 6),
                    Text('EN LIGNE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Aperçu de la version actuelle',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            h.titre,
            style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Playfair Display'),
          ),
          const SizedBox(height: 8),
          Text(
            h.contenu,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
