import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/prompt_model.dart';
import '../animations/premium_widgets.dart';

class PromptCard extends StatefulWidget {
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
  State<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<PromptCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnim;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnim =
        Tween<double>(begin: 0, end: 1).animate(_hoverController);
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
    if (mounted) context.showSnackBar('✅ Prompt berhasil disalin!');
  }

  Color get _categoryColor {
    final hex = widget.prompt.categoryColor ?? '#6C63FF';
    return HexColor.fromHex(hex);
  }

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) {
        _hoverController.reverse();
        context.push('/prompt/${widget.prompt.id}');
      },
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _elevationAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F1F35), Color(0xFF14142A)],
              ),
              border: Border.all(
                color: _categoryColor.withValues(alpha: 0.2 + _elevationAnim.value * 0.3),
                width: 1.0 + _elevationAnim.value * 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _categoryColor
                      .withValues(alpha: 0.05 + _elevationAnim.value * 0.15),
                  blurRadius: 12 + _elevationAnim.value * 8,
                  spreadRadius: _elevationAnim.value * 2,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _categoryColor.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.prompt.categoryIcon ?? '⚡',
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.prompt.categoryName ?? 'Lainnya',
                          style: AppTextStyles.captionText.copyWith(
                            color: _categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Favorite button
                  GestureDetector(
                    onTap: widget.onToggleFavorite,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        widget.prompt.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(widget.prompt.isFavorite),
                        size: 18,
                        color: widget.prompt.isFavorite
                            ? AppColors.secondary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                widget.prompt.title,
                style: AppTextStyles.headingSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Preview
              Text(
                widget.prompt.previewContent,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  height: 1.6,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags
              if (widget.prompt.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.prompt.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.border, width: 1),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTextStyles.captionText.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.prompt.updatedAt.relativeTime,
                    style: AppTextStyles.captionText,
                  ),
                  if (widget.prompt.usageCount > 0) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.bolt_rounded,
                        size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.prompt.usageCount}x',
                      style: AppTextStyles.captionText,
                    ),
                  ],
                  const Spacer(),
                  // Copy button
                  GestureDetector(
                    onTap: _copyPrompt,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(_copied),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _copied
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _copied
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _copied
                                  ? Icons.check_rounded
                                  : Icons.copy_rounded,
                              size: 12,
                              color: _copied
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _copied ? 'Tersalin!' : 'Salin',
                              style: AppTextStyles.captionText.copyWith(
                                color: _copied
                                    ? AppColors.success
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
