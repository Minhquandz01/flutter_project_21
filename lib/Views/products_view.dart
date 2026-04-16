import 'package:flutter/material.dart';
import '../Controllers/product_controller.dart';
import '../Models/product_model.dart';
import 'product_detail_view.dart';
// ĐÃ XÓA import 'admin_view.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final ProductController _controller = ProductController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Nền xám nhạt như web
      // Nút Chat màu đỏ góc dưới cùng bên phải
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFCC0000), // Đỏ Honda chuẩn
        onPressed: () {},
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 20,
        toolbarHeight: 70,
        title: Row(
          children: [
            // Logo HONDA đỏ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFCC0000), borderRadius: BorderRadius.circular(8)),
              child: const Text('HONDA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1)),
            ),
            const Spacer(),
            // Menu điều hướng (Chỉ hiện trên màn hình lớn)
            if (MediaQuery.of(context).size.width > 700) ...[
              _buildNavText('Trang chủ', false),
              _buildNavText('Sản phẩm', true), // Đang ở tab Sản phẩm
              _buildNavText('Liên hệ', false),
              const Spacer(),
            ],
            // Icon giỏ hàng và tài khoản
            IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87), onPressed: () {}),
            const SizedBox(width: 10),
            IconButton(icon: const Icon(Icons.person_outline, color: Colors.black87), onPressed: () {}),
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFCC0000)));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tiêu đề lớn (Hero Section)
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 50, 40, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Danh sách Xe máy', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                      const SizedBox(height: 10),
                      Text('Tìm kiếm chiếc xe hoàn hảo từ bộ sưu tập của chúng tôi', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                ),

                // 2. Thanh lọc danh mục (Filter)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.filter_alt_outlined, color: Colors.black54),
                            const SizedBox(width: 10),
                            Text('Lọc theo Danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 15,
                          children: _controller.categories.map((cat) {
                            String hienThi = cat;
                            if (cat == 'All') hienThi = 'Tất cả';
                            if (cat == 'Scooter') hienThi = 'Xe tay ga';
                            if (cat == 'Sport') hienThi = 'Xe thể thao';
                            if (cat == 'Cub') hienThi = 'Xe số';

                            bool isSelected = _controller.selectedCategory == cat;
                            return ChoiceChip(
                              label: Text(hienThi, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 15)),
                              selected: isSelected,
                              selectedColor: const Color(0xFFCC0000),
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Colors.transparent)),
                              onSelected: (_) => _controller.filterByCategory(cat),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 3. Lưới hiển thị Sản phẩm (Lưới Responsive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
                      final displayedProducts = _controller.filteredProducts;

                      if (displayedProducts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text('Không có xe nào trong danh mục này', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 30,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: displayedProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(displayedProducts[index]);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 60),

                // 4. CHÂN TRANG (FOOTER) 4 CỘT
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0A0A0A), // Nền đen tuyền
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 50,
                        runSpacing: 40,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          // Cột 1: Thông tin HONDA & Mạng xã hội
                          SizedBox(
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                  decoration: BoxDecoration(color: const Color(0xFFCC0000), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('HONDA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                                ),
                                const SizedBox(height: 20),
                                const Text('Nhà sản xuất xe máy hàng đầu mang đến chất lượng, sự đổi mới và hiệu suất từ năm 1948.', style: TextStyle(color: Colors.white54, height: 1.6, fontSize: 14)),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    _buildSocialIcon(Icons.facebook),
                                    _buildSocialIcon(Icons.camera_alt_outlined),
                                    _buildSocialIcon(Icons.flutter_dash),
                                    _buildSocialIcon(Icons.play_circle_outline),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // Cột 2: Quick Links
                          _buildFooterColumn('Liên kết nhanh', ['Tất cả sản phẩm', 'Liên hệ', 'Về Honda', 'Bảo hành', 'Trung tâm dịch vụ']),
                          // Cột 3: Customer Service
                          _buildFooterColumn('Chăm sóc khách hàng', ['Câu hỏi thường gặp', 'Hỗ trợ trả góp', 'Lái thử', 'Sách hướng dẫn', 'Phụ tùng & Phụ kiện']),
                          // Cột 4: Contact Info
                          SizedBox(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Thông tin liên hệ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                _buildContactRow(Icons.location_on_outlined, '123 Đường Honda, Quận 1, TP. Hồ Chí Minh'),
                                _buildContactRow(Icons.phone_outlined, '1800-123-456'),
                                _buildContactRow(Icons.email_outlined, 'support@honda.com.vn'),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 50),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 20),
                      const Text('© 2024 Honda Motor Co., Ltd. Tất cả quyền được bảo lưu.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- CÁC HÀM HỖ TRỢ VẼ GIAO DIỆN CON ---

  // Thẻ sản phẩm (Product Card)
  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailView(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), color: Colors.grey[100]),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.two_wheeler, size: 80, color: Colors.black12))),
                    ),
                  ),
                  Positioned(top: 15, left: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(15)), child: Text(product.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                  Positioned(top: 15, right: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFCC0000), borderRadius: BorderRadius.circular(15)), child: Text(product.year, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                    const SizedBox(height: 8),
                    Text(product.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Text('Màu sắc: ', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        const SizedBox(width: 5),
                        ...product.colors.map((color) => Container(margin: const EdgeInsets.only(right: 6), width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black12)))),
                      ],
                    ),
                    const Spacer(),
                    const Divider(color: Colors.black12),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Giá từ', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(product.price, style: const TextStyle(color: Color(0xFFCC0000), fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFFCC0000), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nút chữ trên thanh điều hướng
  Widget _buildNavText(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: TextStyle(color: isActive ? const Color(0xFFCC0000) : Colors.grey[600], fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: 15)),
          if (isActive) Container(margin: const EdgeInsets.only(top: 5), height: 2, width: 25, color: const Color(0xFFCC0000)),
        ],
      ),
    );
  }

  // Cột chữ ở Chân trang
  Widget _buildFooterColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(link, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        )),
      ],
    );
  }

  // Dòng chứa Icon + Chữ liên hệ
  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFCC0000), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.5))),
        ],
      ),
    );
  }

  // Icon Mạng xã hội chân trang
  Widget _buildSocialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Icon(icon, color: Colors.white54, size: 22),
    );
  }
}