// chat_list_screen.dart
// Écran principal : liste de toutes les conversations de l'utilisateur.
//
// Branché sur ChatCubit (Étape 03) pour afficher les vraies données.
// Affiche des données mockées si le serveur n'est pas disponible.
//
// Fonctionnalités :
//   - Liste des conversations triées par date (plus récente en haut)
//   - Badge de messages non lus (cercle vert avec le nombre)
//   - Aperçu du dernier message
//   - Navigation vers ChatScreen au tap
//   - Bouton profil dans l'AppBar
//   - FAB pour créer une nouvelle conversation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../cubits/login/chat_cubit.dart';
import '../../cubits/login/auth_cubit.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Charge les conversations au démarrage de l'écran
    // Le ChatCubit gère le chargement depuis l'API ou les données mockées
    context.read<ChatCubit>().loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ─────────────────────────────────────────────────
      appBar: AppBar(
        title: Text(
          'NovaX',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          // Bouton recherche
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche de conversations
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Recherche — bientôt disponible")),
              );
            },
          ),
          // Menu contextuel
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profile') context.go('/profile');
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Mon profil'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Corps : liste des conversations ────────────────────────
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          // Récupère l'ID de l'utilisateur connecté pour afficher les noms
          final currentUserId = context.read<AuthCubit>().state.user?.id ?? '';

          // ── État de chargement ─────────────────────────────────
          if (state.status == ChatLoadStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Liste vide ─────────────────────────────────────────
          if (state.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Aucune conversation",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Appuie sur + pour démarrer une discussion",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ── Bannière mode démo (si serveur non disponible) ─────
          return Column(
            children: [
              // Affiche une bannière si on est en mode démo
              if (state.errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.orange.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.errorMessage,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Liste des conversations ────────────────────────
              Expanded(
                child: ListView.separated(
                  itemCount: state.chats.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final chat = state.chats[index];
                    final displayName = chat.participants.isNotEmpty
                        ? chat.getDisplayName(currentUserId)
                        : 'Contact ${index + 1}';

                    // Animation slide-in décalée pour chaque item
                    // Chaque item apparaît avec un délai de 50ms * index
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            // Slide depuis la droite
                            offset: Offset(30 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),

                        // ── Avatar ─────────────────────────────────
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            // Initiale du nom
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),

                        // ── Nom du contact ─────────────────────────
                        title: Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),

                        // ── Aperçu du dernier message ──────────────
                        subtitle: Text(
                          chat.lastMessagePreview,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),

                        // ── Heure + Badge non-lu ───────────────────
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Heure du dernier message
                            Text(
                              _formatTime(chat.lastActivity),
                              style: TextStyle(
                                fontSize: 11,
                                color: chat.unreadCount > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Badge messages non lus
                            if (chat.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  chat.unreadCount > 99
                                      ? '99+'
                                      : '${chat.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),

                        // ── Navigation vers le chat ────────────────
                        onTap: () {
                          context.read<ChatCubit>().markChatAsRead(chat.id);
                          context.go(
                            '/chat/${chat.id}?name=${Uri.encodeComponent(displayName)}',
                          );
                        },
                      ),
                    ); // Ferme TweenAnimationBuilder
                  },
                ),
              ),
            ],
          );
        },
      ),

      // ── Bouton Nouveau Chat ────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigue vers l'écran de sélection de contacts NovaX
          context.go('/contacts');
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  /// Formate la date/heure du dernier message pour l'affichage.
  /// - Aujourd'hui → "14:32"
  /// - Cette semaine → "Lun."
  /// - Plus ancien → "12/05"
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDay == today) {
      // Aujourd'hui : affiche l'heure
      return DateFormat('HH:mm').format(dateTime);
    } else if (now.difference(dateTime).inDays < 7) {
      // Cette semaine : affiche le jour abrégé
      return DateFormat('E', 'fr_FR').format(dateTime);
    } else {
      // Plus ancien : affiche la date
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}
