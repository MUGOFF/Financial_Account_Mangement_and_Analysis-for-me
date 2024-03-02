import 'package:flutter/material.dart';
import 'package:ver_0/pages/account_admin.dart';
// import 'package:ver_0/pages/book_add.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[ const
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('가계부 자산 설정'),
            onTap: () {
              // Handle menu item 1 tap
              // Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountListPage()),
              );
            },
          ),
          ListTile(
            title: const Text('가계부'),
            onTap: () {
              // Handle menu item 2 tap
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('통계 정보'),
            onTap: () {
              // Handle menu item 2 tap
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}