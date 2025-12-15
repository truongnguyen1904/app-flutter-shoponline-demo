import 'package:supabase_flutter/supabase_flutter.dart';

class Category {
  final int id;
  final String title;

  Category({required this.id, required this.title});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    title: json['title'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
  };
}

class CategorySnapshot {
  static final supabase = Supabase.instance.client;

  static Future<Map<int, Category>> getCategoryMap() async {
      final response = await supabase.from('Category').select();
      print('Dữ liệu danh mục từ Supabase: $response');
      return {for (var e in response) e['id'] as int: Category.fromJson(e)};
  }

  static Future<List<Category>> getAllCategories() async {
    final response = await supabase.from('Category').select();
    return response.map<Category>((e) => Category.fromJson(e)).toList();
  }

  static void listenChangeData(
      Map<int, Category> map, {
        required Function() updateUI,
      }) {
    supabase
        .from('Category')
        .stream(primaryKey: ['id'])
        .order('id')
        .listen((event) {
      for (var row in event) {
        final c = Category.fromJson(row);
        map[c.id] = c;
      }
      updateUI();
    });
  }
}