C'est un gros bloc de fonctionnalités. Je vais tout faire dans l'ordre logique. On commence par lire les fichiers concernés :

Je vais lire tous les fichiers en une seule opération batch.

Voici le contenu complet et résumé de chaque fichier :

---

## 1. `contacts_screen.dart`

**Rôle** : Écran de sélection de contacts pour démarrer une nouvelle conversation.

**Structure** :
- `StatefulWidget` avec état : `_contacts`, `_isLoading`, `_errorMessage`
- `initState` → appelle `_loadContacts()`
- `_loadContacts()` : demande la permission via `ContactService.requestContactsPermission()`, puis charge les contacts NovaX via `ContactService.getNovaXContacts()`
- `build` → `AppBar` avec titre "Nouveau message" + bouton retour vers `/home`
- `_buildBody()` gère 4 cas :
  - Chargement → `CircularProgressIndicator`
  - Erreur de permission → message + bouton "Réessayer"
  - Liste vide → message "Aucun contact NovaX trouvé"
  - Liste remplie → `ListView.separated` avec `ListTile` par contact (avatar avec initiale, point vert si en ligne, statut)
- Tap sur un contact → navigation vers `/chat/{id}?name=...`

---

## 2. `chat_repository.dart`

**Rôle** : Couche d'abstraction entre `ChatCubit` et les services (`ChatService` + `HiveService`). Stratégie **Cache-First**.

**Méthodes** :
- `getCachedChats()` → retourne les chats depuis Hive (actuellement retourne `[]`, TODO non implémenté)
- `fetchChatsFromApi()` → appelle `ChatService.getChats()`, convertit en `List<ChatModel>`, trie par `lastActivity` décroissant
- `fetchMessagesFromApi(chatId, {page})` → appelle `ChatService.getMessages()`, convertit en `List<MessageModel>`, sauvegarde dans Hive, trie par timestamp croissant
- `createChat({participantIds, name})` → appelle `ChatService.createChat()`, retourne un `ChatModel`

---

## 3. `chat_service.dart`

**Rôle** : Appels HTTP vers l'API Laravel pour les conversations. Utilise Dio avec intercepteur JWT.

**Méthodes statiques** :
- `getChats()` → `GET /api/chats` → retourne `List<Map<String, dynamic>>`
- `getMessages(chatId, {page})` → `GET /api/chats/{chatId}/messages?page=1&per_page=20` → retourne la liste depuis `response.data['data']`
- `createChat({participantIds, name})` → `POST /api/chats` avec `participant_ids`, `name` (optionnel), `is_group` (true si > 1 participant) → retourne `Map`
- `_handleError(DioException)` → traduit les erreurs Dio en messages lisibles (timeout, réseau, bad response)

---

## 4. `auth_cubit.dart` — méthodes `checkAuthStatus` et `setAuthenticated`

**`checkAuthStatus()`** :
```dart
Future<void> checkAuthStatus() async {
  final isLoggedIn = await authRepository.isLoggedIn();
  if (isLoggedIn) {
    final userId = await authRepository.getCurrentUserId();
    await _connectSocket();
    emit(AuthState.authenticated(UserModel(id: userId ?? '', name: '', email: '')));
  } else {
    emit(AuthState.unauthenticated());
  }
}
```
Vérifie si un token local existe, connecte le socket si oui, émet l'état correspondant.

**`setAuthenticated(UserModel user)`** :
```dart
void setAuthenticated(UserModel user) {
  _connectSocket();
  emit(AuthState.authenticated(user));
}
```
Appelé par `LoginCubit` après un login réussi. Connecte le socket et émet l'état authentifié.

**Contexte** : `AuthCubit` gère l'état global de session (≠ `LoginCubit` qui gère le formulaire). Possède aussi `logout()` (déconnecte socket + supprime token) et `_connectSocket()` (récupère le token via `AuthService.getToken()` et appelle `SocketService.connect(token)`).

---

## 5. `profile_screen.dart`

**Rôle** : Écran de profil utilisateur (design "Kamélia v1.0").

**Structure** (`StatelessWidget`) :
- Lit l'état via `context.watch<AuthCubit>().state`
- **Header** : avatar animé (TweenAnimationBuilder, elasticOut 700ms) avec initiales, nom et email de l'utilisateur
- **Section Paramètres** :
  - Toggle dark/light mode via `BlocBuilder<ThemeCubit, ThemeMode>` + `Switch`
  - Notifications → SnackBar "Bientôt disponible"
  - Confidentialité → SnackBar "Bientôt disponible" + mention "Chiffrement E2EE activé ✓"
- **Bouton Déconnexion** : rouge, ouvre `_showLogoutDialog()`
- **Version** : affiche `NovaX v{AppConstants.appVersion}`
- `_showLogoutDialog()` : `AlertDialog` avec confirmation → appelle `context.read<AuthCubit>().logout()` puis navigue vers `/sign_in`

---

## 6. `auth_repository.dart`

**Rôle** : Couche d'abstraction entre les Cubits et `AuthService`. Pattern Repository pour découpler la logique métier des détails HTTP.

**Méthodes** :
- `login(email, password)` → délègue à `AuthService.login()`, retourne `UserModel.fromJson(data['user'])`
- `register({name, email, password, phoneNumber?})` → délègue à `AuthService.register()`, retourne `UserModel`
- `logout()` → délègue à `AuthService.logout()`
- `isLoggedIn()` → délègue à `AuthService.isLoggedIn()`, retourne `bool`
- `getCurrentUserId()` → délègue à `AuthService.getCurrentUserId()`, retourne `String?`

---

## 7. `auth_service.dart` — méthodes `login`, `register`, `getToken`

**`login(email, password)`** :
- `POST /api/login` avec `{email, password}`
- Si 200 → sauvegarde token via `_saveToken(data['token'], data['user'])` → retourne `Map {token, user}`
- Sinon → lance `Exception(response.data['message'])`

**`register({name, email, password, phoneNumber?})`** :
- `POST /api/register` avec `{name, email, password, password_confirmation, phone_number?}`
- Si 201 → sauvegarde token → retourne `Map`

**`getToken()`** :
```dart
static Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(AppConstants.tokenKey);
}
```
Lit le token JWT depuis `SharedPreferences`.

**Autres méthodes notables** :
- `_saveToken(token, user)` : sauvegarde dans SharedPreferences les clés `tokenKey`, `userIdKey`, `userNameKey`, `userEmailKey`
- `_clearLocalData()` : supprime ces 4 clés
- `isLoggedIn()` : vérifie que `tokenKey` est non null et non vide
- `getCurrentUserId()` : lit `userIdKey` depuis SharedPreferences
- `logout()` : `POST /api/logout` (ignore les erreurs) + `_clearLocalData()`

J'ai tout analysé. Je vais maintenant implémenter tout en parallèle :

**Plan :**
1. `AuthService` + `AuthRepository` — ajouter `getMe()` + `updateProfile()` + `deleteAccount()`
2. `AuthCubit` — charger le vrai profil depuis `GET /api/me`
3. `ContactsScreen` — créer le chat via l'API avant de naviguer
4. `ChatService` — ajouter `sendMessage()` via API
5. `ProfileScreen` — modifier/supprimer le profil
6. `LoginCubit` — connecter `setAuthenticated` après login/register