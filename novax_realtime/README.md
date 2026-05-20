# 🔐 NovaX Realtime — Livrable RSI
> MIWANOU Michaël — Filière Réseaux, Sécurité & Infrastructures  
> Projet NovaX — Méthode Forge-IMeN — Mai 2026

---

## Rôle dans le projet

Michaël est responsable de :
- **Serveur Node.js + Socket.io** — messagerie temps réel (port 3000)
- **Chiffrement E2EE** — AES-256 bout en bout
- **Infrastructure** — Nginx reverse proxy + TLS 1.3 + Fail2ban

---

## Structure de ce dossier

```
novax_realtime/
├── README.md                  → Ce fichier
├── GUIDE_INSTALLATION.md      → Comment lancer le serveur Node.js
├── server.js                  → Serveur Socket.io principal
├── middleware/
│   └── auth.js                → Vérification token JWT
├── config/
│   └── socket_config.json     → Configuration du serveur
└── nginx/
    └── novax.conf             → Configuration Nginx reverse proxy
```

---

## Ce que Firmin (Dev Mobile) attend de Michaël

```dart
// Dans app_constants.dart — à remplir par Michaël :
static const String socketUrl = "http://IP_MICHAEL:3000";
```

**Événements Socket.io attendus :**

| Événement | Direction | Données |
|---|---|---|
| `send_message` | Client → Serveur | `{id, sender_id, chat_id, content, type}` |
| `new_message` | Serveur → Client | même format |
| `typing` | Client → Serveur | `{chat_id}` |
| `stop_typing` | Client → Serveur | `{chat_id}` |
| `message_read` | Client → Serveur | `{chat_id, message_id}` |
| `join_chat` | Client → Serveur | `{chat_id}` |
| `user_online` | Serveur → Client | `userId` |
| `user_offline` | Serveur → Client | `userId` |

---

*MIWANOU Michaël — RSI — Projet NovaX — Mai 2026*
