import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/home_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/screen_auth_user.dart';
import 'package:Nhom4_ShopOnline/BTN/customer_screen.dart';
import 'package:Nhom4_ShopOnline/BTN/cart_screen.dart';
import 'package:Nhom4_ShopOnline/BTN/order_screen.dart';
import 'package:Nhom4_ShopOnline/BTN/support_screen.dart';

import 'cart_icon_button.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  int currentIndex = 0;

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return controller.buildHomeContent(context, widget._scrollController);
      case 1:
        return CustomerScreen(userId: controller.customerId.value);
      case 2:
        return CartScreen(customerId: controller.customerId.value);
      case 3:
        return OrderScreen(customerId: controller.customerId.value);
      case 4:
        return SupportPage();
      default:
        return controller.buildHomeContent(context, widget._scrollController);
    }
  }

  Future<void> handleNavigation(int index) async {
    if ((index == 1 || index == 2 || index == 3) &&
        controller.customerId.value.isEmpty) {
      final result = await Get.to(() => PageLogin());
      if (result == true) {
        controller.signIn();
        setState(() {
          currentIndex = index;
        });
      }
    } else {
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
       Scaffold(
        appBar: currentIndex == 0
            ? AppBar(
          title: const Center(
            child: Text(
              'Shop Online',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.black,
          actions: [
            Obx(() {
              return controller.customerId.value.isNotEmpty
                  ? CartIconButton(customerId: controller.customerId.value)
                  : SizedBox.shrink();
            }),
          ],

        )
            : null,
        drawer: Drawer(
          child: Obx(() => ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(controller.customerId.value.isNotEmpty
                    ? "Xin chào ${controller.customerName.value}"
                    : "Bạn đang truy cập ở chế độ khách"),
                accountEmail: Text(controller.customerId.value.isNotEmpty
                    ? "Chúc bạn có trải nghiệm mua sắm tốt"
                    : "Vui lòng đăng nhập để mua sắm"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: (controller.customerId.value.isNotEmpty &&
                      controller.customerAvatar.value.isNotEmpty)
                      ? NetworkImage(controller.customerAvatar.value)
                      : const AssetImage("asset/image/img.png")
                  as ImageProvider,
                ),
                decoration: const BoxDecoration(color: Colors.orange),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Trang chủ"),
                onTap: () {
                  Navigator.pop(context);
                  handleNavigation(0);
                  widget._scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              if (controller.customerId.value.isEmpty)
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text("Đăng nhập"),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Get.to(() => PageLogin());
                    if (result == true) {
                      controller.signIn();
                      setState(() {
                        currentIndex = 0;
                      });
                    }
                  },
                ),
              if (controller.customerId.value.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Hồ sơ"),
                  onTap: () {
                    Navigator.pop(context);
                    // handleNavigation(1);
                    Get.to(CustomerScreen(userId: controller.customerId.value));
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text("Giỏ hàng"),
                onTap: () {
                  Navigator.pop(context);
                  // handleNavigation(2);
                  Get.to(CartScreen(customerId: controller.customerId.value));

                },
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text("Đơn hàng"),
                onTap: () {
                  Navigator.pop(context);
                  // handleNavigation(3);
                  Get.to(OrderScreen(customerId: controller.customerId.value));

                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Hỗ trợ"),
                onTap: () {
                  Navigator.pop(context);
                  // handleNavigation(4);
                  Get.to(SupportPage());

                },
              ),
              if (controller.customerId.value.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Đăng xuất"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đăng xuất thành công!"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    controller.signOut();
                    setState(() {
                      currentIndex = 0;
                    });
                  },
                ),
              ],
            ],
          )),
        ),
        body: _buildBody(currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            handleNavigation(index);
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Trang chủ"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Hồ sơ"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Giỏ hàng"),
            BottomNavigationBarItem(
                icon: Icon(Icons.payment), label: "Đơn hàng"),
            BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Hỗ trợ'),
          ],
        ),
    );
  }
}
