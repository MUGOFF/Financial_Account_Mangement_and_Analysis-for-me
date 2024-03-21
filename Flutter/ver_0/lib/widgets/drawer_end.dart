import 'package:flutter/material.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/pages/account_admin.dart';
import 'package:ver_0/pages/book_category_admin.dart';
import 'package:ver_0/pages/external_data_inout.dart';
// import 'package:ver_0/pages/debug_test.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[ 
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    // Handle settings button press
                    DatabaseAdmin().clearTable('current_holdings');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    // Handle settings button press
                    DatabaseAdmin().clearTable('investments_expiration');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    // Handle settings button press
                    DatabaseAdmin().clearTable('investments_nonexpiration');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    // Handle settings button press
                    DatabaseAdmin().clearTable('money_transactions');
                  },
                ),
              ],
            )
            
          ),
          ListTile(
            title: const Text('가계부 계좌/카드 관리'),
            onTap: () {
              // Handle menu item 1 tap
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountListPage()),
              );
            },
          ),
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
          // ListTile(
          //   title: const Text('테스트 페이지'),
          //   onTap: () {
          //     // Handle menu item 2 tap
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const TestBed()),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}