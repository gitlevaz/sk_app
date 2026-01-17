import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sahakaru/config/app_config.dart';
import 'package:sahakaru/utils/session_manager.dart';

class MemberProvider with ChangeNotifier {
  
  Future<List<dynamic>> fetchMembersPage({
    required int page,
    String? gender,
    String? city,
    RangeValues? ageRange,
  }) async {
    try {
      final userId = await SessionManager.getUserId();
      final queryParams = {
         'userId': userId,
        'page': page.toString(),
       if (gender != null && gender.isNotEmpty)
  'looking_for': (gender == 'm') ? '2' : (gender == 'f') ? '1' : '',

        if (city != null && city.isNotEmpty) 'city': city,
        if (ageRange != null)
          'height': '${ageRange.start.toInt()} - ${ageRange.end.toInt()}',
      };

      final uri = Uri.https('sahakaru.com', '/api/members', queryParams);

       print(queryParams);
      print("API URL: $uri"); // Debugging

      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Your API may wrap members inside data or members keys
        if (decoded is List) return decoded;
        if (decoded['members'] != null && decoded['members']['data'] != null) {
          return decoded['members']['data'];
        }
        if (decoded['data'] != null) return decoded['data'];
        return [];
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchMembersPage: $e");
      return [];
    }
  }

  Future<List<dynamic>> fetchMembers(int page) async {
    final userId = await SessionManager.getUserId();
    final response = await http.get(
      Uri.parse("${AppConfig.fetchMembers}?page=$page?userId=$userId"),
    );
     print(page);
         print('page');
       print(userId);
    print('userId');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    }
    return [];
  }

Future<Map<String, dynamic>> fetchDashboard(int userId, String token) async {
  try {
    final response = await http.post(
      Uri.parse("${AppConfig.dashboard}"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'userId': userId.toString(),
      },
    );

    print("Dashboard API Response: ${response.body}");

    return jsonDecode(response.body);

  } catch (e) {
    throw Exception("Error fetching dashboard: $e");
  }
}


  // Future<Map<String, dynamic>?> fetchContactInfo(String memberId) async {
  //   final response = await http.get(
  //     // Uri.parse("${AppConfig.contact}"),
  //     Uri.parse("$baseUrl/member/$memberId/contact")
  //     );
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     return data['data'];
  //   }
  //   return null;
  // }

//_checkInterestStatus
  Future<Map<String, dynamic>> checkInterestStatus(int memberId) async {
  final userId = await SessionManager.getUserId();

  try {
    final response = await http.post(
      Uri.parse("${AppConfig.checkInterestStatus}"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'interesting_id': memberId,
        'userId': userId,
      }),
    );

    print("check-interest API response: ${response.body}");

    return jsonDecode(response.body);
  } catch (e) {
    throw Exception("Error checking interest status: $e");
  }
}

//fetchContactInfo
Future<Map<String, dynamic>> fetchContactInfo(int memberId) async {
  final userId = await SessionManager.getUserId();

  try {
    final response = await http.post(
      Uri.parse("${AppConfig.viewContact}"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contact_id': memberId,
        'userId': userId,
      }),
    );

    print("viewContact API Response: ${response.body}");

    return jsonDecode(response.body);

  } catch (e) {
    throw Exception("Error fetching contact info: $e");
  }
}

Future<Map<String, dynamic>> fetchContactInfo2(int memberId) async {
  final userId = await SessionManager.getUserId();

  try {
    final response = await http.post(
      Uri.parse("${AppConfig.viewContact2}"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contact_id': memberId,
        'userId': userId,
      }),
    );

    print("viewContact2 API Response: ${response.body}");

    return jsonDecode(response.body);

  } catch (e) {
    throw Exception("Error fetching contact info 2: $e");
  }
}


Future<Map<String, dynamic>> checkInterestLimit() async {
  final userId = await SessionManager.getUserId();

  try {
    final response = await http.get(
      Uri.parse("${AppConfig.interestLimit}?userId=$userId"),
      headers: {'Accept': 'application/json'},
    );

    print("interest-limit API Response: ${response.body}");

    return jsonDecode(response.body);

  } catch (e) {
    throw Exception("Error checking interest limit: $e");
  }
}


Future<Map<String, dynamic>> expressInterest(int memberId) async {
  final userId = await SessionManager.getUserId();

  try {
    final response = await http.post(
      Uri.parse("${AppConfig.expressInterest}"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'interesting_id': memberId,
        'userId': userId,
      }),
    );

    print("express-interest API Response: ${response.body}");

    return jsonDecode(response.body);

  } catch (e) {
    throw Exception("Error expressing interest: $e");
  }
}

  
}
