import 'package:flutter/material.dart';
import '../../Controllers/auth_controller.dart';
import '../auth_view.dart';
import '../admin_view.dart';
import '../products_view.dart';
import '../contact_view.dart';
import '../wishlist_view.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String activeTab;

  const CustomHeader({super.key, required this.activeTab});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    // Nếu chiều rộng màn hình > 850 thì mới được coi là Desktop/Máy tính bảng ngang
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
            titleSpacing: isDesktop ? 40 : 0, // Căn lề nhỏ lại khi ở trên điện thoại

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. LOGO - Nhấn vào để về trang chủ
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProductsView())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFCC0000),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Text(
                            'HONDA',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. MENU ĐIỀU HƯỚNG (CHỈ HIỆN TRÊN MÁY TÍNH)
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

                // 3. CÁC ICON TIỆN ÍCH BÊN PHẢI & MENU MOBILE
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon Trái tim (Xe yêu thích)
                        IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.black87),
                            onPressed: () {
                              if (!auth.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để xem mục yêu thích'), backgroundColor: Colors.orange));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => WishlistView()));
                              }
                            }
                        ),

                        const SizedBox(width: 5),

                        // Icon Đăng nhập / Đăng xuất
                        IconButton(
                          icon: Icon(
                              auth.isLoggedIn ? Icons.logout : Icons.person_outline,
                              color: auth.isLoggedIn ? const Color(0xFFCC0000) : Colors.black87
                          ),
                          onPressed: () {
                            if (auth.isLoggedIn) {
                              auth.logout();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProductsView()));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => AuthView()));
                            }
                          },
                        ),

                        // MENU HAMBURGER: CHỈ HIỆN TRÊN ĐIỆN THOẠI (!isDesktop)
                        if (!isDesktop)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.menu, color: Colors.black87),
                            offset: const Offset(0, 50), // Đẩy menu drop-down xuống dưới một chút
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onSelected: (value) {
                              if (value == activeTab) return;
                              if (value == 'admin') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminView()));
                              else if (value == 'contact') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ContactScreen()));
                              else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProductsView()));
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

  // Widget tạo từng mục Menu chữ (Dành cho máy tính)
  Widget _buildNavText(BuildContext context, String text, String tabId) {
    bool isActive = activeTab == tabId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: InkWell(
        onTap: () {
          if (isActive) return;

          if (tabId == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminView()));
          } else if (tabId == 'contact') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ContactScreen()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProductsView()));
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                text,
                style: TextStyle(
                    color: isActive ? const Color(0xFFCC0000) : Colors.grey[800],
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15
                )
            ),
            if (isActive)
              Container(margin: const EdgeInsets.only(top: 5), height: 2, width: 25, color: const Color(0xFFCC0000)),
          ],
        ),
      ),
    );
  }
}