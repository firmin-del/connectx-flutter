# 🎨 Wireframes NovaX — Tous les Écrans
> Proposés par Kiro pour ABOU Kamélia — Motion Design / UI-UX  
> Base de travail pour les maquettes Figma haute fidélité  
> Light Mode + Dark Mode — Mai 2026

---

## Palette de couleurs proposée

```
LIGHT MODE                          DARK MODE
──────────────────────────────────  ──────────────────────────────────
Primary      : #B4223F (rouge NovaX) Primary      : #E8395A (rouge clair)
Background   : #FFFFFF               Background   : #0D0D0D
Surface      : #F5F5F5               Surface      : #1A1A1A
Card         : #FFFFFF               Card         : #222222
Text Primary : #1A1A1A               Text Primary : #F0F0F0
Text Secondary: #757575              Text Secondary: #9E9E9E
Divider      : #E0E0E0               Divider      : #2C2C2C
Sent bubble  : #B4223F               Sent bubble  : #B4223F
Recv bubble  : #F0F0F0               Recv bubble  : #2A2A2A
Sent text    : #FFFFFF               Sent text    : #FFFFFF
Recv text    : #1A1A1A               Recv text    : #F0F0F0
Online dot   : #4CAF50               Online dot   : #4CAF50
Badge        : #B4223F               Badge        : #E8395A
```

---

## Police proposée

```
Titre principal  : Poppins Bold (700) — moderne, impactant
Corps de texte   : Poppins Regular (400) — lisible
Messages         : Inter Regular (400) — neutre, confortable
Heure/Secondaire : Inter Regular (400) — 11-12px
```

---

## 1. SplashScreen

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│                                 │
│         ╔═══════════╗           │
│         ║           ║           │
│         ║   [LOGO]  ║           │
│         ║  💬 NovaX ║           │  ← Icône chat arrondie 80x80
│         ║           ║           │     Couleur : Primary #B4223F
│         ╚═══════════╝           │
│                                 │
│         N  O  V  A  X           │  ← Poppins Bold 42px
│                                 │
│   Messagerie sécurisée &        │  ← Inter Regular 15px
│       intelligente              │     Couleur : Text Secondary
│                                 │
│                                 │
│                                 │
│                                 │
│         ●  ●  ●                 │  ← 3 points animés (loader)
│                                 │     Couleur : Primary
│                                 │
└─────────────────────────────────┘

ANIMATION :
- Logo : fade-in de 0 → 1 en 800ms (easeIn)
- Texte "NOVAX" : slide-up + fade-in, délai 200ms
- Slogan : fade-in, délai 400ms
- Loader : apparaît à 600ms, pulse infini
- Durée totale avant navigation : 3 secondes
```

---

## 2. LoginScreen

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│         ╔═══════════╗           │
│         ║   [LOGO]  ║           │  ← Icône 70x70, Primary
│         ╚═══════════╝           │
│                                 │
│           N O V A X             │  ← Poppins Bold 32px
│    Connecte-toi pour continuer  │  ← Inter 14px, Text Secondary
│                                 │
│  ┌─────────────────────────┐    │
│  │ ✉  Email                │    │  ← TextField
│  └─────────────────────────┘    │     Border radius 12px
│                                 │     Border : Divider color
│  ┌─────────────────────────┐    │     Focus border : Primary
│  │ 🔒  Mot de passe    👁  │    │  ← TextField + toggle visibilité
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │    SE CONNECTER         │    │  ← ElevatedButton
│  └─────────────────────────┘    │     Background : Primary
│                                 │     Height : 52px, radius 12px
│                                 │     Poppins SemiBold 16px blanc
│  Pas encore de compte ?         │
│  ──────────── S'inscrire ──────  │  ← Texte cliquable, Primary
│                                 │
└─────────────────────────────────┘

ÉTATS DU BOUTON :
- Normal    : fond Primary, texte blanc
- Loading   : fond Primary 70%, spinner blanc centré
- Disabled  : fond gris, texte gris

VALIDATION (messages d'erreur sous les champs) :
- Email vide     → "L'email est obligatoire" (rouge, 12px)
- Format invalide → "Format d'email invalide"
- Mdp vide       → "Le mot de passe est obligatoire"
```

---

## 3. RegisterScreen

