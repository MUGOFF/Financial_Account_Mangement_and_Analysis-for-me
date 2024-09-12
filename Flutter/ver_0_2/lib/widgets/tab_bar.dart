import 'package:flutter/material.dart';

class AppBottomNavBar extends StatefulWidget {

  final Function(int) onItemSelected;
  final int currentIndex;

  const AppBottomNavBar({required this.onItemSelected, required this.currentIndex, super.key});

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Books',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.monetization_on),
        //   label: 'Invests',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart),
          label: 'Statistics',
        ),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: widget.onItemSelected,
    );
  }
}