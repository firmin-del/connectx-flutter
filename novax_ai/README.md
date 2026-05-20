# 🤖 NovaX AI — Livrable Big Data & IA
> HANKPE Ulrich — Filière Big Data & IA  
> Projet NovaX — Méthode Forge-IMeN — Mai 2026

---

## Rôle dans le projet

Ulrich est responsable de la couche **Intelligence Artificielle** de NovaX :
- Analyse de sentiment des messages via **Vertex AI** (Google Cloud)
- Pipeline Big Data → **Google Sheets**
- Dashboard décisionnel **Google Looker Studio**

---

## Structure de ce dossier

```
novax_ai/
├── README.md                    → Ce fichier
├── GUIDE_INSTALLATION.md        → Comment configurer Vertex AI
├── config/
│   └── vertex_ai_config.json    → Configuration Vertex AI (à remplir)
├── services/
│   ├── sentiment_service.py     → Service Python d'analyse de sentiment
│   └── sheets_pipeline.py       → Pipeline vers Google Sheets
└── dashboard/
    └── looker_config.json        → Configuration Looker Studio
```

---

## Compte de test

```
Projet Google Cloud : novax-ai-project (à créer)
Région              : europe-west1
Service             : Natural Language API / Vertex AI
```

---

## Ce que Firmin (Dev Mobile) attend d'Ulrich

```dart
// Dans app_constants.dart — à remplir par Ulrich :
static const String vertexAiUrl = "https://...vertex.ai/...";
static const String vertexAiKey = "AIza...";
static const String googleSheetsUrl = "https://sheets.googleapis.com/...";
```

---

*HANKPE Ulrich — Big Data & IA — Projet NovaX — Mai 2026*
