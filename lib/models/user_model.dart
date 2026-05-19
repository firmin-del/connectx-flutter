// user_model.dart
// Modèle utilisateur NovaX.
//
// Les noms de champs dans fromJson() correspondent EXACTEMENT
// au format JSON retourné par l'API Laravel d'Emmanuel (snake_case) :
//   profile_picture, phone_number, is_online, last_seen
//
// Réponse JSON de l'API :
// {
//   "id": 1,
//   "name": "Emmanuel GBODOU",
//   "email": "emmanuel@novax.com",
//   "phone_number": "+22901020304",
//   "profile_picture": null,
//   "is_online": true,
//   "last_seen": "2026-05-20T14:32:00.000000Z"
// }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture; // profile_picture côté Laravel
  final String? phoneNumber; // phone_number côté Laravel
  final bool isOnline; // is_online côté Laravel
  final DateTime? lastSeen; // last_seen côté Laravel

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phoneNumber,
    this.isOnline = false,
    this.lastSeen,
  });

  /// Crée un UserModel depuis le JSON retourné par l'API Laravel.
  /// Les champs Laravel sont en snake_case → on les mappe en camelCase Dart.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Laravel retourne l'id comme int → on le convertit en String
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      // snake_case Laravel → camelCase Dart
      profilePicture: json['profile_picture'] as String?,
      phoneNumber: json['phone_number'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }

  /// Convertit en JSON pour l'envoi à l'API (snake_case).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'phone_number': phoneNumber,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }
}
