// chat_screen.dart
// Écran de conversation — design Kamélia v1.0
//
// Polissage UI :
//   - Animation d'apparition des bulles (scale + fade, 250ms easeOut)
//   - Indicateur "en train d'écrire" (3 points animés comme Kamélia)
//   - Bouton envoi animé (scale au tap)
//   - Scroll automatique vers le bas à chaque nouveau message
//   - Barre de saisie avec fond surface Kamélia

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../theme/app_colors.dart';

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

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  // ScrollController pour auto-scroll vers le bas
  final ScrollController _scrollController = ScrollController();

  // Contrôleur pour l'animation des 3 points "en train d'écrire"
  late AnimationController _typingDot1;
  late AnimationController _typingDot2;
  late AnimationController _typingDot3;

  // Simule l'indicateur "en train d'écrire" (sera branché sur Socket.io)
  bool _isContactTyping = false;

  // Messages de démonstration
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
  void initState() {
    super.initState();
    _setupTypingAnimation();
  }

  void _setupTypingAnimation() {
    // 3 points animés — cycle de 600ms chacun, décalés de 150ms
    _typingDot1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _typingDot2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _typingDot3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  /// Démarre l'animation des 3 points "en train d'écrire".
  void _startTypingAnimation() async {
    _typingDot1.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) _typingDot2.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) _typingDot3.repeat(reverse: true);
  }

  /// Arrête l'animation des 3 points.
  void _stopTypingAnimation() {
    _typingDot1.stop();
    _typingDot2.stop();
    _typingDot3.stop();
    _typingDot1.reset();
    _typingDot2.reset();
    _typingDot3.reset();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingDot1.dispose();
    _typingDot2.dispose();
    _typingDot3.dispose();
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
            // Avatar avec initiale
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                widget.contactName.isNotEmpty
                    ? widget.contactName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                // Statut : "en train d'écrire" ou "en ligne"
                Text(
                  _isContactTyping ? "en train d'écrire..." : "en ligne",
                  style: TextStyle(
                    fontSize: 11,
                    color: _isContactTyping
                        ? AppColors.primary
                        : AppColors.online,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: AppColors.textPrimary),
            onPressed: () => _showComingSoon("Appel audio"),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.textPrimary),
            onPressed: () => _showComingSoon("Appel vidéo"),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Zone des messages ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              // +1 pour l'indicateur "en train d'écrire" si actif
              itemCount: _messages.length + (_isContactTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // L'indicateur "en train d'écrire" est affiché en premier (index 0)
                // car la liste est inversée (reverse: true)
                if (_isContactTyping && index == 0) {
                  return _buildTypingIndicator();
                }

                // Décale l'index si l'indicateur est affiché
                final messageIndex = _isContactTyping ? index - 1 : index;
                final message = _messages[_messages.length - 1 - messageIndex];
                return _buildAnimatedBubble(message, index);
              },
            ),
          ),

          // ── Zone de saisie ─────────────────────────────────────
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── Bulle de message avec animation ──────────────────────────

  /// Construit une bulle de message avec animation d'apparition.
  /// Animation : scale 0.8 → 1.0 + fade-in en 250ms (easeOut)
  Widget _buildAnimatedBubble(_MockMessage message, int index) {
    return TweenAnimationBuilder<double>(
      // Chaque bulle a sa propre animation déclenchée à la construction
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value), // Scale de 0.8 → 1.0
            alignment: message.isMe
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: child,
          ),
        );
      },
      child: _buildMessageBubble(message),
    );
  }

  /// Construit la bulle de message (contenu).
  Widget _buildMessageBubble(_MockMessage message) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? AppColors.messageSent : AppColors.messageReceived,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Image si message image
            if (message.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
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

            // Texte du message
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),

            const SizedBox(height: 3),

            // Heure + coches de statut
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.done_all, size: 13, color: Colors.white60),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Indicateur "en train d'écrire" ───────────────────────────

  /// Construit l'indicateur 3 points animés (design Kamélia).
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.messageReceived,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(_typingDot1),
            const SizedBox(width: 4),
            _buildTypingDot(_typingDot2),
            const SizedBox(width: 4),
            _buildTypingDot(_typingDot3),
          ],
        ),
      ),
    );
  }

  /// Construit un point animé pour l'indicateur de frappe.
  Widget _buildTypingDot(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offset = Tween<double>(begin: 0, end: -6).evaluate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        );
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  // ── Barre de saisie ───────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton emoji
          IconButton(
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),

          // Champ de saisie
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Message...",
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          // Bouton pièce jointe
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColors.textSecondary),
            onPressed: _showImageSourceDialog,
          ),

          // Bouton envoi avec animation scale au tap
          GestureDetector(
            onTap: _sendTextMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_MockMessage(text: text, isMe: true, time: _currentTime()));
    });

    _messageController.clear();

    // Scroll vers le bas après envoi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simule l'indicateur "en train d'écrire" du contact (démo)
    _simulateTyping();
  }

  /// Simule l'indicateur "en train d'écrire" pour la démo.
  /// Sera remplacé par les événements Socket.io de Michaël.
  void _simulateTyping() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() => _isContactTyping = true);
    _startTypingAnimation();

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    _stopTypingAnimation();
    setState(() {
      _isContactTyping = false;
      // Ajoute une réponse simulée
      _messages.add(
        _MockMessage(
          text: "Super message ! 👍",
          isMe: false,
          time: _currentTime(),
        ),
      );
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Envoyer une image",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text(
                  "Prendre une photo",
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  "Utiliser la caméra",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text(
                  "Choisir depuis la galerie",
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  "Sélectionner une photo existante",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile == null) return;

      setState(() {
        _messages.add(
          _MockMessage(
            text: '',
            isMe: true,
            time: _currentTime(),
            imagePath: pickedFile.path,
          ),
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible")));
  }
}

// ── Modèle de message mocké ───────────────────────────────────
class _MockMessage {
  final String text;
  final bool isMe;
  final String time;
  final String? imagePath;

  _MockMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.imagePath,
  });
}
