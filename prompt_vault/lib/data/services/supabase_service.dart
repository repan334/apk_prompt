import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prompt_model.dart';
import '../models/category_model.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ─── PROMPTS ─────────────────────────────────────────────────────────────

  Future<List<PromptModel>> getAllPrompts({
    String? categoryId,
    bool? favoritesOnly,
    String? searchQuery,
    String sortBy = 'updated_at',
    bool ascending = false,
  }) async {
    var query = _client
        .from('prompts')
        .select('*, categories(name, icon, color)')
        .order(sortBy, ascending: ascending);

    final response = await query;
    List<PromptModel> prompts = (response as List)
        .map((json) => PromptModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // Client-side filtering
    if (categoryId != null && categoryId.isNotEmpty) {
      prompts = prompts.where((p) => p.categoryId == categoryId).toList();
    }
    if (favoritesOnly == true) {
      prompts = prompts.where((p) => p.isFavorite).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      prompts = prompts.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.content.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q)) ||
            (p.useCase?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return prompts;
  }

  Future<PromptModel?> getPromptById(String id) async {
    final response = await _client
        .from('prompts')
        .select('*, categories(name, icon, color)')
        .eq('id', id)
        .single();
    return PromptModel.fromJson(response);
  }

  Future<PromptModel> createPrompt(PromptModel prompt) async {
    final response = await _client
        .from('prompts')
        .insert(prompt.toInsertJson())
        .select('*, categories(name, icon, color)')
        .single();
    return PromptModel.fromJson(response);
  }

  Future<PromptModel> updatePrompt(String id, PromptModel prompt) async {
    final json = prompt.toJson();
    json['updated_at'] = DateTime.now().toIso8601String();
    final response = await _client
        .from('prompts')
        .update(json)
        .eq('id', id)
        .select('*, categories(name, icon, color)')
        .single();
    return PromptModel.fromJson(response);
  }

  Future<void> deletePrompt(String id) async {
    await _client.from('prompts').delete().eq('id', id);
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await _client.from('prompts').update({
      'is_favorite': isFavorite,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> incrementUsageCount(String id) async {
    await _client.rpc('increment_usage_count', params: {'prompt_id': id});
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getAllCategories() async {
    final response = await _client
        .from('categories')
        .select('*, prompts(count)')
        .order('name');

    return (response as List).map((json) {
      final map = json as Map<String, dynamic>;
      // Extract count from nested prompts
      int count = 0;
      if (map['prompts'] != null) {
        final prompts = map['prompts'] as List;
        count = prompts.length;
      }
      return CategoryModel.fromJson({...map, 'prompt_count': count});
    }).toList();
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    final response = await _client
        .from('categories')
        .insert(category.toJson())
        .select()
        .single();
    return CategoryModel.fromJson(response);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  // ─── STATS ───────────────────────────────────────────────────────────────

  Future<Map<String, int>> getStats() async {
    final prompts = await _client.from('prompts').select('id, is_favorite');
    final total = (prompts as List).length;
    final favorites = prompts.where((p) => p['is_favorite'] == true).length;
    final categories = await _client.from('categories').select('id');
    return {
      'total_prompts': total,
      'favorites': favorites,
      'categories': (categories as List).length,
    };
  }
}
