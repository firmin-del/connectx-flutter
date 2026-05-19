# 🏁 Clôture des Tâches — Dev Mobile (SAMBIENI Firmin)
> Projet NovaX — Clone WhatsApp Flutter  
> Semaine Forge-IMeN — 18 au 23 Mai 2026  
> Repo : https://github.com/firmin-del/connectx-flutter

---

## 1. Bilan Global

Toutes les tâches Dev Mobile du cahier des charges sont **implémentées**.  
L'application Flutter est fonctionnelle, testable, et prête à être branchée sur les serveurs des autres filières.

```
Étape 01 ✅  Architecture de base + Navigation + UI mockée
Étape 02 ✅  Hive + SocketService + AuthService + Cubits complets
Étape 03 ✅  Firebase FCM + E2EE + ChatCubit + Contacts + image_picker
```

---

## 2. Historique Git Complet

```
bbb5a5a  feat: initial commit — NovaX base architecture (Etape 01)
ac24bf4  feat(etape-02): Hive + SocketService + AuthService + Cubits complets
5bbff8d  fix: suppression imports inutiles + desactivation db_definition obsolete
b37a5fe  fix: URL localhost pour web + LoginScreen avec vrais controllers
d489ac6  docs: ajout resume complet etape 02
42e526a  feat(etape-03): ChatCubit + ChatRepository + EncryptionService + NotificationService + ChatListScreen branche
a7186b2  feat: contacts + image_picker dans ChatScreen — taches Dev Mobile completes
```

---

## 3. Structure Complète du Projet

```
lib/
│
├── constants/
│   ├── app_constants.dart      → Toutes les constantes (URLs, clés, durées)
│   └── api_config.dart         → Configuration Dio + intercepteur JWT
│
├── models/
│   ├── user_model.dart         → Modèle utilisateur (fromJson/toJson)
│   ├── chat_model.dart         → Modèle conversation (annoté Hive typeId:3)
│   ├── chat_model.g.dart       → Adaptateur Hive pour ChatModel
│   ├── message_model.dart      → Modèle message (annoté Hive typeId:0)
│   ├── message_model.g.dart    → Adaptateurs Hive pour MessageModel/Status/Type
│   └── contact_model.dart      → Modèle contact (fromJson/toJson)
│
├── services/
│   ├── hive_service.dart       → Base de données locale (init, CRUD messages)
│   ├── socket_service.dart     → WebSocket temps réel (connect, send, events)
│   ├── auth_service.dart       → Appels API auth (login, register, logout, JWT)
│   ├── chat_service.dart       → Appels API conversations (getChats, getMessages)
│   ├── contact_service.dart    → Contacts téléphone + API NovaX
│   ├── notification_service.dart → Firebase FCM (push notifications)
│   └── encryption_service.dart → Chiffrement AES-256 E2EE
│
├── repositories/
│   ├── api_repository/
│   │   └── auth_repository.dart    → Abstraction auth (login, register, logout)
│   ├── chat_repository.dart        → Abstraction conversations (cache + API)
│   └── message_repository.dart     → Abstraction messages (Offline First)
│
├── cubits/
│   └── login/
│       ├── auth_cubit.dart         → Session globale (connecté/déconnecté)
│       ├── login_cubit.dart        → Formulaire de connexion
│       ├── login_state.dart        → États du login (initial/loading/loaded/error)
│       ├── chat_cubit.dart         → Liste des conversations
│       ├── message_cubit.dart      → Messages d'un chat (temps réel)
│       └── theme_cubit.dart        → Mode clair/sombre persistant
│
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart      → Démarrage + vérification token
│   │   ├── login_screen.dart       → Formulaire connexion
│   │   └── register_screen.dart    → Formulaire inscription
│   ├── home/
│   │   ├── chat_list_screen.dart   → Liste conversations (branché ChatCubit)
│   │   └── home_screen.dart        → Écran alternatif (placeholder)
│   ├── chat/
│   │   └── chat_screen.dart        → Conversation + image_picker
│   ├── contacts/
│   │   └── contacts_screen.dart    → Sélection contact + permission
│   └── profile/
│       └── profile_screen.dart     → Profil + toggle thème + déconnexion
│
├── theme/
│   ├── app_theme.dart              → Thèmes light/dark (Google Fonts Questrial)
│   └── app_colors.dart             → Palette de couleurs NovaX
│
└── main.dart                       → Point d'entrée + init Hive + providers
```

