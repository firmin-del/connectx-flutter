# 🎨 Bilan — Intégration Design Kamélia (ABOU Kamélia)
> Projet NovaX — Dev Mobile : SAMBIENI Firmin  
> Date : Mercredi 20 Mai 2026  
> Commit : `97781ca`

---

## 1. Livrable de Kamélia analysé

**Fichier reçu :** `novax-wireframes.pdf` — Wireframes UI v1.0 — Dark Mode  
**Déposé dans :** `01_Documentation/Wireframes/novax_wireframes.pdf`

### Écrans maquettés par Kamélia

| Écran | Contenu du wireframe |
|---|---|
| **Splash** | Logo rond rouge `[>]`, titre NOVAX, slogan, 3 points animés |
| **Connexion** | Logo, champs Email + Mot de passe, bouton SE CONNECTER, lien S'inscrire |
| **Inscription** | Champs Nom/Email/Téléphone/Mot de passe, bouton CRÉER MON COMPTE |
| **Liste des chats** | AppBar NOVAX + 🔍 + ⋮, liste avec avatars/noms/aperçu/heure/badge, FAB + |
| **Conversation** | AppBar contact + statut en ligne + 📞📹, bulles gauche/droite, barre saisie |
| **Profil** | Avatar initiales, nom/email, paramètres, mode sombre, déconnexion |

### Palette de couleurs officielle NovaX

| Élément | Couleur | Code Hex |
|---|---|---|
| Primary | Rouge NovaX | `#B4223F` |
| Primary Dark | Rouge clair | `#E8395A` |
| Background | Fond principal | `#0D0D0D` |
| Surface | Cartes/AppBar | `#1A1A1A` |
| Bulle reçue | Gris foncé | `#2A2A2A` |
| Texte principal | Blanc cassé | `#F0F0F0` |
| Texte secondaire | Gris | `#9E9E9E` |
| En ligne | Vert | `#4CAF50` |

---

## 2. Fichiers modifiés

### `lib/theme/app_colors.dart` — Palette officielle

Toutes les couleurs de Kamélia centralisées en constantes Dart :

```dart
class AppColors {
  static const Color primary     = Color(0xFFB4223F); // Rouge NovaX
  static const Color primaryDark = Color(0xFFE8395A); // Rouge clair
  static const Color background  = Color(0xFF0D0D0D); // Fond dark
  static const Color surface     = Color(0xFF1A1A1A); // Cartes/AppBar
  static const Color messageSent     = Color(0xFFB4223F); // Bulle envoyée
  static const Color messageReceived = Color(0xFF2A2A2A); // Bulle reçue
  static const Color textPrimary   = Color(0xFFF0F0F0); // Texte principal
  static const Color textSecondary = Color(0xFF9E9E9E); // Texte secondaire
  static const Color online  = Color(0xFF4CAF50); // Point vert en ligne
}
```

### `lib/theme/app_theme.dart` — Thème dark complet

Thème Flutter entièrement reconfiguré selon le design de Kamélia :

```dart
// Dark Theme (prioritaire selon Kamélia)
scaffoldBackgroundColor: AppColors.background,  // #0D0D0D
appBarTheme: AppBarTheme(backgroundColor: AppColors.surface), // #1A1A1A

// Typographie
// Poppins (titres/boutons) + Inter (corps/messages)
textTheme: GoogleFonts.poppinsTextTheme(...)

// Boutons — fond rouge, texte blanc, radius 12px, hauteur 52px
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 52),
    borderRadius: BorderRadius.circular(12),
  ),
)

// Champs de saisie — fond surface, bordure divider, focus rouge
inputDecorationTheme: InputDecorationTheme(
  fillColor: AppColors.surface,
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.primary, width: 2),
  ),
)
```

### `lib/cubits/login/theme_cubit.dart` — Dark mode par défaut

```dart
// AVANT : ThemeMode.system (suivait le système)
ThemeCubit() : super(ThemeMode.system)

// APRÈS : ThemeMode.dark (dark mode par défaut comme Kamélia)
ThemeCubit() : super(ThemeMode.dark)
```

### `lib/screens/auth/splash_screen.dart` — Logo rond

```dart
// AVANT : icône chat simple
Icon(Icons.chat_bubble_rounded, size: 100)

// APRÈS : cercle rouge avec icône [>] (design Kamélia)
Container(
  width: 90, height: 90,
  decoration: BoxDecoration(
    color: AppColors.primary,  // Rouge #B4223F
    shape: BoxShape.circle,
  ),
  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 50),
)
```

### `lib/screens/auth/login_screen.dart` — Logo cohérent

Même logo rond rouge que le SplashScreen (80px).

