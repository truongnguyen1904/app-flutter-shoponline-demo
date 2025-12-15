import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/cart_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/order_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/models/cart.dart';
import 'package:Nhom4_ShopOnline/BTN/home_screen.dart';

class CartScreen extends StatefulWidget {
  final String customerId;

  const CartScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<CartController>().fetchCartItems(widget.customerId);
  }

  Future<void> _buySelectedItems() async {
    final controller = CartController.to;
    final selectedItems = controller.cartItems
        .asMap()
        .entries
        .where((entry) => controller.selectedItems[entry.key] ?? false)
        .map((entry) => entry.value)
        .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm để mua')),
      );
      return;
    }

    final orderController = Get.find<OrderController>();
    try {
      final orderId = await orderController.createOrder(
        customerId: widget.customerId,
        totalAmount: controller.totalAmount,
      );

      for (var item in selectedItems) {
        await orderController.addOrderDetail(
          orderId: orderId,
          productId: item.product.id,
          quantity: item.quantity,
        );
        await controller.removeFromCart(
          customerId: widget.customerId,
          productId: item.product.id,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hàng thành công!')),
      );
    } catch (e) {
      print('Lỗi khi đặt hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi đặt hàng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
      ),
      body: GetBuilder<CartController>(
        id: 'cart',
        builder: (controller) {
          if (controller.cartItems.isEmpty) {
            return const Center(child: Text('Giỏ hàng trống'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: controller.selectedItems[index] ?? false,
                              onChanged: (value) => controller.toggleSelection(index, value ?? false),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.img,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, color: Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(item.product.price),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => controller.updateCartItem(
                                    customerId: widget.customerId,
                                    productId: item.product.id,
                                    quantity: item.quantity - 1,
                                  ),
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => controller.updateCartItem(
                                    customerId: widget.customerId,
                                    productId: item.product.id,
                                    quantity: item.quantity + 1,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => controller.removeFromCart(
                                customerId: widget.customerId,
                                productId: item.product.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(controller.totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _buySelectedItems,
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text('Mua hàng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}