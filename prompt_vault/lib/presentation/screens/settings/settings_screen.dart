import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/prompt_providers.dart';
import '../../widgets/animations/premium_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text('⚙️ Setelan', style: AppTextStyles.headingLarge),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  GlassCard(
                    glowing: true,
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('⚡', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConfig.appName,
                                style: AppTextStyles.headingMedium,
                              ),
                              Text(
                                'Personal Prompt Manager',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.success.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '● Terhubung ke Supabase',
                                  style: AppTextStyles.captionText.copyWith(
                                    color: AppColors.success,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Text('📊 Statistik', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  statsAsync.when(
                    data: (stats) => Column(
                      children: [
                        _StatRow(
                            icon: '⚡',
                            label: 'Total Prompt',
                            value: '${stats['total_prompts'] ?? 0}'),
                        _StatRow(
                            icon: '⭐',
                            label: 'Prompt Favorit',
                            value: '${stats['favorites'] ?? 0}'),
                        _StatRow(
                            icon: '📂',
                            label: 'Kategori Aktif',
                            value: '${stats['categories'] ?? 0}'),
                      ],
                    ),
                    loading: () => Column(
                      children: List.generate(
                          3,
                          (_) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ShimmerBox(
                                  width: double.infinity,
                                  height: 52,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              )),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // About
                  Text('ℹ️ Tentang Aplikasi', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      children: [
                        _InfoRow(label: 'Versi', value: AppConfig.appVersion),
                        const Divider(color: AppColors.border, height: 16),
                        _InfoRow(label: 'Framework', value: 'Flutter 3.x'),
                        const Divider(color: AppColors.border, height: 16),
                        _InfoRow(label: 'Database', value: 'Supabase (PostgreSQL)'),
                        const Divider(color: AppColors.border, height: 16),
                        _InfoRow(label: 'State Management', value: 'Riverpod 2.x'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sync button
                  SizedBox(
                    width: double.infinity,
                    child: GlowButton(
                      label: 'Sync Data Sekarang',
                      icon: Icons.sync_rounded,
                      isOutlined: true,
                      onPressed: () {
                        ref.invalidate(promptsProvider);
                        ref.invalidate(categoriesProvider);
                        ref.invalidate(statsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🔄 Data berhasil di-sync!'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}
