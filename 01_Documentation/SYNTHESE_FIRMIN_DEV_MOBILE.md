📱 NovaX — Synthèse Dev Mobile | SAMBIENI Firmin
> Projet : Clone WhatsApp | Méthode Forge-IMeN | Mai 2026  
> Repo : https://github.com/firmin-del/connectx-flutter

1. Contexte en 2 lignes

NovaX est un clone WhatsApp développé en 5 jours par une équipe de 5 filières.  
Firmin (Dev Mobile) a livré l'application Flutter complète — prête à se brancher sur les serveurs des camarades.

| Filière | Membre | Rôle |

| Dev Mobile | SAMBIENI Firmin | App Flutter (ce document) |
| Dev Web | Emmanuel GBODOU | Backend Laravel + Interface Web |
| RSI | MIWANOU Michaël | Sécurité + Infrastructure Node.js |
| Big Data & IA | HANKPE Ulrich | Analyse de sentiment Vertex AI |
| UI/UX Motion | ABOU Kamélia | Maquettes + Design système |

2. Architecture de l'App Flutter

L'app suit une architecture en couches : chaque couche a un rôle précis et ne connaît que la couche juste en dessous.

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

Flux de données : `UI → Cubit → Repository → Service → Serveur/DB`

3. Les 3 Étapes de Réalisation

Étape 01 — Base visuelle
Mise en place de l'architecture, navigation, et écrans mockés.
- Architecture Flutter en couches (constants / models / services / repositories / cubits / screens)
- Navigation déclarative avec `go_router` (6 routes)
- SplashScreen, LoginScreen, ChatListScreen, ChatScreen (données fictives)
- Thème Light/Dark avec Google Fonts Questrial
- Modèles de données : UserModel, ChatModel, MessageModel, ContactModel
- Commit : `bbb5a5a` — 229 fichiers, 7300 lignes

Étape 02 — Logique métier
Connexion à la vraie logique : base de données, API, temps réel.
- Hive remplace SQLite (demandé dans le cahier des charges) — base NoSQL locale
- SocketService — WebSocket vers Node.js (temps réel)
- AuthService — vrais appels API Laravel (login, register, logout, JWT)
- Cubits complets — AuthCubit, LoginCubit, MessageCubit, ThemeCubit
- Stratégie Offline First — messages sauvegardés localement avant envoi
- LoginScreen réécrit (bug boucle infinie corrigé)
- RegisterScreen et ProfileScreen créés
- Commits : `ac24bf4`, `5bbff8d`, `b37a5fe` — +2644 lignes

Étape 03 — Sécurité, notifications, contacts
Fonctionnalités avancées et finalisation.
- EncryptionService — chiffrement AES-256 E2EE avant envoi
- NotificationService — Firebase FCM (push notifications)
- ChatCubit + ChatRepository — liste des conversations (mode démo si serveur absent)
- ContactService — accès annuaire + permissions Android/iOS
- ContactsScreen — sélection de contact avec indicateur en ligne
- ChatScreen — image_picker intégré (caméra + galerie)
- Commits : `42e526a`, `a7186b2` — +2126 lignes

4. Concepts Clés Expliqués

BLoC/Cubit — Gestion d'état
Un Cubit sépare la logique de l'UI. L'UI appelle une méthode → le Cubit émet un état → l'UI se reconstruit.

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

Hive — Base de données locale
Hive stocke les messages sur l'appareil pour un accès offline. Organisé en "boîtes" (comme des tables).

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

Socket.io — Temps réel
Contrairement à HTTP (le client demande), Socket.io permet au serveur d'envoyer sans qu'on demande.

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

JWT — Authentification
Après login, le serveur renvoie un token JWT. Il est sauvegardé localement et ajouté automatiquement à chaque requête via un intercepteur Dio.

```dart
// L'intercepteur dans api_config.dart fait ça automatiquement :
options.headers['Authorization'] = 'Bearer $token';
```

