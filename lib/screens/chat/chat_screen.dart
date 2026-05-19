/// ============================================================
/// chat_screen.dart
/// Écran de conversation entre deux utilisateurs.
///
/// Reçoit en paramètre :
///   - chatId      : l'identifiant de la conversation
///   - contactName : le nom du contact affiché dans l'AppBar
///
/// Pour l'instant les messages sont mockés (données fictives).
/// L'Étape 02 connectera cet écran au MessageCubit + Socket.io.
/// ============================================================

import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String contactName; // Nom du contact affiché dans l'AppBar

  const ChatScreen({
    super.key,
    required this.chatId,
    this.contactName = 'Contact', // Valeur par défaut si non fourni
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Contrôleur pour lire/vider le champ de saisie
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    // Libère le contrôleur pour éviter les fuites mémoire
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar avec infos du contact ───────────────────────────
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            // Avatar du contact
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              child: const Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 10),
            // Nom + statut en ligne
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contactName, style: const TextStyle(fontSize: 16)),
                const Text(
                  "en ligne",
                  style: TextStyle(fontSize: 12, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
        // Boutons d'action : appel audio et vidéo
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implémenter l'appel audio (WebRTC)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Appel audio — bientôt disponible"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implémenter l'appel vidéo (WebRTC)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Appel vidéo — bientôt disponible"),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Zone des messages ────────────────────────────────────
          Expanded(
            child: ListView.builder(
              reverse: true, // Affiche les messages du bas vers le haut
              padding: const EdgeInsets.all(16),
              itemCount: 15, // Données mockées — sera remplacé par MessageCubit
              itemBuilder: (context, index) {
                // Alterne entre mes messages et ceux du contact
                final isMe = index % 2 == 0;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      // Mes messages en couleur primaire, les autres en gris
                      color: isMe
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMe ? "Bonjour, ça va ?" : "Oui et toi ?",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        // Horodatage du message
                        Text(
                          "14:3${index % 10}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Zone de saisie ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  // withValues remplace withOpacity (déprécié depuis Flutter 3.x)
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                // Bouton emoji
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    // TODO: Ouvrir le sélecteur d'emojis
                  },
                ),

                // Champ de saisie du message
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.15),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null, // Permet les messages multi-lignes
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),

                // Bouton d'envoi
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Envoie le message saisi.
  /// Pour l'instant simule l'envoi — sera connecté au MessageCubit.
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return; // Ignore si le champ est vide

    // TODO: Connecter au MessageCubit.sendTextMessage()
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Envoyé : $text")));
    _messageController.clear();
  }
}
