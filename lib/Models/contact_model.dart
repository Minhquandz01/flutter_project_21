class ContactRequest {
  final String name;
  final String email;
  final String phone;
  final String subject;
  final String message;

  ContactRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(), // Lưu lại thời gian khách gửi
    };
  }
}