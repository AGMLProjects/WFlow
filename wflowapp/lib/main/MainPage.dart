import 'package:flutter/material.dart';
import 'package:wflowapp/main/home/HomePage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = [
    HomePage(),
    Text('Profile'),
    Text('Settings')
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 28.0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: buildFAB(),
    );
  }

  Widget? buildFAB() {
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addHouse');
        },
        tooltip: 'Add House',
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}
