// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:sahakaru/utils/session_manager.dart';

// class MessagesPage extends StatefulWidget {
//   final int senderId;
//   final int receiverId; // your logged-in user id
//   final String senderName; // name of the chat partner
//   final String senderAvatar; // profile image URL of the chat partner
//   final String receiverAvatar; // your profile image URL

//   const MessagesPage({
//     required this.senderId,
//     required this.receiverId,
//     required this.senderName,
//     required this.senderAvatar,
//     required this.receiverAvatar,
//     Key? key,
//   }) : super(key: key);

//   @override
//   _MessagesPageState createState() => _MessagesPageState();
// }

// class _MessagesPageState extends State<MessagesPage> {
//   List messages = [];
//   TextEditingController _controller = TextEditingController();
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchMessages();
//   }

//   Future<void> _fetchMessages() async {
//     setState(() => _loading = true);
//     final response = await http.post(
//       Uri.parse("https://staging.sahakaru.com/api/messages"),
//       headers: {"Accept": "application/json"},
//       body: {
//         "sender_id": widget.senderId.toString(),
//         "receiver_id": widget.receiverId.toString(),
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         messages = data['messages'];
//       });
//     }
//     setState(() => _loading = false);
//   }

//   Future<void> _sendMessage() async {
//       final userId = await SessionManager.getUserId();
   

//         final senderId = 
//     widget.senderId.toString() != userId.toString()
//         ? widget.senderId.toString()
//         : widget.receiverId.toString();

//     if (_controller.text.trim().isEmpty) return;
//  print(senderId);
//       print('widget');
//         print(userId);
   

//     final response = await http.post(
//       Uri.parse("https://staging.sahakaru.com/api/send-message"),
//       headers: {"Accept": "application/json"},
//       body: {
//         "sender_id": userId, // your logged-in user
//         "receiver_id": senderId, // chat partner
//         "message": _controller.text.trim(),
//       },
//     );
    
// print('dddd');
// print(widget.senderId);
// print('dd');
// print(widget.receiverId);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print("✅ Message sent: ${data['data']}");
//       _controller.clear();
//       _fetchMessages();
//     } else {
//       print("❌ Failed: ${response.body}");
//     }
//   }

//   Widget _buildMessage(Map msg) {
//     bool isMe = msg['sender_id'] == widget.receiverId;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       child: Row(
//         mainAxisAlignment:
//             isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isMe) ...[
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: NetworkImage(widget.senderAvatar),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//               decoration: BoxDecoration(
//                 color: isMe ? Colors.blue[100] : Colors.grey[300],
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(12),
//                   topRight: const Radius.circular(12),
//                   bottomLeft: isMe
//                       ? const Radius.circular(12)
//                       : const Radius.circular(0),
//                   bottomRight: isMe
//                       ? const Radius.circular(0)
//                       : const Radius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 msg['message'] ?? "",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//           if (isMe) ...[
//             const SizedBox(width: 8),
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: NetworkImage(widget.receiverAvatar),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

// String _limitWords(String text, int maxWords) {
//   final words = text.split(' ');
//   if (words.length <= maxWords) return text;
//   return '${words.take(maxWords).join(' ')}...';
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: NetworkImage(widget.senderAvatar),
//             ),
//             const SizedBox(width: 10),
//             Flexible(
//               flex: 1,
//               child: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.5, // limit width to 50%
//                 child: Text(
//                   _limitWords(widget.senderName, 20),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   style: const TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),


//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchMessages, // 🔄 Manual refresh button
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : RefreshIndicator( // 🔄 Pull-to-refresh added here
//                     onRefresh: _fetchMessages,
//                     child: ListView.builder(
//                       reverse: true,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       itemCount: messages.length,
//                       itemBuilder: (context, index) {
//                         final msg = messages[index];
//                         final isMe = msg['sender_id'].toString() ==
//                             widget.receiverId.toString(); // your logged-in user
//                         return Align(
//                           alignment: isMe
//                               ? Alignment.centerRight
//                               : Alignment.centerLeft,
//                           child: Container(
//                             constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.7,
//                             ),
//                             margin: const EdgeInsets.symmetric(
//                                 vertical: 4, horizontal: 8),
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: isMe
//                                   ? Colors.blue[100]
//                                   : Colors.grey[300],
//                               borderRadius: BorderRadius.only(
//                                 topLeft: const Radius.circular(12),
//                                 topRight: const Radius.circular(12),
//                                 bottomLeft: isMe
//                                     ? const Radius.circular(12)
//                                     : const Radius.circular(0),
//                                 bottomRight: isMe
//                                     ? const Radius.circular(0)
//                                     : const Radius.circular(12),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 if (!isMe) ...[
//                                   CircleAvatar(
//                                     radius: 16,
//                                     backgroundImage:
//                                         NetworkImage(widget.senderAvatar),
//                                   ),
//                                   const SizedBox(width: 8),
//                                 ],
//                                 Flexible(
//                                   child: Text(
//                                     msg['message'] ?? '',
//                                     style:
//                                         const TextStyle(fontSize: 16),
//                                   ),
//                                 ),
//                                 if (isMe) ...[
//                                   const SizedBox(width: 8),
//                                   CircleAvatar(
//                                     radius: 16,
//                                     backgroundImage: NetworkImage(
//                                         widget.receiverAvatar),
//                                   ),
//                                 ]
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//           ),
//           const Divider(height: 1),
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: Colors.blue,
//                   child: IconButton(
//                     icon:
//                         const Icon(Icons.send, color: Colors.white),
//                     onPressed: _sendMessage,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
