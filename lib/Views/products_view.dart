import 'package:flutter/material.dart';
import '../Controllers/product_controller.dart';
import '../Models/product_model.dart';
import 'product_detail_view.dart';
import 'Widgets/custom_header.dart';
import 'Widgets/custom_footer.dart';

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
    bool isMobile = MediaQuery.of(context).size.width < 700;
    double horizontalPadding = isMobile ? 20.0 : 40.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFCC0000),
        onPressed: () {},
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      appBar: const CustomHeader(activeTab: 'products'),
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
                // 1. HERO SECTION
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, isMobile ? 30 : 50, horizontalPadding, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Danh sách Xe máy', style: TextStyle(fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A24))),
                      const SizedBox(height: 10),
                      Text('Tìm kiếm chiếc xe hoàn hảo từ bộ sưu tập của chúng tôi', style: TextStyle(fontSize: isMobile ? 15 : 18, color: Colors.grey[600])),
                    ],
                  ),
                ),

                // 2. THANH LỌC DANH MỤC
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 20 : 25),
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
                          spacing: 12,
                          runSpacing: 12,
                          children: _controller.categories.map((cat) {
                            String hienThi = cat == 'All' ? 'Tất cả' : (cat == 'Scooter' ? 'Xe tay ga' : (cat == 'Sport' ? 'Xe thể thao' : 'Xe số'));
                            bool isSelected = _controller.selectedCategory == cat;

                            return ChoiceChip(
                              label: Text(hienThi, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
                              selected: isSelected,
                              selectedColor: const Color(0xFFCC0000),
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Colors.transparent)),
                              onSelected: (_) => _controller.filterByCategory(cat),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 3. LƯỚI HIỂN THỊ SẢN PHẨM
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
                      final displayedProducts = _controller.filteredProducts;

                      if (displayedProducts.isEmpty) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(80.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.two_wheeler, size: 80, color: Colors.grey[300]),
                                    const SizedBox(height: 20),
                                    Text('Chưa có xe nào trong danh mục này', style: TextStyle(color: Colors.grey[500], fontSize: 18))
                                  ],
                                )
                            )
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 25,
                          mainAxisSpacing: 25,
                          // ĐÃ CHỈNH SỬA Ở ĐÂY: Trên điện thoại cho tỷ lệ 0.65 để thẻ dài ra, không bị tràn
                          childAspectRatio: isMobile ? 0.62 : 0.75,
                        ),
                        itemCount: displayedProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(displayedProducts[index], context, isMobile);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 60),
                const CustomFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- THIẾT KẾ CARD SẢN PHẨM CHỐNG TRÀN ---
  Widget _buildProductCard(ProductModel product, BuildContext context, bool isMobile) {
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
            // Khối Hình ảnh (Giảm flex xuống một chút để nhường chỗ cho chữ)
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), color: Colors.white),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.two_wheeler, size: 80, color: Colors.black12))),
                    ),
                  ),
                  Positioned(top: 15, left: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(15)), child: Text(product.category == 'Scooter' ? 'Xe tay ga' : (product.category == 'Sport' ? 'Xe thể thao' : 'Xe số'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                  Positioned(top: 15, right: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFCC0000), borderRadius: BorderRadius.circular(15)), child: Text(product.year, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                ],
              ),
            ),

            // Khối Thông tin (Tăng flex để có nhiều không gian hơn)
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 15 : 20), // Thu nhỏ lề trên điện thoại
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A24)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    // Expanded bọc lấy mô tả để nó chiếm hết chỗ trống dư thừa, đẩy Giá tiền xuống hẳn sát đáy
                    Expanded(
                      child: Text(product.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
                    ),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 5),

                    // Khối Giá bán và Nút mũi tên
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Giá từ', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              const SizedBox(height: 4),
                              // Dùng FittedBox bọc lấy Text để giá tự động nhỏ lại nếu số quá dài
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(product.price, style: const TextStyle(color: Color(0xFFCC0000), fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Color(0xFFCC0000), shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18)
                        )
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
}