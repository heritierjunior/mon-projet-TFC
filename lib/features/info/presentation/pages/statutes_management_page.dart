import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/statute_entity.dart';

class StatutesManagementPage extends ConsumerStatefulWidget {
  const StatutesManagementPage({super.key});

  @override
  ConsumerState<StatutesManagementPage> createState() => _StatutesManagementPageState();
}

class _StatutesManagementPageState extends ConsumerState<StatutesManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _editingId;

  void _save() async {
    if (_titleController.text.isEmpty) return;

    final statute = StatuteEntity(
      id: _editingId ?? '',
      titre: _titleController.text.trim(),
      description: _descController.text.trim(),
      fichierPdf: 'standard_statut.pdf',
    );

    try {
      await ref.read(infoRepositoryProvider).addStatute(statute);
      _titleController.clear();
      _descController.clear();
      _editingId = null;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Document légal publié en ligne !"), backgroundColor: Colors.green),
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
    final statutesAsync = ref.watch(statutesProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'CMS : STATUTS & DOCUMENTS OFFICIELS',
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
                const SizedBox(height: 35),
                const Text(
                  'DOCUMENTS ET STATUTS PUBLIÉS',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain, letterSpacing: 1),
                ),
                const SizedBox(height: 15),
                statutesAsync.when(
                  data: (list) => _buildList(list),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                  error: (e, _) => Text("Erreur : $e", style: const TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        ),
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
              Icon(Icons.gavel_rounded, color: AppColors.primaryBlue, size: 24),
              SizedBox(width: 10),
              Text(
                "AJOUTER UN DOCUMENT OFFICIEL",
                style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
            decoration: InputDecoration(
              labelText: "Titre du document (ex: Arrêté ministériel d'homologation)",
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _descController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.5),
            decoration: InputDecoration(
              labelText: "Description ou résumé du document",
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
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: const Text(
                'PUBLIER LE DOCUMENT',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
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

  Widget _buildList(List<StatuteEntity> list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'Aucun document statutaire publié pour le moment.',
            style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final s = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
            ),
            title: Text(
              s.titre,
              style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              s.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              onPressed: () => ref.read(infoRepositoryProvider).deleteStatute(s.id),
            ),
          ),
        );
      },
    );
  }
}
