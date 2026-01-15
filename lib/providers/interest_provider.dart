import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/session_manager.dart';

class InterestProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ✅ Hide Interest
  Future<bool> hideInterest(BuildContext context, int hideId) async {
    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     backgroundColor: Colors.orange[50],
    //     title: const Text(
    //       "Hide Interest",
    //       style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
    //     ),
    //     content: const Text("Do you want to hide this interest? It will not appear again."),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, false),
    //         child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
    //       ),
    //       ElevatedButton(
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Colors.deepOrange,
    //           foregroundColor: Colors.white,
    //         ),
    //         onPressed: () => Navigator.pop(context, true),
    //         child: const Text("Confirm"),
    //       ),
    //     ],
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    //   ),
    // );

    // if (confirm != true) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppConfig.hideInterest),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'hideId': hideId, 'hide': 1}),
      );

      final res = jsonDecode(response.body);
      if (res['status'] == '200' || res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Hidden successfully')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to hide interest')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error hiding interest: $e')),
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// FOUND INTERT PAGE
Future<List<Map<String, dynamic>>> fetchFoundInterests() async {
  final userId = await SessionManager.getUserId();

  try {
  final response = await http.get(
    Uri.parse("${AppConfig.fetchFoundInterest}?userId=$userId"),
  );

    print("Found Interests API Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['found_interests'] ?? []);
    } else {
      throw Exception("Failed to load interests");
    }
  } catch (e) {
    print("Error fetching found interests: $e");
    throw Exception("Error fetching interests: $e");
  }
}


  // ✅ Accept Interest. 
  Future<bool> acceptInterest(BuildContext context, int interestingId) async {
    final userId = await SessionManager.getUserId();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: const Text(
          "Accept Interest",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to accept this interest?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );

    if (confirm != true) return false;

    try {
      final response = await http.post(
        Uri.parse(AppConfig.acceptInterest),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'userId': interestingId, 'interesting_id': userId}),
      );

      final res = jsonDecode(response.body);
      if (res['status'] == '200' || res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Accepted successfully!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to accept.')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting interest: $e')),
      );
      return false;
    }
  }


  // ✅ Reject Interest
  Future<bool> rejectInterest(BuildContext context, int interestingId) async {
    print('rejectInterest');
    final userId = await SessionManager.getUserId();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: const Text(
          "Reject Interest",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to reject this interest?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );

    if (confirm != true) return false;

    try {
      final response = await http.post(
        Uri.parse(AppConfig.rejectInterest),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'userId': interestingId, 'interesting_id': userId}),
      );

      final res = jsonDecode(response.body);
       print(interestingId);
           print(userId);

      if (res['status'] == '200' || res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Rejected successfully!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to reject.')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting interest: $e')),
      );
      return false;
    }
  }

  // END FOUND INTERT PAGE

//requst Intrest page
Future<List<Map<String, dynamic>>> fetchSentInterests() async {
  final userId = await SessionManager.getUserId();

  try {
    final response = await http.get(
      Uri.parse("${AppConfig.sentInterests}?userId=$userId"),
    );

    print("sent-interests API Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["sent_interests"] ?? []);
    } else {
      throw Exception("Failed to load sent interests");
    }

  } catch (e) {
    throw Exception("Error fetching sent interests: $e");
  }
}


    Future<bool> cancelInterest(BuildContext context, int tableId) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.red[50],
          title: const Text(
            "Cancel Interest",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to cancel this interest request?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm"),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );

      if (confirm != true) return false;

      try {
        final response = await http.post(
            Uri.parse(AppConfig.cancelInterest),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'cancel_id': tableId}),
        );

        final data = jsonDecode(response.body);

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(data['message'] ?? 'Interest cancelled')),
        // );

        if (data['status'] == '200' || data['status'] == 'success') {
          // ✅ Remove item from the list immediately
          // setState(() {
          //   _interests.removeWhere(
          //       (i) => int.parse(i['id'].toString()) == tableId);
          // });
                 ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'cancelled successfully!')),
        );
          return true;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error cancelling interest')),
        );
      }
        return false;
    }

//end request intrest page


//hidden 
Future<Map<String, dynamic>> fetchHiddenInterests() async {
  final userId = await SessionManager.getUserId();

  try {
    final response = await http.post(
      Uri.parse("${AppConfig.hiddenUsers}"),
      body: {'userId': userId},
    );

    print("Hidden Interests API Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load hidden interests");
    }
  } catch (e) {
    throw Exception("Error fetching hidden interests: $e");
  }
}



}

