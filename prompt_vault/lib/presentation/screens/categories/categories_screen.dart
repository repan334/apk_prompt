import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/prompt_providers.dart';
import '../../widgets/animations/premium_widgets.dart';


class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Text('📂 Kategori', style: AppTextStyles.headingLarge),
                  const Spacer(),
                ],
              ),
            ),
          ),
          categoriesAsync.when(
            data: (categories) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final cat = categories[i];
                    final catColor = cat.color;
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(promptsProvider.notifier)
                            .setCategory(cat.id);
                        context.go('/prompts');
                      },
                      child: TiltCard(
                        maxTilt: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                catColor.withValues(alpha: 0.15),
                                catColor.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: catColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat.icon,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.name,
                                      style: AppTextStyles.headingSmall
                                          .copyWith(color: catColor),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${cat.promptCount ?? 0} prompt',
                                      style:
                                          AppTextStyles.captionText,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
              ),
            ),
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => ShimmerBox(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  childCount: 6,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
