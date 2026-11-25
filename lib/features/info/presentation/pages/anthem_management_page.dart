import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/anthem_entity.dart';

class AnthemManagementPage extends ConsumerStatefulWidget {
  const AnthemManagementPage({super.key});

  @override
  ConsumerState<AnthemManagementPage> createState() => _AnthemManagementPageState();
}

class _AnthemManagementPageState extends ConsumerState<AnthemManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  String _currentId = "";

  void _save() async {
    final anthem = AnthemEntity(
      id: _currentId,
      titre: _titleController.text.trim(),
      paroles: _lyricsController.text.trim(),
    );

    try {
      await ref.read(infoRepositoryProvider).updateAnthem(anthem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hymne institutionnel mis à jour !"),
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
    final anthemAsync = ref.watch(anthemProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'CMS : HYMNE INSTITUTIONNEL',
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
      body: anthemAsync.when(
        data: (anthem) {
          if (anthem != null && _currentId.isEmpty) {
            _currentId = anthem.id;
            _titleController.text = anthem.titre;
            _lyricsController.text = anthem.paroles;
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 15 : 40,
              vertical: 30,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    _buildForm(),
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
              Icon(Icons.music_note_rounded, color: AppColors.primaryBlue, size: 24),
              SizedBox(width: 10),
              Text(
                "HYMNE DE L'ISTM MAHAGI",
                style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
            decoration: InputDecoration(
              labelText: "Titre de l'hymne",
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
            controller: _lyricsController,
            maxLines: 12,
            style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.6),
            decoration: InputDecoration(
              labelText: "Paroles officielles complètes",
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
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
              label: const Text(
                'ENREGISTRER L\'HYMNE',
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
}
