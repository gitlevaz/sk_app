import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakaru/providers/message_provider.dart';
import 'package:sahakaru/utils/session_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MessagesPage extends StatefulWidget {
  final int senderId; // chat partner id
  final int receiverId; // logged-in user id
  final String senderName;
  final String senderAvatar;
  final String receiverAvatar;

  const MessagesPage({
    Key? key,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.senderAvatar,
    required this.receiverAvatar,
  }) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  int? _myUserId;

  @override
  void initState() {
    super.initState();

    // Get my user id
    SessionManager.getUserId().then((idStr) {
      if (idStr != null) _myUserId = int.tryParse(idStr);
    });

    final provider = Provider.of<MessageProvider>(context, listen: false);

    // Setup callback for new messages
    provider.onNewMessage = (msg) {
      // Only trigger notification if the sender is NOT me
      if (_myUserId != null && msg['sender_id'] != _myUserId) {
        _showLocalNotification(msg['message'] ?? "", widget.senderName ?? "New message");
      }
    };

    // Poll messages every 2 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      provider.fetchMessages(
        senderId: widget.senderId,
        receiverId: widget.receiverId,
      );
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final messageText = _controller.text.trim();
    _controller.clear();

    final int targetReceiverId =
        widget.senderId == _myUserId ? widget.receiverId : widget.senderId;

    final provider = Provider.of<MessageProvider>(context, listen: false);

    // Add locally
    provider.addLocalMessage({
      'sender_id': _myUserId,
      'receiver_id': targetReceiverId,
      'message': messageText,
      'sender_name': 'Me', // optional for UI
    });

    await provider.sendMessage(receiverId: targetReceiverId, message: messageText);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showLocalNotification(String message, String senderName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'New message notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      senderName, // show sender's name
      message,
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessageProvider>(context);
    final messages = provider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.senderAvatar)),
            const SizedBox(width: 10),
            Flexible(child: Text(widget.senderName)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchMessages(
              senderId: widget.senderId,
              receiverId: widget.receiverId,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender_id'].toString() ==
                    widget.receiverId.toString();

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(widget.senderAvatar),
                        ),
                      if (!isMe) const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe
                                  ? const Radius.circular(12)
                                  : const Radius.circular(0),
                              bottomRight: isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(12),
                            ),
                          ),
                          child: Text(msg['message'] ?? "",
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      if (isMe) const SizedBox(width: 8),
                      if (isMe)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(widget.receiverAvatar),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
