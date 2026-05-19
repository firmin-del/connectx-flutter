

Novax — Résumé Technique du Projet
> Clone WhatsApp développé en Flutter  
> Document de présentation à l'équipe — Mai 2026


1. Présentation générale

ConnectX est une application mobile de messagerie instantanée développée avec le framework Flutter (Dart). Elle s'inspire de WhatsApp et vise à reproduire ses fonctionnalités principales : liste de conversations, messagerie en temps réel, gestion de profil, et support des médias.

Le projet est multiplateforme : il peut tourner sur Android, iOS, Web, Windows, Linux et macOS depuis une seule base de code.



2. Stack technique

| Technologie | Rôle | Version |

| Flutter / Dart | Framework UI multiplateforme | SDK ^3.10.4 |
| flutter_bloc | Gestion d'état (pattern BLoC/Cubit) | ^9.1.1 |
| go_router | Navigation déclarative | ^17.2.3 |
| Dio | Client HTTP pour les appels API REST | ^5.9.2 |
| sqflite | Base de données locale SQLite | ^2.4.2 |
| shared_preferences | Stockage clé-valeur (token, préférences) | ^2.5.5 |
| equatable | Comparaison d'objets pour BLoC | ^2.0.8 |
| google_fonts | Typographie (police Questrial) | ^8.1.0 |
| image_picker | Sélection de photos/vidéos | ^1.2.2 |
| permission_handler| Gestion des permissions système | ^12.0.1 |
| intl | Internationalisation et formatage des dates | ^0.20.2 |



3. Architecture du projet

Le projet suit une architecture en couches (Clean Architecture simplifiée), ce qui facilite la maintenance, les tests et le travail en équipe.


