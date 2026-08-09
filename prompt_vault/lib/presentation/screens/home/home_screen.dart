import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/prompt_providers.dart';
import '../../widgets/cards/prompt_card.dart';
import '../../widgets/animations/premium_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(promptsProvider);
    final statsAsync = ref.watch(statsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HEADER BAR ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: _buildHeader(context, ref, isDark),
            ),
          ),

          // ─── 2D ABSTRACT HERO BANNER (Inspired by Reference UI) ──────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: statsAsync.when(
                data: (stats) => _buildAbstractHeroCard(
                    context, stats['total_prompts'] ?? 0, isDark),
                loading: () => ShimmerBox(
                  width: double.infinity,
                  height: 180,
                  borderRadius: BorderRadius.circular(32),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),

          // ─── CATEGORY FILTER PILLS (Organic Squircle) ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildCategoryFilterRow(context, ref, selectedCategory, isDark),
                ],
              ),
            ),
          ),

          // ─── SECTION TITLE: VAULT PROMPTS ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  Text(
                    'My Prompts',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go('/prompts'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkPillBg
                            : const Color(0xFFE8EAF0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'View all',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── PROMPTS GRID / LIST ─────────────────────────────────────────
          promptsAsync.when(
            data: (prompts) {
              if (prompts.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyPromptsState(context, isDark),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PromptCard(
                        prompt: prompts[i],
                        onToggleFavorite: () => ref
                            .read(promptsProvider.notifier)
                            .toggleFavorite(prompts[i].id, prompts[i].isFavorite),
                        showTilt: false,
                      ),
                    ),
                    childCount: prompts.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 160,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  childCount: 3,
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('Failed to load prompts: $e',
                      style: AppTextStyles.bodyMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER WIDGET ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'PromptVault Studio',
              style: AppTextStyles.displayMedium.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ],
        ),
        const Spacer(),
        // Light / Dark Theme Toggle Button
        GestureDetector(
          onTap: () {
            final current = ref.read(themeModeProvider);
            ref.read(themeModeProvider.notifier).state =
                current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E202E) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: isDark ? const Color(0xFF2E3248) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Icon(
              isDark ? Iconsax.sun_1 : Iconsax.moon,
              size: 20,
              color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF18181B),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Search Button
        GestureDetector(
          onTap: () => context.go('/prompts'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E202E) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: isDark ? const Color(0xFF2E3248) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Icon(
              Iconsax.search_normal,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF18181B),
            ),
          ),
        ),
      ],
    );
  }

  // ─── 2D ABSTRACT HERO BANNER ─────────────────────────────────────────────
  Widget _buildAbstractHeroCard(BuildContext context, int totalCount, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E202E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF2E3248) : const Color(0xFFEEF0F5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get your prompts',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Swipe to explore',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Pill Badge (24x style from Reference Image)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.pastelLime : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalCount',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF12131A) : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Vaulted',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF12131A) : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Bar inside Banner Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkLime : const Color(0xFFE2F7C2), // Soft Lime
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF18181B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.flash_15,
                    color: Color(0xFFD6F498),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Prompt Studio',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF12131A),
                        ),
                      ),
                      Text(
                        'Optimize & score your prompts',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/prompt/build'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Build',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORY FILTER ROW ──────────────────────────────────────────────────
  Widget _buildCategoryFilterRow(
      BuildContext context, WidgetRef ref, String selectedId, bool isDark) {
    final categories = [
      {'id': '', 'name': 'All', 'icon': Iconsax.category},
      {'id': 'Coding', 'name': 'Coding', 'icon': Iconsax.code},
      {'id': 'Writing', 'name': 'Writing', 'icon': Iconsax.edit_2},
      {'id': 'Riset', 'name': 'Research', 'icon': Iconsax.search_status},
      {'id': 'Analisis', 'name': 'Analysis', 'icon': Iconsax.chart_21},
      {'id': 'Kreatif', 'name': 'Creative', 'icon': Iconsax.brush_1},
      {'id': 'Bisnis', 'name': 'Business', 'icon': Iconsax.briefcase},
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = selectedId == cat['id'];
          final IconData iconData = cat['icon'] as IconData;

          return GestureDetector(
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state =
                  cat['id'] as String;
              ref
                  .read(promptsProvider.notifier)
                  .setCategory(cat['id'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.pastelLime : const Color(0xFF18181B))
                    : (isDark ? const Color(0xFF1E202E) : Colors.white),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? const Color(0xFF2E3248) : const Color(0xFFE5E7EB)),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.pastelLime
                                  : const Color(0xFF18181B))
                              .withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    iconData,
                    size: 16,
                    color: isSelected
                        ? (isDark ? const Color(0xFF12131A) : Colors.white)
                        : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? const Color(0xFF12131A) : Colors.white)
                          : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
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

  // ─── EMPTY PROMPTS STATE ─────────────────────────────────────────────────
  Widget _buildEmptyPromptsState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E202E) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3248) : const Color(0xFFEEF0F5),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE2D9FF), // Soft Lavender
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.document_text_1,
                size: 32,
                color: Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Vault is Empty',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your first AI prompt now!',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push('/prompt/build'),
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('Create Prompt'),
            ),
          ],
        ),
      ),
    );
  }
}
