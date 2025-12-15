import 'package:supabase_flutter/supabase_flutter.dart';

class Order {
  final String id;
  final String customerId;
  final DateTime orderDate;
  final int total;
  final String status;
  final String shippingAddress;
  final String phone;
  final String email;

  Order({
    required this.id,
    required this.customerId,
    required this.orderDate,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.phone,
    required this.email,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      customerId: json['customerid'] as String,
      orderDate: DateTime.parse(json['orderdate']),
      total: json['total'] is int ? json['total'] : int.parse(json['total'].toString()),
      status: json['status'] as String,
      shippingAddress: json['shippingaddress'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerid': customerId,
      'orderdate': orderDate.toIso8601String(),
      'total': total,
      'status': status,
      'shippingaddress': shippingAddress,
      'phone': phone,
      'email': email,
    };
  }
}

class OrderSnapshot {
  static final supabase = Supabase.instance.client;

  static Future<Map<String, String>> fetchCustomerInfo(String customerId) async {
      final response = await supabase
          .from('Customer')
          .select('phone, email, address')
          .eq('id', customerId)
          .single();
      return {
        'phone': response['phone'] ?? '',
        'email': response['email'] ?? '',
        'address': response['address'] ?? '',
      };

  }

  static Future<int> fetchProductPrice(int productId) async {
      final response = await supabase
          .from('Product')
          .select('price')
          .eq('id', productId)
          .single();
      return response['price'] is int
          ? response['price']
          : int.parse(response['price'].toString());
  }

  static Future<String> createOrder({
    required String customerId,
    required int totalAmount,
  }) async {
      final customerInfo = await fetchCustomerInfo(customerId);
      final response = await supabase
          .from('Orders')
          .insert({
        'customerid': customerId,
        'orderdate': DateTime.now().toIso8601String(),
        'total': totalAmount,
        'status': 'Chờ xác nhận',
        'phone': customerInfo['phone'],
        'email': customerInfo['email'],
        'shippingaddress': customerInfo['address'],
      })
          .select('id')
          .single();
      return response['id'].toString();
  }

  static Future<void> addOrderDetail({
    required String orderId,
    required int productId,
    required int quantity,
  }) async {
      final price = await fetchProductPrice(productId);
      await supabase.from('OrdersDetail').insert({
        'orderid': orderId,
        'productid': productId,
        'quantity': quantity,
        'price': price,
      });
  }

  static Future<List<Map<String, dynamic>>> getOrdersWithDetails(String customerId) async {
      final response = await supabase
          .from('Orders')
          .select('*, OrdersDetail!OrdersDetail_orderid_fkey(*, Product!OrdersDetail_productid_fkey(*))')
          .eq('customerid', customerId)
          .order('orderdate', ascending: false);
      return response as List<Map<String, dynamic>>;
  }

  static Future<Map<String, dynamic>?> getOrderDetail(String orderId) async {
      final response = await supabase
          .from('Orders')
          .select('*, OrdersDetail!OrdersDetail_orderid_fkey(*, Product!OrdersDetail_productid_fkey(*))')
          .eq('id', orderId)
          .maybeSingle();
      return response as Map<String, dynamic>?;
  }

  static Future<List<Order>> fetchOrdersByCustomer(String customerId) async {
      final response = await supabase
          .from('Orders')
          .select()
          .eq('customerid', customerId)
          .order('orderdate', ascending: false);
      final dataList = response as List<dynamic>;
      return dataList.map((item) => Order.fromJson(item)).toList();
  }

  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
      await supabase
          .from('Orders')
          .update({'status': newStatus})
          .eq('id', orderId);

  }
}