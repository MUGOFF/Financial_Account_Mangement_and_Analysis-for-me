import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ver_0_2/widgets/database_admin.dart';


class PersonalSettings extends StatefulWidget {
  const PersonalSettings({super.key});

  @override
  State<PersonalSettings> createState() => _PersonalSettingsState();
}

class _PersonalSettingsState extends State<PersonalSettings> {
  bool isInstallmentSpread = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isInstallmentSpread = prefs.getBool('intallmentCalculation') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
    await DatabaseAdmin().initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // ListTile(
          //   title: const Text('할부 예산 반영'),
          //   trailing: Switch(
          //     value: true,
          //     onChanged: (bool value) {
          //       // setState(() {
          //       //   _isTagSwitched = value;
          //       // });
          //     },
          //   ),
          // ),
          // const Divider(),
          SwitchListTile(
            title: const Text('할부 예산 반영'),
            value: isInstallmentSpread,
            onChanged: (bool value) {
              setState(() {
                isInstallmentSpread = value;
              });
              _saveSetting('intallmentCalculation', value);
            },
          ),
          const Divider(),
        ]
      )
    );
  }
}