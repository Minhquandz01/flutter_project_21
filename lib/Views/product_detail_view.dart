import 'package:flutter/material.dart';
import '../Models/product_model.dart';

class ProductDetailView extends StatefulWidget {
  final ProductModel product;
  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int selectedColorIndex = 0; // Lưu vị trí màu sắc đang được người dùng chọn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Nền xám nhạt đồng bộ
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: const Text(
          'Chi tiết Sản phẩm',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Giỏ hàng đang trống!')),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Khu vực hình ảnh (Hero Image)
                  Container(
                    width: double.infinity,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    padding: const EdgeInsets.all(40),
                    child: Hero(
                      tag: widget.product.id, // Hiệu ứng bay ảnh mượt mà từ trang chủ sang
                      child: Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.two_wheeler, size: 100, color: Colors.black12),
                      ),
                    ),
                  ),

                  // 2. Khu vực thông tin chi tiết
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên xe và Nhãn năm
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCC0000).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.product.year,
                                style: const TextStyle(color: Color(0xFFCC0000), fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Giá tiền
                        Text(
                          widget.product.price,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFCC0000)),
                        ),

                        const SizedBox(height: 35),

                        // Phân loại
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                'Phân khúc: ${widget.product.category}',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 35),

                        // Bảng chọn màu sắc
                        const Text('Chọn màu sắc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                        const SizedBox(height: 15),
                        Row(
                          children: List.generate(widget.product.colors.length, (index) {
                            bool isSelected = selectedColorIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColorIndex = index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 15),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFCC0000) : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: widget.product.colors[index],
                                  radius: 22,
                                  // Thêm viền xám nhẹ nếu xe màu trắng để không bị chìm vào nền
                                  child: widget.product.colors[index] == Colors.white
                                      ? Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12)))
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 35),

                        // Mô tả chi tiết
                        const Text('Mô tả sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
                        const SizedBox(height: 15),
                        Text(
                          widget.product.desc,
                          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.8),
                        ),
                        const SizedBox(height: 50), // Khoảng trống cuộn
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // 3. Thanh điều hướng mua hàng (Bottom Bar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Nút Thêm vào giỏ
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: Color(0xFFCC0000), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm xe vào giỏ hàng!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Icon(Icons.add_shopping_cart, color: Color(0xFFCC0000)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Nút Mua ngay
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC0000),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'MUA NGAY',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}