import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TestDriveAdminManager extends StatelessWidget {
  const TestDriveAdminManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quản lý Lịch Lái Thử', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
        const SizedBox(height: 10),
        Text('Theo dõi và xác nhận các yêu cầu trải nghiệm xe từ khách hàng', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 30),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('test_drives').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFCC0000)));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Chưa có yêu cầu lái thử nào.', style: TextStyle(color: Colors.grey)));
              }

              final requests = snapshot.data!.docs;

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final doc = requests[index];
                  final data = doc.data() as Map<String, dynamic>;

                  // Format ngày lái thử
                  DateTime driveDate = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
                  String formattedDriveDate = DateFormat('dd/MM/yyyy').format(driveDate);

                  return _buildTestDriveCard(context, doc.id, data, formattedDriveDate);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestDriveCard(BuildContext context, String docId, Map<String, dynamic> data, String driveDate) {
    String status = data['status'] ?? 'Chờ xác nhận';
    bool isConfirmed = status == 'Đã xác nhận';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        border: Border.all(color: isConfirmed ? Colors.green.shade100 : Colors.orange.shade100),
      ),
      child: Row(
        children: [
          // Icon trạng thái
          CircleAvatar(
            backgroundColor: isConfirmed ? Colors.green.shade50 : Colors.orange.shade50,
            child: Icon(isConfirmed ? Icons.check_circle : Icons.pending_actions, color: isConfirmed ? Colors.green : Colors.orange),
          ),
          const SizedBox(width: 20),

          // Thông tin khách và xe
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['bikeName'] ?? 'Tên xe', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(data['customerName'] ?? 'Khách hàng', style: const TextStyle(color: Colors.black87)),
                    const SizedBox(width: 20),
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(data['phone'] ?? '', style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),

          // Ngày lái thử
          Column(
            children: [
              const Text('Ngày hẹn', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(driveDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(width: 30),

          // Nút thao tác
          Row(
            children: [
              if (!isConfirmed)
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    FirebaseFirestore.instance.collection('test_drives').doc(docId).update({'status': 'Đã xác nhận'});
                  },
                  tooltip: 'Xác nhận lịch hẹn',
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  FirebaseFirestore.instance.collection('test_drives').doc(docId).delete();
                },
                tooltip: 'Hủy lịch hẹn',
              ),
            ],
          )
        ],
      ),
    );
  }
}