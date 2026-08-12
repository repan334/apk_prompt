import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/category_icon_helper.dart';
import '../../../data/models/prompt_model.dart';
import '../../providers/prompt_providers.dart';
import '../animations/premium_widgets.dart';
import '../prompt/quick_rename_dialog.dart';

class PromptCard extends ConsumerStatefulWidget {
  final PromptModel prompt;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDelete;
  final bool showTilt;

  const PromptCard({
    super.key,
    required this.prompt,
    this.onToggleFavorite,
    this.onDelete,
    this.showTilt = true,
  });

  @override
  ConsumerState<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends ConsumerState<PromptCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _copyPrompt() async {
    await Clipboard.setData(ClipboardData(text: widget.prompt.content));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
    if (mounted) context.showSnackBar('Prompt copied to clipboard!');
  }

  Future<void> _handleQuickRename() async {
    final newTitle = await QuickRenameDialog.show(context, widget.prompt.title);
    if (newTitle != null && newTitle.trim().isNotEmpty && newTitle != widget.prompt.title) {
      final success = await ref
          .read(promptsProvider.notifier)
          .renamePrompt(widget.prompt.id, newTitle.trim());
      if (mounted) {
        if (success) {
          context.showSnackBar('Judul prompt berhasil diubah!');
        } else {
          context.showSnackBar('Gagal mengubah nama prompt', isError: true);
        }
      }
    }
  }

