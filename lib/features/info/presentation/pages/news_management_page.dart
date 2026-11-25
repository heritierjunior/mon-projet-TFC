import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:istm_mahagi/core/constants/app_colors.dart';
import 'package:istm_mahagi/core/utils/responsive.dart';
import 'package:istm_mahagi/features/home/presentation/providers/home_providers.dart';
import '../providers/info_providers.dart';
import '../../../home/domain/entities/news_article.dart';

class NewsManagementPage extends ConsumerStatefulWidget {
  const NewsManagementPage({super.key});

  @override
  ConsumerState<NewsManagementPage> createState() => _NewsManagementPageState();
}

class _NewsManagementPageState extends ConsumerState<NewsManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _editingId;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageUrl = image.path);
    }
  }

  void _save() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le titre de l'article est requis.")),
      );
      return;
    }

    final article = NewsArticle(
      id: _editingId ?? '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      imageUrl: _imageUrl ?? 'default_news.jpg',
      date: DateTime.now(),
    );

    try {
      await ref.read(infoRepositoryProvider).saveNews(article);
      _titleController.clear();
      _contentController.clear();
      _imageUrl = null;
      _editingId = null;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Article publié sur le portail public !"),
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
    final newsAsync = ref.watch(newsStreamProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'CMS : GESTION DES ACTUALITÉS',
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
                _buildForm(isMobile),
                const SizedBox(height: 35),
                const Text(
                  'ARTICLES ET ACTUALITÉS PUBLIÉS',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain, letterSpacing: 1),
                ),
                const SizedBox(height: 15),
                newsAsync.when(
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

  Widget _buildForm(bool isMobile) {
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
              const Icon(Icons.newspaper_rounded, color: AppColors.primaryBlue, size: 24),
              const SizedBox(width: 10),
              Text(
                _editingId == null ? "PUBLIER UNE NOUVELLE ACTUALITÉ" : "MODIFIER L'ARTICLE",
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
                            Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryBlue, size: 30),
                            SizedBox(height: 6),
                            Text('Image', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
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
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Titre de l'article / communiqué",
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
          const SizedBox(height: 18),
          TextField(
            controller: _contentController,
            maxLines: 6,
            style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.5),
            decoration: InputDecoration(
              labelText: "Contenu complet de l'article...",
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
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              label: Text(
                _editingId == null ? 'PUBLIER SUR LE SITE PUBLIC' : 'METTRE À JOUR L\'ARTICLE',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
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

  Widget _buildList(List<NewsArticle> list) {
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
            'Aucune actualité publiée pour le moment.',
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
        final n = list[index];
        final dateStr = DateFormat('dd/MM/yyyy - HH:mm').format(n.date);

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
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: n.imageUrl.startsWith('http')
                  ? Image.network(
                      n.imageUrl,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _newsPlaceholder(),
                    )
                  : _newsPlaceholder(),
            ),
            title: Text(
              n.title,
              style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              dateStr,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.primaryBlue, size: 20),
                  onPressed: () {
                    setState(() {
                      _editingId = n.id;
                      _titleController.text = n.title;
                      _contentController.text = n.content;
                      _imageUrl = n.imageUrl;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () => ref.read(infoRepositoryProvider).deleteNews(n.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _newsPlaceholder() {
    return Container(
      width: 55,
      height: 55,
      color: const Color(0xFF2D3E50),
      child: const Icon(Icons.newspaper, color: Colors.white38, size: 24),
    );
  }
}
