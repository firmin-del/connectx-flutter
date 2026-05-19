// notification_service.dart
// Service de gestion des notifications push via Firebase Cloud Messaging (FCM).
//
// Firebase Cloud Messaging (FCM) permet d'envoyer des notifications
// aux appareils mobiles même quand l'application est fermée.
//
// Flux d'une notification dans NovaX :
//   1. Utilisateur B envoie un message à Utilisateur A
//   2. Le serveur Laravel détecte que A n'est pas connecté
//   3. Laravel envoie une notification FCM via l'API Firebase
//   4. Firebase réveille l'appareil de A et affiche la notification
//   5. A tape sur la notification → l'app s'ouvre sur le bon chat
//
// ⚠️  CONFIGURATION REQUISE :
//   - Créer un projet Firebase sur https://console.firebase.google.com
//   - Télécharger google-services.json (Android) et GoogleService-Info.plist (iOS)
//   - Placer google-services.json dans android/app/
//   - Exécuter : flutterfire configure
//   - Voir : https://firebase.flutter.dev/docs/messaging/overview

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Handler pour les messages reçus en arrière-plan (hors de l'app)
// DOIT être une fonction top-level (pas une méthode de classe)
// car elle s'exécute dans un isolate séparé
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note : Firebase Core est déjà initialisé dans main.dart
  debugPrint('[FCM] Message reçu en arrière-plan: ${message.messageId}');
  // TODO: Sauvegarder le message dans Hive pour l'afficher au prochain démarrage
}

class NotificationService {
  // Instance Firebase Messaging
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Token FCM de l'appareil (identifiant unique pour les notifications)
  static String? _fcmToken;

  // Callback appelé quand l'utilisateur tape sur une notification
  // Défini par le ChatCubit pour naviguer vers le bon chat
  static Function(String chatId)? onNotificationTapped;

  // ── Initialisation ────────────────────────────────────────────

  /// Initialise Firebase Messaging et configure les handlers.
  /// Appelé dans main.dart après Firebase.initializeApp().
  static Future<void> init() async {
    // Enregistre le handler pour les messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Demande la permission d'envoyer des notifications (iOS + Android 13+)
    await _requestPermission();

    // Récupère le token FCM de cet appareil
    await _getFcmToken();

    // Configure les handlers pour les messages reçus
    _setupMessageHandlers();
  }

  // ── Permissions ───────────────────────────────────────────────

  /// Demande la permission d'afficher des notifications.
  /// Sur Android < 13 : accordée automatiquement.
  /// Sur iOS et Android 13+ : affiche une boîte de dialogue système.
  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true, // Afficher des alertes
      badge: true, // Afficher le badge sur l'icône de l'app
      sound: true, // Jouer un son
      provisional: false, // Demander une permission explicite
    );

    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  // ── Token FCM ─────────────────────────────────────────────────

  /// Récupère le token FCM unique de cet appareil.
  /// Ce token est envoyé au serveur Laravel pour cibler cet appareil.
  static Future<void> _getFcmToken() async {
    // Sur le web, on utilise un VAPID key (clé publique web push)
    // Sur mobile, le token est généré automatiquement par Firebase
    _fcmToken = await _messaging.getToken();
    debugPrint('[FCM] Token: $_fcmToken');

    // Écoute les changements de token (token peut changer après réinstallation)
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('[FCM] Token rafraîchi: $newToken');
      // TODO: Envoyer le nouveau token au serveur Laravel
      // AuthService.updateFcmToken(newToken);
    });
  }

  /// Retourne le token FCM actuel de l'appareil.
  /// À envoyer au serveur Laravel lors du login pour recevoir les notifications.
  static String? get fcmToken => _fcmToken;

  // ── Handlers de messages ──────────────────────────────────────

  /// Configure les 3 cas de réception d'un message FCM :
  ///   1. App au premier plan (foreground)
  ///   2. App en arrière-plan, utilisateur tape la notification
  ///   3. App fermée, utilisateur tape la notification
  static void _setupMessageHandlers() {
    // CAS 1 : Message reçu quand l'app est OUVERTE (foreground)
    // Firebase n'affiche PAS de notification automatiquement dans ce cas
    // On doit l'afficher manuellement ou simplement mettre à jour l'UI
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Message foreground: ${message.notification?.title}');

      // Si le message contient des données de chat, notifie le Cubit
      final chatId = message.data['chat_id'];
      if (chatId != null) {
        // L'app est ouverte → pas besoin de naviguer, le chat se met à jour
        // via Socket.io qui reçoit le message en temps réel
        debugPrint('[FCM] Nouveau message dans le chat: $chatId');
      }
    });

    // CAS 2 : App en ARRIÈRE-PLAN, utilisateur tape la notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification tapée (background): ${message.data}');
      _handleNotificationTap(message);
    });

    // CAS 3 : App FERMÉE, vérifie si elle a été ouverte via une notification
    _checkInitialMessage();
  }

  /// Vérifie si l'app a été lancée en tapant sur une notification.
  static Future<void> _checkInitialMessage() async {
    // getInitialMessage() retourne le message si l'app était fermée
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('[FCM] App lancée via notification: ${initialMessage.data}');
      _handleNotificationTap(initialMessage);
    }
  }

  /// Gère la navigation quand l'utilisateur tape sur une notification.
  static void _handleNotificationTap(RemoteMessage message) {
    // Récupère l'ID du chat depuis les données de la notification
    final chatId = message.data['chat_id'];
    if (chatId != null && onNotificationTapped != null) {
      // Appelle le callback pour naviguer vers le bon chat
      onNotificationTapped!(chatId);
    }
  }

  // ── Abonnements aux topics ────────────────────────────────────

  /// Abonne l'appareil à un topic pour recevoir des notifications de groupe.
  /// Ex: s'abonner au topic "chat_42" pour recevoir les messages du groupe 42.
  static Future<void> subscribeToChat(String chatId) async {
    await _messaging.subscribeToTopic('chat_$chatId');
    debugPrint('[FCM] Abonné au topic: chat_$chatId');
  }

  /// Désabonne l'appareil d'un topic.
  static Future<void> unsubscribeFromChat(String chatId) async {
    await _messaging.unsubscribeFromTopic('chat_$chatId');
    debugPrint('[FCM] Désabonné du topic: chat_$chatId');
  }
}
