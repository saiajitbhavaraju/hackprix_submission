import 'package:flutter/material.dart';
import 'package:ecosnap_1/common/colors.dart';
import 'package:ecosnap_1/screens/camera_screen.dart';
import 'package:ecosnap_1/screens/chat_screen.dart';
import 'package:ecosnap_1/screens/discovery_screen.dart';
import 'package:ecosnap_1/screens/map_screen.dart';
import 'package:ecosnap_1/screens/stories_screen.dart';

class HomePageScreen extends StatefulWidget {
  // Add a parameter to control the starting page.
  final int initialPageIndex;
  const HomePageScreen({Key? key, this.initialPageIndex = 2}) : super(key: key); // Default to Camera

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _pageIndex;

  // List of pages to be displayed in the body
  final List<Widget> _pages = [
    MapScreen(),
    ChatScreen(),
    CameraScreen(),
    StoriesScreen(),
    DiscoverScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set the initial page index from the widget's properties.
    _pageIndex = widget.initialPageIndex;
  }

  /// Changes the selected page index and rebuilds the widget.
  void _onTabTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Builds the custom bottom navigation bar for the application.
  Widget _buildBottomNavigationBar() {
    // Defines the properties for each navigation item.
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.map_outlined, 'text': 'Map', 'color': green},
      {'icon': Icons.chat_bubble_outline, 'text': 'Chat', 'color': blue},
      {'icon': Icons.camera_alt_outlined, 'text': 'Camera', 'color': primary},
      {'icon': Icons.people_outline, 'text': 'Stories', 'color': purple},
      {'icon': Icons.menu, 'text': 'Discover', 'color': primary},
    ];

    return Container(
      width: double.infinity,
      height: 90, // Standard height for bottom nav bar with labels
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(width: 1, color: Colors.white12), // Subtle top border
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final bool isSelected = _pageIndex == index;

            return _buildNavItem(
              icon: item['icon'],
              text: item['text'],
              color: item['color'],
              isSelected: isSelected,
              onTap: () => _onTabTapped(index),
            );
          }),
        ),
      ),
    );
  }

  /// Builds a single item for the navigation bar.
  Widget _buildNavItem({
    required IconData icon,
    required String text,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final itemColor = isSelected ? color : Colors.white.withOpacity(0.5);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        // Removes splash effect for a cleaner look
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: itemColor),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: itemColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
