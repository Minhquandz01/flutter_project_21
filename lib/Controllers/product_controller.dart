import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/product_model.dart';

class ProductController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = false;

  String selectedCategory = 'All';
  List<String> categories = ['All', 'Scooter', 'Sport', 'Cub'];

  ProductController() { fetchProducts(); }

  // --- LẤY & LỌC SẢN PHẨM ---
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

  void filterByCategory(String cat) {
    selectedCategory = cat;
    filteredProducts = cat == 'All' ? allProducts : allProducts.where((p) => p.category == cat).toList();
    notifyListeners();
  }

  // ==========================================
  // --- LOGIC GIỎ HÀNG (CART) ---
  // ==========================================

  Future<void> addToCart(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Vui lòng đăng nhập để mua hàng!');
    }

    try {
      final docRef = _db.collection('carts').doc(user.uid).collection('items').doc(product.id);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({'quantity': (doc.data()?['quantity'] ?? 1) + 1});
      } else {
        await docRef.set({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'quantity': 1,
          'addedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Stream<QuerySnapshot> getCartItems() {
    final user = FirebaseAuth.instance.currentUser;
    return _db.collection('carts').doc(user?.uid).collection('items').orderBy('addedAt', descending: true).snapshots();
  }

  Future<void> removeFromCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _db.collection('carts').doc(user.uid).collection('items').doc(productId).delete();
    }
  }

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var snapshots = await _db.collection('carts').doc(user.uid).collection('items').get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  // ==========================================
  // --- LOGIC ĐƠN HÀNG (ORDERS) & TRỪ KHO ---
  // ==========================================

  // Tạo đơn hàng mới
  Future<String> createOrder(List<QueryDocumentSnapshot> cartItems, int totalAmount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Vui lòng đăng nhập!');

    final orderData = {
      'userId': user.uid,
      'userEmail': user.email,
      'items': cartItems.map((doc) => doc.data() as Map<String, dynamic>).toList(),
      'totalAmount': totalAmount,
      'status': 'Chờ thanh toán',
      'createdAt': Timestamp.now(),
    };

    final docRef = await _db.collection('orders').add(orderData);
    return docRef.id;
  }

  // Lấy lịch sử đơn hàng của User đang đăng nhập
  Stream<QuerySnapshot> getUserOrders() {
    final user = FirebaseAuth.instance.currentUser;
    return _db.collection('orders')
        .where('userId', isEqualTo: user?.uid)
        .snapshots();
  }

  // --- LOGIC BẢO DƯỠNG ---
  Stream<QuerySnapshot> getMaintenanceSchedule() {
    final user = FirebaseAuth.instance.currentUser;
    return _db.collection('maintenance')
        .where('userId', isEqualTo: user?.uid)
        .snapshots();
  }

  // Lấy TOÀN BỘ đơn hàng cho Admin
  Stream<QuerySnapshot> getAllOrdersAdmin() {
    return _db.collection('orders').orderBy('createdAt', descending: true).snapshots();
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  // TRỪ SỐ LƯỢNG TRONG KHO (Dùng giao dịch Transaction để an toàn)
  Future<void> updateProductStock(String productId, int quantityPurchased) async {
    try {
      DocumentReference productRef = _db.collection('products').doc(productId);
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(productRef);
        if (!snapshot.exists) return;

        int currentStock = snapshot['stock'] ?? 0;
        int currentSold = snapshot['sold'] ?? 0;

        // Trừ kho, cộng thêm vào số lượng đã bán
        if (currentStock >= quantityPurchased) {
          transaction.update(productRef, {
            'stock': currentStock - quantityPurchased,
            'sold': currentSold + quantityPurchased
          });
        }
      });
    } catch (e) {
      debugPrint("Lỗi cập nhật kho: $e");
    }
  }

  // --- QUẢN TRỊ SẢN PHẨM ---
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
  // --- LOGIC YÊU THÍCH (WISHLIST) ---
  // ==========================================

  Stream<QuerySnapshot> getWishlist() {
    final user = FirebaseAuth.instance.currentUser;
    return _db.collection('wishlist').doc(user?.uid).collection('items').snapshots();
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _db.collection('wishlist').doc(user.uid).collection('items').doc(product.id);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'addedAt': Timestamp.now(),
      });
    }
    notifyListeners();
  }

  // --- LOGIC VOUCHER ---
  Future<Map<String, dynamic>?> applyCoupon(String code) async {
    try {
      final snapshot = await _db.collection('coupons')
          .where('code', isEqualTo: code.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Mã giảm giá không tồn tại!');
      }

      final data = snapshot.docs.first.data();
      // Vì hiện tại chỉ có loại Mua xe, nên không cần check type phức tạp
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
