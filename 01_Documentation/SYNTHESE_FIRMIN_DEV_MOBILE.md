# 📱 NovaX — Synthèse Dev Mobile | SAMBIENI Firmin
> Projet : Clone WhatsApp | Méthode Forge-IMeN | Mai 2026  
> Repo : https://github.com/firmin-del/connectx-flutter

---

## 1. Contexte en 2 lignes

**NovaX** est un clone WhatsApp développé en 5 jours par une équipe de 5 filières.  
Firmin (Dev Mobile) a livré l'application Flutter complète — prête à se brancher sur les serveurs des camarades.

| Filière | Membre | Rôle |
|---|---|---|
| Dev Mobile | **SAMBIENI Firmin** | App Flutter (ce document) |
| Dev Web | Emmanuel GBODOU | Backend Laravel + Interface Web |
| RSI | MIWANOU Michaël | Sécurité + Infrastructure Node.js |
| Big Data & IA | HANKPE Ulrich | Analyse de sentiment Vertex AI |
| UI/UX Motion | ABOU Kamélia | Maquettes + Design système |

---

## 2. Architecture de l'App Flutter

L'app suit une **architecture en couches** : chaque couche a un rôle précis et ne connaît que la couche juste en dessous.

```
┌─────────────────────────────────────────────────────┐
│  SCREENS (UI)  →  ce que l'utilisateur voit         │
│  SplashScreen | LoginScreen | RegisterScreen        │
│  ChatListScreen | ChatScreen | ContactsScreen       │
│  ProfileScreen                                      │
├─────────────────────────────────────────────────────┤
│  CUBITS (Logique métier)  →  BLoC/Cubit pattern     │
│  AuthCubit | LoginCubit | ChatCubit                 │
│  MessageCubit | ThemeCubit                          │
├─────────────────────────────────────────────────────┤
│  REPOSITORIES (Abstraction données)                 │
│  AuthRepository | ChatRepository | MessageRepository│
├─────────────────────────────────────────────────────┤
│  SERVICES (Accès bas niveau)                        │
│  AuthService → Laravel API (HTTP/Dio)               │
│  SocketService → Node.js (WebSocket)                │
│  HiveService → Base locale (offline)                │
│  EncryptionService → AES-256 (E2EE)                 │
│  NotificationService → Firebase FCM                 │
│  ContactService → Annuaire téléphone                │
└─────────────────────────────────────────────────────┘
```

**Flux de données :** `UI → Cubit → Repository → Service → Serveur/DB`

---

## 3. Les 3 Étapes de Réalisation

### Étape 01 — Base visuelle
Mise en place de l'architecture, navigation, et écrans mockés.
- Architecture Flutter en couches (constants / models / services / repositories / cubits / screens)
- Navigation déclarative avec `go_router` (6 routes)
- SplashScreen, LoginScreen, ChatListScreen, ChatScreen (données fictives)
- Thème Light/Dark avec Google Fonts Questrial
- Modèles de données : UserModel, ChatModel, MessageModel, ContactModel
- **Commit :** `bbb5a5a` — 229 fichiers, 7300 lignes

### Étape 02 — Logique métier
Connexion à la vraie logique : base de données, API, temps réel.
- **Hive** remplace SQLite (demandé dans le cahier des charges) — base NoSQL locale
- **SocketService** — WebSocket vers Node.js (temps réel)
- **AuthService** — vrais appels API Laravel (login, register, logout, JWT)
- **Cubits complets** — AuthCubit, LoginCubit, MessageCubit, ThemeCubit
- **Stratégie Offline First** — messages sauvegardés localement avant envoi
- LoginScreen réécrit (bug boucle infinie corrigé)
- RegisterScreen et ProfileScreen créés
- **Commits :** `ac24bf4`, `5bbff8d`, `b37a5fe` — +2644 lignes

### Étape 03 — Sécurité, notifications, contacts
Fonctionnalités avancées et finalisation.
- **EncryptionService** — chiffrement AES-256 E2EE avant envoi
- **NotificationService** — Firebase FCM (push notifications)
- **ChatCubit + ChatRepository** — liste des conversations (mode démo si serveur absent)
- **ContactService** — accès annuaire + permissions Android/iOS
- **ContactsScreen** — sélection de contact avec indicateur en ligne
- **ChatScreen** — image_picker intégré (caméra + galerie)
- **Commits :** `42e526a`, `a7186b2` — +2126 lignes

---

## 4. Concepts Clés Expliqués

### BLoC/Cubit — Gestion d'état
Un **Cubit** sépare la logique de l'UI. L'UI appelle une méthode → le Cubit émet un état → l'UI se reconstruit.

```dart
// Exemple : LoginCubit
Future<void> login(String email, String password) async {
  emit(state.copyWith(loginStatus: LoginStatus.loading)); // → spinner
  try {
    await authRepository.login(email, password);
    emit(state.copyWith(loginStatus: LoginStatus.loaded)); // → /home
  } catch (e) {
    emit(state.copyWith(loginStatus: LoginStatus.error));  // → SnackBar rouge
  }
}
```

### Hive — Base de données locale
Hive stocke les messages sur l'appareil pour un accès **offline**. Organisé en "boîtes" (comme des tables).

```dart
HiveService.saveMessage(message)           // Sauvegarder
HiveService.getMessagesForChat(chatId)     // Lire
HiveService.updateMessageStatus(id, status) // Mettre à jour
```

Chaque classe stockée dans Hive a un `typeId` unique :
- `typeId: 0` → MessageModel
- `typeId: 1` → MessageType (text, image, video, file, voice)
- `typeId: 2` → MessageStatus (sending, sent, delivered, read, failed)
- `typeId: 3` → ChatModel

