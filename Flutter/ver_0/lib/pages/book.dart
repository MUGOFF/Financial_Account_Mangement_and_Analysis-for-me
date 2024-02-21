import 'package:flutter/material.dart';
import 'package:ver_0/widgets/drawer_end.dart';
import 'package:ver_0/pages/book_add.dart';

class Book extends StatelessWidget {
  const Book({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('가계부'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings button press
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
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          )
        ],
      ),
      endDrawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Page 1'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookAdd()),
          );
        },
        tooltip: 'Add new transaction',
        child: const Icon(Icons.add),
      ),//
    );
  }
}