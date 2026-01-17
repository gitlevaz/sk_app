import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sahakaru/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

Future<void> _showPurchaseMessageAndRedirect() async {
  Fluttertoast.showToast(
    msg: "You have to go our website for purchase package",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
  );

  // Wait so user can read the message
  await Future.delayed(const Duration(seconds: 2));

  final Uri url =
      Uri.parse("${AppConfig.packages}");

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}


  Widget planCard({
    required String title,
    required String price,
    required Gradient gradient,
    required List<String> features,
    required VoidCallback onBuy,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: const TextStyle(
              color: Colors.purple,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: features
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check, color: Colors.purple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: const Text(
              "Buy Now",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientGeneral =
        const LinearGradient(colors: [Color(0xFFc678ff), Color(0xFF99c7ff)]);
    final gradientPaid =
        const LinearGradient(colors: [Color(0xFFd67bff), Color(0xFF89b6ff)]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Package"),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// GENERAL PLAN
            planCard(
              title: "General",
              price: "0.00 LKR",
              gradient: gradientGeneral,
              features: [
                "Duration (365 Days)",
                "Interest Express (20)",
                "Image Upload Unlimited",
              ],
              onBuy: () {
                Fluttertoast.showToast(msg: "Free Plan Activated");
              },
            ),

            /// PAID PLAN
            planCard(
              title: "Paid",
              price: "500.00 LKR",
              gradient: gradientPaid,
              features: [
                "Duration Unlimited",
                "Interest Express (20)",
                "Image Upload Unlimited",
              ],
              onBuy: _showPurchaseMessageAndRedirect,
            ),
          ],
        ),
      ),
    );
  }
}
