// chat_screen.dart
// Écran de conversation entre deux utilisateurs.
//
// Fonctionnalités implémentées :
//   - Affichage des messages (bulles droite/gauche)
//   - Saisie et envoi de messages texte
//   - Envoi d'images via image_picker (caméra ou galerie)
//   - Indicateur de statut en ligne
//   - Boutons appel audio/vidéo (placeholders)
//
// Paramètres reçus via go_router :
//   - chatId      : identifiant de la conversation
//   - contactName : nom du contact affiché dans l'AppBar

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Package pour caméra/galerie
import 'dart:io'; // Pour afficher les images locales (File)
import 'package:flutter/foundation.dart' show kIsWeb; // Détection web

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String contactName;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.contactName = 'Contact',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Contrôleur du champ de saisie texte
  final TextEditingController _messageController = TextEditingController();

  // Instance image_picker pour accéder à la caméra et la galerie
  final ImagePicker _imagePicker = ImagePicker();

  // Liste des messages affichés (mockés pour l'instant)
  // Sera remplacée par MessageCubit quand le serveur sera disponible
  final List<_MockMessage> _messages = [
    _MockMessage(text: "Salut ! Comment ça va ?", isMe: false, time: "14:30"),
    _MockMessage(text: "Très bien merci, et toi ?", isMe: true, time: "14:31"),
    _MockMessage(
      text: "Super ! Tu as vu le projet NovaX ?",
      isMe: false,
      time: "14:32",
    ),
    _MockMessage(text: "Oui, on avance bien 🚀", isMe: true, time: "14:33"),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ─────────────────────────────────────────────────
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            // Avatar du contact avec initiale
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              child: Text(
                widget.contactName.isNotEmpty
                    ? widget.contactName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Nom + statut
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contactName, style: const TextStyle(fontSize: 16)),
                const Text(
                  "en ligne",
                  style: TextStyle(fontSize: 11, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Bouton appel audio
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _showComingSoon("Appel audio"),
          ),
          // Bouton appel vidéo
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _showComingSoon("Appel vidéo"),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Zone des messages ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              reverse: true, // Plus récent en bas
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Les messages sont en ordre inverse (reverse: true)
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // ── Zone de saisie ─────────────────────────────────────
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── Construction d'une bulle de message ──────────────────────

  Widget _buildMessageBubble(_MockMessage message) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(
          // La bulle ne dépasse pas 75% de la largeur de l'écran
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[700],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            // Coin inférieur arrondi du côté opposé à l'expéditeur
            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // ── Image si c'est un message image ─────────────────
            if (message.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    // Sur le web, on ne peut pas utiliser File
                    ? const Icon(Icons.image, color: Colors.white, size: 80)
                    : Image.file(
                        File(message.imagePath!),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 4),
            ],

            // ── Texte du message ─────────────────────────────────
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),

            const SizedBox(height: 2),

            // ── Heure + statut de lecture ────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                // Coches de statut (uniquement pour mes messages)
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all, // ✓✓
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Barre de saisie ───────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Bouton pièce jointe (image) ────────────────────────
          // Ouvre un menu pour choisir entre caméra et galerie
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _showImageSourceDialog,
            tooltip: "Envoyer une image",
          ),

          // ── Champ de saisie ────────────────────────────────────
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
                fillColor: Colors.grey.withValues(alpha: 0.12),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              maxLines: null, // Multi-lignes
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          // ── Bouton envoi ───────────────────────────────────────
          IconButton(
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _sendTextMessage,
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────

  /// Envoie le message texte saisi.
  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Ajoute le message à la liste locale (optimistic update)
    setState(() {
      _messages.add(_MockMessage(text: text, isMe: true, time: _currentTime()));
    });

    _messageController.clear();

    // TODO: Connecter à MessageCubit.sendTextMessage() quand serveur disponible
    // context.read<MessageCubit>().sendTextMessage(text, receiverId);
  }

  /// Affiche un menu pour choisir la source de l'image.
  /// Deux options : Caméra ou Galerie de photos.
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      // Coins arrondis en haut
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre du menu
              const Text(
                "Envoyer une image",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Option : Prendre une photo avec la caméra
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
                title: const Text("Prendre une photo"),
                subtitle: const Text("Utiliser la caméra"),
                onTap: () {
                  Navigator.pop(context); // Ferme le menu
                  _pickImage(ImageSource.camera);
                },
              ),

              // Option : Choisir depuis la galerie
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.photo_library)),
                title: const Text("Choisir depuis la galerie"),
                subtitle: const Text("Sélectionner une photo existante"),
                onTap: () {
                  Navigator.pop(context); // Ferme le menu
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ouvre la caméra ou la galerie et envoie l'image sélectionnée.
  ///
  /// [source] : ImageSource.camera ou ImageSource.gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Ouvre la caméra ou la galerie
      // imageQuality: 70 = compresse l'image à 70% pour réduire la taille
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Compression pour économiser la bande passante
        maxWidth: 1024, // Largeur max en pixels
        maxHeight: 1024, // Hauteur max en pixels
      );

      // L'utilisateur a annulé la sélection
      if (pickedFile == null) return;

      // Ajoute le message image à la liste locale
      setState(() {
        _messages.add(
          _MockMessage(
            text: '', // Pas de texte pour un message image
            isMe: true,
            time: _currentTime(),
            imagePath: pickedFile.path, // Chemin local de l'image
          ),
        );
      });

      // TODO: Uploader l'image sur le serveur et envoyer l'URL via Socket.io
      // final imageUrl = await MediaService.uploadImage(pickedFile);
      // context.read<MessageCubit>().sendImageMessage(imageUrl, receiverId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image sélectionnée — envoi bientôt disponible"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Gestion des erreurs (permission refusée, caméra indisponible, etc.)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Impossible d'accéder à la caméra : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Retourne l'heure actuelle formatée "HH:mm"
  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Affiche un SnackBar "bientôt disponible"
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible")));
  }
}

// ── Modèle de message mocké ───────────────────────────────────

/// Classe interne pour les messages mockés.
/// Sera remplacée par MessageModel quand le serveur sera disponible.
class _MockMessage {
  final String text; // Contenu textuel
  final bool isMe; // true = message envoyé par moi
  final String time; // Heure d'envoi formatée "HH:mm"
  final String? imagePath; // Chemin local de l'image (null si message texte)

  _MockMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.imagePath,
  });
}
