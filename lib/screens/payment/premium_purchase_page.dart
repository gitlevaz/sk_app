// import 'package:flutter/material.dart';
// import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';

// class PremiumPurchasePage extends StatefulWidget {
//   @override
//   State<PremiumPurchasePage> createState() => _PremiumPurchasePageState();
// }

// class _PremiumPurchasePageState extends State<PremiumPurchasePage> {
//   void startPayment() async {
//     var payment = {
//       "sandbox": true,
//       "merchant_id": "1232877",
//       "merchant_secret": "",
//       "notify_url": "https://yourdomain.com/payhere-notify",
//       "order_id": "ORDER_${DateTime.now().millisecondsSinceEpoch}",
//       "items": "Premium",
//       "amount": "500.00",
//       "currency": "LKR",
//       "first_name": "Customer",
//       "last_name": "User",
//       "email": "customer@example.com",
//       "phone": "0771234567",
//       "address": "Sri Lanka",
//       "city": "Colombo",
//       "country": "Sri Lanka",
//     };

//     PayHere.startPayment(
//       payment,
//       (paymentId) {
//         print("Payment Success: $paymentId");
//       },
//       (error) {
//         print("Payment Failed: $error");
//       },
//       () {
//         print("Payment Dismissed by User");
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Buy Premium")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: startPayment,
//           child: Text("Pay Rs. 500 for Premium"),
//         ),
//       ),
//     );
//   }
// }
