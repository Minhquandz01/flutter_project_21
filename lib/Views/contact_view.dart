import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Controllers/contact_controller.dart';
import '../Models/contact_model.dart';
import 'Widgets/custom_header.dart';
import 'Widgets/custom_footer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ContactController _controller = ContactController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedSubject;

  final List<Map<String, String>> faqs = [
    {"question": "Chính sách bảo hành xe mới như thế nào?", "answer": "Tất cả xe máy Honda mới đều được bảo hành chính hãng 3 năm hoặc 30.000km tùy điều kiện nào đến trước."},
    {"question": "Showroom có hỗ trợ mua xe trả góp không?", "answer": "Chúng tôi hỗ trợ trả góp qua thẻ tín dụng và các công ty tài chính với lãi suất cực kỳ hấp dẫn chỉ từ 0%."},
    {"question": "Tôi có thể đặt lịch lái thử xe ở đâu?", "answer": "Bạn có thể gọi trực tiếp vào Hotline hoặc điền form liên hệ bên trên, chọn chủ đề 'Đặt lịch lái thử'."},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showChatDialog(context),
        backgroundColor: const Color(0xFFCC0000),
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: const Text("Chat với CSKH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomHeader(activeTab: 'contact'),
            const Padding(
              padding: EdgeInsets.only(top: 60, bottom: 10),
              child: Text("Liên Hệ Với Chúng Tôi", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Color(0xFF0B1629))),
            ),
            const Text("Kết nối với Honda Showroom Hà Nội. Chúng tôi luôn sẵn sàng hỗ trợ bạn!", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
              child: isMobile
                  ? Column(children: [_buildLeftInfo(), const SizedBox(height: 40), _buildRightForm(context)])
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildLeftInfo()),
                  const SizedBox(width: 40),
                  Expanded(flex: 2, child: _buildRightForm(context)),
                ],
              ),
            ),
            _buildFAQSection(isMobile),
            _buildMapSection(),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftInfo() {
    return Column(
      children: [
        _infoCard(Icons.phone_outlined, "Điện thoại", "Gọi cho chúng tôi 24/7", "1800-123-456", Colors.red, onTap: () => _controller.callPhone("1800-123-456")),
        const SizedBox(height: 20),
        _infoCard(Icons.email_outlined, "Email", "Gửi phản hồi bất cứ lúc nào", "support@honda.com.vn", Colors.red, onTap: () => _controller.sendEmail("support@honda.com.vn")),
        const SizedBox(height: 20),
        _infoCard(Icons.location_on_outlined, "Địa chỉ", "Ghé thăm Showroom của chúng tôi", "198 Trần Quang Khải,\nHà Nội, Việt Nam", Colors.red, onTap: () => _controller.openMap()),
        const SizedBox(height: 20),
        _infoCard(Icons.access_time, "Giờ làm việc", "Thứ Hai - Thứ Sáu: 8:00 - 18:00\nThứ Bảy: 8:00 - 17:00", "Chủ Nhật: Nghỉ", Colors.red),
      ],
    );
  }

  Widget _buildRightForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gửi Lời Nhắn Cho Chúng Tôi", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _customField("Họ và tên *", "Nhập tên của bạn", controller: _nameController)),
              const SizedBox(width: 20),
              Expanded(child: _customField("Địa chỉ Email *", "email_cua_ban@example.com", controller: _emailController)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _customField("Số điện thoại", "Ví dụ: 0912 345 678", controller: _phoneController)),
              const SizedBox(width: 20),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Chủ đề cần tư vấn *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Chọn chủ đề"),
                            value: _selectedSubject,
                            items: const [
                              DropdownMenuItem(value: 'Mua xe mới', child: Text('Mua xe mới')),
                              DropdownMenuItem(value: 'Bảo dưỡng / Sửa chữa', child: Text('Bảo dưỡng / Sửa chữa')),
                              DropdownMenuItem(value: 'Phụ tùng', child: Text('Hỏi về phụ tùng')),
                              DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                            ],
                            onChanged: (v) => setState(() => _selectedSubject = v),
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
          const SizedBox(height: 20),
          _customField("Nội dung tin nhắn *", "Cho chúng tôi biết chúng tôi có thể giúp gì bạn...", maxLines: 4, controller: _messageController),
          const SizedBox(height: 30),

          // NÚT BẤM THÔNG MINH (Không cần Provider)
          SizedBox(
            width: double.infinity,
            child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 20)),
                    onPressed: _controller.isLoading
                        ? null
                        : () async {
                      final req = ContactRequest(
                        name: _nameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text,
                        subject: _selectedSubject ?? 'Khác',
                        message: _messageController.text,
                      );

                      await _controller.submitForm(req);

                      if (_controller.message == "success") {
                        _nameController.clear(); _emailController.clear(); _phoneController.clear(); _messageController.clear();
                        setState(() => _selectedSubject = null);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cảm ơn bạn! Lời nhắn đã được gửi tới hệ thống.'), backgroundColor: Colors.green));
                      } else if (_controller.message.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_controller.message), backgroundColor: Colors.red));
                      }
                      _controller.resetMessage();
                    },
                    child: _controller.isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Gửi liên hệ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final LatLng hondaLocation = const LatLng(21.0285, 105.8566);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          const Text("Bản Đồ Showroom Hà Nội", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1629))),
          const SizedBox(height: 5),
          const Text("198 Trần Quang Khải, Lý Thái Tổ, Hoàn Kiếm, Hà Nội", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 400, width: double.infinity,
              child: FlutterMap(
                options: const MapOptions(initialCenter: LatLng(21.0285, 105.8566), initialZoom: 15.0),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                  MarkerLayer(markers: [Marker(point: hondaLocation, width: 80, height: 80, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
      child: Column(
        children: [
          const Text("Câu Hỏi Thường Gặp (FAQ)", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0B1629))),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
            child: ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: faqs.length, separatorBuilder: (c, i) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(faqs[index]["question"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(faqs[index]["answer"]!, style: const TextStyle(color: Colors.grey, height: 1.5)))],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    final chatController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 380, height: 480,
          child: Column(
            children: [
              Container(
                color: const Color(0xFFCC0000), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    const Icon(Icons.support_agent, color: Colors.white, size: 28), const SizedBox(width: 10),
                    const Text("CSKH Trực tuyến", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.white))
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey.shade100, padding: const EdgeInsets.all(20), width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: const Text("Chào bạn! Honda Showroom có thể giúp gì cho bạn hôm nay?", style: TextStyle(color: Colors.black87, height: 1.5, fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: chatController,
                        decoration: InputDecoration(hintText: "Nhập tin nhắn...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey.shade200, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: const Color(0xFFCC0000), radius: 24,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tin nhắn đã được gửi tới tư vấn viên!'), backgroundColor: Colors.green));
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String sub, String content, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white)),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(content, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _customField(String label, String hint, {int maxLines = 1, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))),
        ),
      ],
    );
  }
}