import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContactAdminManager extends StatelessWidget {
  const ContactAdminManager({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 850;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tin nhắn Liên hệ', style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A24))),
        const SizedBox(height: 5),
        Text('Quản lý các yêu cầu và phản hồi từ khách hàng', style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey[600])),
        const SizedBox(height: 30),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('contacts').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFCC0000)));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Chưa có tin nhắn nào.', style: TextStyle(color: Colors.grey)));
              }

              final contacts = snapshot.data!.docs;

              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final doc = contacts[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildContactCard(context, doc.id, data, isMobile);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, String docId, Map<String, dynamic> data, bool isMobile) {
    bool isRead = data['isRead'] ?? false;
    String rawDate = data['createdAt'] ?? '';
    String formattedDate = '';
    try {
      DateTime parsed = DateTime.parse(rawDate);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (e) {
      formattedDate = rawDate;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isRead ? Colors.grey.shade200 : Colors.red.shade200, width: isRead ? 1 : 1.5),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: isRead ? Colors.grey[200] : Colors.red[50],
          child: Icon(Icons.person, color: isRead ? Colors.grey : const Color(0xFFCC0000)),
        ),
        // SỬA Ở ĐÂY: Dùng Wrap/Expanded để chữ tự rớt dòng, không đâm vỡ màn hình
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 5,
          children: [
            Text(
              data['name'] ?? 'Không tên',
              style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 16),
            ),
            if (data['subject'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                child: Text(data['subject'], style: const TextStyle(fontSize: 12, color: Colors.blue)),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        onExpansionChanged: (expanded) {
          if (expanded && !isRead) {
            FirebaseFirestore.instance.collection('contacts').doc(docId).update({'isRead': true});
          }
        },
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 15 : 20),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BỌC EMAIL VÀO ROW VÀ EXPANDED ĐỂ TỰ ĐỘNG CẮT CHỮ NẾU DÀI
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(data['email'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(data['phone'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(),
                ),
                const Text('Nội dung:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Text(data['message'] ?? '', style: const TextStyle(fontSize: 15, height: 1.5)),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      FirebaseFirestore.instance.collection('contacts').doc(docId).delete();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    label: const Text('Xóa tin nhắn', style: TextStyle(color: Colors.red)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}