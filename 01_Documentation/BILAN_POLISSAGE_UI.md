# ✨ Bilan — Polissage UI (Jeudi — Finition)
> Projet NovaX — Dev Mobile : SAMBIENI Firmin  
> Date : Mercredi 20 Mai 2026  
> Commits : `d3fc60b`, `8c7d79e`

---

## Animations ajoutées par écran

| Écran | Animation | Durée | Courbe |
|---|---|---|---|
| **SplashScreen** | Logo fade-in | 800ms | easeIn |
| **SplashScreen** | Titre slide-up + fade | 600ms | easeOut |
| **SplashScreen** | Slogan fade-in | 500ms | easeIn |
| **SplashScreen** | 3 points animés (Kamélia) | 600ms/cycle | easeInOut |
| **LoginScreen** | Shake formulaire sur erreur | 400ms | easeInOut |
| **ChatScreen** | Bulles scale + fade à l'apparition | 250ms | easeOut |
| **ChatScreen** | Indicateur "en train d'écrire" (3 points) | 600ms/cycle | easeInOut |
| **ChatScreen** | Scroll auto vers le bas | 300ms | easeOut |
| **ChatListScreen** | Slide-in décalé par item | 300ms + 50ms/item | easeOut |
| **ProfileScreen** | Avatar pop (elasticOut) | 700ms | elasticOut |

---

## Détail technique

### SplashScreen — 3 points animés
```dart
// Chaque point monte de 0 → -8px et redescend, décalé de 150ms
_dot1Controller.repeat(reverse: true);
await Future.delayed(Duration(milliseconds: 150));
_dot2Controller.repeat(reverse: true);
await Future.delayed(Duration(milliseconds: 150));
_dot3Controller.repeat(reverse: true);
```

### LoginScreen — Shake sur erreur
```dart
// TweenSequence : 0 → 10 → -10 → 10 → -10 → 0 (en 400ms)
_shakeAnimation = TweenSequence<double>([...]).animate(controller);
// Déclenché dans BlocListener quand loginStatus == error
_shakeController.forward(from: 0);
```

### ChatScreen — Bulle animée
```dart
// Chaque bulle : scale 0.8 → 1.0 + opacity 0 → 1 en 250ms
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: Duration(milliseconds: 250),
  curve: Curves.easeOut,
  builder: (context, value, child) => Opacity(
    opacity: value,
    child: Transform.scale(scale: 0.8 + (0.2 * value), child: child),
  ),
)
```

### ChatScreen — Simulation "en train d'écrire"
```dart
// Après envoi d'un message → simule la réponse du contact
// 1. Affiche les 3 points animés pendant 2 secondes
// 2. Ajoute une réponse automatique
// Sera remplacé par les événements Socket.io de Michaël
```

### ChatListScreen — Slide-in décalé
```dart
// Chaque item slide depuis la droite avec un délai croissant
TweenAnimationBuilder<double>(
  duration: Duration(milliseconds: 300 + (index * 50)),
  builder: (context, value, child) => Transform.translate(
    offset: Offset(30 * (1 - value), 0), // Slide depuis droite
    child: Opacity(opacity: value, child: child),
  ),
)
```

### ProfileScreen — Avatar pop
```dart
// L'avatar apparaît avec un effet "pop" élastique à l'ouverture
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: Duration(milliseconds: 700),
  curve: Curves.elasticOut, // Effet rebond
  builder: (context, value, child) => Transform.scale(scale: value, child: child),
)
```

---

## Améliorations visuelles supplémentaires

- **ProfileScreen** : icônes colorées par section (rouge/bleu/vert), fond surface Kamélia, version app en bas
- **ChatScreen** : bouton envoi rond rouge (cercle primary), barre de saisie fond surface
- **LoginScreen** : style dark complet avec AppColors, lettrage espacé sur le titre
- **BottomSheet image** : fond surface Kamélia, icônes avec fond coloré

---

## Ce qui reste (si Michaël livre Socket.io)

- Remplacer la simulation "en train d'écrire" par les vrais événements Socket.io
- Coches ✓✓ bleues quand message lu (événement `message_read`)
- Statut "en ligne" dynamique depuis Socket.io

---

*SAMBIENI Firmin — Dev Mobile — Projet NovaX — 20 Mai 2026*
