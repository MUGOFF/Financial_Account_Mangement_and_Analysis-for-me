import 'package:flutter/material.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/drawer_end.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () {
              // Handle settings button press
              DatabaseAdmin().clearTable('current_holdings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Handle info button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              // Handle help button press
            },
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: const Center(
        child: Text('This is 통계'),
      ),
    );
  }
}