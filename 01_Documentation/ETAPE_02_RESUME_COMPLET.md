Étape 02 — Résumé Complet & Détaillé
> Projet NovaX — Clone WhatsApp Flutter  
> Réalisé par : SAMBIENI Firmin — Dev Mobile  
> Date : Mardi 20 Mai 2026  
> Branche Git : `master` — Commits : `ac24bf4`, `5bbff8d`, `b37a5fe`

1. Objectif de l'Étape 02

L'Étape 01 avait posé les bases visuelles (écrans mockés, navigation, thème).  
L'Étape 02 a pour but de connecter l'application à la vraie logique métier :

- Remplacer la base de données SQLite (sqflite) par Hive (demandé dans le cahier des charges)
- Implémenter la connexion temps réel via Socket.io vers le serveur Node.js
- Implémenter les vrais appels API vers le backend Laravel
- Compléter tous les Cubits (logique métier) vides
- Corriger les bugs détectés lors du premier test

2. Procédure Git — Les 3 Commits de l'Étape 02

Comment fonctionne Git dans ce projet ?

Git est un outil de versionnage : il garde l'historique de toutes les modifications du code.  
Chaque `commit` est une "photo" du projet à un instant T, avec un message explicatif.

```
Historique des commits :
─────────────────────────────────────────────────────────
bbb5a5a  feat: initial commit — NovaX base architecture (Etape 01)
ac24bf4  feat(etape-02): Hive + SocketService + AuthService + Cubits complets
5bbff8d  fix: suppression imports inutiles + desactivation db_definition obsolete
b37a5fe  fix: URL localhost pour web + LoginScreen avec vrais controllers
─────────────────────────────────────────────────────────
```

Commit 1 — `ac24bf4` : Le gros du travail

```bash
git add .
git commit -m "feat(etape-02): Hive + SocketService + AuthService + Cubits complets"
```

23 fichiers modifiés — 2644 lignes ajoutées 
C'est le commit principal de l'étape 02. Il contient toute la logique métier.

Commit 2 — `5bbff8d` : Nettoyage

```bash
git add .
git commit -m "fix: suppression imports inutiles + desactivation db_definition obsolete"
```

3 fichiers modifiés  
Suppression des warnings détectés par l'analyseur Flutter :
- `home_screen.dart` : import `go_router` inutilisé supprimé
- `app_theme.dart` : import `app_colors.dart` inutilisé supprimé
- `db_definition.dart` : fichier sqflite désactivé (remplacé par Hive)

Commit 3 — `b37a5fe` : Correction des bugs du premier test

```bash
git add .
git commit -m "fix: URL localhost pour web + LoginScreen avec vrais controllers"
```

2 fichiers modifiés**  
Corrections suite au test sur Chrome :
- `app_constants.dart` : URL `10.0.2.2` → `localhost` pour le web
- `login_screen.dart` : réécriture complète avec vrais contrôleurs

Pousser sur GitHub

```bash
git push origin master
```

Le code est visible sur : https://github.com/firmin-del/connectx-flutter

3. Fichiers Créés / Modifiés — Vue d'ensemble

| Fichier | Action | Rôle |

| `pubspec.yaml` | Modifié | Ajout hive, hive_flutter, socket_io_client |

| `constants/app_constants.dart` | Modifié | Nouvelles constantes (clés Hive, URLs) |

| `constants/api_config.dart` | Modifié | Intercepteur JWT automatique |

| `models/message_model.dart` | Modifié | Annoté Hive + enum MessageStatus |

| `models/message_model.g.dart` | Créé | Adaptateurs Hive (sérialisation) |

| `services/hive_service.dart` | Créé | Gestion base de données locale |

| `services/socket_service.dart` | Créé | Connexion temps réel Socket.io |

| `services/auth_service.dart` | Modifié | Vrais appels API Laravel |

| `repositories/auth_repository.dart` | Modifié | Couche d'abstraction complète |

| `repositories/message_repository.dart` | Modifié | Stratégie Offline First |

| `cubits/login_cubit.dart` | Modifié | Validation + appel API réel |

| `cubits/login_state.dart` | Modifié | Ajout userName, userId |

| `cubits/auth_cubit.dart` | Créé | Gestion session globale |

| `cubits/message_cubit.dart` | Créé | Messages temps réel |

| `cubits/theme_cubit.dart` | Créé | Toggle dark/light mode |

