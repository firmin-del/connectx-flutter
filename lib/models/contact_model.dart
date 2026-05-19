// contact_model.dart
// Modèle représentant un contact dans NovaX.
//
// Un contact est un utilisateur NovaX que l'on peut contacter.
// Il est différent d'un UserModel car il représente
// la vue simplifiée d'un utilisateur dans la liste de contacts.

class ContactModel {
  final String id; // ID unique de l'utilisateur NovaX
  final String name; // Nom complet
  final String? avatar; // URL de la photo de profil (nullable)
  final bool isOnline; // Statut en ligne (mis à jour via Socket.io)
  final String? phoneNumber; // Numéro de téléphone (optionnel)

  ContactModel({
    required this.id,
    required this.name,
    this.avatar,
    this.isOnline = false,
    this.phoneNumber,
  });

  /// Crée un ContactModel depuis un JSON reçu de l'API Laravel
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  /// Convertit en JSON pour l'envoi à l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'is_online': isOnline,
      'phone_number': phoneNumber,
    };
  }
}
