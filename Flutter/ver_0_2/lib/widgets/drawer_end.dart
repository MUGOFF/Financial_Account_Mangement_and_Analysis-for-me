import 'package:flutter/material.dart';
import 'package:ver_0_2/pages/book_category_admin.dart';
import 'package:ver_0_2/pages/external_data_inout.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget> [ 
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            )
            
          ),
          // ListTile(
          //   title: const Text('가계부 계좌/카드 관리'),
          //   onTap: () {
          //     // Handle menu item 1 tap
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const AccountListPage()),
          //     );
          //   },
          // ),
          ListTile(
            title: const Text('가계부 카테고리 관리'),
            onTap: () {
              // Handle menu item 2 tap
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryAdminPage()),
              );
            },
          ),
          ListTile(
            title: const Text('데이터 가져오기/내보내기'),
            onTap: () {
              // Handle menu item 2 tap
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExternalTerminal()),
              );
            },
          ),
        ],
      ),
    );
  }
}