Offline First — Stratégie messages
Les messages sont d'abord sauvegardés localement, puis envoyés au serveur. L'UI est toujours réactive.

```
Envoi :  Hive (sending) → Socket.io → Hive (sent ou failed)
Réception : Socket.io → Hive (delivered) → UI → Hive (read)
```

E2EE — Chiffrement AES-256
Le message est chiffré avant d'être envoyé. Le serveur ne voit jamais le contenu en clair.

```
"Bonjour" → encrypt() → "aB3xK9mP:xYz123..." → Socket.io → decrypt() → "Bonjour"
```

Format : `"IV:CipherText"` — l'IV (nombre aléatoire unique) garantit que deux messages identiques donnent des résultats différents.

Optimistic Update — UX fluide
Le message apparaît immédiatement dans l'UI sans attendre la confirmation du serveur.

```dart
// 1. Affiche immédiatement
emit(state.copyWith(messages: [...state.messages, message]));
// 2. Envoie en arrière-plan
final sentMessage = await messageRepository.sendMessage(message);
// 3. Met à jour le statut (sending → sent)
```

5. Écrans et leur rôle

| Écran | Route | Rôle |

| SplashScreen | `/` | Animation + vérifie token → redirige |
| LoginScreen | `/sign_in` | Formulaire + validation + BLoC |
| RegisterScreen | `/register` | Inscription avec validation complète |
| ChatListScreen | `/home` | Liste conversations + badges non-lus |
| ChatScreen | `/chat/:id` | Messages + image_picker |
| ContactsScreen | `/contacts` | Sélection contact + permissions |
| ProfileScreen | `/profile` | Profil + toggle thème + déconnexion |

6. Packages utilisés

| Package | Rôle |

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

7. Ce qui attend les camarades

| Besoin | Camarade | Action |

| Serveur Laravel (login, chats, contacts) | Emmanuel | Lancer sur port 8000 |
| Serveur Node.js Socket.io | Michaël| Lancer sur port 3000 |
| Protocole échange de clés E2EE | Michaël | Définir la méthode |
| Projet Firebase + google-services.json | Équipe | Créer + configurer |
| Wireframes + palette Flutter | Kamélia | Export Figma |
| Endpoint Vertex AI | **Ulrich** | URL + clé API |

Quand Emmanuel lance Laravel, changer dans `app_constants.dart` :
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

8. Checklist finale ✅

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

9. Ce que Firmin a livré — Détail complet

✅ Fonctionnalités 100% opérationnelles (testables maintenant)

| Fonctionnalité | Fichier(s) | Comment tester |

| Démarrage + animation logo | `splash_screen.dart` | Lancer l'app → logo fade-in 3s |
| Vérification session auto | `splash_screen.dart` + `auth_cubit.dart` | Si token → /home, sinon → /sign_in |
| Formulaire login avec validation | `login_screen.dart` | Champs vides → messages d'erreur |
| Formulaire inscription | `register_screen.dart` | Validation nom/email/mdp |
| Navigation entre écrans | `main.dart` (go_router) | Tous les boutons naviguent |
| Liste conversations (mode démo) | `chat_list_screen.dart` | 8 conversations fictives + badges |
| Ouverture d'un chat | `chat_screen.dart` | Tap sur une conversation |
| Envoi de message texte (local) | `chat_screen.dart` | Saisir + envoyer → bulle apparaît |
| Envoi d'image (caméra/galerie) | `chat_screen.dart` + `image_picker` | Bouton 📎 → choisir source |
| Sélection de contacts | `contacts_screen.dart` | Bouton + → liste contacts mockés |
| Indicateur en ligne (contacts) | `contacts_screen.dart` | Point vert sur avatar |
| Toggle dark/light mode | `profile_screen.dart` + `theme_cubit.dart` | Switch dans le profil |
| Déconnexion avec confirmation | `profile_screen.dart` | Bouton déconnexion → AlertDialog |
| Persistance du thème | `theme_cubit.dart` | Fermer/rouvrir l'app → thème conservé |
| Base de données locale Hive | `hive_service.dart` | Messages sauvegardés offline |
| Chiffrement AES-256 | `encryption_service.dart` | `EncryptionService.encrypt("texte")` |

