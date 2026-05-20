// contacts_screen.dart
// Sélection d'un contact → crée la conversation via l'API puis navigue.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../models/contact_model.dart';
import '../../services/contact_service.dart';
import '../../repositories/chat_repository.dart';
import '../../theme/app_colors.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<ContactModel> _contacts = [];
  List<ContactModel> _filtered = [];
  bool _isLoading = true;
  bool _isCreatingChat = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _contacts
          : _contacts
                .where((c) => c.name.toLowerCase().contains(query))
                .toList();
    });
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final hasPermission = await ContactService.requestContactsPermission();
    if (!hasPermission) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Permission refusée.\nActivez-la dans les paramètres.";
      });
      return;
    }

    final contacts = await ContactService.getNovaXContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
        _filtered = contacts;
        _isLoading = false;
      });
    }
  }

  /// Crée ou récupère la conversation avec ce contact via l'API,
  /// puis navigue vers l'écran de chat.
  Future<void> _openChat(ContactModel contact) async {
    setState(() => _isCreatingChat = true);

    try {
      final chatRepository = context.read<ChatRepository>();

      // Crée la conversation via POST /api/chats
      // Si elle existe déjà, Laravel retourne la conversation existante
      final chat = await chatRepository.createChat(
        participantIds: [contact.id],
      );

      if (mounted) {
        setState(() => _isCreatingChat = false);
        // Navigue vers le chat avec le vrai ID de conversation
        context.go(
          '/chat/${chat.id}?name=${Uri.encodeComponent(contact.name)}',
        );
      }
    } catch (_) {
      // Fallback : navigue directement avec l'ID du contact
      if (mounted) {
        setState(() => _isCreatingChat = false);
        context.go(
          '/chat/${contact.id}?name=${Uri.encodeComponent(contact.name)}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Nouveau message",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isCreatingChat
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    "Ouverture de la conversation...",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.contacts_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContacts,
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── Barre de recherche ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "Rechercher un contact...",
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // ── Liste des contacts ─────────────────────────────────
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun contact trouvé",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.divider,
                    indent: 72,
                  ),
                  itemBuilder: (context, index) {
                    final contact = _filtered[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              contact.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (contact.isOnline)
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
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        contact.isOnline ? "En ligne" : "Hors ligne",
                        style: TextStyle(
                          color: contact.isOnline
                              ? AppColors.online
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => _openChat(contact),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
