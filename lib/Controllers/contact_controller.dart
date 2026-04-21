import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/contact_model.dart';

class ContactController extends ChangeNotifier {
  bool isLoading = false;
  String message = '';

  // 1. Chức năng gọi điện thoại
  Future<void> callPhone(String phoneNumber) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // 2. Chức năng gửi Email
  Future<void> sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // 3. Mở bản đồ
  Future<void> openMap() async {
    final Uri uri = Uri.parse("https://maps.google.com/?q=21.0285,105.8566");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // 4. Gửi Liên hệ lên Firebase
  Future<void> submitForm(ContactRequest request) async {
    // Kiểm tra dữ liệu đầu vào
    if (request.name.isEmpty || request.email.isEmpty || request.message.isEmpty) {
      message = "Vui lòng điền đầy đủ Tên, Email và Nội dung!";
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners(); // Bật vòng xoay loading trên nút bấm

    try {
      // Đẩy thẳng lên bảng 'contacts' trong Firestore
      await FirebaseFirestore.instance.collection('contacts').add(request.toMap());
      message = "success";
    } catch (e) {
      message = "Lỗi khi gửi: $e";
    }

    isLoading = false;
    notifyListeners(); // Tắt vòng xoay loading
  }

  void resetMessage() {
    message = '';
    notifyListeners();
  }
}