⏳ Fonctionnalités prêtes mais en attente du serveur

| Fonctionnalité | Fichier prêt | Bloqué par |

| Login réel avec token JWT | `auth_service.dart` | Serveur Laravel d'Emmanuel |
| Inscription réelle | `auth_service.dart` | Serveur Laravel d'Emmanuel |
| Liste vraies conversations | `chat_service.dart` + `chat_cubit.dart` | Serveur Laravel d'Emmanuel |
| Messages temps réel | `socket_service.dart` + `message_cubit.dart` | Serveur Node.js de Michaël |
| Indicateur "en train d'écrire" | `message_cubit.dart` | Serveur Node.js de Michaël |
| Coches de lecture (✓✓ bleus) | `message_repository.dart` | Serveur Node.js de Michaël |
| Notifications push | `notification_service.dart` | Firebase à configurer |
| Contacts réels NovaX | `contact_service.dart` | Serveur Laravel d'Emmanuel |
| Chiffrement E2EE activé | `encryption_service.dart` | Protocole de clés de Michaël |

10. Ce que chaque camarade doit me rendre — Précis
🌐 Emmanuel GBODOU — Dev Web (Laravel)

Ce qu'il doit me donner :

A. La liste des endpoints API (format exact attendu) :

| Endpoint | Méthode | Corps | Réponse attendue |

| `/api/login` | POST | `{email, password}` | `{token: "JWT...", user: {id, name, email}}` |
| `/api/register` | POST | `{name, email, password, password_confirmation}` | `{token: "JWT...", user: {id, name, email}}` |
| `/api/logout` | POST | (token dans header) | `{message: "ok"}` |
| `/api/chats` | GET | (token dans header) | `[{id, participants, last_message, unread_count, ...}]` |
| `/api/chats/{id}/messages` | GET | `?page=1&per_page=20` | `{data: [{id, sender_id, content, type, created_at}]}` |
| `/api/contacts` | GET | (token dans header) | `[{id, name, avatar, is_online, phone_number}]` |

B. L'URL de son serveur pour que je mette à jour `app_constants.dart` :
```dart
// Je dois changer cette ligne avec son URL réelle :
static const String baseUrl = "http://SON_IP:8000/api";
```

C. Le format exact du JSON pour chaque réponse (surtout les noms des champs).  
Exemple : est-ce `sender_id` ou `senderId` ? `created_at` ou `timestamp` ?



🔐 Michaël MIWANOU — RSI (Node.js + Sécurité)

Ce qu'il doit me donner :

A. L'URL du serveur Socket.io :
```dart
// Je dois changer cette ligne :
static const String socketUrl = "http://SON_IP:3000";
```

B. La liste des événements Socket.io qu'il a implémentés côté serveur :

| Événement | Direction | Données |

| `send_message` | Client → Serveur | `{id, sender_id, receiver_id, chat_id, content, type}` |
| `new_message` | Serveur → Client | même format |
| `typing` | Client → Serveur | `{chat_id}` |
| `stop_typing` | Client → Serveur | `{chat_id}` |
| `message_read` | Client → Serveur | `{chat_id, message_id}` |
| `join_chat` | Client → Serveur | `{chat_id}` |

> ⚠️ Si les noms d'événements sont différents, je dois les mettre à jour dans `socket_service.dart`.

C. La méthode d'échange de clés E2EE :  
Mon `EncryptionService` utilise une clé symétrique locale pour l'instant.  
Michaël doit me dire comment échanger les clés entre deux utilisateurs.  
Options possibles :
- Clé partagée via l'API Laravel (simple mais moins sécurisé)
- Échange Diffie-Hellman (plus sécurisé, plus complexe)

