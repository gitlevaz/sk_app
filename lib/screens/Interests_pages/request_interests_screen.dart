import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sahakaru/config/app_config.dart';
import 'package:sahakaru/providers/interest_provider.dart';
import 'package:sahakaru/screens/member_pages/member_detail_screen.dart';
import 'package:sahakaru/screens/message_pages/message_screen.dart';
import 'package:sahakaru/utils/session_manager.dart';

class RequestInterestsPage extends StatefulWidget {
  const RequestInterestsPage({super.key});

  @override
  State<RequestInterestsPage> createState() => _RequestInterestsPageState();
}

class _RequestInterestsPageState extends State<RequestInterestsPage> {
  List<dynamic> _interests = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _showSearch = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchSentInterests();
  }

  String formatDate(String date) {
    try {
      final DateTime dt = DateTime.parse(date);
      return "${dt.day}-${dt.month}-${dt.year}";
    } catch (e) {
      return date;
    }
  }
Future<void> _fetchSentInterests() async {
  print('_fetchSentInterests');

  try {
    final provider = Provider.of<InterestProvider>(context, listen: false);
    final list = await provider.fetchSentInterests();

    setState(() {
      _interests = list;
      _isLoading = false;
    });

  } catch (e) {
    debugPrint("Error fetching interests: $e");

    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return const Scaffold(
        body: Center(child: Text("Failed to load interests.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Request Interests",
          style: TextStyle(color: Colors.white), // ✅ white title text
        ),
        backgroundColor: const Color.fromARGB(255, 32, 7, 74),
        centerTitle: true,
         iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _interests.isEmpty
          ? const Center(child: Text("No interests sent yet."))
          : RefreshIndicator(
              onRefresh: _fetchSentInterests,
              child: ListView.builder(
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final item = _interests[index];
                  final profile = item['profile'] ?? {};
                  final status = item['status']?.toString() ?? '0';
                  final isAccepted = status == '1';
                  final isPending = status == '0';
                  final image = profile['image'] ?? '';

                  return Dismissible(
                    key: Key(item['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.orange,
                      child: const Icon(Icons.visibility_off, color: Colors.white),
                    ),
                   
                    // onDismissed: (_) => _hideInterest(int.parse(item['id'].toString())),
                    confirmDismiss: (_) async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: Colors.orange[50],
                          title: const Text(
                            "Hide Interest",
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                          content: const Text("Do you want to hide this interest?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Confirm"),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        // ✅ Instantly remove item from UI
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<InterestProvider>(context, listen: false)
                              .hideInterest(context, int.parse(item['id'].toString()));
                        });
                        return true; // immediately dismiss
                      }

                      return false; // don't dismiss
                    },

                    child: Card(
                      color: isAccepted ? Colors.green.shade50 : Colors.grey.shade50,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isAccepted ? Colors.green : Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(
                            (image.toString().isNotEmpty)
                                ? "${AppConfig.imgpath}$image"
                                : 'https://via.placeholder.com/150',
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${profile['firstname'] ?? ''} ${profile['lastname'] ?? ''}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isAccepted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Accepted",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (profile['birth_date'] != null)
                              Text("Birth Date: ${formatDate(profile['birth_date'])}"),
                            Text("Status: ${isAccepted ? 'Accepted' : isPending ? 'Pending' : 'Unknown'}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          if (isPending)
                            // IconButton(
                            //   icon: const Icon(Icons.cancel, color: Colors.red),
                            //   tooltip: "Cancel Request",
                            //   onPressed: () async {
                            //     await _cancelInterest(int.parse(item['id'].toString()));
                            //   },
                            // ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    tooltip: "Cancel Request",
                                    onPressed: () async {
                                      final success = await Provider.of<InterestProvider>(context, listen: false)
                                          .cancelInterest(context, int.parse(item['id'].toString()));
                                      if (success) _fetchSentInterests();
                                    },
                                  ),
                              
                            if (isAccepted)
                              IconButton(
                                icon: const Icon(Icons.message, color: Colors.blue),
                                tooltip: "Message",
                                onPressed: () async {
                                  final myUserId = await SessionManager.getUserId();
                                  final myAvatar = await SessionManager.getUserAvatar();
                                  final senderId = int.parse(item['interesting_id'].toString());
                                  final senderName =
                                      "${profile['firstname'] ?? ''} ${profile['lastname'] ?? ''}";
                                  final senderAvatar =
                                      (profile['image'] != null && profile['image'].toString().isNotEmpty)
                                          ? "${AppConfig.imgpath}${profile['image']}"
                                          : 'https://via.placeholder.com/150';

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MessagesPage(
                                        senderId: senderId,
                                        receiverId: int.parse(myUserId ?? '0'),
                                        senderName: senderName,
                                        senderAvatar: senderAvatar,
                                        receiverAvatar:
                                            myAvatar ?? 'https://via.placeholder.com/150',
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberDetailScreen(member: profile),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
