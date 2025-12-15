import 'package:get/get.dart';
import 'package:Nhom4_ShopOnline/BTN/models/order.dart';

class OrderController extends GetxController {
  static OrderController get to => Get.find();
  RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchOrders(String customerId) async {
    try {
      isLoading.value = true;
      final fetchedOrders = await OrderSnapshot.getOrdersWithDetails(customerId);
      orders.assignAll(fetchedOrders);
    } finally {
      isLoading.value = false;
    }
    update(['orders']);
  }

  Future<String> createOrder({
    required String customerId,
    required int totalAmount,
  }) async {
    final orderId = await OrderSnapshot.createOrder(
      customerId: customerId,
      totalAmount: totalAmount,
    );
    await fetchOrders(customerId);
    return orderId;
  }

  Future<void> addOrderDetail({
    required String orderId,
    required int productId,
    required int quantity,
  }) async {
    await OrderSnapshot.addOrderDetail(
      orderId: orderId,
      productId: productId,
      quantity: quantity,
    );
  }

  Future<Map<String, dynamic>?> getOrderDetail(String orderId) async {
    try {
      isLoading.value = true;
      final detail = await OrderSnapshot.getOrderDetail(orderId);
      return detail;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus, String customerId) async {
    await OrderSnapshot.updateOrderStatus(orderId, newStatus);
    await fetchOrders(customerId);
    update(['orders']);
  }
}