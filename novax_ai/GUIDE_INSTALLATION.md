# 🤖 NovaX AI — Guide d'Installation Complet
> HANKPE Ulrich — Big Data & IA  
> Projet Forge-IMeN — Mai 2026

---

## Prérequis

| Outil | Version | Téléchargement |
|---|---|---|
| Python | >= 3.10 | https://python.org |
| Google Cloud SDK | Latest | https://cloud.google.com/sdk |
| Compte Google Cloud | - | https://console.cloud.google.com |

---

## Étape 1 — Créer le projet Google Cloud

```bash
# Installer Google Cloud SDK puis :
gcloud auth login
gcloud projects create novax-ai-project
gcloud config set project novax-ai-project
```

---

## Étape 2 — Activer les APIs nécessaires

```bash
# API Vertex AI (analyse de sentiment)
gcloud services enable aiplatform.googleapis.com

# API Google Sheets (pipeline Big Data)
gcloud services enable sheets.googleapis.com

# API Natural Language (alternative à Vertex AI)
gcloud services enable language.googleapis.com
```

---

## Étape 3 — Créer une clé API

```bash
# Crée une clé de service account
gcloud iam service-accounts create novax-ai-sa
gcloud iam service-accounts keys create key.json \
  --iam-account novax-ai-sa@novax-ai-project.iam.gserviceaccount.com
```

La clé `key.json` contient les credentials à utiliser.

---

## Étape 4 — Installer les dépendances Python

```bash
cd novax_ai
pip install -r requirements.txt
```

---

## Étape 5 — Configurer le fichier config

Remplir `config/vertex_ai_config.json` :

```json
{
  "project_id": "novax-ai-project",
  "location": "europe-west1",
  "api_key": "AIza...",
  "endpoint_url": "https://language.googleapis.com/v1/documents:analyzeSentiment",
  "google_sheets_id": "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms",
  "google_sheets_range": "Sheet1!A:F"
}
```

---

## Étape 6 — Tester l'analyse de sentiment

```bash
python services/sentiment_service.py --text "Salut, ça va super bien !"
# → { "score": "positive", "confidence": 0.95 }

python services/sentiment_service.py --text "Ce projet est nul"
# → { "score": "negative", "confidence": 0.87 }
```

---

## Étape 7 — Donner les infos à Firmin (Dev Mobile)

Une fois configuré, donner à Firmin :

```
URL Vertex AI  : https://language.googleapis.com/v1/documents:analyzeSentiment
Clé API        : AIza...
URL Sheets     : https://sheets.googleapis.com/v4/spreadsheets/{ID}/values/{RANGE}:append
```

Firmin les met dans `lib/constants/app_constants.dart` :
```dart
static const String vertexAiUrl = "TON_URL";
static const String vertexAiKey = "TA_CLE";
static const String googleSheetsUrl = "TON_URL_SHEETS";
```

---

## Format des requêtes/réponses

### Analyse de sentiment (Vertex AI / Natural Language API)

**Requête :**
```json
POST https://language.googleapis.com/v1/documents:analyzeSentiment
Authorization: Bearer {API_KEY}

{
  "document": {
    "type": "PLAIN_TEXT",
    "content": "Salut, ça va super bien !"
  },
  "encodingType": "UTF8"
}
```

**Réponse :**
```json
{
  "documentSentiment": {
    "magnitude": 0.9,
    "score": 0.8
  },
  "language": "fr",
  "sentences": [...]
}
```

**Interprétation du score :**
- `score > 0.25`  → **positive** 😊
- `score < -0.25` → **negative** 😠
- Entre les deux  → **neutral** 😐

---

## Pipeline Big Data — Google Sheets

### Format des données envoyées

| Colonne | Type | Description |
|---|---|---|
| A | DateTime | Heure d'envoi |
| B | Integer | Longueur du message |
| C | String | Score sentiment (positive/neutral/negative) |
| D | Integer | Heure de la journée (0-23) |
| E | Integer | Jour de la semaine (1-7) |
| F | String | Hash anonymisé du chat |

### Dashboard Looker Studio

Connecter Google Sheets au dashboard :
1. Aller sur https://lookerstudio.google.com
2. Créer une nouvelle source de données → Google Sheets
3. Sélectionner le fichier NovaX Analytics
4. Créer les graphiques :
   - Répartition des sentiments (camembert)
   - Évolution du mood dans le temps (courbe)
   - Pics d'activité par heure (histogramme)

---

*HANKPE Ulrich — Big Data & IA — Projet NovaX — Mai 2026*
