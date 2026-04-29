import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../Controllers/product_controller.dart';
import 'cart_view.dart';
import 'Widgets/custom_header.dart';
import 'Widgets/custom_footer.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  final ProductController _controller = ProductController();
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: const CustomHeader(activeTab: ''),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lịch sử mua hàng', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                  const SizedBox(height: 30),

                  StreamBuilder<QuerySnapshot>(
                    stream: _controller.getUserOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // ĐÃ SỬA LỖI 1: Bọc CircularProgressIndicator bằng Padding thay vì truyền thẳng vào Center
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(50),
                                child: CircularProgressIndicator(color: Color(0xFFCC0000))
                            )
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 80),
                              child: const Text('Bạn chưa có đơn hàng nào.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            )
                        );
                      }

                      final orders = snapshot.data!.docs.toList();
                      // Sắp xếp đơn hàng mới nhất lên đầu (Client-side)
                      orders.sort((a, b) {
                        Timestamp t1 = (a.data() as Map<String, dynamic>)['createdAt'];
                        Timestamp t2 = (b.data() as Map<String, dynamic>)['createdAt'];
                        return t2.compareTo(t1);
                      });

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (ctx, i) {
                          var order = orders[i].data() as Map<String, dynamic>;
                          String status = order['status'] ?? 'Chờ thanh toán';
                          bool isSuccess = status == 'Đã thanh toán' || status == 'Đã nhận xe';
                          DateTime date = (order['createdAt'] as Timestamp).toDate();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 20),
                            elevation: 0,
                            // ĐÃ SỬA LỖI 2: Dùng side: BorderSide(...) thay cho border: Border.all(...)
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: Colors.grey.shade200)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 20 : 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Mã đơn: ${orders[i].id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: isSuccess ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(20)),
                                        child: Text(status, style: TextStyle(color: isSuccess ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                                      )
                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                                  Text('Ngày đặt hàng: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tổng tiền: ${formatter.format(order['totalAmount'])}', style: const TextStyle(color: Color(0xFFCC0000), fontSize: 18, fontWeight: FontWeight.bold)),
                                      if (status == 'Chờ thanh toán')
                                        ElevatedButton(
                                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartView())),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC0000), foregroundColor: Colors.white),
                                          child: const Text('Thanh toán ngay'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}