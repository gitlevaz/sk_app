// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sahakaru/providers/message_provider.dart';
// import 'package:sahakaru/utils/session_manager.dart';

// class MessagesPage extends StatefulWidget {
//   final int senderId;
//   final int receiverId;
//   final String senderName;
//   final String senderAvatar;
//   final String receiverAvatar;

//   const MessagesPage({
//     required this.senderId,
//     required this.receiverId,
//     required this.senderName,
//     required this.senderAvatar,
//     required this.receiverAvatar,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<MessagesPage> createState() => _MessagesPageState();
// }

// class _MessagesPageState extends State<MessagesPage> {
//   final TextEditingController _controller = TextEditingController();

//   Future<void> _loadMessages(BuildContext context) async {
//     final userIdString = await SessionManager.getUserId();
//     if (userIdString == null) return;

//     final userId = int.tryParse(userIdString);
//     if (userId == null) return;

//     await context.read<MessageProvider>().fetchMessages(
//           senderId: userId,
//           receiverId: widget.receiverId,
//         );
//   }

//   String _limitWords(String text, int maxWords) {
//     final words = text.split(' ');
//     if (words.length <= maxWords) return text;
//     return '${words.take(maxWords).join(' ')}...';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => MessageProvider(),
//       child: Builder(
//         builder: (context) {
//           // ✅ Call after provider is ready
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _loadMessages(context);
//           });

//           final provider = context.watch<MessageProvider>();
//           final messages = provider.messages;

//           return Scaffold(
//             appBar: AppBar(
//               title: Row(
//                 children: [
//                   CircleAvatar(backgroundImage: NetworkImage(widget.senderAvatar)),
//                   const SizedBox(width: 10),
//                   Flexible(
//                     child: Text(
//                       _limitWords(widget.senderName, 20),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: () => _loadMessages(context),
//                 ),
//               ],
//             ),
//             body: Column(
//               children: [
//                 Expanded(
//                   child: provider.isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : RefreshIndicator(
//                           onRefresh: () => _loadMessages(context),
//                           child: ListView.builder(
//                             reverse: true,
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             itemCount: messages.length,
//                             itemBuilder: (context, index) {
//                               final msg = messages[index];

//                               // ✅ Get logged user ID for correct alignment
//                               final currentUserId = int.tryParse(
//                                    '1');
//                               final isMe =
//                                   msg['sender_id'].toString() == currentUserId.toString();

//                               return Align(
//                                 alignment:
//                                     isMe ? Alignment.centerRight : Alignment.centerLeft,
//                                 child: Container(
//                                   margin: const EdgeInsets.symmetric(
//                                       vertical: 4, horizontal: 8),
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color:
//                                         isMe ? Colors.blue[100] : Colors.grey[300],
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: const Radius.circular(12),
//                                       topRight: const Radius.circular(12),
//                                       bottomLeft: isMe
//                                           ? const Radius.circular(12)
//                                           : const Radius.circular(0),
//                                       bottomRight: isMe
//                                           ? const Radius.circular(0)
//                                           : const Radius.circular(12),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       if (!isMe)
//                                         CircleAvatar(
//                                             radius: 16,
//                                             backgroundImage:
//                                                 NetworkImage(widget.senderAvatar)),
//                                       const SizedBox(width: 8),
//                                       Flexible(
//                                         child: Text(
//                                           msg['message'] ?? '',
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                       ),
//                                       if (isMe)
//                                         CircleAvatar(
//                                             radius: 16,
//                                             backgroundImage:
//                                                 NetworkImage(widget.receiverAvatar)),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                 ),
//                 const Divider(height: 1),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText: "Type a message...",
//                             filled: true,
//                             fillColor: Colors.grey[100],
//                             contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 12, horizontal: 16),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       CircleAvatar(
//                         radius: 24,
//                         backgroundColor: Colors.blue,
//                         child: IconButton(
//                           icon: const Icon(Icons.send, color: Colors.white),
//                           onPressed: () async {
//                             await context.read<MessageProvider>().sendMessage(
//                                   receiverId: widget.receiverId,
//                                   message: _controller.text,
//                                 );
//                             _controller.clear();
//                           },
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
