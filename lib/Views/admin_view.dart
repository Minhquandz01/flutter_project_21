import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Controllers/product_controller.dart';
import '../Models/product_model.dart';
import 'Widgets/custom_header.dart';
import 'Widgets/custom_footer.dart';
import 'contact_admin_view.dart';
import 'test_drive_admin_view.dart';
import 'dashboard_view.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final ProductController _controller = ProductController();
  int _selectedSidebarIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: const CustomHeader(activeTab: 'admin'),
      body: isMobile
          ? Column(
        children: [
          _buildMobileMenu(),
          Expanded(child: _buildMainContent(isMobile)),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent(isMobile)),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    double padding = isMobile ? 15.0 : 40.0;

    return _selectedSidebarIndex == 0
        ? const DashboardView()
        : _selectedSidebarIndex == 1
        ? _buildProductManager(isMobile)
        : _selectedSidebarIndex == 2
        ? Padding(padding: EdgeInsets.all(padding), child: const ContactAdminManager())
        : Padding(padding: EdgeInsets.all(padding), child: const TestDriveAdminManager());
  }

  Widget _buildProductManager(bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quản lý Sản phẩm', style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A24))),
                const SizedBox(height: 5),
                Text('Cập nhật và theo dõi kho hàng xe máy', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 30),
                _buildTable(isMobile),
              ],
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }

  Widget _buildTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 30),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              runSpacing: 15,
              children: [
                Text('Danh sách Xe', style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC0000), padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _showDialog(isMobile: isMobile),
                  icon: const Icon(Icons.add_box, color: Colors.white, size: 20),
                  label: Text('Thêm Xe Mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),

          ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                if (_controller.isLoading) return const Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator(color: Color(0xFFCC0000))));

                // GIẢI PHÁP ĐẶC TRỊ ÉP BẢNG FULL WIDTH TRÊN PC
                return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          // Lệnh này bắt buộc bảng phải rộng ÍT NHẤT bằng màn hình
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            horizontalMargin: 30, headingRowHeight: 60, dataRowMinHeight: 80, dataRowMaxHeight: 80,
                            headingTextStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13),
                            columns: const [DataColumn(label: Text('Tên xe')), DataColumn(label: Text('Giá bán')), DataColumn(label: Text('Tồn kho')), DataColumn(label: Text('Thao tác'))],
                            rows: _controller.allProducts.map((p) => DataRow(cells: [
                              DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                              DataCell(Text(p.price, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)), child: Text('${p.stock} chiếc', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)))),
                              DataCell(Row(
                                  mainAxisSize: MainAxisSize.min, // Chống tràn ngang trên row con
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: () => _showDialog(p: p, isMobile: isMobile)),
                                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _controller.deleteProduct(p.id)),
                                  ]
                              )),
                            ])).toList(),
                          ),
                        ),
                      );
                    }
                );
              }
          )
        ],
      ),
    );
  }

  void _showDialog({ProductModel? p, required bool isMobile}) {
    bool isEdit = p != null;
    final name = TextEditingController(text: isEdit ? p.name : '');
    final price = TextEditingController(text: isEdit ? p.price.replaceAll(RegExp(r'[^0-9]'), '') : '');
    final imageUrl = TextEditingController(text: isEdit ? p.imageUrl : '');
    final stock = TextEditingController(text: isEdit ? p.stock.toString() : '0');
    final desc = TextEditingController(text: isEdit ? p.desc : '');
    String cat = isEdit ? p.category : 'Scooter';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSTB) => AlertDialog(
          backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEdit ? 'Cập nhật xe' : 'Thêm xe', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: isMobile ? double.infinity : 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStyledTextField(name, 'Tên xe'), const SizedBox(height: 15),
                  _buildStyledTextField(imageUrl, 'Link ảnh', icon: Icons.link, onChanged: (v) => setStateSTB(() {})),
                  if (imageUrl.text.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(imageUrl.text, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 80, color: Colors.red[50], child: const Center(child: Text('Lỗi ảnh')))))),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(value: cat, decoration: _getInputDecoration('Danh mục'), items: const [DropdownMenuItem(value: 'Scooter', child: Text('Xe tay ga')), DropdownMenuItem(value: 'Sport', child: Text('Xe thể thao')), DropdownMenuItem(value: 'Cub', child: Text('Xe số'))], onChanged: (v) => cat = v!),
                  const SizedBox(height: 15),
                  Row(children: [Expanded(child: _buildStyledTextField(price, 'Giá bán', isNumber: true, isPrice: true)), const SizedBox(width: 15), Expanded(child: _buildStyledTextField(stock, 'Tồn kho', isNumber: true))]),
                  const SizedBox(height: 15),
                  _buildStyledTextField(desc, 'Mô tả', maxLines: 3),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC0000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                final prod = ProductModel(id: isEdit ? p.id : '', name: name.text, price: '${price.text} VNĐ', category: cat, imageUrl: imageUrl.text, stock: int.tryParse(stock.text) ?? 0, sold: isEdit ? p.sold : 0, year: '2024', desc: desc.text.isEmpty ? 'Chưa có' : desc.text, colors: []);
                isEdit ? _controller.updateProduct(prod) : _controller.addProduct(prod);
                Navigator.pop(ctx);
              },
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField(TextEditingController controller, String label, {IconData? icon, String? suffix, bool isNumber = false, bool isPrice = false, int maxLines = 1, Function(String)? onChanged}) {
    return TextFormField(controller: controller, maxLines: maxLines, keyboardType: isNumber ? TextInputType.number : TextInputType.text, inputFormatters: isPrice ? [CurrencyFormatter()] : [], onChanged: onChanged, decoration: _getInputDecoration(label, icon: icon, suffix: suffix));
  }
  InputDecoration _getInputDecoration(String label, {IconData? icon, String? suffix}) {
    return InputDecoration(labelText: label, suffixText: suffix, suffixIcon: icon != null ? Icon(icon, color: Colors.grey[500]) : null, filled: true, fillColor: Colors.grey[50], enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[200]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCC0000))));
  }

  Widget _buildSidebar() {
    return Container(
        width: 260, color: const Color(0xFF161B22),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(30, 40, 30, 40), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('HONDA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), Text('Trang Quản Trị', style: TextStyle(color: Colors.grey, fontSize: 13))])),
              _sidebarItem(0, Icons.dashboard_outlined, 'Dashboard'), _sidebarItem(1, Icons.inventory_2_outlined, 'Sản phẩm'), _sidebarItem(2, Icons.email_outlined, 'Tin nhắn liên hệ'), _sidebarItem(3, Icons.calendar_today_outlined, 'Lịch lái thử'),
            ]
        )
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label) {
    bool active = _selectedSidebarIndex == index;
    return Container(margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), decoration: BoxDecoration(color: active ? const Color(0xFFCC0000) : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: ListTile(leading: Icon(icon, color: active ? Colors.white : Colors.grey[500], size: 20), title: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey[500], fontWeight: active ? FontWeight.bold : FontWeight.w500, fontSize: 15)), onTap: () => setState(() => _selectedSidebarIndex = index)));
  }

  Widget _buildMobileMenu() {
    return Container(
      width: double.infinity, color: const Color(0xFF161B22), padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [const SizedBox(width: 15), _mobileMenuItem(0, Icons.dashboard_outlined, 'Dashboard'), _mobileMenuItem(1, Icons.inventory_2_outlined, 'Sản phẩm'), _mobileMenuItem(2, Icons.email_outlined, 'Tin nhắn'), _mobileMenuItem(3, Icons.calendar_today_outlined, 'Lịch hẹn'), const SizedBox(width: 15)]),
      ),
    );
  }

  Widget _mobileMenuItem(int index, IconData icon, String label) {
    bool active = _selectedSidebarIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSidebarIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(color: active ? const Color(0xFFCC0000) : Colors.transparent, borderRadius: BorderRadius.circular(20), border: active ? null : Border.all(color: Colors.grey[800]!)),
        child: Row(children: [Icon(icon, color: active ? Colors.white : Colors.grey[400], size: 16), const SizedBox(width: 6), Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 13))]),
      ),
    );
  }
}

class CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String num = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String fmt = ''; int c = 0;
    for (int i = num.length - 1; i >= 0; i--) { if (c == 3) { fmt = '.$fmt'; c = 0; } fmt = num[i] + fmt; c++; }
    return TextEditingValue(text: fmt, selection: TextSelection.collapsed(offset: fmt.length));
  }
}