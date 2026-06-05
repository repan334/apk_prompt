import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/prompts/all_prompts_screen.dart';
import '../../presentation/screens/create_edit/create_edit_screen.dart';
import '../../presentation/screens/detail/prompt_detail_screen.dart';
import '../../presentation/screens/categories/categories_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/home/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _buildFadeTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/prompts',
          pageBuilder: (context, state) => _buildFadeTransitionPage(
            key: state.pageKey,
            child: const AllPromptsScreen(),
          ),
        ),
        GoRoute(
          path: '/categories',
          pageBuilder: (context, state) => _buildFadeTransitionPage(
            key: state.pageKey,
            child: const CategoriesScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _buildFadeTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/prompt/create',
      pageBuilder: (context, state) => _buildSlideTransitionPage(
        key: state.pageKey,
        child: const CreateEditScreen(),
      ),
    ),
    GoRoute(
      path: '/prompt/edit/:id',
      pageBuilder: (context, state) {
        final promptId = state.pathParameters['id']!;
        return _buildSlideTransitionPage(
          key: state.pageKey,
          child: CreateEditScreen(promptId: promptId),
        );
      },
    ),
    GoRoute(
      path: '/prompt/:id',
      pageBuilder: (context, state) {
        final promptId = state.pathParameters['id']!;
        return _buildSlideTransitionPage(
          key: state.pageKey,
          child: PromptDetailScreen(promptId: promptId),
        );
      },
    ),
  ],
);

CustomTransitionPage<T> _buildFadeTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

CustomTransitionPage<T> _buildSlideTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: Curves.easeOutCubic),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
