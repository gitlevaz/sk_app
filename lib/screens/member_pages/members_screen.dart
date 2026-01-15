import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:provider/provider.dart';
import 'package:sahakaru/config/app_config.dart';
import 'package:sahakaru/screens/member_pages/member_detail_screen.dart';
import 'package:sahakaru/screens/layout/navigation_handler.dart';
import 'package:sahakaru/screens/profile_pages/profile_screen.dart';
import 'package:sahakaru/providers/member_provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final List<dynamic> _members = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _showSearch = false;
  int _selectedIndex = 3; // Default to "Home"

  final EasyRefreshController _controller = EasyRefreshController();
  final ScrollController _scrollController = ScrollController();

  // Filters
  String? _selectedGender;
  String? _selectedCity;
  RangeValues _ageRange = const RangeValues(18, 65);

  @override
  void initState() {
    super.initState();
    _loadMembers(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMoreOlderMembers();
      }
    });
  }

  Future<void> _loadMembers({bool reset = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (reset) {
      _currentPage = 1;
      _members.clear();
      _hasMore = true;
    }

    try {
      final provider = Provider.of<MemberProvider>(context, listen: false);
      final newMembers = await provider.fetchMembersPage(
        page: _currentPage,
        gender: _selectedGender,
        city: _selectedCity,
        ageRange: _ageRange,
      );

      setState(() {
        _members.addAll(newMembers);
        if (newMembers.isEmpty) _hasMore = false;
      });
    } catch (e) {
      print("Error loading members: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _loadMoreOlderMembers() async {
    if (_isLoading) return;
    _isLoading = true;  

    try {
      final provider = Provider.of<MemberProvider>(context, listen: false);
      final newMembers = await provider.fetchMembersPage(
        page: _currentPage + 1,
        gender: _selectedGender,
        city: _selectedCity,
        ageRange: _ageRange,
      );

      if (newMembers.isEmpty) {
        _hasMore = false;
      } else {
        setState(() {
          _currentPage++;
          _members.addAll(newMembers);
        });
      }
    } catch (e) {
      print("Error loading older members: $e");
    } finally {
      _isLoading = false;
    }
  }

  void _onSearchPressed() {
    FocusScope.of(context).unfocus();
    _loadMembers(reset: true);
  }

  /// ✅ Unified Navigation: Uses NavigationHandler
  void _onBottomNavTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationHandler(initialIndex: index),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 21, 81),
        title: const Text('Members'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
              });
            },
          ),
        ],
      ),

      body: Column(
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showSearch
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedGender,
                          onChanged: (v) => setState(() => _selectedGender = v),
                          items: const [
                            DropdownMenuItem(value: '', child: Text('Any')),
                            DropdownMenuItem(value: 'm', child: Text('Male')),
                            DropdownMenuItem(value: 'f', child: Text('Female')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => _selectedCity = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Age Range: ${_ageRange.start.toInt()} - ${_ageRange.end.toInt()}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      RangeSlider(
                        values: _ageRange,
                        min: 18,
                        max: 65,
                        divisions: 47,
                        labels: RangeLabels(
                          _ageRange.start.toInt().toString(),
                          _ageRange.end.toInt().toString(),
                        ),
                        onChanged: (v) => setState(() => _ageRange = v),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _onSearchPressed,
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: const Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 230, 109, 149),
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
          const Divider(height: 1),

          Expanded(
            child: EasyRefresh(
              controller: _controller,
              header: const ClassicHeader(),
              footer: const ClassicFooter(),
              onRefresh: () async => _loadMembers(reset: true),
              onLoad: _hasMore ? () async => _loadMoreOlderMembers() : null,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  final basic = member['basic_info'] ?? {};

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          (member['image'] != null &&
                                  member['image'].toString().isNotEmpty)
                                ? "${AppConfig.imgpath}${member['image']}"
                              : 'https://via.placeholder.com/150',
                        ),
                        radius: 25,
                      ),
                      title: Text(member['firstname'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Profile ID: ${member['profile_id'] ?? 'N/A'} | Religion: ${basic['religion'] ?? 'N/A'}",
                          ),
                          Text(
                            "Gender: ${basic['gender'] == 'm' ? 'Male' : basic['gender'] == 'f' ? 'Female' : 'N/A'} | Profession: ${basic['profession'] ?? 'N/A'}",
                          ),
                          Text(
                            "City: ${basic['present_address']?['city'] ?? 'N/A'} | Birth date: ${basic['birth_date'] ?? 'N/A'}",
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberDetailScreen(member: member),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),


    );
  }
}
