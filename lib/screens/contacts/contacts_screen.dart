// contacts_screen.dart
// Écran de sélection de contacts pour démarrer une nouvelle conversation.
//
// Accessible depuis le bouton "+" de ChatListScreen.
// Affiche les contacts qui ont un compte NovaX.
//
// Fonctionnalités :
//   - Demande la permission d'accès aux contacts
//   - Affiche la liste des contacts NovaX
//   - Indicateur de statut en ligne (point vert)
//   - Tap sur un contact → crée/ouvre la conversation

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/contact_model.dart';
import '../../services/contact_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // Liste des contacts chargés
  List<ContactModel> _contacts = [];

  // État de chargement
  bool _isLoading = true;

  // Message d'erreur si permission refusée
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Charge les contacts au démarrage
    _loadContacts();
  }

  /// Demande la permission puis charge les contacts NovaX.
  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Demande la permission d'accès aux contacts
    final hasPermission = await ContactService.requestContactsPermission();

    if (!hasPermission) {
      // Permission refusée → affiche un message explicatif
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Permission d'accès aux contacts refusée.\n"
            "Activez-la dans les paramètres pour voir vos contacts NovaX.";
      });
      return;
    }

    // Charge les contacts depuis l'API (ou les mockés si API indisponible)
    final contacts = await ContactService.getNovaXContacts();

    if (mounted) {
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau message"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── Chargement ─────────────────────────────────────────────
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ── Erreur de permission ────────────────────────────────────
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContacts, // Réessayer
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    // ── Liste vide ──────────────────────────────────────────────
    if (_contacts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Aucun contact NovaX trouvé",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Invitez vos contacts à rejoindre NovaX !",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // ── Liste des contacts ──────────────────────────────────────
    return ListView.separated(
      itemCount: _contacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final contact = _contacts[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),

          // ── Avatar avec indicateur en ligne ──────────────────
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  contact.name[0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              // Point vert si en ligne
              if (contact.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      // Bordure blanche pour séparer du fond
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Nom du contact ────────────────────────────────────
          title: Text(
            contact.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          // ── Statut ────────────────────────────────────────────
          subtitle: Text(
            contact.isOnline ? "En ligne" : "Hors ligne",
            style: TextStyle(
              color: contact.isOnline ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),

          // ── Tap → ouvre/crée la conversation ─────────────────
          onTap: () {
            // Navigue vers le chat avec ce contact
            // L'ID du contact devient l'ID du chat (conversation privée)
            context.go(
              '/chat/${contact.id}?name=${Uri.encodeComponent(contact.name)}',
            );
          },
        );
      },
    );
  }
}
