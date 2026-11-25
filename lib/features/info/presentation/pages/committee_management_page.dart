import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import '../providers/info_providers.dart';
import '../../domain/entities/comite_entity.dart';

class CommitteeManagementPage extends ConsumerStatefulWidget {
  const CommitteeManagementPage({super.key});

  @override
  ConsumerState<CommitteeManagementPage> createState() => _CommitteeManagementPageState();
}

class _CommitteeManagementPageState extends ConsumerState<CommitteeManagementPage> {
  final TextEditingController _nomCompletController = TextEditingController();
  final TextEditingController _fonctionController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _rangController = TextEditingController();
  String? _editingId;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _categorieController.text = "Direction";
    _rangController.text = "1";
  }

  void _clear() {
    _nomCompletController.clear();
    _fonctionController.clear();
    _categorieController.text = "Direction";
    _bioController.clear();
    _rangController.text = "1";
    _editingId = null;
    _imageUrl = null;
    setState(() {});
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageUrl = image.path);
    }
  }

  void _save() async {
    if (_nomCompletController.text.isEmpty || _fonctionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le Nom Complet et la Fonction sont obligatoires.")),
      );
      return;
    }

    final member = ComiteEntity(
      id: _editingId ?? '',
      nomComplet: _nomCompletController.text.trim(),
      fonction: _fonctionController.text.trim(),
      categorie: _categorieController.text.trim(),
      photoMembre: _imageUrl ?? 'default.jpg',
      bio: _bioController.text.trim(),
      rang: int.tryParse(_rangController.text) ?? 10,
    );

    try {
      await ref.read(infoRepositoryProvider).saveCommitteeMember(member);
      _clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingId == null ? "Nouveau membre du COGE enregistré !" : "Profil COGE mis à jour !"),
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
    final committeeAsync = ref.watch(committeeProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'CMS : COMITÉ DE GESTION (COGE)',
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
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMemberForm(isMobile),
                const SizedBox(height: 35),
                const Text(
                  'MEMBRES ENREGISTRÉS DU COGE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain, letterSpacing: 1),
                ),
                const SizedBox(height: 15),
                _buildMembersList(committeeAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberForm(bool isMobile) {
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
            children: [
              const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryBlue, size: 24),
              const SizedBox(width: 10),
              Text(
                _editingId == null ? "AJOUTER UN MEMBRE DU COGE" : "MODIFIER LE MEMBRE DU COGE",
                style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 90,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: _imageUrl == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo_rounded, color: AppColors.primaryBlue, size: 28),
                            SizedBox(height: 6),
                            Text('Photo', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _imageUrl!.startsWith('http')
                              ? Image.network(_imageUrl!, fit: BoxFit.cover)
                              : Image.file(File(_imageUrl!), fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildInput(_nomCompletController, "Nom complet avec titres (ex: Dr. KAVULA MAWAZO, PhD)"),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(flex: 2, child: _buildInput(_fonctionController, "Fonction (ex: Recteur)")),
                        const SizedBox(width: 15),
                        Expanded(flex: 1, child: _buildInput(_categorieController, "Catégorie")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(flex: 3, child: _buildInput(_bioController, "Courte note explicative (Optionnel)")),
              const SizedBox(width: 15),
              Expanded(flex: 1, child: _buildInput(_rangController, "Rang (Ordre d'affichage)", isNumeric: true)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              if (_editingId != null)
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("ANNULER", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                  ),
                ),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    label: Text(
                      _editingId == null ? 'ENREGISTRER LE MEMBRE' : 'METTRE À JOUR LE PROFIL',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0088FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.textMain, fontSize: 13),
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildMembersList(AsyncValue<List<ComiteEntity>> asyncList) {
    return asyncList.when(
      data: (list) {
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
                'Aucun membre du COGE enregistré pour le moment.',
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
            final m = list[index];
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
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text('${m.rang}', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
                title: Text(
                  m.nomComplet,
                  style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  m.fonction,
                  style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.primaryBlue, size: 20),
                      onPressed: () {
                        setState(() {
                          _editingId = m.id;
                          _nomCompletController.text = m.nomComplet;
                          _fonctionController.text = m.fonction;
                          _categorieController.text = m.categorie;
                          _bioController.text = m.bio;
                          _rangController.text = m.rang.toString();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmDelete(m.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.redAccent)),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le membre ?"),
        content: const Text("Voulez-vous vraiment retirer ce membre du comité de gestion ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(infoRepositoryProvider).deleteCommitteeMember(id);
            },
            child: const Text("SUPPRIMER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
