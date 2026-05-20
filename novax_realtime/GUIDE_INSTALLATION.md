# 🔐 NovaX Realtime — Guide d'Installation
> MIWANOU Michaël — RSI  
> Projet Forge-IMeN — Mai 2026

---

## Prérequis

| Outil | Version | Téléchargement |
|---|---|---|
| Node.js | >= 18.x | https://nodejs.org |
| npm | >= 9.x | Inclus avec Node.js |

Vérifier :
```bash
node --version
npm --version
```

---

## Étape 1 — Installer les dépendances

```bash
cd novax_realtime
npm install
```

Packages installés :
- `socket.io` — WebSocket temps réel
- `jsonwebtoken` — Vérification token JWT Laravel
- `cors` — Autoriser les requêtes cross-origin depuis Flutter

---

## Étape 2 — Configurer

Modifier `config/socket_config.json` :

```json
{
  "port": 3000,
  "jwt_secret": "MEME_SECRET_QUE_LARAVEL",
  "cors_origins": ["http://localhost:*", "http://192.168.*.*:*"]
}
```

> ⚠️ Le `jwt_secret` doit être **identique** à celui dans le `.env` Laravel d'Emmanuel.

---

## Étape 3 — Lancer le serveur

```bash
node server.js
```

Le serveur tourne sur : **http://localhost:3000**

---

## Étape 4 — Donner l'URL à Firmin

```dart
// Firmin modifie dans app_constants.dart :
static const String socketUrl = "http://IP_MICHAEL:3000";
```

---

## Résumé des événements Socket.io

### Client → Serveur (Flutter envoie)
```javascript
socket.emit('join_chat',    { chat_id: '42' })
socket.emit('send_message', { id, sender_id, chat_id, content, type })
socket.emit('typing',       { chat_id: '42' })
socket.emit('stop_typing',  { chat_id: '42' })
socket.emit('message_read', { chat_id: '42', message_id: '123' })
```

### Serveur → Client (Flutter reçoit)
```javascript
socket.on('new_message',  (data) => { ... })
socket.on('user_online',  (userId) => { ... })
socket.on('user_offline', (userId) => { ... })
socket.on('typing',       (chatId) => { ... })
socket.on('stop_typing',  (chatId) => { ... })
socket.on('message_read', ({ chat_id, message_id }) => { ... })
```

---

## Configuration Nginx (Infrastructure)

```nginx
# /etc/nginx/sites-available/novax
server {
    listen 80;
    server_name novax.local;

    # Laravel API → port 8000
    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Socket.io → port 3000
    location /socket.io {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

---

*MIWANOU Michaël — RSI — Projet NovaX — Mai 2026*
