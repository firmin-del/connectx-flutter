import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussions"),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: 8, // Temporaire, on mettra des vraies données après
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text("Contact ${index + 1}"),
            subtitle: const Text("Dernier message..."),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("14:32", style: TextStyle(fontSize: 12)),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.green,
                  child: Text("2", style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ),
        onTap: () {
  context.go('/chat/${index + 1}');
},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Nouveau chat / Groupe bientôt disponible")),
          );
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}