D. Le token d'authentification Socket.io :  
Mon code envoie déjà le JWT dans `setAuth({'token': token})`.  
Michaël doit confirmer que son serveur Node.js vérifie bien ce token.

Toute l'équipe — Firebase

Ce dont j'ai besoin :

1. Créer un projet Firebase sur https://console.firebase.google.com
2. Ajouter l'app Android avec le package `com.example.clone_whatsapp_base_code`
3. Télécharger `google-services.json` → me l'envoyer pour le placer dans `android/app/`
4. Me donner la VAPID key pour le web (si on déploie sur Chrome)

Kamélia ABOU — UI/UX Motion

Ce qu'elle doit me donner :

A. La palette de couleurs en format Flutter :
```dart
// Format attendu (à mettre dans app_colors.dart) :
static const Color primary = Color(0xFF??????);
static const Color background = Color(0xFF??????);
static const Color messageSent = Color(0xFF??????);
static const Color messageReceived = Color(0xFF??????);
```

B. La police de caractères :
```dart
// Si elle change la police Questrial actuelle :
GoogleFonts.nomDeLaPolice()
```

C. Les specs des animations (durées en millisecondes) :
- Animation d'envoi de message : `?? ms`
- Transition entre écrans : `?? ms`
- Indicateur "en train d'écrire" : style (3 points ? vague ?)

D. Les wireframes dans le dossier `01_Documentation/Wireframes/` (actuellement vide).

🤖 Ulrich HANKPE — Big Data & IA

Ce qu'il doit me donner :

A. L'endpoint Vertex AI pour l'analyse de sentiment :
```dart
// Format attendu :
// URL : https://...vertex.ai/...
// Méthode : POST
// Corps : { "text": "message à analyser" }
// Réponse : { "score": "positive" | "neutral" | "negative" }
```

