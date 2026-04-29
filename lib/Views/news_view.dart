import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Controllers/auth_controller.dart';
import 'Widgets/custom_header.dart';
import 'Widgets/custom_footer.dart';
import 'news_detail_view.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Tất cả', 'Xe mới', 'Bảo dưỡng', 'Mã giảm giá'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách ID mã giảm giá đã lưu của user từ Firestore
  Stream<List<String>> _getUserCollectedCoupons() {
    final user = AuthController.instance.isLoggedIn ? FirebaseAuth.instance.currentUser : null;
    if (user == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('saved_coupons')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1000;
    double paddingX = isMobile ? 20 : 60;
    final isAdmin = AuthController.instance.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: const CustomHeader(activeTab: 'news'),
      drawer: CustomHeader.buildDrawer(context, 'news'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_selectedTab == 0 || _selectedTab == 1) _buildFeaturedNews(isMobile),
            const SizedBox(height: 40),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingX),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTabBar(isMobile),
                  if (isAdmin)
                    ElevatedButton.icon(
                      onPressed: () => _selectedTab == 3 ? _showCouponDialog() : _showNewsDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(_selectedTab == 3 ? 'Thêm Voucher' : 'Thêm Tin tức', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC0000), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingX),
              child: _selectedTab == 3 ? _buildCouponsGrid(isMobile, isAdmin) : _buildNewsGrid(isMobile, isAdmin),
            ),

            const SizedBox(height: 80),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // ================= TẠO THANH TABS =================
  Widget _buildTabBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_tabs.length, (index) {
            bool isActive = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(color: isActive ? const Color(0xFFCC0000) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                child: Text(_tabs[index], style: TextStyle(color: isActive ? Colors.white : const Color(0xFF0B1629), fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ================= TẠO LƯỚI MÃ GIẢM GIÁ =================
  Widget _buildCouponsGrid(bool isMobile, bool isAdmin) {
    return StreamBuilder<List<String>>(
      stream: _getUserCollectedCoupons(),
      builder: (context, collectedSnapshot) {
        final collectedIds = collectedSnapshot.data ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('coupons').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final coupons = snapshot.data!.docs;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 3,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 2.2,
              ),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final doc = coupons[index];
                final data = doc.data() as Map<String, dynamic>;
                bool isCollected = collectedIds.contains(doc.id);

                return Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF7FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple.withOpacity(0.1)),
                        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 15)],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text(data["type"] ?? 'Mua xe', style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 15),
                                Text(data["title"] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const Spacer(),
                                Text('Mã: ${data["code"]}', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 5),
                                Text('HSD: ${data["date"]}', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(data["value"] ?? '', style: const TextStyle(color: Colors.purple, fontSize: 26, fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCollected ? Colors.grey[300] : const Color(0xFFA020F0),
                                  foregroundColor: isCollected ? Colors.grey[600] : Colors.white,
                                  elevation: isCollected ? 0 : 2,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: isCollected
                                    ? null
                                    : () async {
                                        final user = FirebaseAuth.instance.currentUser;
                                        if (user == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để lưu mã giảm giá!'), backgroundColor: Colors.orange));
                                          return;
                                        }
                                        
                                        await _firestore
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection('saved_coupons')
                                            .doc(doc.id)
                                            .set({
                                              ...data,
                                              'savedAt': Timestamp.now(),
                                            });

                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu mã thành công! Đã thêm vào Ví Voucher.'), backgroundColor: Colors.green));
                                        }
                                      },
                                child: Text(isCollected ? 'Đã lưu' : 'Lưu mã', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    if (isAdmin)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showCouponDialog(doc: doc)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => doc.reference.delete()),
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ================= TẠO LƯỚI TIN TỨC =================
  Widget _buildNewsGrid(bool isMobile, bool isAdmin) {
    String filterCat = _selectedTab == 1 ? 'Xe mới' : (_selectedTab == 2 ? 'Bảo dưỡng' : 'All');
    Query query = _firestore.collection('news');
    if (filterCat != 'All') query = query.where('category', isEqualTo: filterCat);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final news = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
            childAspectRatio: 0.8,
          ),
          itemCount: news.length,
          itemBuilder: (context, index) {
            final doc = news[index];
            final data = doc.data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetailView(newsItem: data))),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: Stack(
                      children: [
                        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(data["img"] ?? '', fit: BoxFit.cover, width: double.infinity, errorBuilder: (c,e,s) => const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)))),
                        if (isAdmin)
                          Positioned(
                            top: 10, right: 10,
                            child: Row(
                              children: [
                                CircleAvatar(backgroundColor: Colors.white, radius: 18, child: IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showNewsDialog(doc: doc))),
                                const SizedBox(width: 8),
                                CircleAvatar(backgroundColor: Colors.white, radius: 18, child: IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), onPressed: () => doc.reference.delete())),
                              ],
                            ),
                          )
                      ],
                    )),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]), const SizedBox(width: 8), Text(data["date"] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 13))]),
                            const SizedBox(height: 15),
                            Text(data["title"] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A24)), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 10),
                            Text(data["excerpt"] ?? '', style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            const Row(children: [Text("Xem chi tiết", style: TextStyle(color: Color(0xFFCC0000), fontWeight: FontWeight.bold)), SizedBox(width: 5), Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCC0000))])
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= BANNER KHỦNG TRÊN CÙNG =================
  Widget _buildFeaturedNews(bool isMobile) {
    return Container(
      width: double.infinity, height: isMobile ? 400 : 500,
      decoration: const BoxDecoration(
        image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1558981806-ec527fa84c39?q=80&w=2070"), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.9), Colors.transparent]),
        ),
        padding: EdgeInsets.all(isMobile ? 30 : 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70, size: 16), const SizedBox(width: 8), const Text('20 Tháng 4, 2026', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 15),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFCC0000), borderRadius: BorderRadius.circular(5)), child: const Text('NỔI BẬT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
              ],
            ),
            const SizedBox(height: 15),
            Text('Honda Winner X 2026:\nThiết Kế Đột Phá, Hiệu Suất Đỉnh Cao', style: TextStyle(color: Colors.white, fontSize: isMobile ? 28 : 46, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 15),
            if (!isMobile) const SizedBox(width: 700, child: Text('Khám phá mẫu Winner X hoàn toàn mới với công nghệ phun xăng điện tử tiên tiến và thiết kế khí động học sắc nét thiết lập tiêu chuẩn mới trong phân khúc xe côn tay thể thao.', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6))),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC0000), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {},
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Đọc ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(width: 8), Icon(Icons.arrow_forward, color: Colors.white, size: 18)]),
            )
          ],
        ),
      ),
    );
  }

  // ================= DIALOG QUẢN TRỊ TIN TỨC =================
  void _showNewsDialog({DocumentSnapshot? doc}) {
    final data = doc?.data() as Map<String, dynamic>?;
    final titleCtrl = TextEditingController(text: data?['title']);
    final imgCtrl = TextEditingController(text: data?['img']);
    final excerptCtrl = TextEditingController(text: data?['excerpt']);
    String category = data?['category'] ?? 'Xe mới';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doc == null ? 'Thêm Tin Tức' : 'Sửa Tin Tức'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
              TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'URL Ảnh')),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Xe mới', 'Bảo dưỡng', 'Sự kiện'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => category = v!,
                decoration: const InputDecoration(labelText: 'Danh mục'),
              ),
              TextField(controller: excerptCtrl, decoration: const InputDecoration(labelText: 'Nội dung tóm tắt'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                'title': titleCtrl.text, 'img': imgCtrl.text, 'category': category,
                'excerpt': excerptCtrl.text, 'date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
              };
              doc == null ? await _firestore.collection('news').add(payload) : await doc.reference.update(payload);
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          )
        ],
      ),
    );
  }

  // ================= DIALOG QUẢN TRỊ VOUCHER =================
  void _showCouponDialog({DocumentSnapshot? doc}) {
    final data = doc?.data() as Map<String, dynamic>?;
    final titleCtrl = TextEditingController(text: data?['title']);
    final codeCtrl = TextEditingController(text: data?['code']);
    final valueCtrl = TextEditingController(text: data?['value']);
    final dateCtrl = TextEditingController(text: data?['date']);
    String type = 'Mua xe'; // Cố định loại là Mua xe

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doc == null ? 'Thêm Voucher' : 'Sửa Voucher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Mã giảm giá')),
              TextField(controller: valueCtrl, decoration: const InputDecoration(labelText: 'Giá trị (VD: 20% hoặc 500K)')),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Hạn dùng (Ngày/Tháng/Năm)')),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Loại: Mua xe", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                'title': titleCtrl.text, 'code': codeCtrl.text, 'value': valueCtrl.text, 'date': dateCtrl.text, 'type': type
              };
              doc == null ? await _firestore.collection('coupons').add(payload) : await doc.reference.update(payload);
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          )
        ],
      ),
    );
  }
}
