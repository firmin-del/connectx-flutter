Analyse Détaillée du Cahier des Charges — Projet NovaX
> Document de synthèse à destination de l'équipe  
> Rédigé par : SAMBIENI Firmin — Dev Mobile  
> Date : Mardi 20 Mai 2026

1. Contexte et Objectif du Projet

Le projet NovaX s'inscrit dans le cadre de la méthode Forge-IMeN, une semaine intensive de développement en équipe pluridisciplinaire.

- Durée totale: 5 jours du Lundi 18 au Vendredi 23 Mai 2026
- Objectif principal: Reconstruire de zéro l'écosystème complet de messagerie instantanée de WhatsApp
- Contraintes: Application fonctionnelle, sécurisée, temps réel, multiplateforme (Web + Mobile)
- Évaluation finale: Grand Oral devant jury — Noté sur 42 XP le Vendredi

2. Composition de l'Équipe (Groupe 1)

Le projet réunit 5 filières différentes, chacune avec un rôle précis et complémentaire :

| # | Filière | Membre | Rôle dans NovaX |

| 1 | Développement Mobile | SAMBIENI Firmin | Application Flutter (iOS/Android) |
| 2 | Développement Web | Emmanuel GBODOU | Interface Web + Backend Laravel |
| 3 | RSI (Réseaux, Sécurité, Infra) | MIWANOU Michaël | Chiffrement E2EE + Infrastructure serveur |
| 4 | Big Data & IA | HANKPE Ulrich | Analyse de sentiment + Dashboard |
| 5 | Motion Design / UI-UX | ABOU Kamélia | Maquettes, animations, design système |

> ⚠️ Chaque membre a signé le cahier des charges le Lundi 18/05/2026, s'engageant à respecter les interfaces définies et les délais.

3. Architecture Globale du Système NovaX

Le système est découplé en plusieurs couches pour garantir la performance, sécurité et scalabilité.

┌─────────────────────────────────────────────────────────────────┐
│                        CLIENTS                                  │
│                                                                 │
│   📱 Flutter (Mobile)          🌐 Web (Laravel Blade)           │
│   iOS / Android                HTML5 + TailwindCSS + JS ES6+    │
└──────────────┬──────────────────────────┬───────────────────────┘
               │                          │
               │  REST API (HTTP/HTTPS)    │  REST API (HTTP/HTTPS)
               │                          │
               ▼                          ▼
