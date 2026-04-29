import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Controllers/product_controller.dart';
import '../Controllers/momo_controller.dart'; // Nạp MoMo để kiểm tra
import 'products_view.dart';
import 'order_history_view.dart';
import 'Widgets/custom_header.dart';
import 'Widgets/custom_footer.dart';

class PaymentResultView extends StatefulWidget {
  final String firebaseOrderId;
  final String momoOrderId;
  final List<QueryDocumentSnapshot> items;

  const PaymentResultView({super.key, required this.firebaseOrderId, required this.momoOrderId, required this.items});

  @override
  State<PaymentResultView> createState() => _PaymentResultViewState();
}

class _PaymentResultViewState extends State<PaymentResultView> with WidgetsBindingObserver {
  final ProductController _controller = ProductController();
  final MoMoController _momoController = MoMoController(); // Khởi tạo MoMo
  bool _isProcessing = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isProcessing) {
      _autoConfirmPayment();
    }
  }

  void _autoConfirmPayment() async {
    // Cho App đợi 3 giây để Server MoMo cập nhật tiền bạc xong xuôi
    await Future.delayed(const Duration(seconds: 3));

    try {
      // GỌI HỎI SERVER MOMO: "Khách có thanh toán thật không?"
      bool isPaidReal = await _momoController.checkPaymentStatus(widget.momoOrderId);

      if (isPaidReal) {
        // --- NẾU MO MO BÁO THÀNH CÔNG THẬT ---
        await _controller.updateOrderStatus(widget.firebaseOrderId, 'Đã thanh toán');
        for (var doc in widget.items) {
          String productId = doc['id'];
          int qty = doc['quantity'] ?? 1;
          await _controller.updateProductStock(productId, qty);
        }
        await _controller.clearCart();

        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isSuccess = true;
          });
        }
      } else {
        // --- NẾU THẺ BỊ KHÓA / KHÔNG ĐỦ TIỀN / KHÁCH TẮT NGANG ---
        await _controller.updateOrderStatus(widget.firebaseOrderId, 'Thanh toán thất bại');

        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isSuccess = false; // Nhảy sang màn hình Đỏ
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() { _isProcessing = false; _isSuccess = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: const CustomHeader(activeTab: ''),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                ),
                child: _isProcessing ? _buildProcessingUI() : _buildResultUI(),
              ),
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }

  Widget _buildProcessingUI() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const CircularProgressIndicator(color: Color(0xFFA50064)),
      const SizedBox(height: 25),
      const Text('Hệ thống đang kết nối với MoMo...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text('Không tắt ứng dụng lúc này', style: TextStyle(color: Colors.grey[600])),
    ],
  );

  Widget _buildResultUI() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(_isSuccess ? Icons.check_circle : Icons.cancel, color: _isSuccess ? Colors.green : Colors.red, size: 80),
      const SizedBox(height: 20),
      Text(_isSuccess ? 'THANH TOÁN THÀNH CÔNG' : 'GIAO DỊCH THẤT BẠI',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _isSuccess ? Colors.green : Colors.red)),
      const SizedBox(height: 15),
      Text(_isSuccess
          ? 'Đơn hàng đã được xác nhận tự động. Số lượng kho đã cập nhật.'
          : 'Thẻ của bạn không đủ số dư hoặc giao dịch đã bị hủy ngang.',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[800], fontSize: 15)),
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _isSuccess ? Colors.black : Colors.red, padding: const EdgeInsets.symmetric(vertical: 20)),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _isSuccess ? const OrderHistoryView() : const ProductsView())),
          child: Text(_isSuccess ? 'XEM LỊCH SỬ ĐƠN HÀNG' : 'QUAY LẠI MUA SẮM', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      )
    ],
  );
}