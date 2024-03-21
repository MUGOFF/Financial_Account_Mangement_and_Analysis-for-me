import 'package:flutter/material.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/drawer_end.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭의 수를 지정합니다. 여기서는 두 개의 탭이 있으므로 2로 설정합니다.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('통계'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        endDrawer: const AppDrawer(),
        body: const Column(
          children: [
            TabBar(
              tabs: <Widget>[
                Tab(text: '소비 상태'),
                Tab(text: '투자 상태'),
              ]
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  Center(child: Text('This is 통계')),
                  Center(child: Text('This is 통계')),
                ],
              ),
            )
          ]
        ),
        
      ),
    );
  }
}