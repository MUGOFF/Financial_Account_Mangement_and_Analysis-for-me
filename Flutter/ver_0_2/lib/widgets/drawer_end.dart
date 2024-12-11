import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:logger/logger.dart';
import 'package:ver_0_2/pages/book_category_admin.dart';
import 'package:ver_0_2/pages/external_data_inout.dart';

// final Logger logger = Logger();
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  void _openStorePage() async {// 자신의 앱 URL로 변경
    final Uri appStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.polycarpsmoonmug.demo_release_1');// 자신의 앱 URL로 변경
    if (await canLaunchUrl (appStoreUrl)) {
      try {
        await launchUrl(appStoreUrl);
      } catch (e) {
        // logger.e(e);
        Fluttertoast.showToast(
          msg: '스토어 URL을 열 수 없습니다: $appStoreUrl',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.green.shade400,
        );
      }       
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget> [
          FutureBuilder<String>(
            future: _getAppVersion(),
            builder: (context, snapshot) {
              final appVersion = snapshot.data ?? 'Loading...';
              return DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _openStorePage,
                          // style: ElevatedButton.styleFrom(
                          //   backgroundColor: Colors.white,
                          //   foregroundColor: Colors.blue,
                          // ),
                          // child: const Text('Check for Updates'),
                          icon: const Icon(Icons.info_outline),
                          label: Text(
                            'Version: $appVersion',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // const SizedBox(height: 8),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    const Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                )
              );
            }
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