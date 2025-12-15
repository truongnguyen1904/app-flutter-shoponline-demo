import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'customer_screen.dart';

AuthResponse? response;
final supabase = Supabase.instance.client;

class PageLogin extends StatelessWidget {
  PageLogin({super.key});

  final box = GetStorage();

  void saveId(String customerId) {
    box.write('id', customerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đăng nhập"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shopping_cart, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "Chào mừng bạn đến với ứng dụng Shop Online!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SupaEmailAuth(
                onSignInComplete: (respons) async {
                  response = respons;
                  final uuid = respons.user?.id;

                  if (uuid == null) {
                    print("Không lấy được uuid");
                    return;
                  }

                  saveId(uuid);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đăng nhập thành công!"),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  final checkCustomer = await supabase
                      .from('Customer')
                      .select('id')
                      .eq('id', uuid)
                      .maybeSingle();

                  if (checkCustomer == null) {
                    final result = await Get.to(() => CustomerScreen(userId: uuid));
                    if (result == true) {
                      Get.back(result: true);
                    }
                  } else {
                    Get.back(result: true);
                  }
                },
                onSignUpComplete: (response) {
                  if (response.user != null) {
                    Get.to(() => PageVerifyOTP(email: response.user!.email!));
                  }
                },
                showConfirmPasswordField: true,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class PageVerifyOTP extends StatelessWidget {
  final String email;

  PageVerifyOTP({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Xác thực mã OTP"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Nhập mã OTP đã gửi về email của bạn",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            OtpTextField(
              numberOfFields: 6,
              borderColor: Colors.deepPurple,
              showFieldAsBox: true,
              onCodeChanged: (String code) {},
              onSubmit: (String verificationCode) async {
                response = await Supabase.instance.client.auth.verifyOTP(
                  email: email,
                  token: verificationCode,
                  type: OtpType.email,
                );

                if (response?.session != null && response?.user != null) {
                  Get.offAll(() => PageLogin());
                }
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đang gửi lại mã OTP..."), duration: Duration(seconds: 1)),
                );
                await supabase.auth.signInWithOtp(email: email);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Mã OTP đã được gửi lại vào $email")),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text("Gửi lại mã OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