---

## 4. Explication Détaillée de Chaque Fichier

---

### 4.1. `constants/app_constants.dart`

**Rôle :** Centralise toutes les constantes pour éviter les "magic strings".

```dart
// URLs des serveurs
static const String baseUrl   = "http://localhost:8000/api"; // Laravel
static const String socketUrl = "http://localhost:3000";     // Node.js

// Clés SharedPreferences (stockage local)
static const String tokenKey    = "auth_token";  // Token JWT
static const String userIdKey   = "user_id";

// Noms des boîtes Hive
static const String messagesBox = "messages_box";
static const String chatsBox    = "chats_box";
```

**Pourquoi c'est important :** Si l'URL du serveur change, on modifie UNE seule ligne ici au lieu de chercher dans tout le code.

---

### 4.2. `constants/api_config.dart`

**Rôle :** Configure le client HTTP Dio avec un intercepteur JWT automatique.

**L'intercepteur JWT :**
```dart
onRequest: (options, handler) async {
  final token = prefs.getString(AppConstants.tokenKey);
  if (token != null) {
    // Ajoute automatiquement "Authorization: Bearer TOKEN" à chaque requête
    options.headers['Authorization'] = 'Bearer $token';
  }
  return handler.next(options);
}
```

**Pourquoi c'est important :** Sans ça, il faudrait ajouter le token manuellement à chaque appel API. L'intercepteur le fait automatiquement.

---

### 4.3. `models/message_model.dart` + `message_model.g.dart`

**Rôle :** Représente un message avec son statut de livraison.

**Annotations Hive :**
```dart
@HiveType(typeId: 0)  // MessageModel — stocké dans Hive
@HiveType(typeId: 1)  // MessageType (text, image, video, file, voice)
@HiveType(typeId: 2)  // MessageStatus (sending, sent, delivered, read, failed)
```

**Statuts de livraison (comme WhatsApp) :**
```
sending   → ⏳ En cours d'envoi (affiché immédiatement)
sent      → ✓  Reçu par le serveur
delivered → ✓✓ Reçu par le destinataire
read      → ✓✓ Lu (coches bleues)
failed    → ✗  Échec d'envoi
```

**`copyWith()` :** Crée une copie avec certains champs modifiés sans toucher à l'original (pattern immuable).

---

### 4.4. `models/chat_model.dart` + `chat_model.g.dart`

**Rôle :** Représente une conversation (privée ou groupe).

```dart
@HiveType(typeId: 3)  // ChatModel — stocké dans Hive
```

**Méthodes utiles :**
```dart
// Retourne le nom à afficher selon le type de conversation
chat.getDisplayName(currentUserId)
// → "Emmanuel GBODOU" pour une conversation privée
// → "Équipe NovaX" pour un groupe

// Aperçu du dernier message (tronqué à 40 caractères)
chat.lastMessagePreview
// → "Salut, tu as vu le projet..."
```

---

### 4.5. `services/hive_service.dart`

**Rôle :** Gère la base de données locale Hive.

