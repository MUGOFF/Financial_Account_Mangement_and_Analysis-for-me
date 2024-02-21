import 'package:flutter/material.dart';
import 'package:ver_0/widgets/drawer_end.dart';
import 'package:ver_0/pages/investment_add.dart';

class Invest extends StatelessWidget {
  const Invest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투자정보'),
      ),
      endDrawer: const AppDrawer(),
      body: const Center(
        child: Text('투자'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InvestAdd()),
          );
        },
        tooltip: 'Add new transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}