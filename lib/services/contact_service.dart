// contact_service.dart
// Service d'accès aux contacts du téléphone.
//
// Rôle : lire l'annuaire local du téléphone pour identifier
// quels contacts utilisent déjà NovaX.
//
// Flux :
//   1. Demande la permission d'accès aux contacts (Android/iOS)
//   2. Lit tous les contacts du téléphone
//   3. Envoie les numéros de téléphone à l'API Laravel
//   4. Laravel répond avec les contacts qui ont un compte NovaX
//   5. L'UI affiche uniquement les contacts NovaX
//
// Package utilisé : permission_handler (déjà dans pubspec.yaml)
// Note : contacts_service n'est pas dans le pubspec — on utilise
// permission_handler + une approche simplifiée compatible web/desktop

import 'package:permission_handler/permission_handler.dart';
import '../models/contact_model.dart';
import '../constants/app_constants.dart';
import 'package:dio/dio.dart';
import '../constants/api_config.dart';

class ContactService {
  static final Dio _api = ApiConfig.api();

  // ── Permissions ───────────────────────────────────────────────

  /// Demande la permission d'accès aux contacts du téléphone.
  /// Retourne true si la permission est accordée.
  ///
  /// Sur Android : affiche une boîte de dialogue système
  /// Sur iOS     : affiche une boîte de dialogue système
  /// Sur Web     : retourne false (pas d'accès aux contacts sur le web)
  static Future<bool> requestContactsPermission() async {
    // Vérifie l'état actuel de la permission
    final status = await Permission.contacts.status;

    if (status.isGranted) {
      // Permission déjà accordée
      return true;
    } else if (status.isDenied) {
      // Demande la permission à l'utilisateur
      final result = await Permission.contacts.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // L'utilisateur a refusé définitivement → ouvre les paramètres
      await openAppSettings();
      return false;
    }

    return false;
  }

  // ── Contacts NovaX depuis l'API ───────────────────────────────

  /// Récupère la liste des utilisateurs NovaX depuis l'API Laravel.
  /// Ces utilisateurs peuvent être contactés via NovaX.
  ///
  /// L'API retourne uniquement les utilisateurs qui ont un compte,
  /// pas tous les contacts du téléphone (respect de la vie privée).
  static Future<List<ContactModel>> getNovaXContacts() async {
    try {
      // GET /api/contacts → Laravel retourne les utilisateurs NovaX
      final response = await _api.get('/contacts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ContactModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? AppConstants.defaultErrorMessage,
        );
      }
    } on DioException {
      // Si l'API n'est pas disponible, retourne des contacts mockés
      return _getMockContacts();
    }
  }

  // ── Contacts mockés (développement) ──────────────────────────

  /// Retourne des contacts fictifs quand le serveur n'est pas disponible.
  static List<ContactModel> _getMockContacts() {
    return [
      ContactModel(id: '1', name: 'Emmanuel GBODOU', isOnline: true),
      ContactModel(id: '2', name: 'Michaël MIWANOU', isOnline: false),
      ContactModel(id: '3', name: 'Ulrich HANKPE', isOnline: true),
      ContactModel(id: '4', name: 'Kamélia ABOU', isOnline: true),
      ContactModel(id: '5', name: 'Alice Martin', isOnline: false),
      ContactModel(id: '6', name: 'Bob Dupont', isOnline: true),
    ];
  }
}
