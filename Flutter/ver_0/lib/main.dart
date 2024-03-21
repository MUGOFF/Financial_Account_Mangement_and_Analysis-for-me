import 'package:flutter/material.dart';
import 'package:ver_0/pages/book.dart';
import 'package:ver_0/pages/investment.dart';
import 'package:ver_0/pages/stats.dart';
import 'package:ver_0/widgets/tab_bar.dart';
import 'package:ver_0/widgets/drawer_end.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/current_holdings.dart';
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
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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

class HomePageCotent extends StatefulWidget {
  const HomePageCotent({super.key});

  @override
  State<HomePageCotent> createState() => _HomePageCotentState();
}

class _HomePageCotentState extends State<HomePageCotent> {
  late PageController _pageController;
  List<Holdings> currentHoldings = [];
  List<String> investCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchHoldings();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchHoldings() async {
    List<Holdings> fetchedHoldings = await DatabaseAdmin().getCurrentHoldInvestments();
    setState(() {
      currentHoldings = fetchedHoldings;
      investCategories = currentHoldings.map((holding) => holding.investcategory).toList();
    });
  }

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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: PageView(
            controller: _pageController,
            children: [
              InvestHolingsPage(currentHoldings: currentHoldings, investCategories: investCategories),
            ],
          ),
      ),
    );
  }
}

class InvestHolingsPage extends StatelessWidget {
  final List<Holdings> currentHoldings;
  final List<String> investCategories;
  const InvestHolingsPage({required this.currentHoldings, required this.investCategories, super.key});

  @override
  Widget build(BuildContext context) {

    Map<String, List<Holdings>> groupedHoldings = {};
    for (var holding in currentHoldings) {
      if (!groupedHoldings.containsKey(holding.investcategory)) {
        groupedHoldings[holding.investcategory] = [];
      }
      groupedHoldings[holding.investcategory]!.add(holding);
    }

    if (currentHoldings.isEmpty) {
      return const Center(
        child: Text(
          '투자 데이터가 없습니다',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView(
      children: groupedHoldings.entries.map((entry) {
        String category = entry.key;
        List<Holdings> holdings = entry.value;

        // 카테고리별 보유 정보 리스트를 출력하는 위젯을 생성합니다.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                category, // 카테고리 이름 출력
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: holdings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(holdings[index].investment),
                  subtitle: Text(holdings[index].totalAmount.toString()),
                );
              },
            ), 
          ],
        );
      }).toList(),
    );
  }
}
