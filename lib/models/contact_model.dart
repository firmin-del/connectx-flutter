class ContactModel {
  final String id;
  final String name;
  final String? avatar;
  final bool isOnline;

  ContactModel({
    required this.id,
    required this.name,
    this.avatar,
    this.isOnline = false,
  });
}