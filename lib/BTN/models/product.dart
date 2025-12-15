import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class Product {
  final int id;
  final int categoryId;
  final int price;
  final double rate;
  final String title;
  final String content;
  final String img;
  final String createAt;

  Product({
    required this.id,
    required this.categoryId,
    required this.price,
    required this.rate,
    required this.title,
    required this.content,
    required this.img,
    required this.createAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'content': content,
      'img': img,
      'categoryid': categoryId,
      'rate': rate,
      'createat': createAt,
    };
  }
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      categoryId: map['categoryid'] as int,
      price: map['price'] as int,
      rate: (map['rate'] as num).toDouble(),
      title: map['title'] as String,
      content: map['content'] as String,
      img: map['img'] as String,
      createAt: map['createat'] as String,
    );
  }
}

class ProductSnapshot {
  static final supabase = Supabase.instance.client;

  static Future<Map<int, Product>> getProductMap() async {
      final data = await supabase.from('Product').select();
      print('Dữ liệu từ Supabase: $data');
      return {for (var e in data) e['id'] as int: Product.fromMap(e)};
  }


  static Future<List<Product>> getAllProducts() async {
    final response = await supabase.from('Product').select();
    return response.map<Product>((e) => Product.fromMap(e)).toList();
  }

  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    final response = await supabase
        .from('Product')
        .select()
        .eq('categoryid', categoryId);
    return response.map<Product>((e) => Product.fromMap(e)).toList();
  }



  static Future<List<Product>> searchProducts(
      int categoryId, String searchTerm) async {
    final response = await supabase
        .from('Product')
        .select()
        .eq('categoryid', categoryId)
        .ilike('title', '%$searchTerm%');
    return response.map<Product>((e) => Product.fromMap(e)).toList();
  }

  static Future<List<Product>> getProductsByCategoryWithSort(
      int categoryId, String sortType) async {
    PostgrestTransformBuilder<PostgrestList> query = supabase.from('Product').select().eq('categoryid', categoryId);

    switch (sortType) {
      case 'Giá thấp đến cao':
        query = query.order('price', ascending: true);
        break;
      case 'Giá cao đến thấp':
        query = query.order('price', ascending: false);
        break;
      case 'Đánh giá cao nhất':
        query = query.order('rate', ascending: false);
        break;
      case 'Mới nhất':
        query = query.order('createat', ascending: false);
        break;
      default:
        query = query.order('id', ascending: true);
    }

    final response = await query;
    return response.map((json) => Product.fromMap(json)).toList();
  }

  static Future<Product?> getProductById(int productId) async {
    final response = await supabase
        .from('Product')
        .select()
        .eq('id', productId)
        .maybeSingle();

    if (response != null) {
      return Product.fromMap(response);
    }
    return null;
  }
  static void listenChangeData(
      Map<int, Product> map, {
        required Function() updateUI,
      }) {
    supabase
        .from('Product')
        .stream(primaryKey: ['id'])
        .order('id')
        .listen((event) {
      for (var row in event) {
        final p = Product.fromMap(row);
        map[p.id] = p;
      }
      updateUI();
    });
  }
}