```
┌─────────────────────────────────┐
│  ←  Créer un compte             │  ← AppBar minimal, flèche retour
├─────────────────────────────────┤
│                                 │
│  Rejoins NovaX                  │  ← Poppins Bold 26px
│  Crée ton compte pour           │  ← Inter 14px, Text Secondary
│  commencer à discuter           │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 👤  Nom complet         │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ ✉  Email                │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 📱  Téléphone (optionnel)│    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🔒  Mot de passe    👁  │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │    CRÉER MON COMPTE     │    │  ← Même style que Login
│  └─────────────────────────┘    │
│                                 │
│  Déjà un compte ?               │
│  ──────── Se connecter ────────  │
│                                 │
└─────────────────────────────────┘
```

---

## 4. ChatListScreen (Écran principal)

```
┌─────────────────────────────────┐
│  N O V A X          🔍  ⋮       │  ← AppBar
│                                 │     "NOVAX" en Primary Bold
│                                 │     Icônes : Search + Menu
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🔍  Rechercher...       │    │  ← Barre de recherche (optionnel)
│  └─────────────────────────┘    │     Background Surface, radius 20px
│                                 │
├─────────────────────────────────┤
│  ●  Emmanuel GBODOU             │  ← ListTile conversation
│     Salut, tu as vu le projet ? │     Avatar : initiale "E" colorée
│                          14:32  │     Heure en Primary si non-lu
│                           [2]   │     Badge rouge avec nombre
├─────────────────────────────────┤
│     Michaël MIWANOU             │
│     J'ai envoyé le fichier 📎   │
│                          13:15  │
│                                 │  ← Pas de badge = tout lu
├─────────────────────────────────┤
│  ●  Kamélia ABOU                │
│     Les wireframes sont prêts ! │
│                          11:00  │
│                           [5]   │
├─────────────────────────────────┤
│     Ulrich HANKPE               │
│     Dashboard mis à jour        │
│                          Hier   │
├─────────────────────────────────┤
│     Équipe NovaX 👥             │  ← Conversation de groupe
│     Firmin: On avance bien 🚀   │     Icône groupe différente
│                          Lun.   │
├─────────────────────────────────┤
│  ...                            │
│                                 │
│                                 │
│                         [  +  ] │  ← FAB Primary, icône add_comment
└─────────────────────────────────┘

DÉTAIL D'UN ITEM :
┌──────────────────────────────────────────────┐
│  ┌────┐                                       │
│  │ E  │  Emmanuel GBODOU          14:32  [2]  │
│  └────┘  Salut, tu as vu le projet ?          │
│  Avatar  Nom (SemiBold 15px)    Heure  Badge  │
│  48x48   Aperçu (Regular 13px, Secondary)     │
└──────────────────────────────────────────────┘

Avatar : cercle 48px, fond Primary 20% opacité, initiale Primary Bold
Badge  : cercle 20px, fond Primary, texte blanc 10px Bold
Heure  : Primary si non-lu, Secondary si lu
```

---

## 5. ChatScreen (Écran de messagerie)

