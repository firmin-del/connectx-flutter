// create_group_screen.dart
// Écran de création d'un groupe de conversation.
//
// Flux :
//   1. L'utilisateur sélectionne plusieurs contacts (minimum 2)
//   2. Il donne un nom au groupe
//   3. On appelle POST /api/chats avec is_group: true
//   4. On navigue vers le chat du groupe créé

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../models/contact_model.dart';
import '../../services/contact_service.dart';
import '../../repositories/chat_repository.dart';
import '../../theme/app_colors.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  // Liste de tous les contacts disponibles
  List<ContactModel> _contacts = [];

  // Contacts sélectionnés pour le groupe
  final Set<String> _selectedIds = {};

  // Contrôleur pour le nom du groupe
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isCreating = false;
  String _searchQuery = '';

  // Étape : 1 = sélection contacts, 2 = nom du groupe
  int _step = 1;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    await ContactService.requestContactsPermission();
    final contacts = await ContactService.getNovaXContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    }
  }

  /// Crée le groupe via l'API Laravel.
  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Donnez un nom au groupe"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sélectionnez au moins 2 contacts"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final chatRepository = context.read<ChatRepository>();

      // Crée le groupe via POST /api/chats
      final chat = await chatRepository.createChat(
        participantIds: _selectedIds.toList(),
        name: groupName,
      );

      if (mounted) {
        setState(() => _isCreating = false);
        // Navigue vers le chat du groupe
        context.go('/chat/${chat.id}?name=${Uri.encodeComponent(groupName)}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isCreating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    "Création du groupe...",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : _step == 1
          ? _buildStep1()
          : _buildStep2(),
    );
  }

  // ── AppBar dynamique selon l'étape ────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () {
          if (_step == 2) {
            setState(() => _step = 1);
          } else {
            context.go('/contacts');
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nouveau groupe",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_step == 1)
            Text(
              "${_selectedIds.length} sélectionné(s)",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
        ],
      ),
      actions: [
        if (_step == 1 && _selectedIds.length >= 2)
          // Bouton Suivant — actif si au moins 2 contacts sélectionnés
          TextButton(
            onPressed: () => setState(() => _step = 2),
            child: const Text(
              "Suivant",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_step == 2)
          // Bouton Créer
          TextButton(
            onPressed: _createGroup,
            child: const Text(
              "Créer",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // ── Étape 1 : Sélection des contacts ─────────────────────────

  Widget _buildStep1() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Contacts filtrés par la recherche
    final filtered = _searchQuery.isEmpty
        ? _contacts
        : _contacts
              .where((c) => c.name.toLowerCase().contains(_searchQuery))
              .toList();

    return Column(
      children: [
        // Chips des contacts sélectionnés
        if (_selectedIds.isNotEmpty)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _selectedIds.map((id) {
                  final contact = _contacts.firstWhere(
                    (c) => c.id == id,
                    orElse: () => ContactModel(id: id, name: id),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.15,
                      ),
                      label: Text(
                        contact.name.split(' ').first,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      avatar: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 10,
                        child: Text(
                          contact.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      // Bouton X pour désélectionner
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      onDeleted: () => setState(() => _selectedIds.remove(id)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // Barre de recherche
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

        // Liste des contacts avec cases à cocher
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun contact trouvé",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.divider,
                    indent: 72,
                  ),
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    final isSelected = _selectedIds.contains(contact.id);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.15),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
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
                      // Coche à droite
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : const Icon(
                              Icons.radio_button_unchecked,
                              color: AppColors.textSecondary,
                            ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(contact.id);
                          } else {
                            _selectedIds.add(contact.id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Étape 2 : Nom du groupe ───────────────────────────────────

  Widget _buildStep2() {
    // Contacts sélectionnés pour l'aperçu
    final selectedContacts = _contacts
        .where((c) => _selectedIds.contains(c.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône du groupe
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.group,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Champ nom du groupe
          const Text(
            "Nom du groupe",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _groupNameController,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
            decoration: InputDecoration(
              hintText: "Ex: Équipe NovaX 🚀",
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () => _groupNameController.clear(),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Membres du groupe
          Text(
            "MEMBRES (${selectedContacts.length + 1})",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Toi (admin)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 22),
            ),
            title: const Text(
              "Toi",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              "Admin",
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),

          // Autres membres
          ...selectedContacts.map(
            (contact) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  contact.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              title: Text(
                contact.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
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
            ),
          ),

          const SizedBox(height: 32),

          // Bouton Créer le groupe
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _createGroup,
              icon: const Icon(Icons.group_add),
              label: const Text(
                "Créer le groupe",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
