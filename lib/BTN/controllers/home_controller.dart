import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/customer_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/product_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/cart_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/category_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/order_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/models/category.dart';
import 'package:Nhom4_ShopOnline/BTN/product_screen.dart';
import 'package:Nhom4_ShopOnline/BTN/screen_auth_user.dart';
import 'package:Nhom4_ShopOnline/BTN/category_screen.dart';

class HomeController extends GetxController {
  final productController = Get.find<ControllerProduct>();
  final categoryController = Get.find<CategoryController>();
  final cartController = Get.find<CartController>();
  final orderController = Get.find<OrderController>();
  final customerController = Get.find<CustomerController>();

  final RxString customerId = RxString('');
  final RxString customerName = RxString('');
  final RxString customerAvatar = RxString('');
  final RxString searchQuery = RxString('');
  final RxList<Category> categories = RxList<Category>([]);
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() async{
    super.onInit();
    await loadCustomerId();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      categories.value = await categoryController.fetchAllCategories();
      if (customerId.value.isNotEmpty) {
        await cartController.fetchCartItems(customerId.value);
        await orderController.fetchOrders(customerId.value);
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> refreshCustomerData() async {
    print('Refreshing customer data...');
    if (customerId.value.isNotEmpty) {
      try {
        await customerController.fetchCustomer(customerId.value);
        customerName.value = customerController.customer.value?.lastname ?? 'Khách';
        customerAvatar.value = customerController.customer.value?.img ?? '';
        print('Refreshed customer data: name=${customerName.value}, avatar=${customerAvatar.value}');
        update(); // Trigger rebuild
      } catch (e) {
        print('Error refreshing customer data: $e');
        customerName.value = 'Khách';
        customerAvatar.value = '';
      }
    }
  }

  Future<void> loadCustomerId() async {
    final box = GetStorage();
    String? uuid = box.read('id');
    customerId.value = uuid ?? '';
    isLoggedIn.value = uuid != null;
    if (customerId.value.isNotEmpty) {
      try {
        await Future.wait([
          customerController.fetchCustomer(customerId.value),
          cartController.fetchCartItems(customerId.value),
          orderController.fetchOrders(customerId.value),
        ]);
        customerName.value = customerController.customer.value?.lastname ?? 'Khách';
        customerAvatar.value = customerController.customer.value?.img ?? '';
      } catch (e) {
        print('Lỗi khi tải thông tin khách hàng: $e');
      }
    }
  }

  void signIn() async {
    await loadCustomerId();
    isLoggedIn.value = true;
    if (customerId.value.isNotEmpty) {
      await loadData();
    }
  }

  void signOut() {
    final box = GetStorage();
    box.remove('id');
    customerId.value = '';
    customerName.value = '';
    customerAvatar.value = '';
    isLoggedIn.value = false;
  }

  Widget buildHomeContent(BuildContext context, ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          buildSearchBar(),
          const SizedBox(height: 12),
          buildBanner(),
          const SizedBox(height: 16),
          buildCategorySection(context),
          const SizedBox(height: 16),
          const Text(
            "Các sản phẩm của shop",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
          ),
          const SizedBox(height: 16),
          buildProductsSection(context),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          searchQuery.value = value;
        },
      ),
    );
  }

  Widget buildBanner() {
    return Container(
      height: 150,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 150,
          autoPlay: true,
        ),
        items: [
          buildBannerItem('asset/image/banner.png'),
          buildBannerItem('asset/image/banner2.jpg'),
        ],
      ),
    );
  }

  Widget buildBannerItem(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildCategorySection(BuildContext context) {
    return Obx(() => isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : categories.isEmpty
        ? const Center(child: Text('Không có danh mục sản phẩm'))
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục sản phẩm',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: GetBuilder<CategoryController>(
            id: "categories",
            builder: (controller) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  IconData iconData;
                  switch (cat.title) {
                    case 'Điện tử':
                      iconData = Icons.phone_android;
                      break;
                    case 'Đồ dùng cá nhân':
                      iconData = Icons.accessibility;
                      break;
                    case 'Thời trang':
                      iconData = Icons.checkroom;
                      break;
                    case 'Đồ gia dụng':
                      iconData = Icons.kitchen;
                      break;
                    default:
                      iconData = Icons.category;
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(category: cat),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 21),
                      width: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.orange,
                              child: Icon(
                                iconData,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat.title,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ));
  }

  Widget buildProductsSection(BuildContext context) {
    return GetBuilder<ControllerProduct>(
      id: 'products',
      builder: (controller) {
        var productList = controller.products.toList();
        if (searchQuery.value.isNotEmpty) {
          productList = productList.where((product) {
            return product.title.toLowerCase().contains(searchQuery.value.toLowerCase());
          }).toList();
        }
        if (productList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Không có sản phẩm nào phù hợp với tìm kiếm của bạn.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: productList.length,
          itemBuilder: (context, index) {
            var product = productList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(product: product),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.img,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(product.price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RatingBarIndicator(
                            rating: product.rate,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 16.0,
                            direction: Axis.horizontal,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (customerId.value.isEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageLogin()),
                              );
                            } else {
                              cartController.addToCart(
                                customerId: customerId.value,
                                product: product,
                                quantity: 1,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã thêm ${product.title} vào giỏ hàng!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Thêm vào giỏ'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}