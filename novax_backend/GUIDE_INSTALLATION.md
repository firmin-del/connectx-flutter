# NovaX Backend — Guide d'Installation Complet
> Dev Web : Emmanuel GBODOU  
> Projet Forge-IMeN — Mai 2026

---

## Prérequis à installer sur ta machine

| Outil | Version | Téléchargement |
|---|---|---|
| PHP | >= 8.2 | https://www.php.net/downloads |
| Composer | >= 2.x | https://getcomposer.org |
| MySQL | >= 8.0 | https://dev.mysql.com/downloads |
| Node.js | >= 18.x | https://nodejs.org (pour npm) |

Vérifier que tout est installé :
```bash
php --version
composer --version
mysql --version
```

---

## Étape 1 — Cloner / Copier le projet

Le dossier `novax-backend/` est déjà créé dans le workspace.  
Copie-le à l'endroit où tu veux travailler, par exemple :

```bash
# Si tu travailles directement dans le dossier :
cd novax-backend
```

---

## Étape 2 — Installer les dépendances PHP

```bash
composer install
```

Cette commande lit `composer.json` et télécharge :
- `laravel/framework` — le framework
- `laravel/sanctum` — l'authentification par tokens
- `laravel/tinker` — console interactive

---

## Étape 3 — Configurer le fichier .env

```bash
# Copie le fichier d'exemple
cp .env.example .env

# Génère la clé de chiffrement Laravel (obligatoire)
php artisan key:generate
```

Ensuite ouvre `.env` et modifie ces lignes :

```env
APP_NAME=NovaX
APP_URL=http://localhost:8000

# URL du serveur Socket.io de Michaël
SOCKET_URL=http://localhost:3000

# Base de données MySQL
DB_DATABASE=novax_db
DB_USERNAME=root
DB_PASSWORD=ton_mot_de_passe_mysql
```

---

## Étape 4 — Créer la base de données MySQL

```bash
# Ouvre MySQL en ligne de commande
mysql -u root -p

# Dans MySQL, crée la base de données
CREATE DATABASE novax_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

---

## Étape 5 — Lancer les migrations

Les migrations créent les tables dans MySQL :

```bash
php artisan migrate
```

Cela crée les tables :
- `users` — utilisateurs NovaX
- `chats` — conversations
- `chat_participants` — qui participe à quel chat
- `messages` — tous les messages
- `personal_access_tokens` — tokens Sanctum (JWT)

---

## Étape 6 — Peupler la base avec des données de test

```bash
php artisan db:seed
```

Cela crée :
- 5 utilisateurs (toute l'équipe NovaX)
- 3 conversations (2 privées + 1 groupe)
- Des messages de test

**Compte de test :**
```
Email    : emmanuel@novax.com
Password : password123
```

---

## Étape 7 — Lancer le serveur Laravel

```bash
php artisan serve --port=8000
```

Le serveur tourne sur : **http://localhost:8000**

- Interface Web : http://localhost:8000/login
- API REST      : http://localhost:8000/api/login

---

## Étape 8 — Tester l'API avec curl ou Postman

### Test login
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"emmanuel@novax.com","password":"password123"}'
```

Réponse attendue :
```json
{
  "token": "1|abc123...",
  "user": {
    "id": 1,
    "name": "Emmanuel GBODOU",
    "email": "emmanuel@novax.com",
    "phone_number": "+22901020304",
    "profile_picture": null,
    "is_online": true,
    "last_seen": "2026-05-20T14:32:00+00:00"
  }
}
```

### Test liste des chats (avec token)
```bash
curl -X GET http://localhost:8000/api/chats \
  -H "Authorization: Bearer TON_TOKEN_ICI"
```

### Test liste des contacts
```bash
curl -X GET http://localhost:8000/api/contacts \
  -H "Authorization: Bearer TON_TOKEN_ICI"
```

---

## Étape 9 — Donner l'URL à Firmin (Dev Mobile)

Une fois le serveur lancé, donne à Firmin l'IP de ta machine :

```bash
# Trouver ton IP sur le réseau local
ipconfig   # Windows
ifconfig   # Mac/Linux
```

