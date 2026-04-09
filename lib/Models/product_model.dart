// Vị trí lưu: lib/models/product_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final String year;
  final String desc;
  final String price;
  final String imageUrl;
  final List<Color> colors;

  ProductModel({
    required this.id, required this.name, required this.category,
    required this.year, required this.desc, required this.price,
    required this.imageUrl, required this.colors
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    List<Color> parsedColors = [];
    if (data['colors'] != null) {
      for(var colorValue in data['colors']) {
        parsedColors.add(Color(colorValue as int));
      }
    }

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      year: data['year'] ?? '',
      desc: data['desc'] ?? '',
      price: data['price'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      colors: parsedColors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'year': year,
      'desc': desc,
      'price': price,
      'imageUrl': imageUrl, // Đẩy link ảnh lên mạng
      'colors': colors.map((c) => c.value).toList(),
    };
  }
}