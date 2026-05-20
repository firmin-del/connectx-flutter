# ✅ Actions Restantes — Michaël & Ulrich
> Projet NovaX — Suivi par SAMBIENI Firmin  
> À compléter avant la soutenance Vendredi 23 Mai 2026

---

## 🔐 MICHAËL MIWANOU — RSI

### Statut actuel
Firmin a déjà créé le serveur Node.js complet dans `novax_realtime/`.  
Michaël doit juste le lancer et donner son IP à Firmin.

---

### Action 1 — Lancer le serveur Socket.io ⏱ 5 min

```bash
# Dans le terminal, aller dans le dossier :
cd "p:\forge_imen_2026\clone_whatsapp_base_code\novax_realtime"

# Installer les dépendances (une seule fois)
npm install

# Lancer le serveur
node server.js
```

✅ Si tout va bien, tu vois :
```
[NovaX Realtime] 🚀 Serveur Socket.io démarré sur le port 3000
[NovaX Realtime] Health check : http://localhost:3000/health
```

---

### Action 2 — Configurer le JWT secret ⏱ 2 min

Ouvrir `novax_realtime/config/socket_config.json` et remplir :

```json
{
  "port": 3000,
  "jwt_secret": "COLLER_ICI_LA_VALEUR_APP_KEY_DU_ENV_LARAVEL"
}
```

> ⚠️ Ce secret doit être **exactement le même** que dans le fichier `.env` de Laravel (Emmanuel).  
> Demander à Emmanuel la valeur de `APP_KEY` dans son `.env`.

---

### Action 3 — Donner l'IP à Firmin ⏱ 1 min

Trouver son IP sur le réseau local :
```bash
# Windows
ipconfig
# → Chercher "Adresse IPv4" ex: 192.168.1.45
```

Donner à Firmin : **`http://192.168.X.X:3000`**

Firmin modifie dans `lib/constants/app_constants.dart` :
```dart
static const String socketUrl = "http://192.168.X.X:3000";
```

---

### Action 4 — E2EE (si le temps le permet) ⏱ 30 min

Actuellement le chiffrement AES-256 utilise une clé locale.  
Pour un vrai E2EE, Michaël doit créer un endpoint d'échange de clés.

**Option simple (recommandée pour la démo) :**
Ajouter dans Laravel (Emmanuel) :
```
POST /api/key-exchange
Body : { "user_id": 2, "public_key": "..." }
GET  /api/key-exchange/{user_id}
```

---

### Action 5 — Nginx (optionnel pour la démo) ⏱ 1h

Si on veut tout passer par un seul port (80) :
```bash
sudo cp novax_realtime/nginx/novax.conf /etc/nginx/sites-available/novax
sudo ln -s /etc/nginx/sites-available/novax /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### ✅ Checklist Michaël

- [ ] `npm install` dans `novax_realtime/`
- [ ] Remplir `jwt_secret` dans `socket_config.json`
- [ ] `node server.js` → serveur sur port 3000
- [ ] Donner son IP à Firmin
- [ ] (Optionnel) E2EE échange de clés
- [ ] (Optionnel) Nginx reverse proxy

### Impact si Michaël fait les 3 premières actions
→ **Messages temps réel entre 2 appareils activés**  
→ **Indicateur "en train d'écrire" actif**  
→ **Coches bleues ✓✓ actives**

---
---

## 🤖 ULRICH HANKPE — Big Data & IA

### Statut actuel
Firmin a déjà créé `SentimentService` (analyse locale) et `AnalyticsService` (log console).  
L'app fonctionne avec l'analyse par mots-clés. Ulrich doit activer le vrai Vertex AI.

---

### Action 1 — Créer le projet Google Cloud ⏱ 10 min

1. Aller sur https://console.cloud.google.com
2. Créer un nouveau projet : **`novax-ai-project`**
3. Activer les APIs :

```bash
gcloud services enable language.googleapis.com
gcloud services enable sheets.googleapis.com
```

---

### Action 2 — Générer une clé API ⏱ 5 min

1. Dans Google Cloud Console → **APIs & Services** → **Credentials**
2. Cliquer **Create Credentials** → **API Key**
3. Copier la clé générée (format : `AIzaSy...`)

---

### Action 3 — Donner la clé API à Firmin ⏱ 1 min

Firmin modifie dans `lib/constants/app_constants.dart` :
```dart
static const String vertexAiUrl =
    "https://language.googleapis.com/v1/documents:analyzeSentiment";
