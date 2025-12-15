import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/cart_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/models/cart.dart';
import 'package:Nhom4_ShopOnline/BTN/models/product.dart';
import 'package:Nhom4_ShopOnline/BTN/cart_screen.dart';
import 'package:Nhom4_ShopOnline/BTN/screen_auth_user.dart';
import 'package:get/get.dart';

import 'cart_icon_button.dart';

class ProductScreen extends StatefulWidget {
  final Product product;

  const ProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _quantityController = TextEditingController(text: '1');
  int get quantity => int.tryParse(_quantityController.text) ?? 1;
  String? customerId;

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    final box = GetStorage();
    final uuid = box.read('id');
    setState(() {
      customerId = uuid;
    });
  }

  void _updateQuantity(int newValue) {
    if (newValue < 1) newValue = 1;
    if (newValue > 10) newValue = 10;
    setState(() {
      _quantityController.text = newValue.toString();
    });
  }

  Future<void> addToCart() async {
    if (customerId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PageLogin()),
      );
      return;
    }
    final controller = CartController.to;
    await controller.addToCart(
      customerId: customerId!,
      product: widget.product,
      quantity: quantity,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${widget.product.title} vào giỏ hàng!')),
    );
  }

  String formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.img,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RatingBarIndicator(
              rating: product.rate,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 18.0,
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(product.price),
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mô tả:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(product.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Số lượng:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _updateQuantity(quantity - 1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 2,
                    decoration: InputDecoration(
                      counterText: '',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) {
                      final valInt = int.tryParse(val);
                      if (valInt == null || valInt < 1 || valInt > 10) {
                        _updateQuantity(1);
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _updateQuantity(quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addToCart,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Thêm vào giỏ hàng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
      // Trong product_screen.dart
      floatingActionButton: FloatingActionButton(
        backgroundColor: customerId != null ? Colors.orange: Colors.white,
        onPressed: () {
        },
        child:   customerId != null
            ? CartIconButton(customerId: customerId)
            : const SizedBox.shrink()
        ,
      ),

    );
  }
}