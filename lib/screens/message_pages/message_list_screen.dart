import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sahakaru/config/app_config.dart';
import 'package:sahakaru/providers/message_provider.dart';
import 'package:sahakaru/screens/member_pages/member_detail_screen.dart';
import 'package:sahakaru/screens/message_pages/message_screen.dart';
import 'package:sahakaru/utils/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:sahakaru/utils/session_manager.dart';
import 'package:sahakaru/providers/interest_provider.dart';


class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  List<Map<String, dynamic>> _interests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

Future<void> _fetch() async {
  print('mzgusers');
  setState(() => _loading = true);

  try {
    final provider = Provider.of<MessageProvider>(context, listen: false);
    final list = await provider.fetchMessageUsers();

    setState(() {
      _interests = list;
    });

  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(color: Colors.white), // ✅ white title text
        ),
        backgroundColor: const Color.fromARGB(255, 12, 8, 86),
        centerTitle: true,
         iconTheme: const IconThemeData(color: Colors.white),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetch),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _interests.isEmpty
              ? const Center(child: Text("No Found Interests yet."))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    itemCount: _interests.length,
                    itemBuilder: (context, index) {
                      final interest = _interests[index];
                      final profile = interest['user'] ?? interest['profile'] ?? {};
                      final name =
                          "${profile['user_id'] ?? ''} ${profile['lastname'] ?? ''}";
                      final image = profile['image'] ?? '';
                      final status = interest['status']?.toString() ?? '0';
                      final isAccepted = status == '1';
                      final isPending = status == '0';

                      return Dismissible(
                        key: Key(interest['user_id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.hide_source, color: Colors.white),
                        ),
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
                              .hideInterest(context, (int.parse(interest['id'].toString())));
                        });
                        return true; // immediately dismiss
                      }

                      return false; // don't dismiss
                    },
                    
                        // confirmDismiss: (direction) async {
                        //   await _hideInterest(int.parse(interest['id'].toString()));
                        //   // return false; // Prevent auto-dismiss, handled manually
                        // },
                        //  onDismissed: (_) => _hideInterest(int.parse(interest['id'].toString())),
                        child: Card(
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
                            subtitle: Text(
                              "Status: ${isAccepted ? 'Accepted' : isPending ? 'Pending' : 'Rejected'}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
          
                                if (isAccepted)
                             
                                  IconButton(
                                    icon: const Icon(Icons.message, color: Colors.blue),
                                    tooltip: "Message",
                                    onPressed: () async {
                                      final myUserId = await SessionManager.getUserId();
                                      final myAvatar =
                                          await SessionManager.getUserAvatar();
                                              final userId = await SessionManager.getUserId();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MessagesPage(
                                            //chek interesting_id == user id or another number
                                            //if != user id interesting_id = user id
                                               //if == user id interesting_id = interesting_id
                                           senderId: 
                                        interest['interesting_id'].toString() != userId.toString()
                                            ? int.parse(interest['interesting_id'].toString())
                                            : int.parse(interest['user_id'].toString()),
                                            receiverId: int.parse(myUserId ?? '0'),
                                            senderName: name,
                                            senderAvatar:
                                                "${AppConfig.imgpath}$image",
                                            receiverAvatar: myAvatar ??
                                                'https://via.placeholder.com/150',
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

