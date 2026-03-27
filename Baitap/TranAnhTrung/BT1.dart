import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    ));

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  String _result = "";

  void _calculate() {
    setState(() {
      double? amount = double.tryParse(_amountController.text);
      double? rate = double.tryParse(_rateController.text);

      if (amount != null && rate != null && rate > 0) {
        _result = (log(2) / log(1 + (rate / 100))).toStringAsFixed(1);
      } else {
        _result = "Lỗi";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        title: Row(
          children: const [
            Text('Máy tính lãi suất', style: TextStyle(color: Colors.black, fontSize: 18)),
            Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
        actions: const [
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(flex: 2, child: Text('Số tiền', style: TextStyle(color: Colors.black, fontSize: 16))),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5)),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(flex: 2, child: Text('Lãi hàng năm', style: TextStyle(color: Colors.black, fontSize: 16))),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5)),
                    child: TextField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                const Text('Số năm để tiền tăng gấp đôi', style: TextStyle(color: Colors.black, fontSize: 16)),
                const SizedBox(width: 20),
                Text(_result, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _calculate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5)),
                  child: const Text('Tính toán', style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
