import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/prompt_providers.dart';
import '../../widgets/cards/prompt_card.dart';
import '../../widgets/animations/premium_widgets.dart';
import '../../../data/models/category_model.dart';

class AllPromptsScreen extends ConsumerStatefulWidget {
  const AllPromptsScreen({super.key});

  @override
  ConsumerState<AllPromptsScreen> createState() => _AllPromptsScreenState();
}

class _AllPromptsScreenState extends ConsumerState<AllPromptsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promptsAsync = ref.watch(promptsProvider);
    final notifier = ref.read(promptsProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '⚡ Semua Prompt',
                    style: AppTextStyles.headingLarge,
                  ),
                ),
                // Sort button
                _SortButton(
                  onSortChanged: (sort) => notifier.setSortBy(sort),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _AnimatedSearchBar(
              controller: _searchController,
              onChanged: (q) => notifier.setSearch(q),
              onFocusChanged: (_) {},
            ),
          ),
          const SizedBox(height: 16),
          // Category filter chips
          categoriesAsync.when(
            data: (cats) => _CategoryFilter(
              categories: cats,
              selectedId: notifier.selectedCategoryId,
              onSelected: (id) => notifier.setCategory(id),
            ),
            loading: () => const SizedBox(height: 44),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          // Prompts list
          Expanded(
            child: promptsAsync.when(
              data: (prompts) {
                if (prompts.isEmpty) {
                  return _buildEmpty(context);
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                  onRefresh: () => notifier.refresh(),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: prompts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => PromptCard(
                      prompt: prompts[i],
                      onToggleFavorite: () => ref
                          .read(promptsProvider.notifier)
                          .toggleFavorite(
                              prompts[i].id, prompts[i].isFavorite),
                      showTilt: false,
                    ),
                  ),
                );
              },
              loading: () => ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => ShimmerBox(
                  width: double.infinity,
                  height: 160,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('❌', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat prompt\n$e',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GlowButton(
                      label: 'Coba Lagi',
                      onPressed: () => notifier.refresh(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.accent.withValues(alpha: 0.1)
                  ],
                ),
              ),
              child: const Center(
                  child: Text('🔍', style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak ada prompt ditemukan',
              style: AppTextStyles.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah filter atau kata kunci pencarian',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlowButton(
              label: 'Tambah Prompt Baru',
              icon: Icons.add_rounded,
              onPressed: () => context.push('/prompt/create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool> onFocusChanged;

  const _AnimatedSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFocusChanged,
  });

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
      widget.onFocusChanged(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? AppColors.primary : AppColors.border,
          width: _focused ? 1.5 : 1.0,
        ),
        color: AppColors.card,
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Cari prompt, tag, atau isi...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          suffixIcon: widget.controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 18),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final all = [
      const CategoryModel(
          id: '', name: 'Semua', icon: '🌐', colorHex: '#6C63FF'),
      ...categories,
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = all[i];
          final isSelected = cat.id == selectedId;
          final color = cat.color;
          return GestureDetector(
            onTap: () => onSelected(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:
                    isSelected ? color.withValues(alpha: 0.15) : AppColors.card,
                border: Border.all(
                  color:
                      isSelected ? color.withValues(alpha: 0.5) : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    cat.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? color : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final ValueChanged<String> onSortChanged;

  const _SortButton({required this.onSortChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.card,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => _SortSheet(onSortChanged: onSortChanged),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded,
                color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 4),
            Text('Urutkan',
                style: AppTextStyles.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final ValueChanged<String> onSortChanged;

  const _SortSheet({required this.onSortChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('updated_at', '🕐 Terbaru Diubah'),
      ('created_at', '📅 Terbaru Dibuat'),
      ('title', '🔤 Nama A-Z'),
      ('usage_count', '🔥 Paling Sering Dipakai'),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Urutkan Prompt', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          ...options.map((opt) => GestureDetector(
                onTap: () {
                  onSortChanged(opt.$1);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(opt.$2, style: AppTextStyles.bodyMedium),
                ),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
