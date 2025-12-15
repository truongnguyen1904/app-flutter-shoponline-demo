import 'package:Nhom4_ShopOnline/BTN/models/product.dart';

class OrderDetail {
  final int quantity;
  final int price;
  final Product product;

  OrderDetail({
    required this.quantity,
    required this.price,
    required this.product,
  });

  int get total => quantity * price;

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      quantity: json['quantity'],
      price: json['price'],
      product: Product.fromMap(json['Product']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'price': price,
      'product': product.toMap(),
    };
  }
}
