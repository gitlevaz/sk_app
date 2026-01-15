import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sahakaru/config/app_config.dart';
import 'package:sahakaru/providers/member_provider.dart';
import 'package:sahakaru/utils/session_manager.dart';

class MemberDetailScreen extends StatefulWidget {
  final dynamic member;
  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {

  @override
void initState() {
  super.initState();
  _checkInterestStatus();
}


  Map<String, dynamic>? _contactInfo;
  bool _loadingContact = false;
  bool _loadingInterest = false;
  bool _interestExpressed = false; 


Future<void> _checkInterestStatus() async {
  print('check-interest');

  try {
    final provider = Provider.of<MemberProvider>(context, listen: false);

    final res = await provider.checkInterestStatus(widget.member['id']);

    if (res['status'] == '200' && res['result'] == 'already') {
      setState(() {
        _interestExpressed = true;
      });
    }

  } catch (e) {
    debugPrint("Interest check failed: $e");
  }
}

Future<void> _fetchContactInfo() async {
  print('viewContact');

  if (_loadingContact) return;
  setState(() => _loadingContact = true);

  try {
    final provider = Provider.of<MemberProvider>(context, listen: false);
    final res = await provider.fetchContactInfo(widget.member['id']);

    if (res['status'] == 'yes') {
      final remaining = res['remaining'] ?? 0;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Contact View"),
          content: Text("${res['message']} - $remaining"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
          ],
        ),
      );

      if (confirm == true) {
        await _fetchContactInfo2();
      }

    } else {
      setState(() => _contactInfo = {
        'member': res['member'],
        'message': res['message'],
      });
    }

  } catch (e) {
    setState(() => _contactInfo = {'error': e.toString()});
  } finally {
    setState(() => _loadingContact = false);
  }
}


Future<void> _fetchContactInfo2() async {
  print('viewContact2');
  final provider = Provider.of<MemberProvider>(context, listen: false);

  try {
    final res = await provider.fetchContactInfo2(widget.member['id']);

    if (res['status'] == 'success' || res['status'] == 'exists') {
      setState(() => _contactInfo = {
        'member': res['member'],
        'message': res['message'],
      });
    } else {
      setState(() => _contactInfo = {
        'error': res['message'] ?? 'Unknown error',
      });
    }

  } catch (e) {
    setState(() => _contactInfo = {'error': e.toString()});
  } finally {
    setState(() => _loadingContact = false);
  }
}



  Future<void> _handleInterests() async {
  print('interest-limit');

  if (_loadingInterest) return;
  setState(() => _loadingInterest = true);

  try {
    final provider = Provider.of<MemberProvider>(context, listen: false);

    // ✅ Step 1: Check remaining limit
    final res = await provider.checkInterestLimit();

    if (res['status'] == 'yes') {
      final remaining = res['remaining'] ?? 0;

      // ✅ Confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Interest"),
          content: Text("${res['message']} -  $remaining"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
          ],
        ),
      );

      if (confirm == true) {
        // ✅ Step 2: Express interest API
        final confirmData = await provider.expressInterest(widget.member['id']);

        if (confirmData['status'] == '200' && confirmData['result'] == 'success') {
          setState(() {
            _interestExpressed = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(confirmData['message'] ?? "Interest sent successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(confirmData['message'] ?? "Failed to send interest.")),
          );
        }
      }

    } else {
      // ✅ No remaining interest limit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "No remaining interests.")),
      );
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => _loadingInterest = false);
  }
}



  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final basic = member['basic_info'] ?? {};
    final city = basic['present_address']?['city'] ?? 'N/A';
    final gender = basic['gender'] == 'm'
        ? 'Male'
        : basic['gender'] == 'f'
            ? 'Female'
            : 'N/A';

    final imageUrl = (member['image'] != null && member['image'].toString().isNotEmpty)
        ? "${AppConfig.imgpath}${member['image']}"
        : 'https://via.placeholder.com/300';

    return Scaffold(
      appBar: AppBar(title: Text(member['firstname'] ?? 'Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.height * 0.25,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Basic Info
            Text(
              "${member['firstname'] ?? ''} ${member['lastname'] ?? ''}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Profile ID: ${member['profile_id'] ?? 'N/A'}"),
            Text("Gender: $gender"),
            Text("City: $city"),
            Text("Religion: ${basic['religion'] ?? 'N/A'}"),
            Text("Profession: ${basic['profession'] ?? 'N/A'}"),
            Text("Birth Date: ${basic['birth_date'] ?? 'N/A'}"),
            const SizedBox(height: 20),

            // Row with Contact Info & Interests buttons
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _loadingContact ? null : _fetchContactInfo,
                icon: const Icon(Icons.contact_phone),
                label: Text(_loadingContact ? "Loading..." : "View Contact"),
              ),
              ElevatedButton.icon(
                onPressed: (_loadingInterest || _interestExpressed) ? null : _handleInterests,
                icon:  Icon(Icons.favorite, color:_interestExpressed
                      ? Colors.pink.shade200 // background turns pink after interested
                      : Colors.red), // default backgroundColors.red),
                label: _loadingInterest
                    ? const Text("Loading...")
                    : Text(
                        _interestExpressed ? "Interested" : "Send Interests",
                        style: const TextStyle(fontSize: 14),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _interestExpressed
                      ? Colors.pink.shade200 // background turns pink after interested
                      : const Color.fromARGB(255, 244, 240, 223) , // default background
                  foregroundColor: Colors.red.shade900,
                ),
              ),
            ],
          ),


            const SizedBox(height: 20),

            // Display Contact Info
            if (_contactInfo != null) ...[
              const Divider(),
              const Text(
                "Contact Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_contactInfo!['error'] != null)
                Text(
                  "❌ ${_contactInfo!['error']}",
                  style: const TextStyle(color: Colors.red),
                ),
              if (_contactInfo!['member'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_contactInfo!['member']['phone_visibility'] == '2')
                      Text("📱 Mobile: ${_contactInfo!['member']['mobile'] ?? 'N/A'}"),
                    if (_contactInfo!['member']['phone_visibility'] == '1')
                      const Text("📱 Mobile: Hidden"),
                    Text("✉️ Email: ${_contactInfo!['member']['email'] ?? 'N/A'}"),
                    Text("ℹ️ ${_contactInfo!['message'] ?? ''}"),
                  ],
                ),
            ]
          ],
        ),
      ),
    );
  }
}
