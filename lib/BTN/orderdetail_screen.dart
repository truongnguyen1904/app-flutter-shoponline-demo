import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/order_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/models/orderdetail.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

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

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng #$orderId'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: orderController.getOrderDetail(orderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data!;
          final details = (order['OrdersDetail'] as List<dynamic>)
              .map((detail) => OrderDetail.fromJson(detail))
              .toList();
          final status = order['status'] as String? ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trạng thái đơn hàng
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: _getStatusColor(status)),
                        const SizedBox(width: 10),
                        Text(
                          'Trạng thái: $status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Thông tin đơn hàng
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin đơn hàng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const Divider(height: 20, thickness: 1),
                        _buildInfoRow(
                          label: 'Mã đơn hàng:',
                          value: order['id'].toString(),
                        ),
                        _buildInfoRow(
                          label: 'Ngày tạo:',
                          value: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order['orderdate'])),
                        ),
                      ],
                    ),
                  ),
                ),
                 SizedBox(height: 20),

                // Thông tin khách hàng
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin khách hàng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const Divider(height: 20, thickness: 1),

                        _buildInfoRow(
                          label: 'Số điện thoại:',
                          value: order['phone'] ?? '-',
                        ),
                        _buildInfoRow(
                          label: 'Email:',
                          value: order['email'] ?? '-',
                        ),
                        _buildInfoRow(
                          label: 'Địa chỉ giao hàng:',
                          value: order['shippingaddress'] ?? '-',
                        ),
                        _buildInfoRow(
                          label: 'Phí vận chuyển: ',
                          value: 'Miễn phí' ?? '-',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Danh sách sản phẩm
                const Text(
                  'Sản phẩm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                ...details.map((detail) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          detail.product.img,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                      title: Text(
                        detail.product.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mã sản phẩm: ${detail.product.id}'),
                          Text('Số lượng: ${detail.quantity}'),
                          Text(
                            'Đơn giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(detail.price)}',
                          ),
                          Text(
                            'Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(detail.total)}',
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),
                const Divider(thickness: 1),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(order['total'] ?? 0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Nút xác nhận/hủy đơn
                if (status != 'Đã nhận hàng' && status != 'Đã hủy')
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return ElevatedButton.icon(
                            onPressed: orderController.isLoading.value
                                ? null
                                : () async {
                              try {
                                await orderController.updateOrderStatus(
                                  orderId,
                                  'Đã nhận hàng',
                                  order['customerid'] as String,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Xác nhận đơn hàng thành công!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi xác nhận đơn hàng: $e')),
                                );
                              }
                            },
                            icon: orderController.isLoading.value
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              orderController.isLoading.value ? 'Đang xử lý' : 'Xác nhận đã nhận',
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          return ElevatedButton.icon(
                            onPressed: orderController.isLoading.value
                                ? null
                                : () async {
                              try {
                                await orderController.updateOrderStatus(
                                  orderId,
                                  'Đã hủy',
                                  order['customerid'] as String,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đơn hàng đã được hủy!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi khi hủy đơn: $e')),
                                );
                              }
                            },
                            icon: orderController.isLoading.value
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.cancel_outlined),
                            label: Text(
                              orderController.isLoading.value ? 'Đang xử lý' : 'Hủy đơn hàng',
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