```
┌─────────────────────────────────┐
│  ←  ┌──┐  Emmanuel GBODOU  📞 📹│  ← AppBar
│     │ E │  en ligne             │     Avatar 36px + nom + statut
│     └──┘                        │     Icônes appel + vidéo
├─────────────────────────────────┤
│                                 │
│  ╔═══════════════════════╗      │
│  ║ Salut, ça va ?        ║      │  ← Message reçu (gauche)
│  ║                 14:30 ║      │     Fond : Recv bubble
│  ╚═══════════════════════╝      │     Texte : Recv text
│                                 │     Radius : 18 18 18 0 (coin BG)
│      ╔═══════════════════════╗  │
│      ║ Très bien merci !     ║  │  ← Message envoyé (droite)
│      ║              14:31 ✓✓║  │     Fond : Primary
│      ╚═══════════════════════╝  │     Texte : blanc
│                                 │     Radius : 18 18 0 18 (coin BD)
│  ╔═══════════════════════╗      │
│  ║ Tu as vu le projet ?  ║      │
│  ║                 14:32 ║      │
│  ╚═══════════════════════╝      │
│                                 │
│      ╔═══════════════════════╗  │
│      ║ Oui, on avance 🚀    ║  │
│      ║              14:33 ✓✓║  │
│      ╚═══════════════════════╝  │
│                                 │
│  ┌─ Emmanuel est en train       │
│  │  d'écrire  ● ● ●  ─────┐    │  ← Indicateur typing
│  └──────────────────────────┘   │     3 points animés, Secondary
│                                 │
├─────────────────────────────────┤
│  😊  ┌──────────────┐  📎  ➤   │  ← Barre de saisie
│      │ Message...   │           │     Emoji | TextField | Attach | Send
│      └──────────────┘           │     Background Surface
│                                 │     TextField : radius 30px
└─────────────────────────────────┘

DÉTAIL DES BULLES :
Message envoyé (droite) :
  - Fond : Primary #B4223F
  - Texte : blanc, Inter 15px
  - Heure : blanc 70%, Inter 10px
  - Coches : ✓ (envoyé) | ✓✓ gris (reçu) | ✓✓ bleu (lu)
  - Max width : 75% de l'écran
  - Padding : 14px horizontal, 8px vertical
  - Border radius : 18 18 0 18

Message reçu (gauche) :
  - Fond : #F0F0F0 (light) / #2A2A2A (dark)
  - Texte : Text Primary, Inter 15px
  - Heure : Text Secondary, Inter 10px
  - Border radius : 18 18 18 0

Message image :
  - Image arrondie 200x200, radius 12px
  - Heure en overlay bas-droite sur fond noir 40%

INDICATEUR "EN TRAIN D'ÉCRIRE" :
  - 3 cercles 8px, couleur Secondary
  - Animation : chaque point monte/descend en décalé (150ms)
  - Fond : bulle reçue normale
```

---

## 6. ContactsScreen

```
┌─────────────────────────────────┐
│  ←  Nouveau message             │  ← AppBar
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🔍  Rechercher un contact│   │  ← Barre de recherche
│  └─────────────────────────┘    │
│                                 │
│  CONTACTS NOVAX (6)             │  ← Label section, 12px, Secondary
├─────────────────────────────────┤
│  ┌──┐●  Emmanuel GBODOU         │  ← Contact en ligne
│  │ E │   En ligne               │     Point vert sur avatar
│  └──┘                           │     "En ligne" en vert 12px
├─────────────────────────────────┤
│  ┌──┐   Michaël MIWANOU         │  ← Contact hors ligne
│  │ M │   Hors ligne             │     Pas de point vert
│  └──┘                           │     "Hors ligne" en Secondary
├─────────────────────────────────┤
│  ┌──┐●  Kamélia ABOU            │
│  │ K │   En ligne               │
│  └──┘                           │
├─────────────────────────────────┤
│  ┌──┐●  Ulrich HANKPE           │
│  │ U │   En ligne               │
│  └──┘                           │
├─────────────────────────────────┤
│  ...                            │
└─────────────────────────────────┘

AVATAR AVEC INDICATEUR EN LIGNE :
  ┌────────────┐
  │   ┌────┐   │
  │   │ E  │   │  ← Cercle 48px, fond Primary 15%, initiale Primary Bold
  │   └────┘●  │  ← Point vert 12px, bordure blanche 2px (bas-droite)
  └────────────┘
```

---

## 7. ProfileScreen

```
┌─────────────────────────────────┐
│  ←  Mon Profil                  │  ← AppBar
├─────────────────────────────────┤
│                                 │
│         ┌──────────┐            │
│         │          │            │
│         │  [PHOTO] │            │  ← Avatar 80px
│         │          │            │     Fond Primary 20%
│         └──────────┘            │     Icône person 50px Primary
│           📷                    │  ← Bouton modifier photo (optionnel)
│                                 │
│         Firmin SAMBIENI         │  ← Poppins SemiBold 20px
│      firmin@email.com           │  ← Inter 14px, Secondary
│                                 │
├─────────────────────────────────┤
│                                 │
│  PARAMÈTRES                     │  ← Label section
│                                 │
│  🌙  Mode sombre                │  ← ListTile
│      Activé / Désactivé    [●]  │     Switch à droite
│                                 │
│  🔔  Notifications          ›   │  ← ListTile avec chevron
│      Gérer les notifications    │
│                                 │
│  🔒  Confidentialité        ›   │
│      Chiffrement E2EE activé    │
│                                 │
├─────────────────────────────────┤
│                                 │
│  🚪  Se déconnecter             │  ← ListTile rouge
│                                 │     Icône + texte en rouge
│                                 │
└─────────────────────────────────┘

DIALOG DE CONFIRMATION DÉCONNEXION :
┌─────────────────────────────────┐
│  Se déconnecter                 │  ← Titre Bold
│                                 │
│  Es-tu sûr de vouloir te        │
│  déconnecter de NovaX ?         │
│                                 │
│  [  Annuler  ]  [ Déconnecter ] │  ← Annuler : texte Primary
│                                 │     Déconnecter : texte rouge
└─────────────────────────────────┘
```