lib/
│
├── constants/          → Constantes globales (URL API, nom de l'app, durées...)
├── cubits/             → Logique métier et gestion d'état (BLoC/Cubit)
├── models/             → Structures de données (User, Chat, Message, Contact)
├── repositories/       → Couche d'accès aux données (API + base locale)
│   ├── api_repository/ → Appels vers le serveur distant
│   └── local_db_repository/ → Accès à la base SQLite locale
├── routes/             → Configuration de la navigation
├── screens/            → Écrans de l'application (UI)
│   ├── auth/           → Splash, Login, Register
│   ├── home/           → Liste des conversations
│   ├── chat/           → Écran de messagerie
│   └── profile/        → Profil utilisateur
├── services/           → Services bas niveau (HTTP, Socket, Notifications)
├── theme/              → Thème visuel (couleurs, typographie, dark/light mode)
├── utils/              → Fonctions utilitaires partagées
└── widgets/            → Composants UI réutilisables


Principe du flux de données


UI (Screen)
    ↕  écoute / déclenche
Cubit (logique métier)
    ↕  appelle
Repository (abstraction des données)
    ↕  délègue à
Service (HTTP / Socket / DB locale)
    ↕  communique avec
Serveur distant / SQLite



4. Gestion d'état — Pattern BLoC/Cubit

On a utilisé flutter_bloc avec le pattern Cubit (version simplifiée de BLoC).

-Comment ça fonctionne ?

Un Cubit est une classe qui :
- Détient un état (`State`)
- Expose des méthodes que l'UI peut appeler
- Émet de nouveaux états via `emit()`

Exemple concret — LoginCubit

```dart
// L'état possible du login
enum LoginStatus { initial, loading, loaded, error }

class LoginState extends Equatable {
  final LoginStatus loginStatus;
  final String errorMessage;
  // ...
}

// Le Cubit qui gère la logique
class LoginCubit extends Cubit<LoginState> {
  Future<void> login(String email, String password) async {
    emit(state.copyWith(loginStatus: LoginStatus.loading)); // → affiche un loader
    try {
      await authRepository.login(email, password);
      emit(state.copyWith(loginStatus: LoginStatus.loaded)); // → redirige vers home
    } catch (e) {
      emit(state.copyWith(loginStatus: LoginStatus.error)); // → affiche une erreur
    }
  }
}
```
L'UI écoute ces changements avec `BlocListener` ou `BlocBuilder` et réagit automatiquement.


5.Navigation — go_router

La navigation est gérée de façon déclarative avec `go_router`. Toutes les routes sont définies en un seul endroit.

Routes actuelles

| Route | Écran | Description |

| `/` | SplashScreen | Écran de démarrage (3 secondes) |
| `/sign_in` | LoginScreen | Connexion utilisateur |
| `/home` | ChatListScreen | Liste des conversations |
| `/chat/:chatId` | ChatScreen | Conversation avec un contact |

Navigation dans le code

```dart
context.go('/home');           // Naviguer vers home (remplace l'historique)
context.go('/chat/42');        // Ouvrir le chat avec l'ID 42
context.push('/sign_in');      // Empiler un écran (avec retour possible)
```
6. Modèles de données

Les modèles représentent les entités métier de l'application.

UserModel
```
id, name, email, profilePicture, phoneNumber, isOnline, lastSeen
```

ChatModel
```
id, participants (liste de UserModel), name (pour groupes),
lastMessage, lastActivity, unreadCount, isGroup
```

MessageModel
```
id, senderId, receiverId, chatId, content,
type (text/image/video/file/voice), timestamp, isRead, mediaUrl
```

ContactModel
```
id, name, avatar, isOnline
```
Tous les modèles ont des méthodes `fromJson()` et `toJson()` pour la sérialisation avec l'API.

7. Écrans réalisés

🟢 SplashScreen
- Affiche le logo et le nom de l'app pendant 3 secondes
- Redirige automatiquement vers le login
- Utilise le thème de l'application (compatible dark/light mode)

🟢 LoginScreen
- Formulaire email + mot de passe
- Connecté au `LoginCubit` via `BlocListener`
- Affiche un feedback visuel (SnackBar) selon le résultat
- Redirige vers `/home` en cas de succès

🟢 ChatListScreen
- Liste scrollable des conversations (données mockées pour l'instant)
- Chaque item affiche : avatar, nom du contact, dernier message, heure, badge non-lu
- Tap sur un item → navigation vers `ChatScreen`
- Bouton flottant pour créer un nouveau chat (à implémenter)

🟢 ChatScreen
- Reçoit l'`id` du chat via les paramètres de route
- Affiche les messages sous forme de bulles (droite = moi, gauche = l'autre)
- Zone de saisie avec bouton emoji et bouton envoi
- AppBar avec nom du contact, statut "en ligne", boutons appel/vidéo
- Données mockées (15 messages alternés)

🟡 HomeScreen
- Écran alternatif (placeholder) — non utilisé dans la navigation actuelle

🔴 RegisterScreen — vide
🔴 ProfileScreen — vide

8. Thème visuel

L'application supporte le mode clair et sombre automatiquement selon le système.

Couleurs principales
- Primaire: Rouge foncé `#B4223F` (couleur de marque ConnectX)
- Background light: `#FCFCFC`
- Background dark: `#121212`
- Messages envoyés: Bleu `#0084FF`
- Messages reçus: Gris foncé `#2A2A2A`

Typographie
- Police Questrial (Google Fonts) — moderne et lisible

9. Configuration API

```dart
// Deux environnements prévus
static String testBaseUrl = "https://api.dev.com/api/v1/";
static String prodBaseUrl  = "https://api.com/api/v1/";

// URL locale pour le développement (émulateur Android)
static const String baseUrl   = "http://10.0.2.2:3000";
static const String socketUrl = "http://10.0.2.2:3000";
```

Le client HTTP **Dio** est configuré avec :
- Timeout de connexion : 30 secondes
- Headers JSON par défaut
- Acceptation de tous les codes HTTP < 600 (gestion manuelle des erreurs)

10. Base de données locale (SQLite)

La structure de base est en place via `sqflite`. Le fichier `db_definition.dart` contient la logique de création de la base. Le schéma est à adapter aux modèles du projet (tables : users, chats, messages).

11. Ce qui reste à faire

Priorité haute 🔴
- [ ] Implémenter le vrai appel API dans `AuthService.login()`
- [ ] Créer `RegisterScreen` (inscription)
- [ ] Remplir `ChatCubit` + `ChatRepository` avec des données réelles
- [ ] Adapter le schéma SQLite (tables users, chats, messages)

Priorité moyenne 🟡
- [ ] Implémenter `SocketService` pour la messagerie en temps réel
- [ ] Implémenter `NotificationService` pour les push notifications
- [ ] Créer `ProfileScreen`
- [ ] Remplir `MessageCubit` + `MessageRepository`
- [ ] Implémenter `ThemeCubit` pour le changement de thème manuel

Priorité basse 🟢
- [ ] Déplacer la config router dans `app_routes.dart`
- [ ] Corriger les imports dupliqués dans `main.dart`
- [ ] Utiliser `AppColors` dans le thème
- [ ] Ajouter la gestion des médias (image_picker)
- [ ] Implémenter la recherche de contacts

12. Répartition suggérée du travail en équipe

| Module | Fichiers concernés | Compétences |

|Auth & Login| `auth_cubit`, `auth_service`, `register_screen` | BLoC, API REST |
|Messagerie| `chat_cubit`, `message_cubit`, `chat_screen` | BLoC, Socket.IO |
|Base de données| `db_definition`, `chat_repository`, `message_repository` | SQLite, SQL |
|UI / Thème| `app_theme`, `app_colors`, widgets communs | Flutter UI |
|Profil| `profile_screen`, `user_model` | Flutter UI, API |
|Notifications| `notification_service` | Firebase / local notif |

13. Comment lancer le projet

```bash
# Installer les dépendances
flutter pub get

# Lancer sur un émulateur ou appareil connecté
flutter run

# Lancer sur Chrome (web)
flutter run -d chrome

# Build Android
flutter build apk
```

---

*Document généré le 19 Mai 2026 — Projet ConnectX*
