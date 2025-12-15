import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Nhom4_ShopOnline/BTN/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productid': product.id,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromMap(json['Product']),
      quantity: json['quantity'] as int,
    );
  }
}

class CartSnapshot {
  static final supabase = Supabase.instance.client;

  static Future<void> addToCart({
    required String customerId,
    required Product product,
    required int quantity,
  }) async {

      final createdAt = DateTime.now().toIso8601String();
      await supabase.from('Cart').insert({
        'customerid': customerId,
        'productid': product.id,
        'createat': createdAt,
        'quantity': quantity,
      });

  }

  static Future<List<CartItem>> fetchCartItems(String customerId) async {

      final response = await supabase
          .from('Cart')
          .select('productid, quantity, Product(id, title, price, img, content, rate, categoryid, createat)')
          .eq('customerid', customerId);
      return response.map<CartItem>((json) => CartItem.fromJson(json)).toList();
  }

  static Future<void> removeFromCart({
    required String customerId,
    required int productId,
  }) async {

      await supabase
          .from('Cart')
          .delete()
          .match({'customerid': customerId, 'productid': productId});
  }

  static Future<void> updateCartItem({
    required String customerId,
    required int productId,
    required int quantity,
  }) async {

      await supabase
          .from('Cart')
          .update({'quantity': quantity})
          .eq('customerid', customerId)
          .eq('productid', productId);
  }

  static Future<int> getCartItemCount(String customerId) async {
      final List<dynamic> items = await supabase
          .from('Cart')
          .select('quantity')
          .eq('customerid', customerId);

      int totalQuantity = items.fold(0, (sum, item) => sum + (item['quantity'] as int));
      return totalQuantity;
  }

  static Future<Map<String, dynamic>?> getCartItem(
      String customerId, int productId) async {
      final response = await supabase
          .from('Cart')
          .select('*')
          .eq('customerid', customerId)
          .eq('productid', productId)
          .maybeSingle();
      return response;
  }
}