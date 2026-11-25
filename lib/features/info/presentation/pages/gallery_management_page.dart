import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/home/presentation/providers/home_providers.dart';
import '../providers/info_providers.dart';
import '../../../home/domain/entities/gallery_item.dart';

class GalleryManagementPage extends ConsumerStatefulWidget {
  const GalleryManagementPage({super.key});

  @override
  ConsumerState<GalleryManagementPage> createState() => _GalleryManagementPageState();
}

class _GalleryManagementPageState extends ConsumerState<GalleryManagementPage> {
  final TextEditingController _captionController = TextEditingController();
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageUrl = image.path);
    }
  }

  void _save() async {
    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez d'abord sélectionner une photo.")),
      );
      return;
    }

    final item = GalleryItem(
      id: '',
      imageUrl: _imageUrl!,
      legende: _captionController.text.trim(),
      date: DateTime.now(),
    );

    try {
      await ref.read(infoRepositoryProvider).saveGalleryItem(item);
      _captionController.clear();
      _imageUrl = null;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo ajoutée à la galerie !"), backgroundColor: Colors.green),
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
    final galleryAsync = ref.watch(galleryStreamProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'CMS : GALERIE PHOTOS',
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
                _buildForm(),
                const SizedBox(height: 35),
                const Text(
                  'PHOTOS DE LA GALERIE EN LIGNE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain, letterSpacing: 1),
                ),
                const SizedBox(height: 15),
                galleryAsync.when(
                  data: (list) => _buildGrid(list, isMobile),
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
              Icon(Icons.photo_library_rounded, color: AppColors.primaryBlue, size: 24),
              SizedBox(width: 10),
              Text(
                "AJOUTER UNE PHOTO À LA GALERIE",
                style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
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
                  width: 110,
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
                            Icon(Icons.add_a_photo_rounded, color: AppColors.primaryBlue, size: 30),
                            SizedBox(height: 6),
                            Text('Choisir', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
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
                child: TextField(
                  controller: _captionController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Légende ou description de la photo",
                    hintText: "ex: Cérémonie de rentrée académique sur le campus...",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
              label: const Text(
                'PUBLIER DANS LA GALERIE',
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

  Widget _buildGrid(List<GalleryItem> list, bool isMobile) {
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
            'Aucune photo enregistrée dans la galerie.',
            style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.imageUrl.startsWith('http')
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Text(
                        item.legende.isNotEmpty ? item.legende : 'Galerie ISTM Mahagi',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => ref.read(infoRepositoryProvider).deleteGalleryItem(item.id),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF2D3E50),
      child: const Center(child: Icon(Icons.image_not_supported_rounded, color: Colors.white38, size: 36)),
    );
  }
}