**Concept Hive :**
- Hive = base de données NoSQL locale (stockée sur l'appareil)
- Organisée en "boîtes" (boxes) = comme des tables
- Très rapide car tout est en mémoire + fichier binaire

**Opérations disponibles :**
```dart
HiveService.saveMessage(message)              // Sauvegarder un message
HiveService.getMessagesForChat(chatId)        // Lire les messages d'un chat
HiveService.updateMessageStatus(id, status)   // Mettre à jour le statut
HiveService.deleteMessagesForChat(chatId)     // Supprimer une conversation
```

**Pourquoi Hive et pas SQLite :**
- Plus rapide (pas de requêtes SQL)
- Plus simple (pas de schéma à définir)
- Parfait pour les messages (clé = ID du message)
- Demandé explicitement dans le cahier des charges

---

### 4.6. `services/socket_service.dart`

**Rôle :** Connexion WebSocket temps réel vers le serveur Node.js.

**Différence HTTP vs WebSocket :**
```
HTTP classique :
  Client → "Donne-moi les nouveaux messages" → Serveur
  Serveur → "Voici les messages" → Client
  (Le client doit demander en permanence = polling)

WebSocket (Socket.io) :
  Connexion permanente ouverte
  Serveur → "Nouveau message !" → Client (sans que le client demande)
  Client → "Message envoyé" → Serveur
```

**Événements écoutés (serveur → client) :**
```dart
'new_message'  → Nouveau message reçu
'user_online'  → Un contact vient de se connecter
'user_offline' → Un contact vient de se déconnecter
'typing'       → Un contact est en train d'écrire
'stop_typing'  → Un contact a arrêté d'écrire
'message_read' → Un message a été lu (coches bleues)
```

**Événements émis (client → serveur) :**
```dart
SocketService.sendMessage(message)           // Envoyer un message
SocketService.emitTyping(chatId)             // "Je suis en train d'écrire"
SocketService.emitMessageRead(chatId, msgId) // "J'ai lu ce message"
SocketService.joinChat(chatId)               // Rejoindre une room
```

---

### 4.7. `services/auth_service.dart`

**Rôle :** Appels HTTP vers l'API Laravel pour l'authentification.

**Flux complet du login :**
```
LoginScreen (UI)
    ↓ appelle
LoginCubit.login(email, password)
    ↓ appelle
AuthRepository.login(email, password)
    ↓ appelle
AuthService.login(email, password)
    ↓ POST /api/login
Laravel API
    ↓ retourne { token: "JWT...", user: { id, name, email } }
AuthService._saveToken(token, user)
    ↓ sauvegarde dans SharedPreferences
LoginCubit émet LoginStatus.loaded
    ↓
LoginScreen redirige vers /home
```

---

### 4.8. `services/encryption_service.dart`

**Rôle :** Chiffrement AES-256 E2EE avant envoi des messages.

**Principe E2EE :**
```
Utilisateur A tape "Bonjour"
    ↓ encrypt("Bonjour", key)
"aB3xK9mP:xYz123..." (texte chiffré)
    ↓ envoyé via Socket.io
Serveur Node.js (ne voit que du texte illisible)
    ↓ relayé à Utilisateur B
decrypt("aB3xK9mP:xYz123...", key)
    ↓
"Bonjour" (texte en clair)
```

**Format du message chiffré :** `"IV:CipherText"` (les deux en Base64)
- **IV** = Initialization Vector = nombre aléatoire unique par message
- **CipherText** = message chiffré

**Pourquoi l'IV est important :** Sans IV, deux messages identiques donneraient le même ciphertext, ce qui permettrait de déduire le contenu.

---

### 4.9. `services/notification_service.dart`

**Rôle :** Notifications push Firebase FCM.

**3 cas de réception d'une notification :**
```
1. App OUVERTE (foreground)
   → Firebase n'affiche pas de notification automatiquement
   → On met à jour l'UI via Socket.io (déjà connecté)

2. App en ARRIÈRE-PLAN
   → Firebase affiche la notification dans la barre système
   → Tap → onMessageOpenedApp → navigation vers le chat

3. App FERMÉE
   → Firebase réveille l'appareil et affiche la notification
   → Tap → getInitialMessage → navigation vers le chat
```

**⚠️ Configuration requise :**
- Créer un projet Firebase sur console.firebase.google.com
- Télécharger `google-services.json` → placer dans `android/app/`
- Exécuter `flutterfire configure`
- Décommenter les lignes Firebase dans `main.dart`

---

### 4.10. `services/contact_service.dart`

**Rôle :** Accès aux contacts du téléphone + récupération des utilisateurs NovaX.

**Flux :**
```
1. Demande permission contacts (Android/iOS)
2. GET /api/contacts → Laravel retourne les utilisateurs NovaX
3. Affichage dans ContactsScreen
4. Tap sur un contact → navigation vers /chat/{contactId}
```

**Gestion des permissions :**
```dart
Permission.contacts.status  → Vérifie l'état actuel
Permission.contacts.request() → Demande à l'utilisateur
openAppSettings()           → Ouvre les paramètres si refus définitif
```

---

### 4.11. `repositories/auth_repository.dart`

**Rôle :** Couche d'abstraction entre AuthCubit et AuthService.

**Pourquoi ce pattern ?**
- Le Cubit ne sait pas si les données viennent d'une API, d'une base locale, ou d'un mock
- Si on change de backend (Laravel → autre), on modifie seulement le Repository
- Facilite les tests unitaires (on peut remplacer le Repository par un faux)

---

### 4.12. `repositories/message_repository.dart`

**Rôle :** Stratégie "Offline First" pour les messages.

```
Envoi d'un message :
  1. Sauvegarde IMMÉDIATEMENT dans Hive (statut: sending)
     → L'UI affiche le message instantanément
  2. Envoie via Socket.io au serveur
  3. Succès → statut: sent
  4. Échec  → statut: failed (message visible mais marqué)

Réception d'un message :
  1. Arrive via Socket.io
  2. Sauvegardé dans Hive (statut: delivered)
  3. Affiché dans l'UI
  4. Marqué "lu" automatiquement si le chat est ouvert
```

---

### 4.13. `repositories/chat_repository.dart`

**Rôle :** Gestion des conversations avec stratégie cache.

```dart
// Retour instantané depuis Hive (pas de réseau)
getCachedChats()

// Chargement depuis l'API Laravel (réseau)
fetchChatsFromApi()

// Historique des messages avec pagination
fetchMessagesFromApi(chatId, page: 1)
```

---

### 4.14. `cubits/login/auth_cubit.dart`

**Rôle :** Gestion de la session globale (disponible dans toute l'app).

**États possibles :**
```dart
AuthStatus.unknown         → Vérification en cours (SplashScreen)
AuthStatus.authenticated   → Connecté → affiche /home
AuthStatus.unauthenticated → Non connecté → affiche /sign_in
```

**Méthodes clés :**
```dart
checkAuthStatus()    // Vérifie le token au démarrage (SplashScreen)
setAuthenticated()   // Appelé après login réussi + connecte Socket.io
logout()             // Supprime token + déconnecte Socket.io
```

---

### 4.15. `cubits/login/login_cubit.dart`

**Rôle :** Logique du formulaire de connexion.

**États :**
```dart
LoginStatus.initial  → Formulaire vide
LoginStatus.loading  → Requête en cours → spinner sur le bouton
LoginStatus.loaded   → Succès → redirection vers /home
LoginStatus.error    → Échec → SnackBar rouge avec le message
```

---

### 4.16. `cubits/login/chat_cubit.dart`

**Rôle :** Gestion de la liste des conversations.

**Fonctionnalités :**
```dart
loadChats()                    // Charge depuis API (ou mockées si indisponible)
updateChatWithNewMessage(...)  // Met à jour quand un message arrive
markChatAsRead(chatId)         // Remet le badge non-lu à 0
```

**Mode démo :** Si le serveur Laravel n'est pas disponible, affiche 8 conversations fictives avec une bannière orange "Mode démo".

---

### 4.17. `cubits/login/message_cubit.dart`

**Rôle :** Gestion des messages d'une conversation ouverte.

**Optimistic Update :**
```dart
// Le message apparaît IMMÉDIATEMENT dans l'UI
// sans attendre la confirmation du serveur
final updatedMessages = [...state.messages, message];
emit(state.copyWith(messages: updatedMessages));

// Puis envoi en arrière-plan
final sentMessage = await messageRepository.sendMessage(message);
// Mise à jour du statut (sending → sent)
```

**Indicateur "en train d'écrire" :**
```dart
SocketService.onTyping = (chatId) => emit(state.copyWith(isTyping: true));
SocketService.onStopTyping = (chatId) => emit(state.copyWith(isTyping: false));
```

---

### 4.18. `cubits/login/theme_cubit.dart`

**Rôle :** Toggle dark/light mode persistant.

```dart
toggleTheme()  // Bascule et sauvegarde dans SharedPreferences
setDark()      // Force le mode sombre
setLight()     // Force le mode clair
isDarkMode     // Getter : true si mode sombre actif
```

---

### 4.19. `screens/auth/splash_screen.dart`

**Rôle :** Écran de démarrage avec animation + vérification de session.

**Logique de navigation :**
```
App lancée
    ↓ Animation fade-in (1 seconde)
    ↓ Attente 3 secondes
    ↓ AuthCubit.checkAuthStatus()
    ↓
Token trouvé → context.go('/home')
Pas de token → context.go('/sign_in')
```

---

### 4.20. `screens/auth/login_screen.dart`

**Rôle :** Formulaire de connexion avec validation.

**Points importants :**
- `StatefulWidget` (nécessaire pour les TextEditingControllers)
- `BlocListener` : réagit aux changements sans rebuild (redirection, SnackBar)
- `BlocBuilder` : reconstruit uniquement le bouton selon l'état (spinner/texte)
- `GlobalKey<FormState>` : valide tous les champs avant d'appeler le Cubit
- `dispose()` : libère les contrôleurs pour éviter les fuites mémoire

---

### 4.21. `screens/auth/register_screen.dart`

**Rôle :** Formulaire d'inscription avec validation complète.

**Validations :**
- Nom : obligatoire, minimum 2 caractères
- Email : obligatoire, format valide (regex)
- Téléphone : optionnel
- Mot de passe : obligatoire, minimum 8 caractères

---

### 4.22. `screens/home/chat_list_screen.dart`

**Rôle :** Liste des conversations branchée sur ChatCubit.

**Fonctionnalités :**
- Initiale du contact dans l'avatar (pas de photo = initiale colorée)
- Badge non-lu (cercle coloré avec le nombre)
- Formatage intelligent de l'heure :
  - Aujourd'hui → "14:32"
  - Cette semaine → "Lun."
  - Plus ancien → "12/05"
- Bannière orange si mode démo (serveur indisponible)
- Bouton "+" → navigue vers ContactsScreen

---

### 4.23. `screens/chat/chat_screen.dart`

**Rôle :** Écran de conversation avec envoi de texte et d'images.

**image_picker intégré :**
```dart
// Ouvre un menu BottomSheet avec 2 options
_showImageSourceDialog()
  → ImageSource.camera   → Prendre une photo
  → ImageSource.gallery  → Choisir depuis la galerie

// Paramètres de compression
imageQuality: 70   // 70% de qualité (économise la bande passante)
maxWidth: 1024     // Largeur max en pixels
maxHeight: 1024    // Hauteur max en pixels
```

**Bulles de messages :**
- Coin inférieur droit arrondi = mes messages
- Coin inférieur gauche arrondi = messages reçus
- Heure + coches de statut (✓✓)

---

### 4.24. `screens/contacts/contacts_screen.dart`

**Rôle :** Sélection d'un contact pour démarrer une conversation.

**Gestion des permissions :**
```
Permission accordée → charge les contacts NovaX depuis l'API
Permission refusée  → affiche un message + bouton "Réessayer"
Refus définitif     → ouvre les paramètres système
```

**Indicateur en ligne :** Point vert sur l'avatar si `contact.isOnline == true`.

---

### 4.25. `screens/profile/profile_screen.dart`

**Rôle :** Profil utilisateur + paramètres.

**Fonctionnalités :**
- Affiche nom et email depuis AuthCubit
- Toggle dark/light mode via ThemeCubit
- Déconnexion avec confirmation (AlertDialog)
- Placeholders pour notifications et confidentialité

---

### 4.26. `main.dart`

**Rôle :** Point d'entrée — initialise tout et injecte les dépendances.

**Ordre d'initialisation :**
```dart
1. WidgetsFlutterBinding.ensureInitialized()  // Flutter prêt
2. HiveService.init()                          // Base de données locale
3. initializeDateFormatting('fr_FR')           // Dates en français
4. setPathUrlStrategy()                        // URLs propres sur le web
5. SystemChrome.setPreferredOrientations()     // Portrait uniquement
6. runApp(MainApp())                           // Lance l'UI
```

**Injection de dépendances (MultiRepositoryProvider + MultiBlocProvider) :**
```
MultiRepositoryProvider
  ├── AuthRepository
  ├── MessageRepository
  └── ChatRepository
        ↓
MultiBlocProvider
  ├── ThemeCubit      → Thème global
  ├── AuthCubit       → Session globale
  ├── LoginCubit      → Formulaire login
  └── ChatCubit       → Liste conversations
```

---

## 5. Dépendances Flutter (pubspec.yaml)

| Package | Version | Rôle |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | Pattern BLoC/Cubit — gestion d'état |
| `equatable` | ^2.0.8 | Comparaison d'objets pour les States |
| `go_router` | ^17.2.3 | Navigation déclarative |
| `dio` | ^5.9.2 | Client HTTP pour l'API Laravel |
| `socket_io_client` | ^2.0.3+1 | WebSocket temps réel vers Node.js |
| `hive` | ^2.2.3 | Base de données locale NoSQL |
| `hive_flutter` | ^1.1.0 | Intégration Hive avec Flutter |
| `shared_preferences` | ^2.5.5 | Stockage token JWT et préférences |
| `firebase_core` | ^3.6.0 | SDK Firebase (base) |
| `firebase_messaging` | ^15.1.3 | Push notifications FCM |
| `encrypt` | ^5.0.3 | Chiffrement AES-256 E2EE |
| `image_picker` | ^1.2.2 | Caméra et galerie photos |
| `permission_handler` | ^12.0.1 | Permissions système |
| `google_fonts` | ^8.1.0 | Police Questrial |
| `intl` | ^0.20.2 | Formatage dates en français |

---

## 6. Ce qui Attend les Camarades

| Fonctionnalité | Bloqué par | Action requise |
|---|---|---|
| Login/Register réels | **Emmanuel** (Dev Web) | Lancer Laravel sur port 8000 |
| Messages temps réel | **Michaël** (RSI) | Lancer Node.js Socket.io sur port 3000 |
| Firebase FCM activé | **Toute l'équipe** | Créer projet Firebase + `google-services.json` |
| E2EE échange de clés | **Michaël** (RSI) | Définir le protocole d'échange de clés |
| Wireframes finaux | **Kamélia** (UI/UX) | Export Figma + palette Flutter |
| Analyse de sentiment | **Ulrich** (Big Data) | Endpoint Vertex AI |

### Comment brancher le serveur Laravel (Emmanuel)

Quand Emmanuel lance son serveur, changer dans `app_constants.dart` :
```dart
// Développement local (actuel)
static const String baseUrl = "http://localhost:8000/api";

// Si serveur sur réseau local (même WiFi)
static const String baseUrl = "http://192.168.X.X:8000/api";

// Si émulateur Android
static const String baseUrl = "http://10.0.2.2:8000/api";
```

### Comment activer Firebase (quand projet créé)

```dart
// Dans main.dart, décommenter :
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
await NotificationService.init();
```

---

## 7. Checklist Finale Dev Mobile ✅

- [x] Architecture Flutter en couches (constants/models/services/repositories/cubits/screens)
- [x] Navigation déclarative go_router (6 routes)
- [x] SplashScreen avec animation + vérification token JWT
- [x] LoginScreen avec validation + BLoC
- [x] RegisterScreen avec validation complète
- [x] ProfileScreen + toggle dark/light + déconnexion
- [x] ChatListScreen branché ChatCubit + mode démo
- [x] ChatScreen avec bulles + image_picker (caméra + galerie)
- [x] ContactsScreen avec permissions + indicateur en ligne
- [x] Hive (base de données locale offline)
- [x] SocketService (WebSocket temps réel — prêt pour Node.js)
- [x] AuthService (JWT — prêt pour Laravel)
- [x] ChatService (API conversations — prêt pour Laravel)
- [x] ContactService (permissions + API contacts)
- [x] EncryptionService (AES-256 E2EE)
- [x] NotificationService (Firebase FCM — prêt pour configuration)
- [x] ThemeCubit (dark/light persistant)
- [x] AuthCubit (session globale)
- [x] LoginCubit (formulaire)
- [x] ChatCubit (conversations)
- [x] MessageCubit (messages temps réel)
- [x] Repo GitHub avec commits propres
- [x] Documentation complète dans 01_Documentation/

---

*Document de clôture rédigé le 20 Mai 2026*  
*SAMBIENI Firmin — Dev Mobile — Projet NovaX*  
*Repo : https://github.com/firmin-del/connectx-flutter*
