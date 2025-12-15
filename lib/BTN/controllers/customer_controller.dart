import 'dart:io';

import 'package:get/get.dart';
import 'package:Nhom4_ShopOnline/BTN/models/customer.dart';


class CustomerController extends GetxController {
  static CustomerController get to => Get.find();
  Rx<Customer?> customer = Rx<Customer?>(null);
  RxBool isLoading = false.obs;

  Future<void> fetchCustomer(String userId) async {
    try {
      isLoading.value = true;
      final data = await Customer.getCustomerById(userId);
      if (data != null) {
        customer.value = Customer.fromMap(data);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> uploadImage(File image, String userId) async {
    return await Customer.uploadImage(image, userId);
  }

  Future<void> updateCustomer({
    required String userId,
    required String firstname,
    required String lastname,
    required String phone,
    required String address,
    required String email,
    required String img,
    required DateTime? dateOfBirth,
  }) async {
    await Customer.insertCustomer(
      userId: userId,
      firstname: firstname,
      lastname: lastname,
      phone: phone,
      address: address,
      email: email,
      img: img,
      dateofbirth: dateOfBirth,
    );
    await fetchCustomer(userId);
  }

  Future<String?> fetchCustomerName(String? customerId) async {
    return await Customer.fetchCustomerName(customerId);
  }

  Future<String?> fetchCustomerAvatarUrl(String? customerId) async {
    return await Customer.fetchCustomerAvatarUrl(customerId);
  }
}