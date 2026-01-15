import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/session_manager.dart';

class MessageProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _lastMessageId = 0; // track latest message
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  // Callback for new messages
  Function(Map<String, dynamic> message)? onNewMessage;

  Future<void> fetchMessages({
    required int senderId,
    required int receiverId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.fetchmessages}"),
        headers: {"Accept": "application/json"},
        body: {
          "sender_id": senderId.toString(),
          "receiver_id": receiverId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['messages'] is List) {
          final List<dynamic> newList = decoded['messages'];

          // Detect new message
          if (newList.isNotEmpty) {
            int latestId = newList.first['id']; // assuming first = latest
            if (_lastMessageId != 0 && latestId > _lastMessageId) {
              // Trigger callback for new message
              onNewMessage?.call(newList.first);
            }
            _lastMessageId = latestId;
          }

          _messages = List<Map<String, dynamic>>.from(newList);
        } else {
          _messages = [];
        }
      } else {
        debugPrint("❌ Fetch failed: ${response.body}");
        _messages = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching messages: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required int receiverId,
    required String message,
  }) async {
    final userIdStr = await SessionManager.getUserId();
    if (userIdStr == null) return;
    final userId = int.tryParse(userIdStr);
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.sendInterest}"),
        headers: {"Accept": "application/json"},
        body: {
          "sender_id": userId.toString(),
          "receiver_id": receiverId.toString(),
          "message": message.trim(),
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Message sent successfully");
        await fetchMessages(senderId: userId, receiverId: receiverId);
      } else {
        debugPrint("❌ Send failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠️ Error sending message: $e");
    }
  }

  void addLocalMessage(Map<String, dynamic> message) {
    _messages.add(message); // because reverse:true
    notifyListeners();
  }

    // ---------------------------------------------------------------------------
  // FETCH MESSAGE USERS
  // ---------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchMessageUsers() async {
    final userId = await SessionManager.getUserId();

    try {
      final response = await http.get(
        Uri.parse("${AppConfig.fetchMessageUsers}?userId=$userId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['mzgusers_interests'] ?? []);
      } else {
        throw Exception("Failed to load message users");
      }
    } catch (e) {
      throw Exception("Error fetching message users: $e");
    }
  }
  
}
