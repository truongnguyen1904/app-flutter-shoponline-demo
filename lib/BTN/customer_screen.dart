import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Nhom4_ShopOnline/BTN/controllers/customer_controller.dart';
import 'package:Nhom4_ShopOnline/BTN/home_screen.dart';

import 'controllers/home_controller.dart';

class CustomerScreen extends StatelessWidget {
  final String userId;
  const CustomerScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerController>();
    final _formKey = GlobalKey<FormState>();
    RxBool isEditMode = false.obs;
    Rx<File?> imageFile = Rx<File?>(null);
    RxString imageUrl = ''.obs;
    RxString firstname = ''.obs;
    RxString lastname = ''.obs;
    RxString phone = ''.obs;
    RxString address = ''.obs;
    RxString email = ''.obs;
    Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);

    return Obx(() {
      if (controller.isLoading.value && controller.customer.value == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.customer.value != null && !isEditMode.value) {
        firstname.value = controller.customer.value!.firstname ?? '';
        lastname.value = controller.customer.value!.lastname ?? '';
        phone.value = controller.customer.value!.phone ?? '';
        address.value = controller.customer.value!.address ?? '';
        email.value = controller.customer.value!.email ?? '';
        imageUrl.value = controller.customer.value!.img ?? '';
        dateOfBirth.value = controller.customer.value!.dateOfBirth;
      } else {
        isEditMode.value = true;
      }

      Future<void> pickImage() async {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          imageFile.value = File(pickedFile.path);
        }
      }

      Future<void> saveCustomer() async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          if (dateOfBirth.value == null) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Vui lòng chọn ngày sinh')),
            );
            return;
          }
          String uploadUrl = imageUrl.value;
          if (imageFile.value != null) {
            uploadUrl = await controller.uploadImage(imageFile.value!, userId);
          }
          try {
            await controller.updateCustomer(
              userId: userId,
              firstname: firstname.value,
              lastname: lastname.value,
              phone: phone.value,
              address: address.value,
              email: email.value,
              img: uploadUrl,
              dateOfBirth: dateOfBirth.value,
            );
            await controller.fetchCustomer(userId);
            final homeController = Get.find<HomeController>();
            homeController.customerName.value =
            ' ${lastname.value}';
            homeController.customerAvatar.value = imageUrl.value;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thông tin thành công!')),
            );
            Get.off(() => HomeScreen());
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi cập nhật: $e')),
            );
          }
        }
      }

      Widget buildTextField(String label, RxString value, Function(String?) onSave, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            initialValue: value.value,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: keyboardType,
            onSaved: onSave,
            validator: validator ?? (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập $label' : null,
          ),
        );
      }

      Widget buildDatePicker() {
        return Row(
          children: [
            const Icon(Icons.cake, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateOfBirth.value != null
                    ? 'Ngày sinh: ${dateOfBirth.value!.day}/${dateOfBirth.value!.month}/${dateOfBirth.value!.year}'
                    : 'Chưa chọn ngày sinh',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: dateOfBirth.value ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  dateOfBirth.value = selectedDate;
                }
              },
              child: const Text('Chọn', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      }

      Widget buildEditForm() {
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: imageFile.value != null
                        ? FileImage(imageFile.value!)
                        : (imageUrl.value.isNotEmpty ? NetworkImage(imageUrl.value) : null),
                    child: (imageFile.value == null && imageUrl.value.isEmpty)
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                        : null,
                    backgroundColor: Colors.teal[300],
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField(
                  "Họ",
                  firstname,
                      (value) => firstname.value = value!,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập họ';
                    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(val)) {
                      return 'Họ chỉ được chứa chữ cái và dấu cách';
                    }
                    return null;
                  },
                ),
                buildTextField(
                  "Tên",
                  lastname,
                      (value) => lastname.value = value!,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập tên';
                    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(val)) {
                      return 'Tên chỉ được chứa chữ cái và dấu cách';
                    }
                    return null;
                  },
                ),
                buildTextField(
                  "Số điện thoại",
                  phone,
                      (value) => phone.value = value!,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập số điện thoại';
                    if (!RegExp(r'^(?:\+84|0)[35789][0-9]{8}$').hasMatch(val)) {
                      return 'Số điện thoại không hợp lệ ';
                    }
                    return null;
                  },
                ),
                buildTextField(
                  "Địa chỉ",
                  address,
                      (value) => address.value = value!,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập địa chỉ';
                    if (val.length < 5) return 'Địa chỉ phải có ít nhất 5 ký tự';
                    return null;
                  },
                ),
                buildTextField(
                  "Email",
                  email,
                      (value) => email.value = value!,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập email';
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(val)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                buildDatePicker(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: saveCustomer,
                    icon: const Icon(Icons.save),
                    label: const Text("Lưu thông tin"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      Widget buildProfileRow(String label, String value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                flex: 3,
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      }

      Widget buildViewProfile() {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 70,
                backgroundImage: imageUrl.value.isNotEmpty ? NetworkImage(imageUrl.value) : null,
                child: imageUrl.value.isEmpty
                    ? const Icon(Icons.account_circle, size: 70, color: Colors.white70)
                    : null,
                backgroundColor: Colors.teal[300],
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      buildProfileRow("Họ", firstname.value),
                      buildProfileRow("Tên", lastname.value),
                      buildProfileRow("Số điện thoại", phone.value),
                      buildProfileRow("Địa chỉ", address.value),
                      buildProfileRow("Email", email.value),
                      buildProfileRow(
                        "Ngày sinh",
                        dateOfBirth.value != null
                            ? '${dateOfBirth.value!.day}/${dateOfBirth.value!.month}/${dateOfBirth.value!.year}'
                            : '',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => isEditMode.value = true,
                  icon: const Icon(Icons.edit),
                  label: const Text("Chỉnh sửa"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text("Hồ sơ khách hàng"),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: isEditMode.value ? buildEditForm() : buildViewProfile(),
        ),
      );
    });
  }
}