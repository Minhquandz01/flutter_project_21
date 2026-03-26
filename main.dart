import 'package:flutter/material.dart';

void main() => runApp(const CarSalesApp());

class CarSalesApp extends StatelessWidget {
  const CarSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const TeamIntroPage(),
    );
  }
}

class TeamIntroPage extends StatelessWidget {
  const TeamIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 Showroom Ô Tô - Team 21', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.directions_car_filled, size: 80, color: Colors.red),
            const Text(
              'CHUYÊN ĐỀ 2',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Divider(),
            ),
          
            memberCard('Nguyễn Văn Quân', '20224113', 'Nhóm trưởng', Icons.stars),
            memberCard('Bùi Bảo Khang', '20224346', 'Thành viên', Icons.person),
            memberCard('Trần Anh Trung', '20224343', 'Thành viên', Icons.person),
            
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.info),
              label: const Text('Thông tin dự án: App Bán Ô Tô'),
            )
          ],
        ),
      ),
    );
  }

  Widget memberCard(String name, String id, String role, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Icon(icon, color: Colors.red),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('MSSV: $id'),
        trailing: Text(role, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      ),
    );
  }
}