| `main.dart` | Modifié | Init Hive + nouveaux Cubits |

| `screens/auth/splash_screen.dart` | Modifié | Vérification token au démarrage |

| `screens/auth/login_screen.dart` | Modifié | Réécriture StatefulWidget |

| `screens/auth/register_screen.dart` | Créé | Formulaire d'inscription complet |

| `screens/chat/chat_screen.dart` | Modifié | Ajout contactName + nettoyage |

| `screens/profile/profile_screen.dart` | Créé | Profil + toggle thème + logout |

| `repositories/local_db_repository/db_definition/db_definition.dart` | Désactivé | Remplacé par Hive |

4. Changement de Base de Données : sqflite → Hive

Pourquoi ce changement ?

Le cahier des charges spécifie Hive (pas sqflite).  
Hive est plus adapté pour une messagerie car :

| Critère | sqflite (ancien) | Hive (nouveau) |

| Type | SQL relationnel | NoSQL clé-valeur |
| Vitesse | Moyenne | Très rapide |
| Complexité | Requêtes SQL | API simple |
| Adapté pour | Données structurées | Messages, cache |

Modification du pubspec.yaml

```yaml
# SUPPRIMÉ :
sqflite: ^2.4.2+1   # Ancienne base de données SQL

# AJOUTÉ :
hive: ^2.2.3          # Base de données NoSQL locale
hive_flutter: ^1.1.0  # Intégration Flutter pour Hive
socket_io_client: ^2.0.3+1  # Connexion Socket.io temps réel
```
5. Hive Service — Explication Détaillée

Fichier : `lib/services/hive_service.dart`

Concept de base

Hive stocke les données dans des "boîtes" (boxes), comme des tiroirs :
- Chaque boîte a un nom unique
- On y met des objets avec une clé (comme un dictionnaire)
- Les données persistent entre les sessions (stockées sur le disque)

Les 3 boîtes créées

```dart
static const String messagesBox = "messages_box"; // Les messages du chat
static const String chatsBox    = "chats_box";    // Les conversations
static const String usersBox    = "users_box";    // Cache des profils
```

Initialisation (appelée dans main.dart)

```dart
static Future<void> init() async {
  await Hive.initFlutter(); // Initialise Hive avec le dossier de l'app

  // Enregistre les adaptateurs pour que Hive sache comment
  // convertir nos objets Dart en données binaires
  Hive.registerAdapter(MessageModelAdapter());  // typeId: 0
  Hive.registerAdapter(MessageTypeAdapter());   // typeId: 1
  Hive.registerAdapter(MessageStatusAdapter()); // typeId: 2

  // Ouvre les boîtes au démarrage
  await Hive.openBox<MessageModel>(AppConstants.messagesBox);
  await Hive.openBox<String>(AppConstants.chatsBox);
  await Hive.openBox<String>(AppConstants.usersBox);
}
```

Opérations disponibles

```dart
// Sauvegarder un message
HiveService.saveMessage(message);

// Récupérer tous les messages d'un chat (triés par date)
HiveService.getMessagesForChat(chatId);

// Mettre à jour le statut d'un message
HiveService.updateMessageStatus(messageId, MessageStatus.read);

// Supprimer tous les messages d'une conversation
HiveService.deleteMessagesForChat(chatId);
```

Les Adaptateurs Hive (message_model.g.dart)

Pour que Hive puisse stocker nos objets, il faut lui expliquer comment les convertir.  
C'est le rôle des adaptateurs dans `message_model.g.dart` :

```dart
// Chaque classe stockée dans Hive a un typeId unique
@HiveType(typeId: 0)  // MessageModel
@HiveType(typeId: 1)  // MessageType (enum)
@HiveType(typeId: 2)  // MessageStatus (enum)

// Chaque champ a un numéro @HiveField
@HiveField(0) final String id;
@HiveField(1) final String senderId;
// etc.
```
6. Socket Service — Explication Détaillée

Fichier : `lib/services/socket_service.dart`

Pourquoi Socket.io ?

HTTP classique = le client demande, le serveur répond (sens unique).  
Socket.io = communication bidirectionnelle en temps réel :
- Le serveur peut envoyer des données sans que le client ne demande
- Parfait pour la messagerie instantanée

Flux d'un message dans NovaX

