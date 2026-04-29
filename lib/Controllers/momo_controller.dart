import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

class MoMoController {
  // Bộ key bạn vừa cung cấp
  static const String partnerCode = "MOMO";
  static const String accessKey = "F8BBA842ECF85";
  static const String secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";

  static const String momoEndpoint = "https://test-payment.momo.vn/v2/gateway/api/create";
  static const String momoQueryEndpoint = "https://test-payment.momo.vn/v2/gateway/api/query";

  // 1. HÀM TẠO GIAO DỊCH VÀ MỞ TRÌNH DUYỆT MOMO
  Future<void> createTestPayment(int realAmount, String orderTitle, String momoOrderId) async {
    String safeOrderInfo = "Thanh toan don hang Honda";
    String requestId = momoOrderId;
    String redirectUrl = "https://momo.vn";
    String ipnUrl = "https://momo.vn";
    String requestType = "payWithATM";
    String extraData = "";

    // Nối chuỗi để tạo chữ ký (Tuyệt đối không đổi thứ tự)
    String rawSignature = "accessKey=$accessKey&amount=$realAmount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$momoOrderId&orderInfo=$safeOrderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType";

    // Mã hóa bảo mật HMAC_SHA256
    var bytes = utf8.encode(rawSignature);
    var hmacSha256 = Hmac(sha256, utf8.encode(secretKey));
    String signature = hmacSha256.convert(bytes).toString();

    // Body JSON gửi đi
    Map<String, dynamic> requestBody = {
      "partnerCode": partnerCode,
      "partnerName": "Honda Showroom",
      "storeId": "HondaStore",
      "requestId": requestId,
      "amount": realAmount,
      "orderId": momoOrderId,
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
          body: jsonEncode(requestBody)
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['resultCode'] == 0) {
          if (await canLaunchUrl(Uri.parse(data['payUrl']))) {
            await launchUrl(Uri.parse(data['payUrl']), mode: LaunchMode.externalApplication);
          } else {
            throw "Không thể mở trình duyệt điện thoại.";
          }
        } else {
          throw "MoMo từ chối: ${data['message']}";
        }
      } else {
        throw "Lỗi Server MoMo: ${response.statusCode}";
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw "Lỗi CORS: Trình duyệt chặn yêu cầu trực tiếp tới MoMo. Hãy chạy ứng dụng ở chế độ Mobile hoặc dùng Backend proxy.";
      }
      throw Exception("Lỗi kết nối MoMo: $e");
    }
  }

  // 2. HÀM KIỂM TRA TRẠNG THÁI GIAO DỊCH THỰC TẾ
  Future<bool> checkPaymentStatus(String momoOrderId) async {
    String requestId = momoOrderId;
    // Cấu trúc chữ ký riêng cho API Query (Kiểm tra)
    String rawSignature = "accessKey=$accessKey&orderId=$momoOrderId&partnerCode=$partnerCode&requestId=$requestId";

    var bytes = utf8.encode(rawSignature);
    var hmacSha256 = Hmac(sha256, utf8.encode(secretKey));
    String signature = hmacSha256.convert(bytes).toString();

    Map<String, dynamic> requestBody = {
      "partnerCode": partnerCode,
      "requestId": requestId,
      "orderId": momoOrderId,
      "signature": signature,
      "lang": "vi"
    };

    try {
      final response = await http.post(
          Uri.parse(momoQueryEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody)
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // resultCode == 0 nghĩa là khách đã chuyển tiền thành công
        if (data['resultCode'] == 0) {
          return true;
        }
      }
      // Nếu là thẻ khoá, thẻ không đủ tiền, hủy giao dịch... đều sẽ bị bắt và trả về false
      return false;
    } catch (e) {
      return false;
    }
  }
}
