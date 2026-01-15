import 'package:flutter/material.dart';
import 'package:sahakaru/screens/home_screen.dart';
import 'package:sahakaru/screens/member_pages/members_screen.dart';
import 'package:sahakaru/screens/Interests_pages/found_interests_screen.dart';
import 'package:sahakaru/screens/message_pages/message_list_screen.dart';
import 'package:sahakaru/screens/Interests_pages/request_interests_screen.dart';

class NavigationHandler extends StatefulWidget {
  final int initialIndex;
  const NavigationHandler({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<NavigationHandler> createState() => _NavigationHandlerState();
}

class _NavigationHandlerState extends State<NavigationHandler> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const RequestInterestsPage();
      case 1:
        return const FoundInterestsScreen();
      case 2:
        return const MessageListScreen();
      case 3:
      default:
        return MembersScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 113, 3, 38),
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Found',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
      ),
    );
  }
}
