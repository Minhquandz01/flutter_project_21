import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

class MoMoController {
  static const String partnerCode = "MOMO";
  static const String accessKey = "F8BBA842ECF85";
  static const String secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";

  static const String momoEndpoint = "https://test-payment.momo.vn/v2/gateway/api/create";

  Future<void> createTestPayment(int realAmount, String orderTitle) async {
    // 1. Bỏ ép cứng 50k, sử dụng thẳng số tiền thật của đơn hàng
    // Đảm bảo tiếng Việt KHÔNG DẤU để chống lỗi chữ ký
    String safeOrderInfo = "Thanh toan don hang Honda";

    String orderId = "HONDA_${DateTime.now().millisecondsSinceEpoch}";
    String requestId = orderId;
    String redirectUrl = "https://momo.vn";
    String ipnUrl = "https://momo.vn";

    String requestType = "payWithATM";
    String extraData = "";

    // 2. Gắn biến realAmount vào chuỗi tạo chữ ký
    String rawSignature = "accessKey=$accessKey&amount=$realAmount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$safeOrderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType";

    // 3. Mã hóa bằng HMAC_SHA256
    var bytes = utf8.encode(rawSignature);
    var hmacSha256 = Hmac(sha256, utf8.encode(secretKey));
    var digest = hmacSha256.convert(bytes);
    String signature = digest.toString();

    // 4. JSON gửi đi (Sử dụng realAmount)
    Map<String, dynamic> requestBody = {
      "partnerCode": partnerCode,
      "partnerName": "Honda Showroom",
      "storeId": "HondaStore",
      "requestId": requestId,
      "amount": realAmount, // Đã đổi thành số tiền thật
      "orderId": orderId,
      "orderInfo": safeOrderInfo,
      "redirectUrl": redirectUrl,
      "ipnUrl": ipnUrl,
      "lang": "vi",
      "requestType": requestType,
      "autoCapture": true,
      "extraData": extraData,
      "signature": signature,
    };

    try {
      final response = await http.post(
        Uri.parse(momoEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['resultCode'] == 0) {
          String payUrl = data['payUrl'];
          if (await canLaunchUrl(Uri.parse(payUrl))) {
            await launchUrl(Uri.parse(payUrl), mode: LaunchMode.externalApplication);
          } else {
            throw "Lỗi: Không thể mở trình duyệt điện thoại.";
          }
        } else {
          throw "Lỗi MoMo từ chối: ${data['message']}";
        }
      } else {
        var errorData = jsonDecode(response.body);
        throw "Lỗi MoMo 400: ${errorData['message'] ?? 'Dữ liệu không hợp lệ'}";
      }
    } catch (e) {
      throw Exception("$e");
    }
  }
}