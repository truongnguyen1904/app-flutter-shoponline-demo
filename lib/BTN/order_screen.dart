import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/order_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/orderdetail_screen.dart';

class OrderScreen extends StatefulWidget {
  final String customerId;
  const OrderScreen({super.key, required this.customerId});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().fetchOrders(widget.customerId);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã nhận hàng':
        return Colors.green;
      case 'Đang xử lý':
        return Colors.orange;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của bạn'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
      ),
      body: GetBuilder<OrderController>(
        id: 'orders',
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.orders.isEmpty) {
            return Center(
              child: Text(
                'Chưa có đơn hàng nào',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              final details = order['OrdersDetail'] as List<dynamic>;
              final status = order['status'] as String? ?? '';
              final productCount = details.length;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'Mã đơn: ${order['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order['orderdate']))}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Số sản phẩm: $productCount',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  trailing: Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(order['total'] ?? 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(orderId: order['id'].toString()),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}