import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/prompt_model.dart';
import '../../../data/models/category_model.dart';
import '../../providers/prompt_providers.dart';
import '../../widgets/animations/premium_widgets.dart';

class CreateEditScreen extends ConsumerStatefulWidget {
  final String? promptId;
  const CreateEditScreen({super.key, this.promptId});

  @override
  ConsumerState<CreateEditScreen> createState() => _CreateEditScreenState();
}

class _CreateEditScreenState extends ConsumerState<CreateEditScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _useCaseController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();

  CategoryModel? _selectedCategory;
  List<String> _tags = [];
  bool _isFavorite = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  bool get isEditing => widget.promptId != null;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _useCaseController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _initFromPrompt(PromptModel prompt, List<CategoryModel> categories) {
    if (_isInitialized) return;
    _titleController.text = prompt.title;
    _contentController.text = prompt.content;
    _useCaseController.text = prompt.useCase ?? '';
    _notesController.text = prompt.notes ?? '';
    _tags = List.from(prompt.tags);
    _isFavorite = prompt.isFavorite;
    if (prompt.categoryId != null) {
      _selectedCategory = categories.firstWhere(
        (c) => c.id == prompt.categoryId,
        orElse: () => categories.first,
      );
    }
    _isInitialized = true;
  }

  void _addTag(String tag) {
    final cleaned = tag.trim().replaceAll('#', '').toLowerCase();
    if (cleaned.isNotEmpty && !_tags.contains(cleaned)) {
      setState(() => _tags.add(cleaned));
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _savePrompt() async {
    if (_titleController.text.trim().isEmpty) {
      context.showSnackBar('⚠️ Judul prompt tidak boleh kosong', isError: true);
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      context.showSnackBar('⚠️ Isi prompt tidak boleh kosong', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final prompt = PromptModel(
      id: widget.promptId ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      categoryId: _selectedCategory?.id,
      categoryName: _selectedCategory?.name,
      categoryIcon: _selectedCategory?.icon,
      categoryColor: _selectedCategory?.colorHex,
      useCase: _useCaseController.text.trim().isEmpty
          ? null
          : _useCaseController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      tags: _tags,
      isFavorite: _isFavorite,
      usageCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    bool success;
    if (isEditing) {
      success = await ref
          .read(promptsProvider.notifier)
          .updatePrompt(widget.promptId!, prompt);
    } else {
      success = await ref.read(promptsProvider.notifier).createPrompt(prompt);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        context.showSnackBar(
            isEditing ? '✅ Prompt berhasil diperbarui!' : '✅ Prompt baru ditambahkan!');
        context.pop();
      } else {
        context.showSnackBar('❌ Gagal menyimpan prompt', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final promptAsync = isEditing
        ? ref.watch(singlePromptProvider(widget.promptId!))
        : null;

    // Initialize form if editing
    if (isEditing && promptAsync != null) {
      promptAsync.whenData((prompt) {
        if (prompt != null) {
          categoriesAsync.whenData(
              (cats) => _initFromPrompt(prompt, cats));
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.card,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? '✏️ Edit Prompt' : '✨ Prompt Baru',
                        style: AppTextStyles.headingMedium,
                      ),
                    ),
                    // Favorite toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _isFavorite = !_isFavorite),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _isFavorite
                              ? AppColors.secondary.withValues(alpha: 0.15)
                              : AppColors.card,
                          border: Border.all(
                            color: _isFavorite
                                ? AppColors.secondary.withValues(alpha: 0.4)
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: _isFavorite
                              ? AppColors.secondary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _FormSection(
                        label: '📌 Judul Prompt',
                        child: TextField(
                          controller: _titleController,
                          style: AppTextStyles.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Analisis Kompetitor Bisnis',
                            hintStyle: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category picker
                      _FormSection(
                        label: '📂 Kategori',
                        child: categoriesAsync.when(
                          data: (cats) => _CategoryPicker(
                            categories: cats,
                            selected: _selectedCategory,
                            onSelected: (c) =>
                                setState(() => _selectedCategory = c),
                          ),
                          loading: () => ShimmerBox(
                            width: double.infinity,
                            height: 44,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          error: (_, __) => const Text('Gagal memuat kategori'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Use Case
                      _FormSection(
                        label: '🎯 Kegunaan / Target Tugas',
                        child: TextField(
                          controller: _useCaseController,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText:
                                'Contoh: Untuk analisis kompetitor sebelum memulai bisnis baru',
                            hintStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted),
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prompt Content
                      _FormSection(
                        label: '⚡ Isi Prompt',
                        child: TextField(
                          controller: _contentController,
                          style: AppTextStyles.promptText,
                          decoration: InputDecoration(
                            hintText:
                                'Tulis prompt kamu di sini...\n\nContoh: Kamu adalah seorang analis bisnis senior...',
                            hintStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 10,
                          minLines: 5,
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      _FormSection(
                        label: '🏷️ Tags',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tags list
                            if (_tags.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _tags.map((tag) {
                                  return Chip(
                                    label: Text('#$tag',
                                        style:
                                            AppTextStyles.captionText.copyWith(
                                      color: AppColors.primary,
                                    )),
                                    backgroundColor:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    side: BorderSide(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3)),
                                    deleteIcon: Icon(Icons.close_rounded,
                                        size: 14,
                                        color: AppColors.primary),
                                    onDeleted: () => _removeTag(tag),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                            ],
                            // Tag input
                            TextField(
                              controller: _tagController,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'Tambah tag lalu tekan Enter...',
                                hintStyle: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                                prefixText: '# ',
                                prefixStyle: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.primary),
                              ),
                              onSubmitted: _addTag,
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      _FormSection(
                        label: '📝 Catatan (Opsional)',
                        child: TextField(
                          controller: _notesController,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText:
                                'Tips penggunaan, konteks, atau hal yang perlu diingat...',
                            hintStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted),
                          ),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: GlowButton(
                          label: isEditing
                              ? 'Simpan Perubahan'
                              : 'Simpan ke Vault ⚡',
                          icon: isEditing
                              ? Icons.save_rounded
                              : Icons.check_rounded,
                          isLoading: _isLoading,
                          onPressed: _savePrompt,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selected;
  final ValueChanged<CategoryModel?> onSelected;

  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              Text(selected!.icon,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(selected!.name, style: AppTextStyles.bodyMedium),
            ] else
              Text('Pilih kategori...',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Kategori', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            // No category option
            _CategoryOption(
              icon: '🌐',
              name: 'Tanpa Kategori',
              color: AppColors.textMuted,
              isSelected: selected == null,
              onTap: () {
                onSelected(null);
                Navigator.pop(context);
              },
            ),
            ...categories.map((cat) => _CategoryOption(
                  icon: cat.icon,
                  name: cat.name,
                  color: cat.color,
                  isSelected: selected?.id == cat.id,
                  onTap: () {
                    onSelected(cat);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final String icon;
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.icon,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.4) : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(name, style: AppTextStyles.bodyMedium),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