B. La clé API Google Cloud (ou le token d'accès).

C. À quel moment appeler l'API :
- Avant le chiffrement (côté client) ?
- Après réception (côté serveur) ?
- Uniquement pour les groupes ?

11. Comment intégrer le travail des camarades — Guide pas à pas

Étape A — Brancher le serveur Laravel (Emmanuel)

```dart
// 1. Modifier app_constants.dart
static const String baseUrl = "http://IP_EMMANUEL:8000/api";

// 2. Vérifier que les noms de champs JSON correspondent
// Dans auth_service.dart, ligne ~45 :
return UserModel.fromJson(data['user'] as Map<String, dynamic>);
// Si Emmanuel retourne 'utilisateur' au lieu de 'user' → changer ici

// 3. Tester le login
// Lancer l'app → saisir un vrai email/mdp → vérifier que ça redirige vers /home
```

Étape B — Brancher le serveur Socket.io (Michaël)

```dart
// 1. Modifier app_constants.dart
static const String socketUrl = "http://IP_MICHAEL:3000";

// 2. Dans auth_cubit.dart, décommenter la connexion socket après login
void setAuthenticated(UserModel user) {
  _connectSocket(); // ← déjà implémenté, juste décommenter si besoin
  emit(AuthState.authenticated(user));
}

// 3. Dans chat_screen.dart, connecter le MessageCubit
// Remplacer _sendMessage() par :
context.read<MessageCubit>().sendTextMessage(text, receiverId);
```

Étape C — Activer Firebase (Notifications)

```bash
# 1. Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configurer avec le projet Firebase de l'équipe
flutterfire configure

# 3. Cela génère lib/firebase_options.dart automatiquement
```

```dart
// 4. Dans main.dart, décommenter :
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
await NotificationService.init();
```

Étape D — Activer le chiffrement E2EE (Michaël)

```dart
// Dans message_cubit.dart, modifier sendTextMessage() :
Future<void> sendTextMessage(String content, String receiverId) async {
  // Chiffrer avant envoi
  final encryptedContent = await EncryptionService.encrypt(content);

  final message = MessageModel(
    content: encryptedContent, // ← envoyer le texte chiffré
    // ...
  );
  // ...
}

// Dans _onMessageReceived(), déchiffrer à la réception :
Future<void> _onMessageReceived(MessageModel message) async {
  final decryptedContent = await EncryptionService.decrypt(message.content);
  final decryptedMessage = message.copyWith(content: decryptedContent);
  // Afficher decryptedMessage
}
```

Étape E — Appliquer le design de Kamélia

```dart
// Dans app_colors.dart, remplacer les couleurs actuelles par celles de Kamélia
// Dans app_theme.dart, appliquer la nouvelle palette :
colorScheme: ColorScheme.fromSeed(
  seedColor: AppColors.primary, // ← couleur de Kamélia
),
textTheme: GoogleFonts.nouvellePoliceTextTheme(), // ← police de Kamélia
```

Étape F — Intégrer l'analyse de sentiment (Ulrich)

```dart
// Créer lib/services/sentiment_service.dart
class SentimentService {
  static Future<String> analyze(String text) async {
    final response = await _api.post(
      'URL_ULRICH',
      data: {'text': text},
    );
    return response.data['score']; // "positive", "neutral", "negative"
  }
}

// Dans message_cubit.dart, appeler avant envoi :
final sentiment = await SentimentService.analyze(content);
// Stocker dans le message ou envoyer au pipeline Big Data
```

12. Idées pour aller plus vite 🚀

Idée 1 — Réunion de 15 min pour aligner les interfaces
Problème : Chacun travaille de son côté et les noms de champs JSON peuvent ne pas correspondre.  
Solution : Organiser une réunion rapide où Emmanuel partage son Postman/Swagger avec les endpoints exacts. Firmin adapte en 10 minutes.

Idée 2 — Utiliser ngrok pour exposer les serveurs locaux
Problème : Les serveurs de Michaël et Emmanuel tournent en local, pas accessibles depuis les autres machines.  
Solution : Chacun installe [ngrok](https://ngrok.com) et expose son serveur :
```bash
ngrok http 8000  # → donne une URL publique type https://abc123.ngrok.io
ngrok http 3000  # → pour Node.js
```
Firmin met ces URLs dans `app_constants.dart` → tout le monde peut tester immédiatement.


Idée 3 — Créer un fichier `.env` partagé
Problème : Chaque fois qu'une URL change, il faut modifier le code.  
Solution : Créer un fichier `lib/constants/env.dart` que chacun remplit avec ses vraies valeurs :
```dart
// env.dart (ne pas committer sur GitHub)
class Env {
  static const String laravelUrl = "http://...";
  static const String socketUrl  = "http://...";
  static const String vertexKey  = "...";
}
```

Idée 4 — Mode démo déjà en place → ne pas bloquer la soutenance
Avantage : L'app fonctionne déjà avec des données mockées.  
Si un serveur n'est pas prêt le jour de la soutenance, l'app tourne quand même.  
Le jury voit une app fonctionnelle — on explique que le vrai backend est en cours de déploiement.

Idée 5 — Tester l'intégration par couches
Plutôt que d'attendre que tout soit prêt, tester dans cet ordre :
```
1. Tester login seul (Emmanuel) → si ça marche, passer à la suite
2. Tester Socket.io seul (Michaël) → envoyer un message test
3. Tester Firebase seul → envoyer une notification test
4. Tester tout ensemble
```

Idée 6 — Kamélia peut livrer les couleurs en premier
Les wireframes prennent du temps, mais la palette de couleurs peut être livrée en 5 minutes.  
Firmin peut appliquer les couleurs immédiatement dans `app_colors.dart` et `app_theme.dart` sans attendre les wireframes complets.

dée 7 — Partager le repo GitHub avec l'équipe
Ajouter les camarades comme collaborateurs sur le repo :
```
https://github.com/firmin-del/connectx-flutter
→ Settings → Collaborators → Add people
```
Chacun peut voir le code, comprendre les interfaces attendues, et adapter son serveur en conséquence.


SAMBIENI Firmin — Dev Mobile — Projet NovaX — Mai 2026
