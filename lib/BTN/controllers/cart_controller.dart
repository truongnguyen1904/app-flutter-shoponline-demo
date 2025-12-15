import 'package:get/get.dart';
import 'package:Nhom4_ShopOnline/BTN/models/cart.dart';
import 'package:Nhom4_ShopOnline/BTN/models/product.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var selectedItems = <int, bool>{}.obs;

  int get cartItemCount => cartItems.length;

  int get totalAmount => cartItems
      .asMap()
      .entries
      .where((entry) => selectedItems[entry.key] ?? false)
      .fold(0, (sum, entry) => sum + entry.value.product.price * entry.value.quantity);

  static CartController get to => Get.find();

  Future<void> fetchCartItems(String customerId) async {
    final items = await CartSnapshot.fetchCartItems(customerId);
    cartItems.assignAll(items);
    selectedItems.assignAll({for (var i = 0; i < items.length; i++) i: false});
    update(['cart']);
  }

  Future<void> addToCart({
    required String customerId,
    required Product product,
    required int quantity,
  }) async {
    final existingItemIndex = cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingItemIndex != -1) {
      final newQuantity = cartItems[existingItemIndex].quantity + quantity;
      await CartSnapshot.updateCartItem(
        customerId: customerId,
        productId: product.id,
        quantity: newQuantity,
      );
      cartItems[existingItemIndex].quantity = newQuantity;
    } else {
      await CartSnapshot.addToCart(
        customerId: customerId,
        product: product,
        quantity: quantity,
      );
      cartItems.add(CartItem(product: product, quantity: quantity));
    }
    update(['cart']);
  }

  Future<void> removeFromCart({
    required String customerId,
    required int productId,
  }) async {
    await CartSnapshot.removeFromCart(customerId: customerId, productId: productId);
    cartItems.removeWhere((item) => item.product.id == productId);
    selectedItems.removeWhere((key, value) => cartItems.asMap().containsKey(key) == false);
    update(['cart']);
  }

  Future<void> updateCartItem({
    required String customerId,
    required int productId,
    required int quantity,
  }) async {
    if (quantity < 1) return;
    await CartSnapshot.updateCartItem(
      customerId: customerId,
      productId: productId,
      quantity: quantity,
    );
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      cartItems[index].quantity = quantity;
      update(['cart']);
    }
  }

  void toggleSelection(int index, bool value) {
    selectedItems[index] = value;
    update(['cart']);
  }

  @override
  void onReady() {
    super.onReady();
    update(['cart']);
  }
}

// Binding
class CartBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartController());
  }
}