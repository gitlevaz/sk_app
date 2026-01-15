import 'package:flutter/material.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> purchases;

  const PurchaseHistoryScreen({super.key, required this.purchases});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase History"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: purchases.isEmpty
          ? const Center(
              child: Text(
                "No purchase history available.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final package = purchases[index];

                final packageName = package['name'] ?? '';
                final interestLimit = package['interest_express_limit'] ?? '';
                final contactLimit = package['contact_view_limit'] ?? '';
                final imageLimit = package['image_upload_limit'] ?? '';
                final validity = package['validity_period'] ?? '';
                final price = package['price'] ?? '';
                final createdAt = package['created_at'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: Text("Interest Limit: $interestLimit")),
                            Expanded(child: Text("Contact Limit: $contactLimit")),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: Text("Image Limit: $imageLimit")),
                            Expanded(child: Text("Validity: $validity days")),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Price: $price"),
                        const SizedBox(height: 2),
                        Text("Purchased On: $createdAt"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