---

## 8. Spécifications des Animations

### Animation 1 — Envoi d'un message
```
Déclencheur : tap sur bouton Envoyer
Durée       : 250ms
Courbe      : easeOut

Étapes :
1. La bulle apparaît en bas à droite (scale 0.8 → 1.0)
2. Simultanément : fade-in (opacity 0 → 1)
3. La liste scroll automatiquement vers le bas
4. Le champ de saisie se vide avec un fade-out du texte
```

### Animation 2 — Indicateur "en train d'écrire"
```
3 cercles de 8px de diamètre, espacés de 4px
Couleur : Text Secondary

Cycle (infini, 1200ms total) :
- Point 1 : monte de 0 → -6px en 300ms, redescend en 300ms
- Point 2 : même animation, décalée de 150ms
- Point 3 : même animation, décalée de 300ms

Apparition : fade-in 200ms quand l'autre personne commence à écrire
Disparition : fade-out 200ms quand elle arrête
```

### Animation 3 — Swipe pour répondre
```
Déclencheur : glisser un message vers la droite (> 60px)
Durée retour : 300ms (spring animation)

Étapes :
1. Message glisse vers la droite (translateX)
2. À 60px : icône répondre (↩) apparaît à gauche (fade-in)
3. Vibration légère (haptic feedback)
4. Relâcher → message revient en position (spring)
5. Zone de saisie se focus avec "Répondre à : [aperçu]"
```

### Animation 4 — Transition entre écrans
```
ChatList → ChatScreen :
  - ChatScreen slide-in depuis la droite (300ms, easeInOut)
  - ChatList reste visible en arrière-plan (scale 0.95)

ChatScreen → ChatList :
  - ChatScreen slide-out vers la droite (300ms, easeInOut)
  - ChatList revient à scale 1.0
```

### Animation 5 — Badge non-lu
```
Apparition : scale 0 → 1.2 → 1.0 (pop) en 300ms
Disparition : scale 1.0 → 0 en 200ms (quand on ouvre le chat)
Mise à jour du nombre : flip vertical 150ms
```

---

## 9. Composants réutilisables à créer

```
NovaXAvatar
  - Taille : small (32px) | medium (48px) | large (80px)
  - Contenu : initiale colorée OU photo de profil
  - Indicateur en ligne : optionnel (point vert)

NovaXBubble
  - Type : sent | received | image | voice
  - Contenu : texte + heure + statut (coches)
  - Fond selon type et thème

NovaXBadge
  - Nombre de messages non lus
  - Max affiché : 99+

NovaXTextField
  - Style uniforme pour tous les formulaires
  - Radius 12px, border Primary au focus
  - Icône préfixe + suffixe optionnels

NovaXButton
  - Primary : fond Primary, texte blanc
  - Secondary : bordure Primary, texte Primary
  - Loading : spinner centré
  - Disabled : gris
```

---

## 10. Checklist Kamélia → Firmin

Ce que Kamélia doit livrer pour que Firmin intègre :

- [ ] Palette de couleurs complète (format `Color(0xFF...)`)
- [ ] Nom de la police Google Fonts confirmé
- [ ] Wireframes Figma exportés (PNG ou lien Figma) dans `01_Documentation/Wireframes/`
- [ ] Durées des animations (ms) pour chaque interaction
- [ ] Icônes personnalisées si différentes des Material Icons (format SVG)
- [ ] Validation du design sur les 2 modes (Light + Dark)

---

*Wireframes proposés par Kiro — Base de travail pour Kamélia — Projet NovaX — Mai 2026*
