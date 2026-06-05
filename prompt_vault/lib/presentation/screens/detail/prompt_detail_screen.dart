import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../providers/prompt_providers.dart';

class PromptDetailScreen extends ConsumerStatefulWidget {
  final String promptId;
  const PromptDetailScreen({super.key, required this.promptId});

  @override
  ConsumerState<PromptDetailScreen> createState() =>
      _PromptDetailScreenState();
}

class _PromptDetailScreenState extends ConsumerState<PromptDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _copied = false;
  late AnimationController _copyAnimController;
  late Animation<double> _copyScale;

  @override
  void initState() {
    super.initState();
    _copyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _copyScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
        parent: _copyAnimController, curve: Curves.easeOut));

    // Increment usage count
    Future.microtask(() =>
        ref.read(promptsProvider.notifier).incrementUsage(widget.promptId));
  }

  @override
  void dispose() {
    _copyAnimController.dispose();
    super.dispose();
  }

  void _copyPrompt(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    setState(() => _copied = true);
    _copyAnimController.forward(from: 0);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final promptAsync =
        ref.watch(singlePromptProvider(widget.promptId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          ),
          promptAsync.when(
            data: (prompt) {
              if (prompt == null) {
                return const Center(child: Text('Prompt tidak ditemukan'));
              }
              final catColor =
                  HexColor.fromHex(prompt.categoryColor ?? '#6C63FF');

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // AppBar
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    backgroundColor: AppColors.bg.withValues(alpha: 0.95),
                    leading: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.card,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.textPrimary),
                      ),
                    ),
                    actions: [
                      // Edit
                      GestureDetector(
                        onTap: () =>
                            context.push('/prompt/edit/${prompt.id}'),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primary.withValues(alpha: 0.1),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit_rounded,
                                  size: 14,
                                  color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('Edit',
                                  style: AppTextStyles.captionText.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      // Delete
                      GestureDetector(
                        onTap: () => _showDeleteDialog(context, prompt.id),
                        child: Container(
                          margin: const EdgeInsets.only(
                              right: 16, top: 8, bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.error.withValues(alpha: 0.1),
                            border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.error),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding:
                          const EdgeInsets.fromLTRB(64, 0, 16, 16),
                      title: Text(
                        prompt.title,
                        style: AppTextStyles.headingSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Category + Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Category
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: catColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(prompt.categoryIcon ?? '⚡',
                                      style:
                                          const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 5),
                                  Text(
                                    prompt.categoryName ?? 'Lainnya',
                                    style:
                                        AppTextStyles.labelMedium.copyWith(
                                      color: catColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Tags
                            ...prompt.tags.map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.border),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style:
                                        AppTextStyles.captionText.copyWith(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Metadata row
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 13,
                                color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              prompt.updatedAt.relativeTime,
                              style: AppTextStyles.captionText,
                            ),
                            const SizedBox(width: 12),
                            if (prompt.usageCount > 0) ...[
                              Icon(Icons.bolt_rounded,
                                  size: 13,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Dipakai ${prompt.usageCount}x',
                                style: AppTextStyles.captionText,
                              ),
                            ],
                            const Spacer(),
                            // Favorite toggle
                            GestureDetector(
                              onTap: () => ref
                                  .read(promptsProvider.notifier)
                                  .toggleFavorite(
                                      prompt.id, prompt.isFavorite),
                              child: AnimatedSwitcher(
                                duration:
                                    const Duration(milliseconds: 300),
                                child: Row(
                                  key: ValueKey(prompt.isFavorite),
                                  children: [
                                    Icon(
                                      prompt.isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 16,
                                      color: prompt.isFavorite
                                          ? AppColors.secondary
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      prompt.isFavorite
                                          ? 'Favorit'
                                          : 'Tambah Favorit',
                                      style:
                                          AppTextStyles.captionText.copyWith(
                                        color: prompt.isFavorite
                                            ? AppColors.secondary
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Use Case
                        if (prompt.useCase != null &&
                            prompt.useCase!.isNotEmpty) ...[
                          _InfoSection(
                            icon: '🎯',
                            title: 'Kegunaan',
                            content: prompt.useCase!,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Prompt Content
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.card,
                            border: Border.all(
                              color: catColor.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: catColor.withValues(alpha: 0.08),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.code_rounded,
                                      size: 14,
                                      color: AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ISI PROMPT',
                                    style:
                                        AppTextStyles.captionText.copyWith(
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SelectableText(
                                prompt.content,
                                style: AppTextStyles.promptText,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Notes
                        if (prompt.notes != null &&
                            prompt.notes!.isNotEmpty) ...[
                          _InfoSection(
                            icon: '📝',
                            title: 'Catatan',
                            content: prompt.notes!,
                          ),
                        ],
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),

          // Fixed Copy Button at bottom — rendered via whenData properly
          promptAsync.when(
            data: (prompt) {
              if (prompt == null) return const SizedBox.shrink();
              return Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: ScaleTransition(
                  scale: _copyScale,
                  child: GestureDetector(
                    onTap: () => _copyPrompt(prompt.content),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: _copied
                              ? [
                                  AppColors.success,
                                  AppColors.success.withGreen(200)
                                ]
                              : [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_copied
                                    ? AppColors.success
                                    : AppColors.primary)
                                .withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Row(
                            key: ValueKey(_copied),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _copied
                                    ? Icons.check_circle_rounded
                                    : Icons.copy_all_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _copied
                                    ? 'Prompt Berhasil Disalin! ✨'
                                    : 'Salin Prompt',
                                style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Prompt?', style: AppTextStyles.headingSmall),
        content: Text(
          'Prompt ini akan dihapus permanen dari vault kamu.',
          style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMsg = ScaffoldMessenger.of(context);
              final router = GoRouter.of(context);
              Navigator.pop(context);
              final success = await ref
                  .read(promptsProvider.notifier)
                  .deletePrompt(id);
              if (mounted) {
                if (success) {
                  router.pop();
                  scaffoldMsg.showSnackBar(
                    const SnackBar(
                        content: Text('🗑️ Prompt berhasil dihapus')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String icon;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.captionText.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
