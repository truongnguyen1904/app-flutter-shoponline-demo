import 'package:get/get.dart';
import 'package:Nhom4_ShopOnline/BTN/models/product.dart';

class ControllerProduct extends GetxController {
  var _map = <int, Product>{};
  var cartItems = <CartItem>[];

  int get cartItemCount => cartItems.length;

  Iterable<Product> get products => _map.values;

  static ControllerProduct get() => Get.find();

  Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    var map = await ProductSnapshot.getProductMap();
    return map.values.where((p) => p.categoryId == categoryId).toList();
  }

  Future<List<Product>> fetchProductsByCategoryWithSort(int categoryId, String sortType) async {
    return await ProductSnapshot.getProductsByCategoryWithSort(categoryId, sortType);
  }

  Future<List<Product>> searchProducts(int categoryId, String searchTerm) async {
    return await ProductSnapshot.searchProducts(categoryId, searchTerm);
  }

  @override
  void onReady() async {
    super.onReady();
    update(["products"]);

    ProductSnapshot.listenChangeData(
      _map,
      updateUI: () => update(["products"]),
    );
  }

  @override
  void onClose() async {
    super.onClose();
    _map = await ProductSnapshot.getProductMap();
  }

  // Thêm vào giỏ hàng
  addToCart(Product p) {
    for (var item in cartItems) {
      if (item.product.id == p.id) {
        item.quantity++;
        update(['cart']);
        return;
      }
    }
    cartItems.add(CartItem(product: p, quantity: 1));
    update(['cart']);
  }
}

// Binding
class BindingsAppProductStore extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ControllerProduct());
  }
}

// Cart Item model
class CartItem {
  Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}