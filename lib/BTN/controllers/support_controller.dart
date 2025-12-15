 
import 'package:url_launcher/url_launcher.dart';

class SupportController {
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> sendEmail(String emailAddress) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {
        'subject': 'Hỗ trợ từ ứng dụng Shopping',
        'body': 'Xin chào, tôi cần hỗ trợ về...',
      },
    );
    await launchUrl(emailUri);
  }

  Future<void> sendSMS(String phoneNumber) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {
        'body': 'Xin chào, tôi cần hỗ trợ...',
      },
    );
    await launchUrl(smsUri);
  }
}