```
Utilisateur A tape "Bonjour"
        ↓
Flutter appelle SocketService.sendMessage(message)
        ↓
Socket.io émet l'événement 'send_message' vers Node.js
        ↓
Node.js relaie instantanément à l'Utilisateur B
        ↓
Flutter de B reçoit l'événement 'new_message'
        ↓
MessageCubit met à jour la liste → l'UI se reconstruit
```

Connexion au serveur

```dart
static void connect(String token) {
  _socket = IO.io(
    AppConstants.socketUrl,  // http://localhost:3000
    IO.OptionBuilder()
        .setTransports(['websocket'])  // WebSocket (plus rapide que polling)
        .setAuth({'token': token})     // Token JWT pour s'authentifier
        .build(),
  );
  _socket!.connect();
}
```

Événements écoutés (serveur → client)

```dart
_socket!.on('new_message', (data) { ... });   // Nouveau message reçu
_socket!.on('user_online', (userId) { ... }); // Contact connecté
_socket!.on('user_offline', (userId) { ... });// Contact déconnecté
_socket!.on('typing', (chatId) { ... });      // Contact en train d'écrire
_socket!.on('stop_typing', (chatId) { ... }); // Contact arrêté d'écrire
_socket!.on('message_read', (data) { ... });  // Message lu (✓✓ bleus)
```

Événements émis (client → serveur)

```dart
SocketService.sendMessage(message);           // Envoyer un message
SocketService.emitTyping(chatId);             // "Je suis en train d'écrire"
SocketService.emitStopTyping(chatId);         // "J'ai arrêté d'écrire"
SocketService.emitMessageRead(chatId, msgId); // "J'ai lu ce message"
SocketService.joinChat(chatId);               // Rejoindre une conversation
SocketService.leaveChat(chatId);              // Quitter une conversation
```

Les "Rooms" Socket.io

Une room est un groupe de connexions. Quand on rejoint la room `chat_42` :
- On reçoit uniquement les messages du chat 42
- Les autres chats ne nous envoient rien
- Cela évite de recevoir tous les messages de tous les chats

7. Auth Service — Explication Détaillée

Fichier : `lib/services/auth_service.dart`

Rôle

Fait les appels HTTP vers l'API Laravel. C'est la couche la plus basse.

Login

```dart
static Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await _api.post('/login', data: {
    'email': email,
    'password': password,
  });

  if (response.statusCode == 200) {
    await _saveToken(data['token'], data['user']); // Sauvegarde JWT localement
    return data; // { token: "...", user: { id, name, email } }
  }
}
```

Gestion du Token JWT

Après un login réussi, le serveur renvoie un token JWT (JSON Web Token).  
Ce token est sauvegardé localement via SharedPreferences :

```dart
static Future<void> _saveToken(String token, Map user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(AppConstants.tokenKey, token);    // "auth_token"
  await prefs.setString(AppConstants.userIdKey, user['id']);
  await prefs.setString(AppConstants.userNameKey, user['name']);
}
```

À chaque requête suivante, le token est automatiquement ajouté dans le header :

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

C'est l'intercepteur Dio dans `api_config.dart` qui fait ça automatiquement.

8. API Config — L'Intercepteur JWT

Fichier : `lib/constants/api_config.dart`

Un intercepteur est un middleware qui s'exécute avant/après chaque requête HTTP.

```dart
dio.interceptors.add(InterceptorsWrapper(
  // Avant chaque requête : ajoute le token JWT
  onRequest: (options, handler) async {
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options); // Continue la requête
  },

  // Si erreur 401 (token expiré) : supprime le token
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      await prefs.remove(AppConstants.tokenKey);
      // TODO: Rediriger vers login
    }
    return handler.next(error);
  },
));
```

9. Les Cubits — Explication Détaillée

Rappel : Qu'est-ce qu'un Cubit ?

```
UI (Screen)
    │  context.read<MyCubit>().doSomething()  ← appelle une méthode
    ▼
Cubit
    │  emit(newState)  ← émet un nouvel état
    ▼
State
    │  BlocBuilder/BlocListener  ← l'UI réagit
    ▼
UI se reconstruit
```
AuthCubit — Session globale

Fichier : `lib/cubits/login/auth_cubit.dart`

