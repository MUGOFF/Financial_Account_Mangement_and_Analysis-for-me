// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
// import 'package:syncfusion_flutter_core/core.dart';
import 'package:ver_0_2/pages/book.dart';
// import 'package:ver_0_2/pages/investment.dart';
import 'package:ver_0_2/pages/stats.dart';
import 'package:ver_0_2/widgets/tab_bar.dart';
import 'package:ver_0_2/widgets/drawer_end.dart';
// import 'package:ver_0_2/widgets/database_admin.dart';
// import 'package:ver_0_2/widgets/models/current_holdings.dart';

void main() {
  // SyncfusionLicense.registerLicense("YOUR LICENSE KEY"); 
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

  // 탭별로 표시될 위젯을 리스트로 관리
  final List<Widget> _pages = [
    // const Page(), // 필요할 경우 주석 해제
    const HomePageCotent(),
    const Book(),
    // const Invest(),
    const StatisticsView(),
  ];

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
    // Widget selectedWidget = const HomePageCotent();
    // switch (_selectedIndex) {
    //   case 0:
    //     selectedWidget = const HomePageCotent();
    //     break;
    //   case 1:
    //     selectedWidget = const Book();
    //     break;
    //   // case 2:
    //   //   selectedWidget = const Invest();
    //   //   break;
    //   case 2:
    //     selectedWidget = const StatisticsView();
    //     break;
    // }
    
    Widget selectedWidget = _pages[_selectedIndex];

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
  // List<Holdings> currentHoldings = [];
  // List<String> investCategories = [];

  @override
  void initState() {
    super.initState();
    // _fetchHoldings();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Future<void> _fetchHoldings() async {
  //   List<Holdings> fetchedHoldings = await DatabaseAdmin().getCurrentHoldInvestments();
  //   setState(() {
  //     currentHoldings = fetchedHoldings;
  //     investCategories = currentHoldings.map((holding) => holding.investcategory).toList();
  //   });
  // }

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
        title: const Text('Junior Demo App (Book Account)'),
      ),
      endDrawer: const AppDrawer(),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: PageView(
            controller: _pageController,
            children: const [
              Text("미예정"),
              // OutlinedButton(
              //   onPressed: (){
              //     DatabaseAdmin().clearExtraGroup();
              //   }, 
              //   child: Text('칟ㅁㄱ ㄷㅌㅅㄱㅁ')
              // )
              // InvestHolingsPage(currentHoldings: currentHoldings, investCategories: investCategories),
            ],
          ),
      ),
    );
  }
}

/// 금융결제원 API
// class ApiCallbackFISapicenter extends StatefulWidget {
//   const ApiCallbackFISapicenter({super.key});
  
//   @override
//   State<ApiCallbackFISapicenter> createState() => _ApiCallbackFISapicenterState();
// }

// class _ApiCallbackFISapicenterState extends State<ApiCallbackFISapicenter> {
//   final String clientID = "a3b5f451-f822-454b-8bae-3789e5c8eb68";
//   final String clientSecret = "77ffb654-6ad5-42a6-8d84-d18e3cd48ba1";
//   String callbackResult = "Callback 결과가 여기에 표시됩니다.";
//   Logger logger = Logger();

//   // API 호출
//   Future<void> callApiWithCallback() async {
//     final String apiUrlOauth = "https://openapi.openbanking.or.kr/v2.0/accountinfo/list";
//     final String apiUrl = "https://openapi.openbanking.or.kr/v2.0/accountinfo/list";
//     // final String apiUrl = "http://com.polycarpsmoonmug.demo_release_1/start";
//     final String callbackUrl = "http://com.polycarpsmoonmug.demo_release_1/callback";

//     try {
//       // 1. Open API 요청 보내기
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"callback_url": callbackUrl}),
//       );

//       if (response.statusCode == 200) {
//         // 요청 성공 처리
//         logger.d("API 요청 성공: ${response.body}");

//         // 2. Callback URL 처리 (예제에서는 단순히 데이터 fetch)
//         await handleCallback(callbackUrl);
//       } else {
//         logger.d("API 요청 실패: ${response.body}");
//       }
//     } catch (e) {
//       logger.d("에러 발생: $e");
//     }
//   }

//   // 콜백 데이터 처리
//   Future<void> handleCallback(String callbackUrl) async {
//     try {
//       final callbackResponse = await http.get(Uri.parse(callbackUrl));
//       if (callbackResponse.statusCode == 200) {
//         // 콜백 결과를 UI에 표시
//         setState(() {
//           callbackResult = "콜백 처리 성공: ${callbackResponse.body}";
//         });
//       } else {
//         logger.d("콜백 처리 실패: ${callbackResponse.body}");
//       }
//     } catch (e) {
//       logger.d("콜백 에러: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("API Callback Example"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: callApiWithCallback,
//               child: const Text("API 호출 시작"),
//             ),
//             const SizedBox(height: 20),
//             Text(callbackResult),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class InvestHolingsPage extends StatelessWidget {
//   final List<Holdings> currentHoldings;
//   final List<String> investCategories;
//   const InvestHolingsPage({required this.currentHoldings, required this.investCategories, super.key});

//   @override
//   Widget build(BuildContext context) {

//     Map<String, List<Holdings>> groupedHoldings = {};
//     for (var holding in currentHoldings) {
//       if (!groupedHoldings.containsKey(holding.investcategory)) {
//         groupedHoldings[holding.investcategory] = [];
//       }
//       groupedHoldings[holding.investcategory]!.add(holding);
//     }

//     if (currentHoldings.isEmpty) {
//       return const Center(
//         child: Text(
//           '투자 데이터가 없습니다',
//           style: TextStyle(fontSize: 18),
//         ),
//       );
//     }

//     return ListView(
//       children: groupedHoldings.entries.map((entry) {
//         String category = entry.key;
//         List<Holdings> holdings = entry.value;

//         // 카테고리별 보유 정보 리스트를 출력하는 위젯을 생성합니다.
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 category, // 카테고리 이름 출력
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: holdings.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(holdings[index].investment),
//                   subtitle: Text(holdings[index].totalAmount.toString()),
//                 );
//               },
//             ), 
//           ],
//         );
//       }).toList(),
//     );
//   }
// }
