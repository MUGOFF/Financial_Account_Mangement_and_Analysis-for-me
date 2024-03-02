import 'package:flutter/material.dart';
import 'package:ver_0/pages/book.dart';
import 'package:ver_0/pages/investment.dart';
import 'package:ver_0/pages/stats.dart';
import 'package:ver_0/widgets/tab_bar.dart';
import 'package:ver_0/widgets/drawer_end.dart';
// import 'package:ver_0/widgets/database_admin.dart';
// import 'package:my_flutter_app/sub_pages/page2.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 255, 190)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _checkFirstLaunch();
  // }

  // void _checkFirstLaunch() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey('settings')) {
  //     Map<String, dynamic> defaultSettings = {
  //       'user_settings': {
  //         'Category_user': {
  //           "수입": ["급여소득", "용돈", "금융소득"],
  //           "소비": ["식비","주거비","통신비","생활비","미용비","의료비","문화비","교통비","세금","카드대금","보험","기타",],
  //           "이체": ["내계좌이체", "계좌이체", "저축", "투자"],
  //         }, 
  //       },
  //       'fi_data': {
  //         'asset_accounts': [],
  //         'money_transactions': [],
  //         'invest_accounts': [],
  //         'invest_transactions': [],
  //       },
  //     };
  //     // await prefs.setString('settings', json.encode(defaultSettings));
  //     await prefs.setString('settings', defaultSettings);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Widget selectedWidget = const HomePageCotent();
    switch (_selectedIndex) {
      case 0:
        selectedWidget = const HomePageCotent();
        break;
      case 1:
        selectedWidget = const Book();
        break;
      case 2:
        selectedWidget = const Invest();
        break;
      case 3:
        selectedWidget = const StatisticsView();
        break;
    }
    
    return Scaffold(
      body: selectedWidget,
      bottomNavigationBar: AppBottomNavBar(
        onItemSelected: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}

class HomePageCotent extends StatelessWidget {
  const HomePageCotent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Flutter Demo Home Page'),
      ),
      endDrawer: const AppDrawer(),
      body: const Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'HOME PAGE',
            ),
          ],
        ),
      ),
    );
  }
}