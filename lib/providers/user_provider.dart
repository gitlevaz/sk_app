import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sahakaru/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
 bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

 Future<bool> login(String username, String password) async {
    print('mobilelogin');
  setLoading(true);
//  username= 'dsithmallevanjith@gmail.com';
// password= '123456';
  try {
    final response = await http.post(
      Uri.parse("${AppConfig.login}"),
      headers: {'Accept': 'application/json'},
      body: {'username': username, 'password': password},
    );
    print("username Response: $username");
        print("password Response: $password");

    final data = json.decode(response.body);
    print("Login Response: $data");

    if (response.statusCode == 200 &&
        data['token'] != null &&
        data['user'] != null) {
      final token = data['token'].toString();
      final userId = data['user']['id'].toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', token);
      await prefs.setString('user_id', userId);
      await prefs.setString('user', jsonEncode(data['user']));

      print("✅ User ID saved: $userId");

      setLoading(false);
      return true;
    } else {
      print("❌ Login failed: ${data['message']}");
      setLoading(false);
      return false;
    }
  } catch (e) {
    print("Login error: $e");
    setLoading(false);
    return false;
  }
}


  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? password,
    File? profileImage,
    required BuildContext context,
  }) async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token') ?? '';
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      var request = http.MultipartRequest(
          'POST', 
               Uri.parse("${AppConfig.updateProfile}"),
          );
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['userId'] = userId.toString();
      request.fields['name'] = name.trim();
      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', profileImage.path),
        );
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final respData = jsonDecode(respStr);

      if (response.statusCode == 200 && respData['status'] == 'success') {
        prefs.setString('user_name', name.trim());
        if (respData['profile_image'] != null) {
          prefs.setString('profile_image', respData['profile_image']);
        }
        _loading = false;
        notifyListeners();
        return {'success': true, 'message': 'Profile updated successfully'};
      } else {
        _loading = false;
        notifyListeners();
        return {'success': false, 'message': respData['message'] ?? 'Update failed'};
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }
  
}
