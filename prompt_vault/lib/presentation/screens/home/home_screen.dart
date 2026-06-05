import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _buildHeader(context, statsAsync),
            ),
          ),
          // Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: statsAsync.when(
                data: (stats) => _buildStatsRow(stats),
                loading: () => _buildStatsShimmer(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Section: Favorit
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: _buildSectionHeader(
                context,
                '⭐ Prompt Favorit',
                onSeeAll: () {
                  ref.read(promptsProvider.notifier).setFavoritesOnly(true);
                  context.go('/prompts');
                },
              ),
            ),
          ),
          // Favorites horizontal scroll
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: promptsAsync.when(
                data: (prompts) {
                  final favs = prompts.where((p) => p.isFavorite).toList();
                  if (favs.isEmpty) {
                    return _buildEmptyFavorites(context);
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: favs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => SizedBox(
                      width: 260,
                      child: PromptCard(
                        prompt: favs[i],
                        onToggleFavorite: () => ref
                            .read(promptsProvider.notifier)
                            .toggleFavorite(favs[i].id, favs[i].isFavorite),
                        showTilt: true,
                      ),
                    ),
                  );
                },
                loading: () => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => ShimmerBox(
                    width: 260,
                    height: 180,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: AppTextStyles.bodySmall),
                ),
              ),
            ),
          ),
          // Section: Terbaru
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: _buildSectionHeader(
                context,
                '🕐 Prompt Terbaru',
                onSeeAll: () => context.go('/prompts'),
              ),
            ),
          ),
          // Recent prompts grid
          promptsAsync.when(
            data: (prompts) {
              final recent = prompts.take(6).toList();
              if (recent.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyPrompts(context),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PromptCard(
                        prompt: recent[i],
                        onToggleFavorite: () => ref
                            .read(promptsProvider.notifier)
                            .toggleFavorite(
                                recent[i].id, recent[i].isFavorite),
                        showTilt: false,
                      ),
                    ),
                    childCount: recent.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 160,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  childCount: 3,
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                  child: Text('Gagal memuat: $e',
                      style: AppTextStyles.bodyMedium)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<Map<String, int>> stats) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? '🌅 Selamat Pagi!'
        : hour < 17
            ? '☀️ Selamat Siang!'
            : hour < 20
                ? '🌇 Selamat Sore!'
                : '🌙 Selamat Malam!';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text(
                  'PromptVault',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Search shortcut
        GestureDetector(
          onTap: () => context.go('/prompts'),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.card,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return Row(
      children: [
        _StatChip(
          icon: '⚡',
          label: 'Total Prompt',
          value: '${stats['total_prompts'] ?? 0}',
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: '⭐',
          label: 'Favorit',
          value: '${stats['favorites'] ?? 0}',
          color: AppColors.secondary,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: '📂',
          label: 'Kategori',
          value: '${stats['categories'] ?? 0}',
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildStatsShimmer() {
    return Row(
      children: List.generate(
          3,
          (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 72,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.headingSmall),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'Lihat Semua',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              'Belum ada favorit',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPrompts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Vault Kamu Masih Kosong',
              style: AppTextStyles.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai tambahkan prompt engineering\npertama kamu!',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GlowButton(
              label: 'Tambah Prompt',
              icon: Icons.add_rounded,
              onPressed: () => context.push('/prompt/create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: color,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.captionText.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