```dart
enum AuthStatus { unknown, authenticated, unauthenticated }

// Vérifie si un token existe au démarrage (SplashScreen)
Future<void> checkAuthStatus() async {
  final isLoggedIn = await authRepository.isLoggedIn();
  if (isLoggedIn) {
    emit(AuthState.authenticated(user));  // → SplashScreen redirige vers /home
  } else {
    emit(AuthState.unauthenticated());    // → SplashScreen redirige vers /sign_in
  }
}

// Déconnexion : supprime token + déconnecte socket
Future<void> logout() async {
  SocketService.disconnect();
  await authRepository.logout();
  emit(AuthState.unauthenticated()); // → UI redirige vers login
}
```

LoginCubit — Formulaire de connexion

Fichier : `lib/cubits/login/login_cubit.dart`

```dart
Future<void> login(String email, String password) async {
  emit(state.copyWith(loginStatus: LoginStatus.loading)); // Spinner

  try {
    final user = await authRepository.login(email, password);
    emit(state.copyWith(loginStatus: LoginStatus.loaded)); // Succès → /home
  } catch (e) {
    emit(state.copyWith(
      loginStatus: LoginStatus.error,
      errorMessage: e.toString(), // Erreur → SnackBar rouge
    ));
  }
}
```

MessageCubit — Messages en temps réel

Fichier : `lib/cubits/login/message_cubit.dart`

C'est le Cubit le plus complexe. Il gère :

```dart
void init() {
  _loadLocalMessages();    // 1. Charge les messages Hive (instantané)
  SocketService.joinChat(chatId); // 2. Rejoint la room Socket.io

  // 3. Configure les callbacks temps réel
  SocketService.onNewMessage = (message) => _onMessageReceived(message);
  SocketService.onTyping = (chatId) => emit(state.copyWith(isTyping: true));
  SocketService.onStopTyping = (chatId) => emit(state.copyWith(isTyping: false));
}

// Envoi avec "Optimistic Update" :
// Le message apparaît IMMÉDIATEMENT dans l'UI avant la confirmation serveur
Future<void> sendTextMessage(String content, String receiverId) async {
  final message = MessageModel(/* ... */, status: MessageStatus.sending);

  // 1. Ajoute à l'UI immédiatement (pas d'attente)
  emit(state.copyWith(messages: [...state.messages, message]));

  // 2. Envoie au serveur en arrière-plan
  final sentMessage = await messageRepository.sendMessage(message);

  // 3. Met à jour le statut (sending → sent)
  emit(state.copyWith(messages: /* liste mise à jour */));
}
```

ThemeCubit — Mode clair/sombre

Fichier : `lib/cubits/login/theme_cubit.dart`

```dart
// Bascule entre clair et sombre + sauvegarde le choix
Future<void> toggleTheme() async {
  final prefs = await SharedPreferences.getInstance();
  if (state == ThemeMode.dark) {
    await prefs.setBool('is_dark_mode', false);
    emit(ThemeMode.light);
  } else {
    await prefs.setBool('is_dark_mode', true);
    emit(ThemeMode.dark);
  }
}
```
10. Message Repository — Stratégie Offline First

Fichier : `lib/repositories/message_repository.dart`

Concept "Offline First"

L'application fonctionne même sans connexion internet :

```
Envoi d'un message :
  1. Sauvegarde IMMÉDIATEMENT en local (Hive) → statut: sending
  2. Envoie via Socket.io au serveur
  3. Si succès → statut: sent
  4. Si échec  → statut: failed (message visible mais marqué comme non envoyé)

Réception d'un message :
  1. Arrive via Socket.io
  2. Sauvegardé en local (Hive) → statut: delivered
  3. Affiché dans l'UI
  4. Marqué comme "lu" automatiquement si le chat est ouvert
```

---

11. Nouveaux Écrans

RegisterScreen — Inscription

Fichier : `lib/screens/auth/register_screen.dart`

- Formulaire avec validation : nom, email, téléphone (optionnel), mot de passe
- Validation en temps réel avec `GlobalKey<FormState>`
- Bouton désactivé pendant le chargement
- Lien vers le login

ProfileScreen — Profil utilisateur

Fichier : `lib/screens/profile/profile_screen.dart`

- Affiche le nom et email de l'utilisateur connecté
- Toggle dark/light mode via ThemeCubit
- Bouton déconnexion avec confirmation (AlertDialog)
- Placeholders pour notifications et confidentialité

SplashScreen — Amélioré

