// chat_screen.dart
// Écran de conversation — design Kamélia v1.0
//
// Intégrations :
//   - Ulrich (IA) : analyse de sentiment + emoji sur bulles + pipeline Big Data
//   - Michaël (RSI) : Socket.io temps réel (actif si serveur connecté)
//
// Mode automatique :
//   - Socket connecté → messages temps réel via MessageCubit
//   - Socket non connecté → mode démo avec simulation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../theme/app_colors.dart';
import '../../services/sentiment_service.dart';
import '../../services/analytics_service.dart';
import '../../services/socket_service.dart';
import '../../cubits/login/auth_cubit.dart';
import '../../repositories/chat_repository.dart';

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
  final ScrollController _scrollController = ScrollController();

  // Contrôleurs pour l'indicateur "en train d'écrire" (3 points Kamélia)
  late AnimationController _typingDot1;
  late AnimationController _typingDot2;
  late AnimationController _typingDot3;

  bool _isContactTyping = false;
  bool _isAnalyzing = false; // true pendant l'analyse de sentiment

  // Messages affichés — chargés depuis l'API + mis à jour via Socket.io
  final List<_ChatMessage> _messages = [];
  bool _isLoadingMessages = true;

  @override
  void initState() {
    super.initState();
    _setupTypingAnimation();
    _setupSocketCallbacks();
    _loadMessagesFromApi();
  }

  void _setupTypingAnimation() {
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

  // ── Chargement des messages depuis l'API ─────────────────────

  /// Charge l'historique des messages depuis Laravel.
  /// Fallback sur des messages de démo si l'API n'est pas disponible.
  Future<void> _loadMessagesFromApi() async {
    try {
      final chatRepository = context.read<ChatRepository>();
      final apiMessages = await chatRepository.fetchMessagesFromApi(
        widget.chatId,
      );
      final currentUserId = context.read<AuthCubit>().state.user?.id ?? '';

      if (mounted) {
        final chatMessages = apiMessages.map((msg) {
          return _ChatMessage(
            id: msg.id,
            text: msg.content,
            isMe: msg.senderId == currentUserId,
            time: _formatTime(msg.timestamp),
            sentiment: SentimentScore.neutral,
          );
        }).toList();

        setState(() {
          _messages.addAll(chatMessages);
          _isLoadingMessages = false;
        });
      }
    } catch (_) {
      // Fallback : messages de démo si API indisponible
      if (mounted) {
        setState(() {
          _messages.addAll([
            _ChatMessage(
              text: "Salut ! Comment ça va ?",
              isMe: false,
              time: "14:30",
              sentiment: SentimentScore.positive,
            ),
            _ChatMessage(
              text: "Très bien merci, et toi ?",
              isMe: true,
              time: "14:31",
              sentiment: SentimentScore.positive,
            ),
            _ChatMessage(
              text: "Super ! Tu as vu le projet NovaX ?",
              isMe: false,
              time: "14:32",
              sentiment: SentimentScore.positive,
            ),
            _ChatMessage(
              text: "Oui, on avance bien 🚀",
              isMe: true,
              time: "14:33",
              sentiment: SentimentScore.positive,
            ),
          ]);
          _isLoadingMessages = false;
        });
      }
    }
  }

  /// Configure les callbacks Socket.io pour recevoir les messages en temps réel.
  /// Si le socket n'est pas connecté → mode démo automatique.
  void _setupSocketCallbacks() {
    // Rejoint la room de ce chat
    SocketService.joinChat(widget.chatId);

    // Callback : nouveau message reçu via Socket.io
    SocketService.onNewMessage = (message) {
      if (message.chatId == widget.chatId && mounted) {
        // Analyse le sentiment du message reçu
        SentimentService.analyze(message.content).then((sentiment) {
          if (mounted) {
            setState(() {
              _messages.add(
                _ChatMessage(
                  text: message.content,
                  isMe: false,
                  time: _formatTime(message.timestamp),
                  sentiment: sentiment,
                ),
              );
              _isContactTyping = false;
            });
            _stopTypingAnimation();
            _scrollToBottom();
          }
        });
      }
    };

    // Callback : contact en train d'écrire
    SocketService.onTyping = (chatId) {
      if (chatId == widget.chatId && mounted) {
        setState(() => _isContactTyping = true);
        _startTypingAnimation();
      }
    };

    // Callback : contact a arrêté d'écrire
    SocketService.onStopTyping = (chatId) {
      if (chatId == widget.chatId && mounted) {
        setState(() => _isContactTyping = false);
        _stopTypingAnimation();
      }
    };

    // Callback : message lu (coches bleues)
    SocketService.onMessageRead = (chatId, messageId) {
      if (chatId == widget.chatId && mounted) {
        // Met à jour les coches du message concerné
        setState(() {
          for (int i = 0; i < _messages.length; i++) {
            if (_messages[i].id == messageId) {
              _messages[i] = _messages[i].copyWith(isRead: true);
            }
          }
        });
      }
    };
  }

  void _startTypingAnimation() async {
    _typingDot1.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) _typingDot2.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) _typingDot3.repeat(reverse: true);
  }

  void _stopTypingAnimation() {
    _typingDot1.stop();
    _typingDot1.reset();
    _typingDot2.stop();
    _typingDot2.reset();
    _typingDot3.stop();
    _typingDot3.reset();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingDot1.dispose();
    _typingDot2.dispose();
    _typingDot3.dispose();
    // Quitte la room Socket.io quand on ferme le chat
    SocketService.leaveChat(widget.chatId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
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
    );
  }

  // ── Liste des messages ────────────────────────────────────────

  Widget _buildMessageList() {
    // Affiche un loader pendant le chargement initial depuis l'API
    if (_isLoadingMessages) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          "Aucun message — commencez la conversation !",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length + (_isContactTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isContactTyping && index == 0) {
          return _buildTypingIndicator();
        }
        final msgIndex = _isContactTyping ? index - 1 : index;
        final message = _messages[_messages.length - 1 - msgIndex];
        return _buildAnimatedBubble(message);
      },
    );
  }

  // ── Bulle animée ──────────────────────────────────────────────

  Widget _buildAnimatedBubble(_ChatMessage message) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(
          scale: 0.8 + (0.2 * value),
          alignment: message.isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: child,
        ),
      ),
      child: _buildBubble(message),
    );
  }

  Widget _buildBubble(_ChatMessage message) {
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
            // Image
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

            // Texte
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

            // Heure + coches + emoji sentiment (Ulrich)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.sentiment != null) ...[
                  Text(
                    SentimentService.getEmoji(message.sentiment!),
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(width: 3),
                ],
                Text(
                  message.time,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 3),
                  Icon(
                    Icons.done_all,
                    size: 13,
                    // Coches bleues si lu, blanches sinon (Michaël)
                    color: message.isRead
                        ? Colors.lightBlueAccent
                        : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Indicateur "en train d'écrire" ───────────────────────────

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
            decoration: const BoxDecoration(
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
          IconButton(
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (text) {
                // Notifie Socket.io que l'utilisateur est en train d'écrire
                if (text.isNotEmpty) {
                  SocketService.emitTyping(widget.chatId);
                } else {
                  SocketService.emitStopTyping(widget.chatId);
                }
              },
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
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColors.textSecondary),
            onPressed: _showImageSourceDialog,
          ),
          // Bouton envoi — spinner pendant analyse sentiment
          GestureDetector(
            onTap: _isAnalyzing ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isAnalyzing
                    ? AppColors.textSecondary
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _isAnalyzing
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ── Envoi de message ──────────────────────────────────────────

  /// Envoie un message avec :
  ///   1. Analyse de sentiment (Ulrich)
  ///   2. Envoi via Socket.io si connecté (Michaël)
  ///   3. Simulation si Socket.io non connecté (mode démo)
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAnalyzing = true);
    _messageController.clear();
    SocketService.emitStopTyping(widget.chatId);

    // Étape 1 : Analyse de sentiment (Ulrich)
    final sentiment = await SentimentService.analyze(text);

    // Étape 2 : Pipeline Big Data (Ulrich)
    AnalyticsService.trackMessage(
      messageLength: text.length,
      sentiment: sentiment,
      chatId: widget.chatId,
      timestamp: DateTime.now(),
    );

    final currentUserId = context.read<AuthCubit>().state.user?.id ?? 'me';

    final newMessage = _ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      time: _currentTime(),
      sentiment: sentiment,
    );

    setState(() {
      _isAnalyzing = false;
      _messages.add(newMessage);
    });

    _scrollToBottom();

    // Étape 3 : Envoi via Socket.io (Michaël) si connecté
    if (SocketService.isConnected) {
      SocketService.sendMessage(_buildSocketMessage(newMessage, currentUserId));
    } else {
      _simulateReply();
    }

    // Étape 4 : Sauvegarde via l'API Laravel (persistance serveur)
    // Non bloquant — en arrière-plan
    _saveMessageToApi(text, currentUserId);
  }

  /// Sauvegarde le message dans la base de données Laravel.
  Future<void> _saveMessageToApi(String text, String senderId) async {
    try {
      final chatRepository = context.read<ChatRepository>();
      await chatRepository.sendMessageToApi(
        chatId: widget.chatId,
        content: text,
        type: 'text',
      );
    } catch (_) {
      // Silencieux — Socket.io a déjà transmis le message
    }
  }

  /// Crée un MessageModel pour Socket.io à partir d'un _ChatMessage.
  dynamic _buildSocketMessage(_ChatMessage msg, String senderId) {
    // Import inline pour éviter la dépendance circulaire
    return {
      'id': msg.id,
      'chat_id': widget.chatId,
      'sender_id': senderId,
      'content': msg.text,
      'type': 'text',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Simule une réponse du contact (mode démo sans Socket.io).
  void _simulateReply() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() => _isContactTyping = true);
    _startTypingAnimation();

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    _stopTypingAnimation();
    const replyText = "Super message ! 👍";
    final replySentiment = await SentimentService.analyze(replyText);

    setState(() {
      _isContactTyping = false;
      _messages.add(
        _ChatMessage(
          text: replyText,
          isMe: false,
          time: _currentTime(),
          sentiment: replySentiment,
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
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (file == null) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: '',
            isMe: true,
            time: _currentTime(),
            imagePath: file.path,
            sentiment: SentimentScore.neutral,
          ),
        );
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : $e"),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showComingSoon(String f) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("$f — bientôt disponible")));
}

// ── Modèle de message ─────────────────────────────────────────

class _ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final String? imagePath;
  final SentimentScore? sentiment; // Ulrich
  final bool isRead; // Michaël (coches bleues)

  _ChatMessage({
    String? id,
    required this.text,
    required this.isMe,
    required this.time,
    this.imagePath,
    this.sentiment,
    this.isRead = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  _ChatMessage copyWith({bool? isRead}) {
    return _ChatMessage(
      id: id,
      text: text,
      isMe: isMe,
      time: time,
      imagePath: imagePath,
      sentiment: sentiment,
      isRead: isRead ?? this.isRead,
    );
  }
}
