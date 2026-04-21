import 'package:flutter/material.dart';
import '../../Controllers/auth_controller.dart';
import '../auth_view.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String activeTab;

  const CustomHeader({super.key, required this.activeTab});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 700;

    return ListenableBuilder(
        listenable: AuthController.instance,
        builder: (context, _) {
          final auth = AuthController.instance;

          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
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

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildNavText(context, 'Trang chủ', 'home'),
                      _buildNavText(context, 'Sản phẩm', 'products'),
                      _buildNavText(context, 'Liên hệ', 'contact'),

                      if (auth.isAdmin) ...[
                        _buildNavText(context, 'Bảng điều khiển', 'dashboard'),
                        _buildNavText(context, 'Quản trị (Admin)', 'admin'),
                      ],
                    ],
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87), onPressed: () {}),
                        const SizedBox(width: 5),
                        IconButton(
                          icon: Icon(
                              auth.isLoggedIn ? Icons.logout : Icons.person_outline,
                              color: auth.isLoggedIn ? const Color(0xFFCC0000) : Colors.black87
                          ),
                          onPressed: () {
                            if (auth.isLoggedIn) {
                              auth.logout();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthView()));
                            }
                          },
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

  Widget _buildNavText(BuildContext context, String text, String tabId) {
    bool isActive = activeTab == tabId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: InkWell(
        onTap: () {

          if (tabId == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminView()));
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsView()));
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