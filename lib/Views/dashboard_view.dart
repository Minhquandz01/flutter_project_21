import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 850;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan hệ thống', style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A24))),
          const SizedBox(height: 5),
          Text('Chào mừng Admin, đây là số liệu thống kê', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 30),

          // 1. DÃY THẺ THỐNG KÊ (Responsive: 2 cột trên đt, 4 cột trên PC)
          LayoutBuilder(
            builder: (context, constraints) {
              double spacing = 15;
              // Nếu điện thoại -> chia 2 thẻ 1 hàng. Nếu PC -> chia 4 thẻ 1 hàng
              double cardWidth = isMobile
                  ? (constraints.maxWidth - spacing) / 2
                  : (constraints.maxWidth - (spacing * 3)) / 4;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _buildStatCard('Tổng Xe', 'products', Icons.two_wheeler, Colors.blue, cardWidth, isMobile),
                  _buildStatCard('Tin nhắn', 'contacts', Icons.email_outlined, Colors.orange, cardWidth, isMobile),
                  _buildStatCard('Lái thử', 'test_drives', Icons.calendar_today, Colors.green, cardWidth, isMobile),
                  _buildStatCard('Khách', 'users', Icons.people_outline, Colors.purple, cardWidth, isMobile),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // 2. KHU VỰC BIỂU ĐỒ MÔ PHỎNG & HOẠT ĐỘNG
          // Xếp dọc nếu là đt, xếp ngang nếu là PC
          isMobile
              ? Column(
            children: [
              _buildDashboardBox('Phân bố danh mục', _buildCategoryCharts()),
              const SizedBox(height: 20),
              _buildDashboardBox('Hoạt động gần đây', _buildActivities()),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildDashboardBox('Phân bố danh mục', _buildCategoryCharts())),
              const SizedBox(width: 30),
              Expanded(child: _buildDashboardBox('Hoạt động gần đây', _buildActivities())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String collection, IconData icon, Color color, double width, bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
        return Container(
          width: width,
          padding: EdgeInsets.all(isMobile ? 15 : 25),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: isMobile ? 18 : 24, child: Icon(icon, color: color, size: isMobile ? 20 : 24)),
              SizedBox(height: isMobile ? 10 : 20),
              Text(count, style: TextStyle(fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(title, style: TextStyle(color: Colors.grey, fontSize: isMobile ? 12 : 14)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardBox(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryCharts() => Column(
    children: [
      _buildCategoryRow('Xe tay ga', 45, Colors.red),
      _buildCategoryRow('Xe số', 35, Colors.blue),
      _buildCategoryRow('Xe thể thao', 20, Colors.orange),
    ],
  );

  Widget _buildActivities() => Column(
    children: [
      _buildActivityItem('Khách vừa đăng ký lái thử xe SH'),
      _buildActivityItem('Đã cập nhật tồn kho Vision'),
      _buildActivityItem('Tin nhắn mới từ Nguyễn Văn A'),
    ],
  );

  Widget _buildCategoryRow(String name, int percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(name, style: const TextStyle(fontSize: 13)), Text('$percent%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: percent / 100, backgroundColor: color.withOpacity(0.1), color: color, minHeight: 6, borderRadius: BorderRadius.circular(10)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 5), child: Icon(Icons.circle, size: 8, color: Colors.red)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}