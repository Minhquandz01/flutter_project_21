import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/product_model.dart';

class ProductController extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  List<String> categories = ['All', 'Scooter', 'Sport', 'Cub'];
  String selectedCategory = 'All';
  bool isLoading = false;

  ProductController() { fetchProducts(); }

  Future<void> fetchProducts() async {
    isLoading = true; notifyListeners();
    try {
      QuerySnapshot snapshot = await firestore.collection('products').get();
      if (snapshot.docs.isEmpty) {
        await autoSeedData();
        snapshot = await firestore.collection('products').get();
      }
      allProducts = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
      applyFilter();
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  void filterByCategory(String category) {
    selectedCategory = category;
    applyFilter();
    notifyListeners();
  }

  void applyFilter() {
    if (selectedCategory == 'All') {
      filteredProducts = List.from(allProducts);
    } else {
      filteredProducts = allProducts.where((p) => p.category == selectedCategory).toList();
    }
  }

  Future<void> autoSeedData() async {
    List<ProductModel> seedData = [
      ProductModel(id: '', name: 'Honda Vision 2025', category: 'Scooter', year: '2025', desc: 'Thiết kế thanh lịch, trẻ trung.', price: '31,113,000 VNĐ',
          imageUrl: 'https://images.unsplash.com/photo-1558981285-6f0c94958bb6?w=800', colors: [Colors.white, Colors.black, Colors.red[700]!]),
      ProductModel(id: '', name: 'Honda SH 160i', category: 'Scooter', year: '2024', desc: 'Biểu tượng đẳng cấp.', price: '92,490,000 VNĐ',
          imageUrl: 'https://images.unsplash.com/photo-1622185135505-2d795003994a?w=800', colors: [Colors.black, Colors.grey[300]!, Colors.white]),
      ProductModel(id: '', name: 'Winner X', category: 'Sport', year: '2023', desc: 'Đỉnh cao xe thể thao.', price: '46,160,000 VNĐ',
          imageUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3ae8?w=800', colors: [Colors.red[700]!, Colors.black]),
    ];
    for (var product in seedData) {
      await firestore.collection('products').add(product.toMap());
    }
  }
}