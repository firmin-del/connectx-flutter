Voici exactement ce qu'il reste à faire pour chacun :

---

## 🤖 Ulrich — Ce qui reste

### Ce que Firmin a déjà fait (côté Flutter)
- ✅ `SentimentService` — analyse locale par mots-clés (fonctionne sans lui)
- ✅ `AnalyticsService` — log console (fonctionne sans lui)
- ✅ Emoji de sentiment sur les bulles

### Ce qu'Ulrich doit encore livrer

**1. Créer le projet Google Cloud**
```
→ Aller sur console.cloud.google.com
→ Créer projet "novax-ai-project"
→ Activer Natural Language API
→ Générer une clé API
```

**2. Donner à Firmin ces 3 valeurs :**
```dart
// app_constants.dart
static const String vertexAiUrl = "https://language.googleapis.com/v1/documents:analyzeSentiment";
static const String vertexAiKey = "AIza..."; // Sa clé API
static const String googleSheetsUrl = "https://sheets.googleapis.com/v4/spreadsheets/{ID}/values/...";
```

**3. Créer le Google Sheet** avec les colonnes :
```
A: Timestamp | B: Longueur | C: Sentiment | D: Heure | E: Jour | F: Hash chat
```

**4. Créer le dashboard Looker Studio** connecté au Google Sheet

**Impact si Ulrich ne livre pas :** L'app fonctionne quand même avec l'analyse locale. Le jury voit les emojis de sentiment. Seul le vrai dashboard Looker Studio manque.

---

## 🔐 Michaël — Ce qui reste

### Ce que Firmin a déjà fait (côté Flutter)
- ✅ `SocketService` — prêt à se connecter
- ✅ `server.js` — serveur Node.js complet créé
- ✅ `ChatScreen` — bascule automatiquement en temps réel si socket connecté

### Ce que Michaël doit encore livrer

**1. Lancer le serveur Node.js**
```bash
cd novax_realtime
npm install
node server.js
# → Serveur sur port 3000
```

**2. Donner à Firmin son IP :**
```dart
// app_constants.dart
static const String socketUrl = "http://IP_MICHAEL:3000";
```

**3. Configurer le JWT secret** dans `novax_realtime/config/socket_config.json` :
```json
{
  "jwt_secret": "MEME_SECRET_QUE_LARAVEL"
}
```
→ Ce secret doit être **identique** à celui dans le `.env` Laravel d'Emmanuel.

**4. Configurer Nginx** (optionnel pour la démo, obligatoire en prod) :
```bash
sudo cp novax_realtime/nginx/novax.conf /etc/nginx/sites-available/novax
sudo nginx -t && sudo systemctl reload nginx
```

**5. E2EE — Protocole d'échange de clés** (si le temps le permet) :
- Actuellement `EncryptionService` utilise une clé locale symétrique
- Michaël doit définir comment les deux utilisateurs échangent leurs clés
- Option simple : clé partagée via l'API Laravel (POST `/api/key-exchange`)

**Impact si Michaël ne livre pas :** L'app fonctionne en mode démo (simulation). Le jury voit les messages s'envoyer. Seul le vrai temps réel entre 2 appareils manque.

---

## Résumé — Priorités

| Action | Qui | Temps estimé | Impact |
|---|---|---|---|
| Lancer `node server.js` | Michaël | **5 minutes** | Messages temps réel entre 2 appareils |
| Donner IP + JWT secret | Michaël | **2 minutes** | Firmin branche en 1 ligne |
| Créer clé API Google | Ulrich | **15 minutes** | Vrai NLP au lieu de mots-clés |
| Créer Google Sheet | Ulrich | **10 minutes** | Pipeline Big Data actif |
| Dashboard Looker Studio | Ulrich | **30 minutes** | Démo visuelle pour le jury |
| Nginx + TLS | Michaël | **1 heure** | Sécurité prod (optionnel pour démo) |

**La chose la plus rapide et impactante : Michaël lance `node server.js` et donne son IP → 7 minutes de travail pour activer le temps réel complet.**
