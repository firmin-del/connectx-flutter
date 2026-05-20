# 🔗 Bilan — Intégration Backend Laravel (Emmanuel GBODOU)
> Projet NovaX — Dev Mobile : SAMBIENI Firmin  
> Date : Mercredi 20 Mai 2026  
> Commit : `a7c2c54`

---

## 1. Ce qui a été fait

### Livrable d'Emmanuel analysé ✅

Le dossier `novax_backend/` contient un backend Laravel complet :

| Fichier | Rôle |
|---|---|
| `routes/api.php` | Toutes les routes API REST |
| `app/Http/Controllers/AuthController.php` | Login, Register, Logout, Me |
| `app/Http/Controllers/ChatController.php` | Chats, Messages, MarkAsRead |
| `app/Http/Controllers/ContactController.php` | Liste des contacts NovaX |
| `app/Models/User.php` | Modèle utilisateur avec Sanctum |
| `app/Models/Chat.php` | Modèle conversation |
| `app/Models/Message.php` | Modèle message |
| `database/migrations/` | 5 tables créées |
| `database/seeders/DatabaseSeeder.php` | Données de test |

---

## 2. Installation du serveur Laravel

### Prérequis installés
- **Laragon** (PHP 8.3 + MySQL + Composer) sur Windows

### Commandes exécutées
```bash
cd /d "p:\forge_imen_2026\clone_whatsapp_base_code\novax_backend"

composer install                    # Installation des dépendances PHP
copy .env.example .env              # Création du fichier de config
php artisan key:generate            # Génération de la clé de chiffrement
php artisan migrate:fresh --seed    # Création des tables + données de test
php artisan serve --port=8000       # Lancement du serveur
```

### Fichiers manquants créés manuellement
Emmanuel n'avait pas livré ces fichiers (oubli) — créés par Firmin :
- `artisan` — point d'entrée CLI Laravel
- `public/index.php` — point d'entrée HTTP
- `app/Http/Controllers/Controller.php` — classe de base des controllers
- `storage/` — dossiers de cache et logs
- `bootstrap/cache/` — cache de configuration

---

## 3. Tables créées dans MySQL (novax_db)

| Table | Rôle |
|---|---|
| `users` | Utilisateurs NovaX (id, name, email, password, phone_number, is_online...) |
| `chats` | Conversations (id, name, is_group, created_by) |
| `chat_participants` | Qui participe à quel chat (pivot many-to-many) |
| `messages` | Messages (id, chat_id, sender_id, content, type, status) |
| `personal_access_tokens` | Tokens Sanctum (JWT) |
| `cache` | Cache pour le Rate Limiting |

### Données de test (seeder)
```
Compte de test : emmanuel@novax.com / password123
Conversations  : 2 privées + 1 groupe "Équipe NovaX 🚀"
```

---

## 4. Problèmes rencontrés et solutions

| Problème | Cause | Solution |
|---|---|---|
| `Could not open input file: artisan` | Fichier `artisan` manquant | Créé manuellement |
| `Class Controller not found` | `Controller.php` manquant | Créé manuellement |
| `Table cache doesn't exist` | Migration cache manquante | `php artisan migrate` |
| `Table personal_access_tokens doesn't exist` | Migration Sanctum manquante | `php artisan migrate:fresh --seed` |
| Barre rouge dans Flutter | Toutes les erreurs ci-dessus | Résolues une par une |

---

## 5. Adaptation du code Flutter

### UserModel.fromJson() corrigé
Laravel retourne les champs en **snake_case** — Flutter attendait du **camelCase**.

```dart
// AVANT (ne correspondait pas au JSON Laravel)
profilePicture: json['profilePicture'],
phoneNumber: json['phoneNumber'],
isOnline: json['isOnline'] ?? false,
lastSeen: json['lastSeen'] != null ? ...

// APRÈS (correspond exactement au JSON Laravel)
profilePicture: json['profile_picture'] as String?,
phoneNumber: json['phone_number'] as String?,
isOnline: json['is_online'] as bool? ?? false,
lastSeen: json['last_seen'] != null ? ...
```

---

## 6. Résultat final — Capture d'écran

L'application Flutter affiche les **vraies données** de la base MySQL :

```
┌─────────────────────────────────┐
│  NovaX                    🔍  ⋮ │
├─────────────────────────────────┤
│  E  Emmanuel GBODOU       09:52 │
│     Nouvelle conversation       │
├─────────────────────────────────┤
│  E  Emmanuel GBODOU       09:52 │  ← Badge rouge (1 message non lu)
│     Nouvelle conversation       │
├─────────────────────────────────┤
│  É  Équipe NovaX 🚀       09:52 │
│     Nouvelle conversation       │
└─────────────────────────────────┘
```

✅ Thème dark actif  
✅ Initiales dans les avatars  
✅ Badge rouge sur conversation non lue  
✅ Heure réelle depuis la base de données  
✅ Nom du groupe "Équipe NovaX 🚀"  

---

## 7. Endpoints API disponibles et testés

| Méthode | Endpoint | Auth | Statut |
|---|---|---|---|
| POST | `/api/login` | ❌ | ✅ Fonctionne |
| POST | `/api/register` | ❌ | ✅ Fonctionne |
| POST | `/api/logout` | ✅ | ✅ Fonctionne |
| GET | `/api/me` | ✅ | ✅ Fonctionne |
| GET | `/api/contacts` | ✅ | ✅ Fonctionne |
| GET | `/api/chats` | ✅ | ✅ Fonctionne |
| POST | `/api/chats` | ✅ | ✅ Fonctionne |
| GET | `/api/chats/{id}/messages` | ✅ | ✅ Fonctionne |
| POST | `/api/chats/{id}/messages` | ✅ | ✅ Fonctionne |
| PUT | `/api/chats/{id}/messages/read` | ✅ | ✅ Fonctionne |

**Header d'authentification :**
```
Authorization: Bearer {token_retourné_par_login}
```

---

## 8. Comment relancer le serveur

À chaque fois qu'on veut tester l'app, lancer dans le terminal Laragon :

```bash
cd /d "p:\forge_imen_2026\clone_whatsapp_base_code\novax_backend"
php artisan serve --port=8000
```

Puis lancer Flutter :
```bash
flutter run -d chrome
```

---

## 9. Ce qui reste à brancher

| Fonctionnalité | Dépendance | Statut |
|---|---|---|
| Messages temps réel | Serveur Node.js de **Michaël** (port 3000) | ⏳ En attente |
| Notifications push | Firebase à configurer | ⏳ En attente |
| Chiffrement E2EE | Protocole de **Michaël** (RSI) | ⏳ En attente |
| Wireframes + couleurs | **Kamélia** (UI/UX) | ⏳ En attente |
| Analyse de sentiment | Endpoint Vertex AI d'**Ulrich** | ⏳ En attente |

---

*SAMBIENI Firmin — Dev Mobile — Projet NovaX — 20 Mai 2026*  
*Repo : https://github.com/firmin-del/connectx-flutter*
