import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ConnectX"),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 120, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "Bienvenue sur ConnectX",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Tes conversations apparaîtront ici",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Pour plus tard : ouvrir nouvel chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Nouveau message bientôt disponible")),
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
