import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../Controllers/product_controller.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  final ProductController _controller = ProductController();
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 850;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quản lý Đơn hàng', style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A24))),
                const SizedBox(height: 5),
                Text('Theo dõi và quản lý các giao dịch thanh toán', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 30),
                _buildOrdersList(isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(bool isMobile) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 30),
            child: const Text('Danh sách Giao dịch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1, color: Colors.black12),

          StreamBuilder<QuerySnapshot>(
            stream: _controller.getAllOrdersAdmin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator(color: Color(0xFFCC0000))));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Padding(padding: EdgeInsets.all(50), child: Center(child: Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.grey))));

              var orders = snapshot.data!.docs;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  var order = orders[index].data() as Map<String, dynamic>;
                  DateTime date = (order['createdAt'] as Timestamp).toDate();
                  String status = order['status'] ?? 'Chờ thanh toán';
                  bool isSuccess = status == 'Đã thanh toán';

                  return ListTile(
                    contentPadding: EdgeInsets.all(isMobile ? 15 : 20),
                    leading: CircleAvatar(
                      backgroundColor: isSuccess ? Colors.green[50] : Colors.orange[50],
                      child: Icon(isSuccess ? Icons.check_circle : Icons.hourglass_top, color: isSuccess ? Colors.green : Colors.orange),
                    ),
                    title: Text('Khách: ${order['userEmail'] ?? 'Ẩn danh'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text('Mã đơn: ${orders[index].id}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        Text('Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatter.format(order['totalAmount']), style: const TextStyle(color: Color(0xFFCC0000), fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(status, style: TextStyle(color: isSuccess ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}