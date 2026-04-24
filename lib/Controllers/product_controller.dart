import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Đã thêm import này
import '../Models/product_model.dart';

class ProductController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = false;

  // Danh mục dùng cho bộ lọc
  List<String> categories = ['All', 'Scooter', 'Sport', 'Cub'];
  String selectedCategory = 'All';

  ProductController() { fetchProducts(); }

  // Lấy dữ liệu từ Firebase
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db.collection('products').get();
      allProducts = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
      filterByCategory(selectedCategory);
    } catch (e) {
      debugPrint("Lỗi Firestore: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  // Hàm lọc xe theo loại
  void filterByCategory(String cat) {
    selectedCategory = cat;
    if (cat == 'All') {
      filteredProducts = allProducts;
    } else {
      filteredProducts = allProducts.where((p) => p.category == cat).toList();
    }
    notifyListeners();
  }

  Future<void> addProduct(ProductModel p) async {
    await _db.collection('products').add(p.toMap());
    await fetchProducts();
  }

  Future<void> updateProduct(ProductModel p) async {
    await _db.collection('products').doc(p.id).update(p.toMap());
    await fetchProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
    await fetchProducts();
  }

  // ==========================================
  // --- LOGIC XE YÊU THÍCH (WISHLIST) MỚI THÊM ---
  // ==========================================

  // Kiểm tra trạng thái tim (Đã thích hay chưa)
  Stream<bool> isFavorite(String productId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(false);

    return _db
        .collection('wishlists')
        .doc(user.uid)
        .collection('my_favorites')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Thêm hoặc xóa xe khỏi Wishlist
  Future<void> toggleFavorite(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Yêu cầu đăng nhập

    final docRef = _db
        .collection('wishlists')
        .doc(user.uid)
        .collection('my_favorites')
        .doc(product.id);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete(); // Đã có thì xóa đi (Bỏ tim)
    } else {
      await docRef.set({ // Chưa có thì thêm vào
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'addedAt': Timestamp.now(),
      });
    }
  }

  // Lấy danh sách Wishlist để hiển thị trên trang riêng
  Stream<QuerySnapshot> getWishlist() {
    final user = FirebaseAuth.instance.currentUser;
    return _db
        .collection('wishlists')
        .doc(user?.uid)
        .collection('my_favorites')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}