Fichier : `lib/screens/auth/splash_screen.dart`

- Animation fade-in du logo (0 → 1 en 1 seconde)
- Vérifie le token JWT via AuthCubit
- Redirige vers `/home` si connecté, `/sign_in` sinon
- Indicateur de chargement (CircularProgressIndicator)

LoginScreen — Réécriture complète

Fichier : `lib/screens/auth/login_screen.dart`

Transformé de `StatelessWidget` en `StatefulWidget` :

```dart
// AVANT (bugué) :
onPressed: () {
  context.read<LoginCubit>().login("test@email.com", "123456"); // Hardcodé !
}

// APRÈS (correct) :
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

void _onLoginPressed() {
  if (_formKey.currentState?.validate() ?? false) {
    context.read<LoginCubit>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }
}
```

12. Main.dart — Mise à jour

Fichier : `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();  // ← NOUVEAU : initialise Hive avant tout
  await initializeDateFormatting('fr_FR', null);
  setPathUrlStrategy();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MainApp());
}
```

Nouveaux Cubits injectés globalement :

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),       // ← NOUVEAU
    BlocProvider<AuthCubit>(create: (ctx) => AuthCubit(...)),     // ← NOUVEAU
    BlocProvider<LoginCubit>(create: (ctx) => LoginCubit(...)),   // existant
  ],
  child: BlocBuilder<ThemeCubit, ThemeMode>(  // ← NOUVEAU : thème dynamique
    builder: (context, themeMode) {
      return MaterialApp.router(
        themeMode: themeMode, // Contrôlé par ThemeCubit
        ...
      );
    },
  ),
)
```

13. Résultat du Test sur Chrome

Ce qui a été observé

```
✅ Got object store box in database messages_box  → Hive fonctionne
✅ Got object store box in database chats_box     → Hive fonctionne
✅ Got object store box in database users_box     → Hive fonctionne

❌ DioException [connection error] → http://10.0.2.2:8000/api/login
   Cause : 10.0.2.2 = adresse Android Emulator, invalide sur Chrome
   Fix   : URL changée en http://localhost:8000/api

❌ Requêtes en boucle répétées
   Cause : Bouton login avec valeurs hardcodées se redéclenchait
   Fix   : LoginScreen réécrit avec TextEditingControllers
```

Corrections appliquées

```dart
// app_constants.dart — AVANT
static const String baseUrl = "http://10.0.2.2:8000/api";

// app_constants.dart — APRÈS
static const String baseUrl = "http://localhost:8000/api";
// Pour Android Emulator : remettre 10.0.2.2
```

14. État Final du Projet après Étape 02

Ce qui fonctionne ✅

| Fonctionnalité | État |

| Hive (base de données locale) | ✅ Opérationnel |
| Architecture BLoC complète | ✅ Tous les Cubits implémentés |
| Gestion du token JWT | ✅ Sauvegarde + injection automatique |
| Vérification session au démarrage | ✅ SplashScreen intelligent |
| Formulaire login avec validation | ✅ Complet |
| Formulaire inscription | ✅ Complet |
| Écran profil + déconnexion | ✅ Complet |
| Toggle dark/light mode persistant | ✅ Complet |
| Socket.io (structure) | ✅ Prêt (attend le serveur Node.js) |
| Stratégie Offline First | ✅ Implémentée |

Ce qui attend le serveur ⏳

| Fonctionnalité | Dépendance |

| Login/Register réels | Serveur Laravel d'Emmanuel |
| Messages temps réel | Serveur Node.js de Michaël |
| Notifications push | Firebase (Étape 03) |
| Chiffrement E2EE | Coordination RSI (Étape 03) |

15. Prochaine Étape — Étape 03

| Tâche | Responsable | Priorité |

| Firebase FCM (notifications push) | Dev Mobile | 🔴 Haute |
| Chiffrement E2EE AES-256 | RSI + Dev Mobile | 🔴 Haute |
| Connexion au vrai serveur Laravel | Dev Web + Dev Mobile | 🔴 Haute |
| ChatCubit + ChatRepository | Dev Mobile | 🟡 Moyenne |
| Animations micro-interactions | UI/UX + Dev Mobile | 🟢 Jeudi |



Document rédigé le 20 Mai 2026 — SAMBIENI Firmin — Dev Mobile NovaX
Repo GitHub : https://github.com/firmin-del/connectx-flutter
