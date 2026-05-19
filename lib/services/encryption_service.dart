// encryption_service.dart
// Service de chiffrement End-to-End (E2EE) pour NovaX.
//
// Principe du chiffrement E2EE :
//   - Le message est chiffré AVANT d'être envoyé au serveur
//   - Le serveur Node.js/Laravel ne voit que du texte illisible (ciphertext)
//   - Seul le destinataire qui possède la clé peut déchiffrer
//   - Même si le serveur est piraté, les messages restent illisibles
//
// Algorithme utilisé : AES-256-CBC
//   - AES = Advanced Encryption Standard (standard mondial)
//   - 256 = taille de la clé en bits (très sécurisé)
//   - CBC = Cipher Block Chaining (mode de chiffrement par blocs)
//
// Coordination avec RSI (Michaël) :
//   - La clé partagée sera échangée via un protocole asymétrique
//   - Pour l'instant on utilise une clé symétrique partagée (simplification)
//   - TODO: Implémenter l'échange de clés Diffie-Hellman avec Michaël

import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionService {
  // Clé de stockage dans SharedPreferences
  static const String _encryptionKeyPref = 'encryption_key';

  // ── Gestion de la clé ─────────────────────────────────────────

  /// Génère une clé AES-256 aléatoire et la sauvegarde localement.
  /// Appelé une seule fois à la création du compte.
  ///
  /// Une clé AES-256 = 32 octets = 256 bits de données aléatoires.
  static Future<String> generateAndSaveKey() async {
    // Génère 32 octets aléatoires cryptographiquement sûrs
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));

    // Encode en Base64 pour le stockage (Base64 = texte lisible depuis bytes)
    final keyBase64 = base64Encode(keyBytes);

    // Sauvegarde localement
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_encryptionKeyPref, keyBase64);

    return keyBase64;
  }

  /// Récupère la clé de chiffrement stockée localement.
  /// Si aucune clé n'existe, en génère une nouvelle.
  static Future<String> getOrCreateKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? keyBase64 = prefs.getString(_encryptionKeyPref);

    // Si pas de clé, en crée une nouvelle
    if (keyBase64 == null || keyBase64.isEmpty) {
      keyBase64 = await generateAndSaveKey();
    }

    return keyBase64;
  }

  // ── Chiffrement ───────────────────────────────────────────────

  /// Chiffre un message texte avec AES-256-CBC.
  ///
  /// Retourne une chaîne au format : "IV:CipherText" encodée en Base64.
  /// L'IV (Initialization Vector) est un nombre aléatoire unique par message
  /// qui garantit que deux messages identiques donnent des ciphertexts différents.
  ///
  /// [plainText] : le message en clair à chiffrer
  /// [keyBase64] : la clé AES-256 en Base64 (optionnel, utilise la clé locale si null)
  static Future<String> encrypt(String plainText, {String? keyBase64}) async {
    // Récupère la clé (locale ou fournie)
    final key = keyBase64 ?? await getOrCreateKey();

    // Décode la clé Base64 en bytes
    final keyBytes = base64Decode(key);

    // Crée l'objet Key pour la librairie encrypt
    // enc.Key.fromBase64 attend exactement 32 bytes pour AES-256
    final encKey = enc.Key(keyBytes as dynamic);

    // Génère un IV (Initialization Vector) aléatoire de 16 bytes
    // L'IV doit être différent pour chaque message (jamais réutilisé)
    final iv = enc.IV.fromSecureRandom(16);

    // Crée l'encrypteur AES en mode CBC
    final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));

    // Chiffre le message
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Retourne "IV:CipherText" pour que le destinataire puisse déchiffrer
    // Les deux parties sont encodées en Base64 pour être transmissibles
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Déchiffre un message chiffré avec AES-256-CBC.
  ///
  /// [cipherText] : la chaîne "IV:CipherText" retournée par encrypt()
  /// [keyBase64]  : la clé AES-256 en Base64
  static Future<String> decrypt(String cipherText, {String? keyBase64}) async {
    try {
      // Récupère la clé
      final key = keyBase64 ?? await getOrCreateKey();
      final keyBytes = base64Decode(key);
      final encKey = enc.Key(keyBytes as dynamic);

      // Sépare l'IV du ciphertext (format : "IV:CipherText")
      final parts = cipherText.split(':');
      if (parts.length != 2) {
        // Format invalide → retourne le texte tel quel (message non chiffré)
        return cipherText;
      }

      // Reconstruit l'IV depuis le Base64
      final iv = enc.IV.fromBase64(parts[0]);

      // Crée l'encrypteur avec la même clé et le même IV
      final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));

      // Déchiffre et retourne le texte en clair
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      // En cas d'erreur (mauvaise clé, format invalide), retourne le texte brut
      // Cela évite que l'app plante si un message n'est pas chiffré
      return cipherText;
    }
  }

  // ── Utilitaires ───────────────────────────────────────────────

  /// Vérifie si une chaîne ressemble à un message chiffré (format "IV:Cipher").
  static bool isEncrypted(String text) {
    // Un message chiffré contient exactement un ':' et les deux parties
    // sont du Base64 valide
    final parts = text.split(':');
    if (parts.length != 2) return false;
    try {
      base64Decode(parts[0]);
      base64Decode(parts[1]);
      return true;
    } catch (_) {
      return false;
    }
  }
}
