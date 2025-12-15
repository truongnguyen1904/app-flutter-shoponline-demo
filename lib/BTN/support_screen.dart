import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'controllers/support_controller.dart';
import 'models/orderdetail.dart';

class SupportPage extends StatelessWidget {
    SupportPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Trung tâm hỗ trợ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orange.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 60, color: Colors.white,),
                  SizedBox(height: 16),
                  Text('Chúng tôi luôn sẵn sàng hỗ trợ bạn', style: TextStyle(
                    color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text('Tìm câu trả lời hoặc liên hệ với chúng tôi', style: TextStyle(
                    color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Text('Liên hệ với chúng tôi', style: TextStyle( fontSize: 18,  fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildContactCard(
              context,
              icon: Icons.phone,
              title: 'Hotline',
              subtitle: '19001234 (Miễn phí)',
              description: 'Thời gian: 8:00 - 22:00 hàng ngày',
              color: Colors.green,
              actionType: 'phone',
              contactInfo: '19001234',
            ),
            SizedBox(height: 12),

            _buildContactCard(
              context,
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@ntu.edu.vn',
              description: 'Phản hồi trong vòng 24h',
              color: Colors.blue,
              actionType: 'email',
              contactInfo: 'support@ntu.edu.vn',
            ),
            SizedBox(height: 12),

            _buildContactCard(
              context,
              icon: Icons.message,
              title: 'Nhắn tin SMS',
              subtitle: 'Nhắn tin đến số hỗ trợ',
              description: 'Phản hồi trong 30 phút',
              color: Colors.orange,
              actionType: 'sms',
              contactInfo: '19001234',
            ),

            SizedBox(height: 24),
            Text('Câu hỏi thường gặp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildFAQCard(
              'Làm thế nào để đặt hàng?',
              'Bạn có thể dễ dàng đặt hàng bằng cách chọn sản phẩm, thêm vào giỏ hàng và thanh toán.',
            ),
            _buildFAQCard(
              'Chính sách đổi trả như thế nào?',
              'Bạn có thể đổi trả trong vòng 7 ngày kể từ ngày nhận hàng nếu sản phẩm gặp lỗi.',
            ),
            _buildFAQCard(
              'Thời gian giao hàng bao lâu?',
              'Thời gian giao hàng từ 1-3 ngày làm việc tùy theo khu vực của bạn.',
            ),
            _buildFAQCard(
              'Các phương thức thanh toán được hỗ trợ?',
              'Chúng tôi hỗ trợ thanh toán qua thẻ ATM, Visa/MasterCard, ví điện tử và COD.',
            ),

            SizedBox(height: 24),

            Text('Tính năng hỗ trợ khác',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.history,
                    title: 'Lịch sử\nđơn hàng',
                    color: Colors.indigo,
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetail(),),)
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.account_circle,
                    title: 'Tài khoản\ncủa tôi',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.feedback,
                    title: 'Góp ý\nphản hồi',
                    color: Colors.deepOrange,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('Cần thêm hỗ trợ?', style: TextStyle( fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Đừng ngại liên hệ với chúng tôi qua bất kỳ kênh nào ở trên', style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String description,
        required Color color,
        required String actionType,
        required String contactInfo,
      }) {
    return GestureDetector(
      onTap: () => _showContactDialog(context, actionType, contactInfo, title),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.help_outline, color: Colors.orange),
          title: Text(
            question,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                answer,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({

    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context, String type, String contactInfo, String title) {
    String content;
    IconData icon;

    switch (type) {
      case 'phone':
        content = 'Bạn có muốn gọi đến số hotline $contactInfo?';
        icon = Icons.phone;
        break;
      case 'email':
        content = 'Bạn có muốn gửi email đến $contactInfo?';
        icon = Icons.email;
        break;
      case 'sms':
        content = 'Bạn có muốn gửi tin nhắn đến số $contactInfo?';
        icon = Icons.message;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: Colors.orange),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleContactAction(type, contactInfo);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
  final SupportController _supportController = SupportController();
  Future<void> _handleContactAction(String type, String contactInfo) async {

    try {
      switch (type) {
        case 'phone':
          await _supportController.makePhoneCall(contactInfo);
          break;
        case 'email':
          await _supportController.sendEmail(contactInfo);
          break;
        case 'sms':
          await _supportController.sendSMS(contactInfo);
          break;
      }
    } catch (e) {
      print('Lỗi khi mở ứng dụng: $e');
    }
  }




}