┌─────────────────────────────────────────────────────────────────┐
│              BACKEND PRINCIPAL — Laravel (PHP)                  │
│  • Authentification utilisateurs (JWT)                          │
│  • Gestion des profils                                          │
│  • Synchronisation des contacts                                 │
│  • Persistance des données (ORM Eloquent)                       │
│  • Rate Limiting (protection DoS)                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                  BASE DE DONNÉES — MySQL                        │
│  • Utilisateurs, profils, contacts                              │
│  • Métadonnées des messages                                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│           SERVEUR TEMPS RÉEL — Node.js + Socket.io              │
│  • Connexions persistantes WebSocket                            │
│  • Acheminement instantané des messages entre clients           │
│  • Port 3000                                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              SERVICES CLOUD & IA                                │
│                                                                 │
│  🔔 Firebase (FCM)          🤖 Vertex AI (Google Cloud)         │
│  Push notifications         Analyse de sentiment NLP            │
│  Messages hors-ligne        Score Positif/Neutre/Négatif        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              INFRASTRUCTURE (RSI)                               │
│  • Nginx (Reverse Proxy) : Laravel port 80/443, Node port 3000  │
│  • TLS 1.3 (Let's Encrypt) — HTTPS obligatoire                  │
│  • UFW + Fail2ban (pare-feu + protection brute force)           │
└─────────────────────────────────────────────────────────────────┘
```

4. Spécifications Détaillées par Filière

4.1.Dev Mobile — SAMBIENI Firmin (Flutter)

Rôle: Offrir une expérience utilisateur native, rapide et intégrée au système d'exploitation mobile.

Fonctionnalités à livrer

| Fonctionnalité | Description technique | Package Flutter | État |

| Navigation fluide | Transitions entre écrans (liste → chat) | `go_router` | ✅ Fait |
| Liste des discussions | Affichage des conversations avec badge non-lu | `flutter_bloc` | ✅ Fait (mock) |
| Écran de chat | Bulles de messages, zone de saisie | `flutter_bloc` | ✅ Fait (mock) |
| Accès contacts | Synchronisation annuaire local du téléphone | `contact_service` | 🔴 À faire |
| Caméra & images | Capture et envoi d'images dans le chat | `image_picker` | 🔴 À faire |
| Socket.io temps réel | Connexion au serveur Node.js pour messages live | `socket_io_client` | 🔴 À faire |
| Notifications push | Réception messages même appli fermée (FCM) | Firebase SDK | 🟡 Mercredi |
| Persistance locale | Stockage des messages hors-ligne | **Hive** | 🔴 À faire |
| Chiffrement E2EE | Chiffrement AES-256 avant envoi | Coordination RSI | 🟡 Mercredi |
| Micro-animations | Swipe pour répondre, indicateur "en train d'écrire" | Coordination UI/UX | 🟢 Jeudi |

Stack Mobile
```
Flutter (Dart) + Firebase SDK + Hive
```

> ⚠️ Point important: Le cahier des charges spécifie Hive pour la persistance locale (et non SQLite/sqflite). Il faut migrer la base de données locale.

4.2.Dev Web — Emmanuel GBODOU (Laravel + Web)

Rôle: Accessibilité universelle via une interface de bureau et mobile web.

Fonctionnalités à livrer

-Interface Responsive: TailwindCSS pour simuler fidèlement WhatsApp Web
-Bulles de chat: Alignement dynamique (droite émetteur / gauche récepteur), statuts de lecture (envoyé ✓, reçu ✓✓, lu ✓✓ bleu), horodatage, auto-scroll
-Connexion Hybride: Script client Socket.io pour écouter le serveur Node.js en temps réel
-Backend Laravel: Gestion auth, profils, contacts, persistance MySQL

Stack Web
```
Laravel (Blade) + HTML5 + TailwindCSS + JavaScript ES6+ + Socket.io-client
```

> 🔗Interface avec Mobile: Les endpoints API Laravel doivent être partagés avec Firmin pour que Flutter puisse s'y connecter via Dio.

4.3.🔐RSI — MIWANOU Michaël (Sécurité + Infrastructure)

Rôle: Garantir l'inviolabilité des échanges et la résilience de l'infrastructure.

Fonctionnalités à livrer

| Composant | Description |
| E2EE (Chiffrement bout en bout)| Protocole asymétrique (clés publiques/privées). Chiffrement AES-256 côté client avant envoi. Le serveur ne voit que du texte chiffré. |
| Nginx Reverse Proxy | Redirige : port 80/443 → Laravel, port 3000 → Node.js |
| TLS 1.3 | Certificat Let's Encrypt — HTTPS obligatoire |
| Pare-feu | UFW + Fail2ban pour bloquer attaques brute force |
| Rate Limiting | Middleware Laravel pour bloquer les attaques DoS |

> 🔗Interface avec Mobile : Michaël doit fournir la librairie/méthode de chiffrement AES-256 compatible Flutter pour que Firmin puisse l'intégrer côté client mobile.

4.4.🤖Big Data & IA — HANKPE Ulrich (Vertex AI + Analytics)

Rôle: Valoriser les données intelligemment sans violer le chiffrement.

Fonctionnalités à livrer

| Composant | Description |

| Analyse de Sentiment | NLP via Vertex AI (Google Cloud). Score : Positif / Neutre / Négatif. Analyse avant chiffrement côté client ou sur canaux de groupe non chiffrés. |
| Pipeline Big Data | Extraction anonymisée des métadonnées (heure d'envoi, longueur message, score sentiment) → Google Sheets via API depuis Laravel |
| Dashboard | Google Looker Studio connecté en temps réel au Google Sheet. Affiche : mood général, pics de charge horaire |

Stack IA
```
Vertex AI + API Google Sheets + Google Looker Studio
```

> 🔗Interface avec Mobile : Si l'analyse de sentiment se fait côté client, Ulrich doit fournir l'endpoint Vertex AI à appeler depuis Flutter avant l'envoi du message.

4.5.🎨UI/UX Motion — ABOU Kamélia (Design)

Rôle: Rendre l'application intuitive, moderne et agréable.

Livrables attendus

| Livrable | Description |

| Wireframes haute fidélité | Light Mode + Dark Mode, codes graphiques NovaX (dossier `01_Documentation/Wireframes/` — actuellement vide ⚠️) |
| Micro-interactions | Animations d'envoi de messages, swipe pour répondre, indicateur "en train d'écrire" |
| Design Système | Export des assets : icônes, palettes de couleurs (Tailwind + Flutter), polices |

> 🔗Interface avec Mobile : Kamélia doit exporter les couleurs et polices en format compatible Flutter (`Color(0xFF...)`) et fournir les specs des animations pour intégration dans Flutter.

5.Exigences Non Fonctionnelles (Critères de Qualité)

| Critère | Objectif | Responsable |

| Performance | Transmission d'un message en < 200ms | RSI + Dev Web |
| Scalabilité | Séparation HTTP (Laravel) et WebSocket (Node.js) | RSI |
| Disponibilité Mobile | Réception messages hors-ligne via Firebase | Dev Mobile |
| Sécurité | Chiffrement E2EE AES-256, TLS 1.3 | RSI |
| UX | Fluidité des transitions, micro-animations | UI/UX + Dev Mobile |

6.Feuille de Route — 5 Jours

| Jour | Phase | Objectif | Livrable |

| Lundi ✅ | Découverte | Analyse du protocole + design de l'architecture | Cahier des charges validé & signé |
| Mardi 🔴 | Base | Coder les structures de données + envoi/réception | Repo GitHub + Premier Commit |
| Mercredi 🟡 | Construction | Injecter la sécurité (E2EE) + IA fonctionnelle | Démo interne |
| Jeudi 🟢 | Finition | Polissage UI/UX + optimisations + déploiement | Version Bêta en ligne |
| Vendredi 🎯 | Soutenance | Pitch commercial + technique devant jury | Note /42 XP |

7. État d'Avancement — Dev Mobile (Mardi matin)

✅ Déjà réalisé (Étape 01 — Lundi/Mardi matin)

| Réalisation | Détail |

| Architecture Flutter en couches | constants / cubits / models / repositories / services / screens / theme / widgets |
| Navigation go_router | Routes : `/` → `/sign_in` → `/home` → `/chat/:chatId` |
| SplashScreen | Logo + nom + redirection automatique après 3s |
| LoginScreen | Formulaire + BLoC connecté + feedback SnackBar |
| ChatListScreen | Liste mockée 8 contacts + navigation vers chat |
| ChatScreen | Bulles de messages mockées + zone de saisie |
| Modèles de données | UserModel, ChatModel, MessageModel, ContactModel |
| LoginCubit + LoginState | Pattern BLoC complet avec Equatable + copyWith |
| AuthRepository + AuthService | Chaîne complète Cubit → Repo → Service → Dio |
| Thème Light/Dark | Google Fonts Questrial + couleurs NovaX |
| Repo GitHub | [github.com/firmin-del/connectx-flutter](https://github.com/firmin-del/connectx-flutter) |
| Premier commit | 229 fichiers — `feat: initial commit — NovaX base architecture (Etape 01)` |

🔴À faire — Étape 02 (Mardi)

| Tâche | Priorité | Dépendance |

| Migrer sqflite → Hive|🔴Haute| Aucune |
| Implémenter SocketService (Node.js)|🔴Haute| Michaël (URL serveur)|
| Implémenter AuthService réel (API Laravel)|🔴Haute|Emmanuel (endpoints)|
| Compléter ChatCubit + ChatRepository|🔴Haute|SocketService|
| Compléter MessageCubit + MessageRepository|🔴Haute|Hive + Socket 
| Créer RegisterScreen|🔴Haute|AuthService|
| Intégrer contact_service|🟡Moyenne|Permission Android/iOS|

8.Interfaces Critiques entre Filières

Ces points nécessitent une coordination immédiate entre membres :

📡 Mobile ↔ Dev Web (Emmanuel)
- Besoin : Liste des endpoints API Laravel (login, register, get chats, send message, get contacts)
- Format : JSON REST, méthodes HTTP, headers attendus
- Urgence : Aujourd'hui (Mardi)

🔐 Mobile ↔ RSI (Michaël)
- Besoin : Méthode de chiffrement AES-256 compatible Dart/Flutter
- Format : Fonction `encrypt(String message, String publicKey)` → `String ciphertext`
- Urgence : Mercredi matin

🎨 Mobile ↔ UI/UX (Kamélia)
- Besoin : Wireframes + palette de couleurs Flutter + specs animations
- Format : Fichiers Figma exportés + couleurs en `Color(0xFF...)` + durées d'animation en ms
- Urgence : Mercredi (pour intégration Jeudi)

🤖 Mobile ↔ Big Data/IA (Ulrich)
- Besoin : Endpoint Vertex AI ou méthode d'appel pour analyse de sentiment
- Format : URL + clé API + format de la requête/réponse
- Urgence : Mercredi

9.Dépendances Flutter à Ajouter (Étape 02)

Les packages suivants doivent être ajoutés au `pubspec.yaml` pour l'Étape 02 :

```yaml
dependencies:
  Déjà présents ✅
  flutter_bloc: ^9.1.1
  go_router: ^17.2.3
  dio: ^5.9.2
  image_picker: ^1.2.2
  shared_preferences: ^2.5.5

 À ajouter 🔴
  hive: ^2.2.3                    # Base de données locale (remplace sqflite)
  hive_flutter: ^1.1.0            # Intégration Flutter pour Hive
  socket_io_client: ^2.0.3+1      # Connexion Socket.io → Node.js
  firebase_core: ^3.6.0           # Firebase SDK core
  firebase_messaging: ^15.1.3     # Push notifications FCM
  contacts_service: ^0.6.3        # Accès annuaire téléphone
  permission_handler: ^12.0.1     # Déjà présent ✅
  encrypt: ^5.0.3                 # Chiffrement AES-256 côté client
```

10.Résumé Visuel — Ce qu'on construit

```
┌─────────────────────────────────────────────────────┐
│                   APP NOVAX MOBILE                  │
│                                                     │
│  SplashScreen → LoginScreen → RegisterScreen        │
│                      ↓                              │
│              ChatListScreen (Home)                  │
│                      ↓                              │
│              ChatScreen (Messagerie)                │
│                      ↓                              │
│              ProfileScreen                          │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │           COUCHE LOGIQUE (BLoC)             │   │
│  │  LoginCubit | ChatCubit | MessageCubit      │   │
│  │  AuthCubit  | ThemeCubit                    │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │           COUCHE DONNÉES                    │   │
│  │  AuthRepository → AuthService → Laravel API │   │
│  │  ChatRepository → SocketService → Node.js   │   │
│  │  MessageRepository → Hive (local)           │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

Document rédigé le 20 Mai 2026 — SAMBIENI Firmin — Dev Mobile NovaX 
Basé sur : Cahier de charges du projet NovaX.pdf — Méthode Forge-IMeN
