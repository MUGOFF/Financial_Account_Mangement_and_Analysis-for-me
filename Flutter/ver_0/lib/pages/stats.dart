import 'package:flutter/material.dart';
import 'package:ver_0/widgets/drawer_end.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     onPressed: () {
        //       // Handle settings button press
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.info),
        //     onPressed: () {
        //       // Handle info button press
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.help),
        //     onPressed: () {
        //       // Handle help button press
        //     },
        //   ),
        // ],
      ),
      endDrawer: const AppDrawer(),
      body: const Center(
        child: Text('This is 통계'),
      ),
    );
  }
}