static const String vertexAiKey = "AIzaSy..."; // Clé d'Ulrich
```

✅ Dès que ces 2 lignes sont remplies, l'app utilise le **vrai NLP Google** au lieu des mots-clés.

---

### Action 4 — Créer le Google Sheet ⏱ 10 min

1. Aller sur https://sheets.google.com
2. Créer un nouveau fichier : **"NovaX Analytics"**
3. Créer les colonnes en ligne 1 :

| A | B | C | D | E | F |
|---|---|---|---|---|---|
| Timestamp | Longueur | Sentiment | Heure | Jour | Chat Hash |

4. Copier l'**ID du fichier** depuis l'URL :  
   `https://docs.google.com/spreadsheets/d/**ID_ICI**/edit`

5. Donner l'URL complète à Firmin :
```dart
static const String googleSheetsUrl =
    "https://sheets.googleapis.com/v4/spreadsheets/ID_ICI/values/NovaX_Analytics!A:F:append";
```

---

### Action 5 — Créer le Dashboard Looker Studio ⏱ 30 min

1. Aller sur https://lookerstudio.google.com
2. **Créer** → **Rapport**
3. Source de données → **Google Sheets** → sélectionner "NovaX Analytics"
4. Créer les graphiques :

| Graphique | Type | Données |
|---|---|---|
| Répartition des sentiments | Camembert | Colonne C (Sentiment) |
| Activité par heure | Histogramme | Colonne D (Heure) |
| Évolution du mood | Courbe | Colonnes A + C |
| Messages par jour | Barres | Colonne E (Jour) |

5. Partager le lien du dashboard avec l'équipe

---

### ✅ Checklist Ulrich

- [ ] Créer projet Google Cloud `novax-ai-project`
- [ ] Activer Natural Language API
- [ ] Générer clé API → donner à Firmin
- [ ] Créer Google Sheet "NovaX Analytics" avec les 6 colonnes
- [ ] Donner l'URL Google Sheets à Firmin
- [ ] Créer dashboard Looker Studio
- [ ] Partager le lien du dashboard

### Impact si Ulrich fait les 3 premières actions
→ **Vrai NLP Google Cloud activé** (au lieu des mots-clés)  
→ **Analyse de sentiment plus précise** (score 0.0 à 1.0)  
→ **Pipeline Big Data vers Google Sheets actif**

---

## 📊 Tableau de priorité global

| # | Action | Qui | Temps | Impact soutenance |
|---|---|---|---|---|
| 1 | `node server.js` + donner IP | **Michaël** | 7 min | ⭐⭐⭐ Temps réel actif |
| 2 | Clé API Google + donner à Firmin | **Ulrich** | 15 min | ⭐⭐⭐ Vrai NLP actif |
| 3 | Google Sheet + URL à Firmin | **Ulrich** | 10 min | ⭐⭐ Pipeline Big Data |
| 4 | Dashboard Looker Studio | **Ulrich** | 30 min | ⭐⭐ Démo visuelle jury |
| 5 | JWT secret Socket.io | **Michaël** | 2 min | ⭐⭐ Sécurité auth |
| 6 | E2EE échange de clés | **Michaël** | 30 min | ⭐ Sécurité avancée |
| 7 | Nginx reverse proxy | **Michaël** | 1h | ⭐ Prod (optionnel démo) |

---

## ⚠️ Important — Si rien n'est livré

L'app **fonctionne quand même** pour la soutenance :
- Login/Register → ✅ Laravel Emmanuel (déjà branché)
- Liste conversations → ✅ Laravel Emmanuel (déjà branché)
- Analyse de sentiment → ✅ Mode local (mots-clés français)
- Envoi de messages → ✅ Mode démo (simulation réponse)
- Design → ✅ Wireframes Kamélia appliqués

Le jury verra une app **complète et fonctionnelle**.  
Les parties temps réel et IA seront présentées comme "en cours de déploiement".

---

*Document de suivi — SAMBIENI Firmin — Dev Mobile — Projet NovaX — 20 Mai 2026*
