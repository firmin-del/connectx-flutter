// chat_list_screen.dart
// Écran principal — liste des conversations avec recherche et rafraîchissement.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../cubits/login/chat_cubit.dart';
import '../../cubits/login/auth_cubit.dart';
import '../../theme/app_colors.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Contrôle l'affichage de la barre de recherche
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadChats();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          final currentUserId = context.read<AuthCubit>().state.user?.id ?? '';

          if (state.status == ChatLoadStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Filtre les chats selon la recherche
          final chats = _searchQuery.isEmpty
              ? state.chats
              : state.chats.where((chat) {
                  final name = chat.participants.isNotEmpty
                      ? chat.getDisplayName(currentUserId).toLowerCase()
                      : '';
                  final preview = chat.lastMessagePreview.toLowerCase();
                  return name.contains(_searchQuery) ||
                      preview.contains(_searchQuery);
                }).toList();

          if (chats.isEmpty && state.chats.isEmpty) {
            return _buildEmptyState();
          }

          if (chats.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun résultat pour "$_searchQuery"',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Bannière mode démo
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
                      Expanded(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      // Bouton rafraîchir
                      TextButton(
                        onPressed: () => context.read<ChatCubit>().loadChats(),
                        child: const Text(
                          "Réessayer",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Liste des conversations
              Expanded(
                child: RefreshIndicator(
                  // Pull-to-refresh pour recharger les conversations
                  color: AppColors.primary,
                  onRefresh: () => context.read<ChatCubit>().loadChats(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: chats.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: AppColors.divider,
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final displayName = chat.participants.isNotEmpty
                          ? chat.getDisplayName(currentUserId)
                          : chat.name ?? 'Conversation ${index + 1}';

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 250 + (index * 40)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: child,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                child: Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              // Indicateur en ligne (vert)
                              if (_isParticipantOnline(chat, currentUserId))
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.online,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.background,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              if (chat.isGroup)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.group,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  chat.lastMessagePreview,
                                  style: TextStyle(
                                    color: chat.unreadCount > 0
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: chat.unreadCount > 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(chat.lastActivity),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: chat.unreadCount > 0
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (chat.unreadCount > 0)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
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
                          onTap: () {
                            context.read<ChatCubit>().markChatAsRead(chat.id);
                            context.go(
                              '/chat/${chat.id}?name=${Uri.encodeComponent(displayName)}',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.go('/contacts'),
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  // ── AppBar avec recherche ─────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: "Rechercher une conversation...",
            hintStyle: TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      title: const Text(
        'NovaX',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
      actions: [
        // Bouton recherche
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () => setState(() => _isSearching = true),
        ),
        // Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          color: AppColors.surface,
          onSelected: (value) {
            if (value == 'profile') context.go('/profile');
            if (value == 'refresh') context.read<ChatCubit>().loadChats();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Mon profil',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Actualiser',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── État vide ─────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucune conversation",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Appuie sur + pour démarrer une discussion",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/contacts'),
            icon: const Icon(Icons.add),
            label: const Text("Nouvelle conversation"),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  /// Vérifie si l'autre participant du chat est en ligne.
  bool _isParticipantOnline(chat, String currentUserId) {
    if (chat.participants.isEmpty) return false;
    final other = chat.participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => chat.participants.first,
    );
    return other.isOnline;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDay == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('E', 'fr_FR').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}
