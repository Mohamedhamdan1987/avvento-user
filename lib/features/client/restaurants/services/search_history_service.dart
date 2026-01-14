import 'package:hive_flutter/hive_flutter.dart';

class SearchHistoryService {
  static const String _boxNamePrefix = 'restaurant_search_history_';

  static Future<void> addToHistory(String restaurantId, String query) async {
    if (query.trim().isEmpty) return;
    
    final boxName = '$_boxNamePrefix$restaurantId';
    final box = await Hive.openBox<String>(boxName);
    
    // Remove if exists and add to top (re-insert)
    final list = box.values.toList();
    if (list.contains(query)) {
      list.remove(query);
    }
    list.insert(0, query);
    
    // Keep only last 10 searches
    if (list.length > 10) {
      list.removeLast();
    }
    
    await box.clear();
    await box.addAll(list);
  }

  static Future<List<String>> getSearchHistory(String restaurantId) async {
    final boxName = '$_boxNamePrefix$restaurantId';
    final box = await Hive.openBox<String>(boxName);
    return box.values.toList(); // index 0 is newest due to addToHistory logic
  }

  static Future<void> clearHistory(String restaurantId) async {
    final boxName = '$_boxNamePrefix$restaurantId';
    final box = await Hive.openBox<String>(boxName);
    await box.clear();
  }

  static Future<void> removeFromHistory(String restaurantId, String query) async {
    final boxName = '$_boxNamePrefix$restaurantId';
    final box = await Hive.openBox<String>(boxName);
    final index = box.values.toList().indexOf(query);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }
}
