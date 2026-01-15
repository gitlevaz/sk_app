import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cards = [
      {"title": "Remaining Contacts", "icon": Icons.phone_android},
      {"title": "Remaning Interests ", "icon": Icons.favorite},
      {"title": "Interests Sent", "icon": Icons.person_add},
      {"title": "Interests Found", "icon": Icons.person_add},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(card["icon"], size: 40, color: Colors.blue),
                const SizedBox(height: 10),
                Text(card["title"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }
}
