import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/cart_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/screen_auth_user.dart';
import 'package:Nhom4_ShopOnline/BTN/cart_screen.dart';

import 'models/cart.dart';

class CartIconButton extends StatelessWidget {
  final String? customerId;

  const CartIconButton({Key? key, this.customerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      id: 'cart',
      builder: (_) => FutureBuilder<int>(
        future: customerId != null && customerId!.isNotEmpty
            ? CartSnapshot.getCartItemCount(customerId!)
            : Future.value(0),
        builder: (context, snapshot) {
          final itemCount = snapshot.data ?? 0;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  print('CartIconButton pressed, customerId: $customerId');
                  if (customerId != null && customerId!.isNotEmpty) {
                    Get.to(CartScreen(customerId: customerId!));
                  } else {
                    Get.to(PageLogin()
                    );
                  }
                },
              ),
              if (itemCount > 0)
                Positioned(
                  right: 3,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}