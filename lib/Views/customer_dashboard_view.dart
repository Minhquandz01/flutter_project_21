import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../Controllers/auth_controller.dart';
import '../Controllers/product_controller.dart';
import 'Widgets/custom_header.dart';
import 'Widgets/custom_footer.dart';

class CustomerDashboardView extends StatefulWidget {
  const CustomerDashboardView({super.key});

  @override
  State<CustomerDashboardView> createState() => _CustomerDashboardViewState();
}

class _CustomerDashboardViewState extends State<CustomerDashboardView> {
  final ProductController _productController = ProductController();
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1100;
    double horizontalPadding = isMobile ? 15 : 60;

    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: const CustomHeader(activeTab: 'dashboard'),
          drawer: CustomHeader.buildDrawer(context, 'dashboard'),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      // 1. BANNER THÔNG TIN CÁ NHÂN (Dùng dữ liệu thật)
                      _buildProfileBanner(isMobile),
                      const SizedBox(height: 30),

                      // 2. NỘI DUNG CHÍNH (Chia 2 cột trên PC, 1 cột trên Mobile)
                      if (isMobile) ...[
                        _buildPurchaseHistory(),
                        const SizedBox(height: 30),
                        _buildMaintenanceSchedule(),
                        const SizedBox(height: 30),
                        _buildVoucherWallet(),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cột trái: Lịch sử mua hàng
                            Expanded(flex: 6, child: _buildPurchaseHistory()),
                            const SizedBox(width: 30),
                            // Cột phải: Bảo dưỡng & Voucher
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _buildMaintenanceSchedule(),
                                  const SizedBox(height: 30),
                                  _buildVoucherWallet(),
                                ],
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                const CustomFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== WIDGET: PROFILE BANNER ====================
  Widget _buildProfileBanner(bool isMobile) {
    final auth = AuthController.instance;
    final userData = auth.userData;
    String name = userData?['name'] ?? 'Khách hàng';
    String phone = userData?['phone'] ?? '+84 --- --- ---';
    String email = userData?['email'] ?? auth.currentUserEmail;
    String? avatarUrl = userData?['avatarUrl'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      decoration: BoxDecoration(
        color: const Color(0xFFB70000),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (Có ảnh từ Firebase hoặc mặc định chữ cái)
              CircleAvatar(
                radius: isMobile ? 35 : 50,
                backgroundColor: Colors.white,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: TextStyle(color: const Color(0xFFB70000), fontWeight: FontWeight.bold, fontSize: isMobile ? 20 : 28))
                    : null,
              ),
              const SizedBox(width: 20),

              // Thông tin User
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 15,
                      runSpacing: 10,
                      children: [
                        Text(name, style: TextStyle(color: Colors.white, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events, size: 16, color: Colors.white),
                              SizedBox(width: 5),
                              Text('Hạng Vàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    _contactRow(Icons.email_outlined, email),
                    const SizedBox(height: 5),
                    _contactRow(Icons.phone_outlined, phone),
                  ],
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB70000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                onPressed: () => _showEditProfileDialog(context, name, phone),
                child: Text(isMobile ? 'Sửa' : 'Sửa Thông Tin', style: const TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 30),

          // Tiến độ Điểm thành viên
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Điểm Thành Viên', style: TextStyle(color: Colors.white)),
                    Text('8.500 / 10.000', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Còn 1.500 điểm để lên Hạng Bạch Kim', style: TextStyle(color: Colors.white70, fontSize: 12)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  // --- HỘP THOẠI CHỈNH SỬA THÔNG TIN ---
  void _showEditProfileDialog(BuildContext context, String currentName, String currentPhone) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    bool localIsSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => ListenableBuilder(
        listenable: AuthController.instance,
        builder: (context, _) {
          final auth = AuthController.instance;
          final avatarUrl = auth.userData?['avatarUrl'];

          return StatefulBuilder(
            builder: (context, setStateSTB) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Chỉnh Sửa Thông Tin', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Phần chọn ảnh đại diện
                      InkWell(
                        onTap: localIsSaving ? null : () async {
                          setStateSTB(() => localIsSaving = true);
                          try {
                            await auth.uploadAvatar();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tải ảnh lên thành công!'), backgroundColor: Colors.green));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                            }
                          } finally {
                            if (mounted) setStateSTB(() => localIsSaving = false);
                          }
                        },
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                                  child: (avatarUrl == null || avatarUrl.isEmpty) ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(color: Color(0xFFB70000), shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                                if (localIsSaving)
                                  const Positioned.fill(child: Center(child: CircularProgressIndicator(color: Color(0xFFB70000)))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text('Bấm để thay đổi ảnh từ máy tính', style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Họ và Tên',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: localIsSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB70000),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: localIsSaving ? null : () async {
                    setStateSTB(() => localIsSaving = true);
                    try {
                      await auth.updateProfile(name: nameCtrl.text, phone: phoneCtrl.text);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                      }
                    }
                    setStateSTB(() => localIsSaving = false);
                  },
                  child: localIsSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Lưu Thay Đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== WIDGET: LỊCH SỬ MUA HÀNG ====================
  Widget _buildPurchaseHistory() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.shopping_bag, 'Lịch Sử Mua Hàng', 'Danh sách đơn hàng của bạn'),
          const Divider(height: 1, color: Colors.black12),
          StreamBuilder<QuerySnapshot>(
            stream: _productController.getUserOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Color(0xFFB70000))));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text('Bạn chưa có đơn hàng nào.', style: TextStyle(color: Colors.grey))),
                );
              }

              final orders = snapshot.data!.docs;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(25),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12)),
                itemBuilder: (context, index) {
                  final order = orders[index].data() as Map<String, dynamic>;
                  final items = order['items'] as List<dynamic>? ?? [];
                  final firstItem = items.isNotEmpty ? items[0] as Map<String, dynamic> : null;
                  
                  // Nếu đơn hàng có nhiều xe, chỉ hiển thị xe đầu tiên kèm mô tả "+x xe khác"
                  String title = firstItem?['name'] ?? 'Đơn hàng mới';
                  if (items.length > 1) title += " + ${items.length - 1} sản phẩm";

                  DateTime date = (order['createdAt'] as Timestamp).toDate();
                  String dateStr = DateFormat('dd/MM/yyyy').format(date);
                  String price = formatter.format(order['totalAmount'] ?? 0);
                  String imgUrl = firstItem?['imageUrl'] ?? '';
                  String status = order['status'] ?? 'Đang xử lý';

                  return _orderItem(title, orders[index].id, dateStr, 'Tiêu chuẩn', price, imgUrl, status);
                },
              );
            },
          )
        ],
      ),
    );
  }

  Widget _orderItem(String name, String id, String date, String color, String price, String imgUrl, String status) {
    bool isSuccess = status == 'Đã thanh toán' || status == 'Đã nhận xe';
    return LayoutBuilder(builder: (context, constraints) {
      bool isSmall = constraints.maxWidth < 500;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imgUrl, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.two_wheeler))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                      decoration: BoxDecoration(color: isSuccess ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(5)), 
                      child: Text(status, style: TextStyle(color: isSuccess ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text('Mã Đơn: $id', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 10),
                if (!isSmall)
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 5),
                      Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  )
                else
                  Text('Ngày: $date', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 10),
                Text(price, style: const TextStyle(color: Color(0xFFCC0000), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _actionButton('Chi Tiết', null),
                  ],
                )
              ],
            ),
          )
        ],
      );
    });
  }

  Widget _actionButton(String text, IconData? icon) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.grey[300]!)),
      onPressed: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16, color: Colors.black87), const SizedBox(width: 5)],
          Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  // ==================== WIDGET: BẢO DƯỠNG ====================
  Widget _buildMaintenanceSchedule() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.build_outlined, 'Lịch Bảo Dưỡng', 'Kế hoạch chăm sóc xe', color: Colors.blue),
          const Divider(height: 1, color: Colors.black12),
          StreamBuilder<QuerySnapshot>(
            stream: _productController.getUserOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Colors.blue)));
              }

              List<Widget> maintenanceWidgets = [];
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                // Tạo lịch bảo dưỡng giả dựa trên đơn hàng thực tế
                for (var doc in snapshot.data!.docs) {
                  final order = doc.data() as Map<String, dynamic>;
                  final items = order['items'] as List<dynamic>? ?? [];
                  final firstItem = items.isNotEmpty ? items[0] as Map<String, dynamic> : null;
                  if (firstItem != null) {
                    maintenanceWidgets.add(
                        _maintenanceItem('Thay Dầu & Kiểm Tra', firstItem['name'], 'Định kỳ 1000km', 'Sắp đến hạn', Colors.red)
                    );
                    maintenanceWidgets.add(const SizedBox(height: 15));
                  }
                }
              }

              if (maintenanceWidgets.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text('Chưa có lịch bảo dưỡng.', style: TextStyle(color: Colors.grey))),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    ...maintenanceWidgets,
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () {},
                        child: const Text('Đặt Lịch Hẹn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _maintenanceItem(String title, String bike, String date, String countdown, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: Colors.blue, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 5),
          Text(bike, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]), const SizedBox(width: 5), Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 13))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(countdown, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          )
        ],
      ),
    );
  }

  // ==================== WIDGET: VOUCHER ====================
  Widget _buildVoucherWallet() {
    final user = AuthController.instance.isLoggedIn ? FirebaseAuth.instance.currentUser : null;

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.local_offer_outlined, 'Ví Voucher', 'Mã giảm giá đã lưu', color: Colors.purple),
          const Divider(height: 1, color: Colors.black12),
          StreamBuilder<QuerySnapshot>(
            stream: user != null 
                ? FirebaseFirestore.instance.collection('users').doc(user.uid).collection('saved_coupons').snapshots()
                : Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Colors.purple)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text('Ví Voucher của bạn đang trống.', style: TextStyle(color: Colors.grey))),
                );
              }

              final coupons = snapshot.data!.docs;
              return Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: coupons.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _voucherItem(
                        data['type'] ?? 'Mua xe', 
                        data['title'] ?? 'Ưu đãi đặc biệt', 
                        data['code'] ?? '---', 
                        data['date'] ?? '---', 
                        data['value'] ?? ''
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _voucherItem(String tag, String title, String code, String validDate, String highlightValue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFDF7FF), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.purple.withOpacity(0.1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(tag, style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 5),
                Text('Mã: $code', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                const SizedBox(height: 10),
                Text('Hết hạn $validDate', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(highlightValue, style: const TextStyle(color: Colors.purple, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA020F0), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {},
                child: const Text('Dùng Ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              )
            ],
          )
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))]);
  }

  Widget _buildCardHeader(IconData icon, String title, String subtitle, {Color color = const Color(0xFFB70000)}) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 24)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
