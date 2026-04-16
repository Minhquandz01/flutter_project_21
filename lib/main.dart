import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Views/products_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HondaEcommerceApp());
}

class HondaEcommerceApp extends StatelessWidget {
  const HondaEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Honda Showroom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', // Bạn có thể thêm font chữ hiện đại nếu muốn
        useMaterial3: true,
      ),
      home: const ProductsView(),
    );
  }
}