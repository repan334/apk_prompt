import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prompt_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/supabase_service.dart';

// ─── PROMPTS REPOSITORY ────────────────────────────────────────────────────

class PromptsNotifier extends AsyncNotifier<List<PromptModel>> {
  String _searchQuery = '';
  String _selectedCategoryId = '';
  bool _favoritesOnly = false;
  String _sortBy = 'updated_at';

  @override
  Future<List<PromptModel>> build() async {
    return _fetchPrompts();
  }

  Future<List<PromptModel>> _fetchPrompts() {
    return SupabaseService.instance.getAllPrompts(
      categoryId: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
      favoritesOnly: _favoritesOnly ? true : null,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      sortBy: _sortBy,
    );
  }

  void setSearch(String query) {
    _searchQuery = query;
    ref.invalidateSelf();
  }

  void setCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    ref.invalidateSelf();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    ref.invalidateSelf();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<bool> createPrompt(PromptModel prompt) async {
    try {
      await SupabaseService.instance.createPrompt(prompt);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePrompt(String id, PromptModel prompt) async {
    try {
      await SupabaseService.instance.updatePrompt(id, prompt);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePrompt(String id) async {
    try {
      await SupabaseService.instance.deletePrompt(id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleFavorite(String id, bool currentValue) async {
    await SupabaseService.instance.toggleFavorite(id, !currentValue);
    ref.invalidateSelf();
  }

  Future<void> incrementUsage(String id) async {
    try {
      await SupabaseService.instance.incrementUsageCount(id);
    } catch (_) {}
  }

  // Getters
  String get searchQuery => _searchQuery;
  String get selectedCategoryId => _selectedCategoryId;
  bool get favoritesOnly => _favoritesOnly;
}

final promptsProvider =
    AsyncNotifierProvider<PromptsNotifier, List<PromptModel>>(
  PromptsNotifier.new,
);

// ─── SINGLE PROMPT ────────────────────────────────────────────────────────

final singlePromptProvider =
    FutureProvider.family<PromptModel?, String>((ref, id) async {
  return SupabaseService.instance.getPromptById(id);
});

// ─── CATEGORIES ───────────────────────────────────────────────────────────

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    return SupabaseService.instance.getAllCategories();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<bool> createCategory(CategoryModel category) async {
    try {
      await SupabaseService.instance.createCategory(category);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await SupabaseService.instance.deleteCategory(id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

// ─── STATS ────────────────────────────────────────────────────────────────

final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  return SupabaseService.instance.getStats();
});

// ─── SEARCH QUERY STATE ───────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => '');
final showFavoritesProvider = StateProvider<bool>((ref) => false);