  void _showCategoryPickerSheet() {
    final categoriesAsync = ref.read(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return categoriesAsync.when(
          data: (categories) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.borderOf(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Ubah Kategori Prompt',
                      style: AppTextStyles.headingSmallOf(context)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _CategoryPickerOption(
                          iconData: Iconsax.global,
                          name: 'Tanpa Kategori',
                          color: AppColors.textSecondaryOf(context),
                          isSelected: widget.prompt.categoryId == null ||
                              widget.prompt.categoryId!.isEmpty,
                          onTap: () async {
                            Navigator.pop(context);
                            await ref
                                .read(promptsProvider.notifier)
                                .updatePromptCategory(widget.prompt.id, null);
                            if (mounted) {
                              context.showSnackBar('Kategori berhasil diperbarui');
                            }
                          },
                        ),
                        ...categories.map((cat) => _CategoryPickerOption(
                              iconData: cat.iconsaxIcon,
                              name: cat.name,
                              color: cat.color,
                              isSelected: widget.prompt.categoryId == cat.id,
                              onTap: () async {
                                Navigator.pop(context);
                                await ref
                                    .read(promptsProvider.notifier)
                                    .updatePromptCategory(widget.prompt.id, cat);
                                if (mounted) {
                                  context.showSnackBar('Kategori diubah ke ${cat.name}');
                                }
                              },
                            )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Gagal memuat kategori: $e'),
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Prompt?', style: AppTextStyles.headingSmallOf(context)),
        content: Text(
          'Prompt "${widget.prompt.title}" akan dihapus permanen dari vault.',
          style: AppTextStyles.bodyMediumOf(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Batal', style: AppTextStyles.labelLargeOf(context).copyWith(color: AppColors.textSecondaryOf(context))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (widget.onDelete != null) {
                widget.onDelete!();
              } else {
                final success = await ref
                    .read(promptsProvider.notifier)
                    .deletePrompt(widget.prompt.id);
                if (mounted) {
                  if (success) {
                    context.showSnackBar('Prompt berhasil dihapus', isError: true);
                  } else {
                    context.showSnackBar('Gagal menghapus prompt', isError: true);
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catIcon = CategoryIconHelper.getIcon(
        widget.prompt.categoryIcon ?? widget.prompt.categoryName);
    final pastelBg = CategoryIconHelper.getPastelColor(
        widget.prompt.categoryName, isDark: isDark);

    final isLightBg = pastelBg.computeLuminance() > 0.45;

    final primaryTextColor = isLightBg ? const Color(0xFF12131A) : Colors.white;
    final secondaryTextColor = isLightBg
        ? const Color(0xFF374151)
        : Colors.white.withValues(alpha: 0.85);
    final mutedTextColor = isLightBg
        ? const Color(0xFF6B7280)
        : Colors.white.withValues(alpha: 0.65);

    final badgeBg = isLightBg
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF1E202E);
    final badgeIconColor = isLightBg ? const Color(0xFF12131A) : Colors.white;

    final heartBg = isLightBg
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.25);
    final heartInactiveColor = isLightBg
        ? const Color(0xFF6B7280)
        : Colors.white.withValues(alpha: 0.7);

    final scorePillBg = isLightBg
        ? Colors.black.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.15);

    final copyBtnBg = _copied
        ? const Color(0xFF10B981)
        : (isLightBg
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.15));
    final copyIconColor = _copied
        ? Colors.white
        : (isLightBg ? const Color(0xFF12131A) : Colors.white);

    final card = GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) {
        _hoverController.reverse();
        context.push('/prompt/${widget.prompt.id}');
      },
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          final scale = 1.0 - (_hoverController.value * 0.02);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: pastelBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isDark ? const Color(0xFF2E3248) : Colors.white,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Category Icon Badge + Favorite & Actions Menu
                Row(
                  children: [
                    // Circular Abstract Icon Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        catIcon,
                        size: 20,
                        color: badgeIconColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.prompt.categoryName ?? 'General',
                            style: AppTextStyles.labelMediumOf(context).copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: primaryTextColor,
                            ),
                          ),
                          Text(
                            widget.prompt.updatedAt.relativeTime,
                            style: AppTextStyles.bodySmallOf(context).copyWith(
                              fontSize: 10,
                              color: mutedTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Favorite Toggle Button
                    GestureDetector(
                      onTap: widget.onToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: heartBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.prompt.isFavorite
                              ? Iconsax.heart5
                              : Iconsax.heart,
                          size: 18,
                          color: widget.prompt.isFavorite
                              ? const Color(0xFFEF4444)
                              : heartInactiveColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 3-Dots Quick Actions Menu
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: heartBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: heartInactiveColor,
                        ),
                      ),
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'rename':
                            _handleQuickRename();
                            break;
                          case 'category':
                            _showCategoryPickerSheet();
                            break;
                          case 'edit':
                            context.push('/prompt/edit/${widget.prompt.id}');
                            break;
                          case 'delete':
                            _confirmDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Iconsax.edit, size: 16, color: primaryTextColor),
                              const SizedBox(width: 10),
                              Text('Ubah Nama', style: AppTextStyles.bodyMediumOf(context)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'category',
                          child: Row(
                            children: [
                              Icon(Iconsax.folder, size: 16, color: primaryTextColor),
                              const SizedBox(width: 10),
                              Text('Ubah Kategori', style: AppTextStyles.bodyMediumOf(context)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_note_rounded, size: 18, color: primaryTextColor),
                              const SizedBox(width: 10),
                              Text('Edit Lengkap', style: AppTextStyles.bodyMediumOf(context)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                              const SizedBox(width: 10),
                              Text('Hapus Prompt', style: AppTextStyles.bodyMediumOf(context).copyWith(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Prompt Title
                Text(
                  widget.prompt.title,
                  style: AppTextStyles.headingMediumOf(context).copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Content Preview
                Text(
                  widget.prompt.previewContent,
                  style: AppTextStyles.bodyMediumOf(context).copyWith(
                    fontSize: 12,
                    height: 1.5,
                    color: secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Footer Row with Pill Tags (Usage Count + Score + Copy Button)
                Row(
                  children: [
                    // Usage Count Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.prompt.usageCount > 0 ? widget.prompt.usageCount : 1}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Iconsax.document_copy,
                            size: 13,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quality Score Pill if available
                    if (widget.prompt.displayScore > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: scorePillBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.star1,
                              size: 12,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.prompt.displayScore}',
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Copy Action Button
                    GestureDetector(
                      onTap: _copyPrompt,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: copyBtnBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _copied ? Iconsax.tick_circle : Iconsax.copy,
                          size: 16,
                          color: copyIconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.showTilt) {
      return TiltCard(child: card);
    }
    return card;
  }
}

class _CategoryPickerOption extends StatelessWidget {
  final IconData iconData;
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPickerOption({
    required this.iconData,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.4)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(iconData, size: 16, color: color),
            const SizedBox(width: 10),
            Text(name, style: AppTextStyles.bodyMediumOf(context)),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
