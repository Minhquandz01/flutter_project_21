import 'package:flutter/material.dart';
import '../../Controllers/auth_controller.dart';
import '../auth_view.dart';
import '../admin_view.dart';
import '../products_view.dart';
import '../contact_view.dart';
import '../cart_view.dart';
import '../order_history_view.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String activeTab;

  const CustomHeader({super.key, required this.activeTab});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 850;

    return ListenableBuilder(
        listenable: AuthController.instance,
        builder: (context, _) {
          final auth = AuthController.instance;

          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            titleSpacing: isDesktop ? 40 : 15,

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsView())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFCC0000), borderRadius: BorderRadius.circular(8)),
                        child: const Text('HONDA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                      ),
                    ),
                  ),
                ),

                if (isDesktop)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavText(context, 'Trang chủ', 'home'),
                        _buildNavText(context, 'Sản phẩm', 'products'),
                        _buildNavText(context, 'Liên hệ', 'contact'),
                        if (auth.isAdmin) _buildNavText(context, 'Quản trị (Admin)', 'admin'),
                      ],
                    ),
                  ),

                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                            onPressed: () {
                              if (!auth.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để xem giỏ hàng'), backgroundColor: Colors.orange));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartView()));
                              }
                            }
                        ),

                        const SizedBox(width: 5),

                        auth.isLoggedIn
                            ? _buildUserMenu(context, auth)
                            : IconButton(
                          icon: const Icon(Icons.person_outline, color: Colors.black87),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthView())),
                        ),

                        if (!isDesktop)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.menu, color: Colors.black87),
                            offset: const Offset(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onSelected: (value) {
                              if (value == activeTab) return;
                              if (value == 'admin') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminView()));
                              else if (value == 'contact') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
                              else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsView()));
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'home', child: Text('Trang chủ')),
                              const PopupMenuItem(value: 'products', child: Text('Sản phẩm')),
                              const PopupMenuItem(value: 'contact', child: Text('Liên hệ')),
                              if (auth.isAdmin) const PopupMenuItem(value: 'admin', child: Text('Quản trị (Admin)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  // --- MENU KHI NGƯỜI DÙNG ĐÃ ĐĂNG NHẬP (ĐÃ FIX LỖI GẠCH ĐỎ) ---
  Widget _buildUserMenu(BuildContext context, AuthController auth) {
    String username = auth.currentUserEmail.split('@')[0].toUpperCase();

    // ĐÃ SỬA: Định nghĩa rõ kiểu <String>
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      icon: const Icon(Icons.person, color: Color(0xFFCC0000)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

      // ĐÃ SỬA: Định nghĩa rõ kiểu danh sách <PopupMenuEntry<String>>[]
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
            enabled: false,
            value: 'header',
            child: Text('Chào, $username', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))
        ),
        PopupMenuItem<String>(
            value: 'history',
            onTap: () {
              // Dùng Future.delayed để chờ menu đóng rồi mới chuyển trang (tránh giật)
              Future.delayed(const Duration(milliseconds: 10), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryView()));
              });
            },
            child: const Row(children: [Icon(Icons.receipt_long, size: 18, color: Colors.blue), SizedBox(width: 10), Text('Lịch sử đơn hàng')])
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
            value: 'logout',
            onTap: () async {
              await auth.logout();
              // Dùng Future.delayed để chờ menu đóng hoàn tất
              Future.delayed(const Duration(milliseconds: 10), () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsView()));
              });
            },
            child: const Row(children: [Icon(Icons.logout, color: Colors.red, size: 18), SizedBox(width: 10), Text('Đăng xuất', style: TextStyle(color: Colors.red))])
        ),
      ],
    );
  }

  Widget _buildNavText(BuildContext context, String text, String tabId) {
    bool isActive = activeTab == tabId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: InkWell(
        onTap: () {
          if (isActive) return;
          if (tabId == 'admin') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminView()));
          else if (tabId == 'contact') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
          else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsView()));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: TextStyle(color: isActive ? const Color(0xFFCC0000) : Colors.grey[800], fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: 15)),
            if (isActive) Container(margin: const EdgeInsets.only(top: 5), height: 2, width: 25, color: const Color(0xFFCC0000)),
          ],
        ),
      ),
    );
  }
}