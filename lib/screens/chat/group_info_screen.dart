// group_info_screen.dart
// Écran de gestion d'un groupe — modifier nom, membres, quitter/supprimer.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../models/chat_model.dart';
import '../../models/contact_model.dart';
import '../../services/chat_service.dart';
import '../../services/contact_service.dart';
import '../../cubits/login/auth_cubit.dart';
import '../../cubits/login/chat_cubit.dart';
import '../../theme/app_colors.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatModel chat;

  const GroupInfoScreen({super.key, required this.chat});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late TextEditingController _nameController;
  bool _isEditingName = false;
  bool _isLoading = false;
  List<ContactModel> _availableContacts = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chat.name ?? '');
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final contacts = await ContactService.getNovaXContacts();
    if (mounted) setState(() => _availableContacts = contacts);
  }

  String get _currentUserId => context.read<AuthCubit>().state.user?.id ?? '';

  bool get _isGroupCreator =>
      widget.chat.participantIds.isNotEmpty &&
      widget.chat.lastMessageSenderId == _currentUserId;

  // ── Modifier le nom du groupe ─────────────────────────────────

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ChatService.updateGroup(chatId: widget.chat.id, name: name);
      if (mounted) {
        setState(() {
          _isEditingName = false;
          _isLoading = false;
        });
        context.read<ChatCubit>().refreshChats();
        _snack("Nom du groupe mis à jour ✓");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _snack("Erreur : $e");
      }
    }
  }

  // ── Ajouter un membre ─────────────────────────────────────────

  void _showAddMemberDialog() {
    // Contacts qui ne sont pas encore dans le groupe
    final memberIds = widget.chat.participantIds.toSet();
    final available = _availableContacts
        .where((c) => !memberIds.contains(c.id))
        .toList();

    if (available.isEmpty) {
      _snack("Tous vos contacts sont déjà dans ce groupe");
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Ajouter un membre",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...available.map(
            (contact) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  contact.name[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              title: Text(
                contact.name,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _addMember(contact);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _addMember(ContactModel contact) async {
    setState(() => _isLoading = true);
    try {
      await ChatService.addParticipant(
        chatId: widget.chat.id,
        userId: contact.id,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        context.read<ChatCubit>().refreshChats();
        _snack("${contact.name} ajouté au groupe ✓");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _snack("Erreur : $e");
      }
    }
  }

  // ── Retirer un membre ─────────────────────────────────────────

  Future<void> _removeMember(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Retirer du groupe",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          "Retirer $userName du groupe ?",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Annuler",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Retirer",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ChatService.removeParticipant(
        chatId: widget.chat.id,
        userId: userId,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        context.read<ChatCubit>().refreshChats();
        _snack("$userName retiré du groupe");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _snack("Erreur : $e");
      }
    }
  }

  // ── Quitter / Supprimer le groupe ─────────────────────────────

  Future<void> _leaveOrDeleteGroup() async {
    final isCreator = _isGroupCreator;
    final action = isCreator ? "Supprimer le groupe" : "Quitter le groupe";
    final desc = isCreator
        ? "Le groupe sera supprimé pour tous les membres."
        : "Vous quitterez ce groupe.";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(action, style: TextStyle(color: Colors.red.shade700)),
        content: Text(
          desc,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Annuler",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ChatService.leaveOrDeleteChat(widget.chat.id);
      if (mounted) {
        context.read<ChatCubit>().refreshChats();
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _snack("Erreur : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.chat.participants;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Infos du groupe",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              children: [
                // ── Header groupe ──────────────────────────────
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        child: const Icon(
                          Icons.group,
                          size: 45,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nom du groupe (éditable)
                      _isEditingName
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      autofocus: true,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: _saveName,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () =>
                                        setState(() => _isEditingName = false),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.chat.name ?? 'Groupe',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () =>
                                      setState(() => _isEditingName = true),
                                ),
                              ],
                            ),

                      Text(
                        "${participants.length} membre(s)",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Membres ────────────────────────────────────
                Container(
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          "MEMBRES (${participants.length})",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      // Bouton ajouter un membre
                      ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: AppColors.primary,
                          ),
                        ),
                        title: const Text(
                          "Ajouter un membre",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: _showAddMemberDialog,
                      ),

                      const Divider(
                        height: 1,
                        color: AppColors.divider,
                        indent: 16,
                      ),

                      // Liste des membres
                      ...participants.map((participant) {
                        final isMe = participant.id == _currentUserId;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              participant.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            isMe
                                ? "${participant.name} (Toi)"
                                : participant.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            participant.isOnline ? "En ligne" : "Hors ligne",
                            style: TextStyle(
                              color: participant.isOnline
                                  ? AppColors.online
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          // Bouton retirer (seulement pour les autres membres)
                          trailing: !isMe
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeMember(
                                    participant.id,
                                    participant.name,
                                  ),
                                )
                              : null,
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Actions ────────────────────────────────────
                Container(
                  color: AppColors.surface,
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.exit_to_app,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      "Quitter le groupe",
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: _leaveOrDeleteGroup,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
