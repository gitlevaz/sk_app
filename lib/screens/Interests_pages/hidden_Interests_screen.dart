import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sahakaru/config/app_config.dart';
import 'package:sahakaru/providers/interest_provider.dart';
import 'package:sahakaru/screens/member_pages/member_detail_screen.dart';
import 'package:sahakaru/utils/session_manager.dart';

class HiddenInterestsScreen extends StatefulWidget {
  const HiddenInterestsScreen({super.key});

  @override
  State<HiddenInterestsScreen> createState() => _HiddenInterestsScreenState();
}

class _HiddenInterestsScreenState extends State<HiddenInterestsScreen> {
  List<Map<String, dynamic>> hiddenList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHiddenInterests();
  }

  Future<void> _loadHiddenInterests() async {
    setState(() => _loading = true);

    try {
      final provider = Provider.of<InterestProvider>(context, listen: false);
      final data = await provider.fetchHiddenInterests();

      final sent = (data['sent_interests'] ?? [])
          .where((e) => e['hide']?.toString() == '1')
          .map((e) {
            e['profile'] = e['profile'] ?? {};
            return e;
          }).toList();

      final found = (data['found_interests'] ?? [])
          .where((e) => e['hide']?.toString() == '1')
          .map((e) {
            e['profile'] = e['user'] ?? {};
            return e;
          }).toList();

      setState(() {
        hiddenList = [...sent, ...found].cast<Map<String, dynamic>>();
      });

    } catch (e) {
      debugPrint('Error loading hidden interests: $e');
    } finally {
      setState(() => _loading = false);
    }
  }


  Future<bool?> _confirmUnhide() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: const Text(
          "Unhide",
          style: TextStyle(
            color: Colors.orange, 
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to unhide this user?",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 227, 167, 69),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Future<void> _unhideInterest(Map<String, dynamic> item) async {
    final interestingId = item['interesting_id']?.toString() ??
        item['user_id']?.toString() ??
        '';

    if (interestingId.isEmpty) {
      debugPrint('⚠️ interestingId is empty');
      return;
    }

    final body = {
      'hideId': item['id'],
      'hide': '0',
    };

    try {
      final response = await http.post(
        Uri.parse("https://staging.sahakaru.com/api/hide-interest"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Unhidden successfully")),
        );
        setState(() {
          hiddenList.remove(item);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to unhide user")),
        );
      }
    } catch (e) {
      debugPrint("💥 Exception during API call: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hidden Interests"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : hiddenList.isEmpty
              ? const Center(child: Text("No hidden interests yet."))
              : ListView.builder(
                  itemCount: hiddenList.length,
                  itemBuilder: (context, index) {
                    final item = hiddenList[index];
                    final profile = item['profile'] ?? {};
                    final name =
                        "${profile['firstname'] ?? ''} ${profile['lastname'] ?? ''}";
                    final image = profile['image'] ?? '';

                    return Dismissible(
                      key: ValueKey(item['id'] ?? index),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        final confirmed = await _confirmUnhide();
                        if (confirmed == true) {
                          await _unhideInterest(item);
                        }
                        return confirmed;
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.visibility, color: Colors.white, size: 28),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(
                              image.isNotEmpty
                                  ? "${AppConfig.imgpath}$image"
                                  : 'https://via.placeholder.com/150',
                            ),
                          ),
                          title: Text(
                            name.isNotEmpty ? name : "Unknown Member",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: const Text("Status: Hidden"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MemberDetailScreen(member: profile),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
