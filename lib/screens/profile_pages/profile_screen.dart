import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sahakaru/providers/member_provider.dart';
import 'package:sahakaru/screens/member_pages/members_screen.dart';
import 'package:sahakaru/screens/Interests_pages/hidden_Interests_screen.dart';
import 'package:sahakaru/screens/purchase/purchase_screen.dart';
import 'package:sahakaru/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_screen.dart';
import '../Interests_pages/request_interests_screen.dart';
import '../Interests_pages/found_interests_screen.dart';
import 'purchase_history_screen.dart';
import 'edit_profile_screen.dart';
import 'package:sahakaru/config/app_config.dart';

final GlobalKey<_ProfileScreenState> profileKey = GlobalKey<_ProfileScreenState>();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? username;
String profileImage = ""; 
  String firstname = "User";
  // Dashboard data
  String remainingContacts = "-";
  String remainingInterests = "-";
  String interestsSent = "-";
  String interestsFound = "-";
  List<Map<String, dynamic>> purchasedPackages = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchDashboardData();
      _loadFirstname();   
  }

Future<void> _loadFirstname() async {
  final user = await SessionManager.getUserData();
  if (user != null && mounted) {
    setState(() {
      firstname = user['firstname']?.split(' ').first ?? 'User';
      profileImage = user['image'] ?? "";
    });
  }
}

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('user_name') ?? 'User';
      profileImage = prefs.getString('profile_image') ?? '';
    });
  }

Future<void> fetchDashboardData() async {
  final userId = await SessionManager.getUserId();

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token') ?? '';

    final provider = Provider.of<MemberProvider>(context, listen: false);

    // ✅ API moved to provider
    final data = await provider.fetchDashboard(int.parse(userId ?? '0'), token);

    if (data['status'] == 'success' && data['member'] != null) {
      final member = data['member'];

      setState(() {
        remainingContacts = member['contact_view_limit']?.toString() ?? '0';
        remainingInterests = member['interest_express_limit']?.toString() ?? '0';
        interestsSent = member['interests']?.toString() ?? '0';
        interestsFound = member['interest_requests']?.toString() ?? '0';
        _loading = false;

        if (member['limitation'] != null &&
            member['limitation']['package'] != null) {
          purchasedPackages = [
            Map<String, dynamic>.from(member['limitation']['package'])
          ];
        }
      });
    } else {
      setState(() => _loading = false);
    }

  } catch (e) {
    setState(() => _loading = false);
    debugPrint('Error fetching dashboard data: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Members page
          const MembersScreen(),

          // Clickable 15% overlay to close Profile
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // close panel
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.15,
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                ),
              ),
            ),
          ),

          // Profile Panel (85%)
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.85, // panel width
              child: GestureDetector(
                onTap: () {}, // prevent closing when tapping inside
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color.fromARGB(255, 241, 208, 240), Color.fromARGB(255, 239, 236, 237)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                          AppBar(
                            backgroundColor: Colors.pink,
                            elevation: 1,
                            title: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: (profileImage!.isNotEmpty)
                                      ? NetworkImage(
                                         "${AppConfig.imgpath}/$profileImage")
                                      : const NetworkImage(
                                           "${AppConfig.imgpath}/default.jpg"),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Hi, $firstname",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Expanded(
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildProfileContent(context),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBeautifulStatBox(
                icon: Icons.contact_phone,
                title: "Remaining Contacts",
                value: remainingContacts,
                startColor: Colors.blueAccent,
                endColor: Colors.lightBlueAccent,
              ),
              _buildBeautifulStatBox(
                icon: Icons.favorite_border,
                title: "Remaining Interests",
                value: remainingInterests,
                startColor: Colors.purpleAccent,
                endColor: Colors.deepPurpleAccent,
              ),
              _buildBeautifulStatBox(
                icon: Icons.send,
                title: "Interests Sent",
                value: interestsSent,
                startColor: Colors.orangeAccent,
                endColor: Colors.deepOrange,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildBeautifulStatBox(
              icon: Icons.people_outline,
              title: "Interests Found",
              value: interestsFound,
              startColor: Colors.greenAccent,
              endColor: Colors.teal,
            ),
            _buildBeautifulStatBox(
              icon: Icons.notifications_active,
              title: "Notifications",
              value: "2",
              startColor: Colors.blueAccent,
              endColor: Colors.lightBlue,
            ),
          ],
        ),
        const SizedBox(height: 25),
        const Divider(thickness: 1),
        const Text(
          "Menu",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _buildMenuItem(context, Icons.favorite_border, "Request Interests",
            const RequestInterestsPage()),
        _buildMenuItem(context, Icons.people_outline, "Found Interests",
            const FoundInterestsScreen()),
        _buildMenuItem(context, Icons.visibility_off, "Hidden Interests",
            const HiddenInterestsScreen()),
        _buildMenuItem(
          context,
          Icons.history,
          "Purchase History",
          PurchaseHistoryScreen(purchases: purchasedPackages),
        ),
                _buildMenuItem(
          context,
          Icons.history,
          "Purchase",
          PurchaseScreen(),
        ),
        _buildMenuItem(
            context, Icons.edit, "Edit Profile", const EditProfileScreen()),
        const Divider(thickness: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            "Logout",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  Widget _buildBeautifulStatBox({
    required IconData icon,
    required String title,
    required String value,
    required Color startColor,
    required Color endColor,
  }) {
    return Container(
      width: 115,
      height: 80,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: endColor.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await SessionManager.clearSession();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