### Socket.io — Temps réel
Contrairement à HTTP (le client demande), Socket.io permet au **serveur d'envoyer sans qu'on demande**.

```
Utilisateur A envoie "Bonjour"
    → SocketService.sendMessage() → Node.js → Utilisateur B
    → B reçoit 'new_message' → MessageCubit met à jour l'UI
```

Événements clés :
```dart
// Écoute (serveur → client)
'new_message'  → nouveau message
'typing'       → contact en train d'écrire
'message_read' → message lu (coches bleues)

// Émission (client → serveur)
SocketService.sendMessage(message)
SocketService.emitTyping(chatId)
SocketService.emitMessageRead(chatId, msgId)
```

### JWT — Authentification
Après login, le serveur renvoie un **token JWT**. Il est sauvegardé localement et ajouté automatiquement à chaque requête via un **intercepteur Dio**.

```dart
// L'intercepteur dans api_config.dart fait ça automatiquement :
options.headers['Authorization'] = 'Bearer $token';
```

### Offline First — Stratégie messages
Les messages sont **d'abord sauvegardés localement**, puis envoyés au serveur. L'UI est toujours réactive.

```
Envoi :  Hive (sending) → Socket.io → Hive (sent ou failed)
Réception : Socket.io → Hive (delivered) → UI → Hive (read)
```

### E2EE — Chiffrement AES-256
Le message est chiffré **avant** d'être envoyé. Le serveur ne voit jamais le contenu en clair.

```
"Bonjour" → encrypt() → "aB3xK9mP:xYz123..." → Socket.io → decrypt() → "Bonjour"
```

Format : `"IV:CipherText"` — l'IV (nombre aléatoire unique) garantit que deux messages identiques donnent des résultats différents.

### Optimistic Update — UX fluide
Le message apparaît **immédiatement** dans l'UI sans attendre la confirmation du serveur.

```dart
// 1. Affiche immédiatement
emit(state.copyWith(messages: [...state.messages, message]));
// 2. Envoie en arrière-plan
final sentMessage = await messageRepository.sendMessage(message);
// 3. Met à jour le statut (sending → sent)
```

---

## 5. Écrans et leur rôle

| Écran | Route | Rôle |
|---|---|---|
| SplashScreen | `/` | Animation + vérifie token → redirige |
| LoginScreen | `/sign_in` | Formulaire + validation + BLoC |
| RegisterScreen | `/register` | Inscription avec validation complète |
| ChatListScreen | `/home` | Liste conversations + badges non-lus |
| ChatScreen | `/chat/:id` | Messages + image_picker |
| ContactsScreen | `/contacts` | Sélection contact + permissions |
| ProfileScreen | `/profile` | Profil + toggle thème + déconnexion |

---

## 6. Packages utilisés

| Package | Rôle |
|---|---|
| `flutter_bloc` | Gestion d'état BLoC/Cubit |
| `go_router` | Navigation déclarative |
| `dio` | Client HTTP → Laravel API |
| `socket_io_client` | WebSocket → Node.js |
| `hive` + `hive_flutter` | Base de données locale offline |
| `shared_preferences` | Stockage token JWT |
| `firebase_core` + `firebase_messaging` | Push notifications FCM |
| `encrypt` | Chiffrement AES-256 E2EE |
| `image_picker` | Caméra + galerie photos |
| `permission_handler` | Permissions Android/iOS |
| `equatable` | Comparaison d'états BLoC |
| `google_fonts` | Police Questrial |
| `intl` | Dates en français |

---

## 7. Ce qui attend les camarades

| Besoin | Camarade | Action |
|---|---|---|
| Serveur Laravel (login, chats, contacts) | **Emmanuel** | Lancer sur port 8000 |
| Serveur Node.js Socket.io | **Michaël** | Lancer sur port 3000 |
| Protocole échange de clés E2EE | **Michaël** | Définir la méthode |
| Projet Firebase + google-services.json | **Équipe** | Créer + configurer |
| Wireframes + palette Flutter | **Kamélia** | Export Figma |
| Endpoint Vertex AI | **Ulrich** | URL + clé API |

**Quand Emmanuel lance Laravel**, changer dans `app_constants.dart` :
```dart
static const String baseUrl = "http://192.168.X.X:8000/api"; // réseau local
// ou
static const String baseUrl = "http://10.0.2.2:8000/api"; // émulateur Android
```

**Quand Firebase est configuré**, décommenter dans `main.dart` :
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
await NotificationService.init();
```

---

## 8. Checklist finale ✅

- [x] Architecture Flutter en couches
- [x] Navigation go_router (6 routes)
- [x] SplashScreen + vérification token JWT
- [x] LoginScreen + RegisterScreen avec validation
- [x] ProfileScreen + toggle thème + déconnexion
- [x] ChatListScreen branché ChatCubit + mode démo
- [x] ChatScreen + image_picker (caméra + galerie)
- [x] ContactsScreen + gestion permissions
- [x] Hive (offline) + SocketService (temps réel) + AuthService (JWT)
- [x] ChatCubit + MessageCubit + AuthCubit + ThemeCubit + LoginCubit
- [x] EncryptionService AES-256 E2EE
- [x] NotificationService Firebase FCM (prêt)
- [x] Repo GitHub + 8 commits propres
- [x] Documentation complète (4 fichiers dans 01_Documentation/)

---

*SAMBIENI Firmin — Dev Mobile — Projet NovaX — Mai 2026*