### `lib/screens/chat/chat_screen.dart` — Couleurs des bulles

```dart
// AVANT : bleu pour mes messages, gris[700] pour les reçus
color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[700]

// APRÈS : couleurs officielles de Kamélia
color: isMe ? AppColors.messageSent : AppColors.messageReceived
// messageSent     = #B4223F (rouge)
// messageReceived = #2A2A2A (gris foncé)
```

### `lib/screens/profile/profile_screen.dart` — Avatar initiales

```dart
// AVANT : icône person générique
Icon(Icons.person, size: 60)

// APRÈS : initiales du nom (comme dans le wireframe "FS")
Text(
  user.name.split(' ').take(2).map((e) => e[0].toUpperCase()).join(),
  // "Firmin SAMBIENI" → "FS"
  // "Emmanuel GBODOU" → "EG"
)
```

---

## 3. Comparaison Avant / Après

| Élément | Avant | Après (Kamélia) |
|---|---|---|
| Fond principal | `#121212` | `#0D0D0D` ✅ |
| Surface/AppBar | `#1E1E1E` | `#1A1A1A` ✅ |
| Bulle envoyée | Bleu `#0084FF` | Rouge `#B4223F` ✅ |
| Bulle reçue | `#2A2A2A` | `#2A2A2A` ✅ |
| Texte principal | Blanc pur | `#F0F0F0` ✅ |
| Texte secondaire | `#B0B0B0` | `#9E9E9E` ✅ |
| Statut en ligne | `#00C853` | `#4CAF50` ✅ |
| Logo | Icône chat | Cercle rouge `[>]` ✅ |
| Police | Questrial | Poppins + Inter ✅ |
| Thème par défaut | System | **Dark** ✅ |
| Avatar profil | Icône person | Initiales (ex: "FS") ✅ |
| Boutons | Radius 12px | Radius 12px + hauteur 52px ✅ |

---

## 4. Résultat visuel

L'app correspond maintenant fidèlement aux wireframes de Kamélia :

```
SPLASH                    CONNEXION                 LISTE DES CHATS
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   fond #0D0D0D  │       │   fond #0D0D0D  │       │ NovaX    🔍  ⋮  │
│                 │       │                 │       │ surface #1A1A1A │
│    ╔═══╗        │       │    ╔═══╗        │       ├─────────────────┤
│    ║[>]║        │       │    ║[>]║        │       │ E  Emmanuel     │
│    ╚═══╝        │       │    ╚═══╝        │       │    Salut...14:32│
│   #B4223F       │       │   #B4223F       │       │              [2]│
│                 │       │                 │       ├─────────────────┤
│  N O V A X      │       │  N O V A X      │       │ M  Michaël      │
│  Poppins Bold   │       │  Poppins Bold   │       │    J'ai envo... │
│                 │       │                 │       └─────────────────┘
│  Messagerie...  │       │ ┌─────────────┐ │
│  Inter Regular  │       │ │ Email       │ │       CONVERSATION
│                 │       │ └─────────────┘ │       ┌─────────────────┐
│   ● ● ●         │       │ ┌─────────────┐ │       │ ← E Emmanuel    │
│   #B4223F       │       │ │ Mot de passe│ │       │   ● en ligne    │
└─────────────────┘       │ └─────────────┘ │       │                 │
                          │ ┌─────────────┐ │       │ ╔═════════════╗ │
                          │ │SE CONNECTER │ │       │ ║ Salut, ça   ║ │
                          │ │  #B4223F    │ │       │ ║ va ? #2A2A2A║ │
                          │ └─────────────┘ │       │ ╚═════════════╝ │
                          └─────────────────┘       │      ╔════════╗ │
                                                    │      ║Très    ║ │
                                                    │      ║bien !  ║ │
                                                    │      ║#B4223F ║ │
                                                    │      ╚════════╝ │
                                                    └─────────────────┘
```

---

## 5. Ce qui reste du design (Jeudi — Finition)

| Élément | Statut | Note |
|---|---|---|
| Animations d'envoi de message | ⏳ À faire | Durées non spécifiées par Kamélia |
| Indicateur "en train d'écrire" (3 points) | ⏳ À faire | Attend Socket.io de Michaël |
| Swipe pour répondre | ⏳ À faire | Jeudi finition |
| Light Mode complet | ⏳ Optionnel | Dark mode prioritaire |
| Icônes personnalisées | ⏳ Optionnel | Material Icons utilisées pour l'instant |

---

*SAMBIENI Firmin — Dev Mobile — Projet NovaX — 20 Mai 2026*  
*Repo : https://github.com/firmin-del/connectx-flutter*