Firmin modifie dans `lib/constants/app_constants.dart` :
```dart
// Remplacer localhost par ton IP
static const String baseUrl = "http://192.168.X.X:8000/api";
```

---

## Résumé des endpoints API

| Méthode | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/login` | ❌ | Connexion |
| POST | `/api/register` | ❌ | Inscription |
| POST | `/api/logout` | ✅ | Déconnexion |
| GET | `/api/me` | ✅ | Profil connecté |
| GET | `/api/contacts` | ✅ | Liste contacts |
| GET | `/api/chats` | ✅ | Liste conversations |
| POST | `/api/chats` | ✅ | Créer conversation |
| GET | `/api/chats/{id}/messages` | ✅ | Messages paginés |
| POST | `/api/chats/{id}/messages` | ✅ | Envoyer message |
| PUT | `/api/chats/{id}/messages/read` | ✅ | Marquer comme lus |

**Header d'authentification :**
```
Authorization: Bearer {token_retourné_par_login}
```

---

## Résumé des routes Web (Interface Blade)

| Méthode | URL | Description |
|---|---|---|
| GET | `/login` | Page de connexion |
| POST | `/login` | Traitement connexion |
| GET | `/register` | Page d'inscription |
| POST | `/register` | Traitement inscription |
| POST | `/logout` | Déconnexion |
| GET | `/chats` | Liste des conversations |
| GET | `/chats/{id}` | Ouvrir une conversation |
| GET | `/contacts` | Liste des contacts |
| POST | `/chats/start` | Démarrer une conversation |

---

## Structure des fichiers produits

```
novax-backend/
│
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php       → API : login, register, logout, me
│   │   │   ├── ChatController.php       → API : chats, messages
│   │   │   ├── ContactController.php    → API : contacts
│   │   │   ├── WebAuthController.php    → Web : login/register (sessions)
│   │   │   └── WebChatController.php    → Web : vues Blade
│   │   └── Middleware/
│   │       └── RateLimitMiddleware.php  → Protection DoS
│   ├── Models/
│   │   ├── User.php                     → Modèle utilisateur
│   │   ├── Chat.php                     → Modèle conversation
│   │   └── Message.php                  → Modèle message
│   └── Providers/
│       └── AppServiceProvider.php       → Rate limiters nommés
│
├── bootstrap/
│   └── app.php                          → Config middleware + exceptions JSON
│
├── config/
│   ├── app.php                          → Config générale + socket_url
│   ├── cors.php                         → CORS pour Flutter
│   ├── database.php                     → Config MySQL
│   └── sanctum.php                      → Config tokens API
│
├── database/
│   ├── migrations/
│   │   ├── ..._create_users_table.php
│   │   ├── ..._create_chats_table.php
│   │   └── ..._create_messages_table.php
│   └── seeders/
│       └── DatabaseSeeder.php           → Données de test (5 users, 3 chats)
│
├── resources/views/
│   ├── layouts/
│   │   └── app.blade.php                → Layout principal (TailwindCSS)
│   ├── auth/
│   │   ├── login.blade.php              → Page connexion
│   │   └── register.blade.php           → Page inscription
│   ├── chat/
│   │   ├── index.blade.php              → Liste conversations
│   │   └── show.blade.php               → Écran de chat (Socket.io)
│   └── contacts/
│       └── index.blade.php              → Sélection contact
│
├── routes/
│   ├── api.php                          → Routes API REST (Flutter)
│   └── web.php                          → Routes Web (Blade)
│
├── composer.json                        → Dépendances PHP
├── .env.example                         → Template de configuration
└── GUIDE_INSTALLATION.md                → Ce fichier
```

---

## En cas de problème

### Erreur "Class not found"
```bash
composer dump-autoload
```

### Erreur de migration
```bash
# Recrée toutes les tables depuis zéro
php artisan migrate:fresh --seed
```

### Erreur CORS depuis Flutter
Vérifie que dans `config/cors.php` :
```php
'allowed_origins' => ['*'],  // En dev : tout autoriser
```

### Voir les logs d'erreur
```bash
tail -f storage/logs/laravel.log
```

### Tester les routes disponibles
```bash
php artisan route:list
```

---

*Emmanuel GBODOU — Dev Web — Projet NovaX — Mai 2026*
