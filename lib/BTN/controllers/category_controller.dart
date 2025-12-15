import 'package:get/get.dart';
import 'package:Nhom4_ShopOnline/BTN/models/category.dart';

class CategoryController extends GetxController {
  var _map = <int, Category>{};

  Iterable<Category> get categories => _map.values;

  static CategoryController get() => Get.find();

  Future<List<Category>> fetchAllCategories() async {
    var map = await CategorySnapshot.getCategoryMap();
    return map.values.toList();
  }

  @override
  void onReady() async {
    super.onReady();
    update(["categories"]);

    CategorySnapshot.listenChangeData(
      _map,
      updateUI: () => update(["categories"]),
    );
  }

  @override
  void onClose() async {
    super.onClose();
    _map = await CategorySnapshot.getCategoryMap();
  }
}

// Binding
class BindingsAppCategoryStore extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoryController());
  }
}