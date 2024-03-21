import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:ver_0/pages/investment_add.dart';
import 'package:ver_0/widgets/drawer_end.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/expiration_investment.dart';
import 'package:ver_0/widgets/models/nonexpiration_investment.dart';

class Invest extends StatefulWidget {
  const Invest({super.key});

  @override
  State<Invest> createState() => _InvestState();
}

class _InvestState extends State<Invest> {
  Logger logger = Logger();
  DateTime endDate = DateTime.now();
  DateTime startDate = DateTime.now().subtract(const Duration(days: 1));
  bool selectRange = false;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateFormat('yyyy년 MM월 dd일').format(startDate);
    _endDateController.text = DateFormat('yyyy년 MM월 dd일').format(endDate);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('투자정보'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        endDrawer: const AppDrawer(),
        body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          Container(
            color: Colors.grey[200],
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: (){
                    setState(() {
                      endDate = DateTime.now();
                      startDate = DateTime.now().subtract(const Duration(days: 1));
                      _startDateController.text = DateFormat('yyyy년 MM월 dd일').format(startDate);
                      _endDateController.text = DateFormat('yyyy년 MM월 dd일').format(endDate);
                      selectRange = false;
                    });
                  }, 
                  child: const Text('1일')
                ),
                TextButton(
                  onPressed: (){
                    setState(() {
                      endDate = DateTime.now();
                      startDate = DateTime(DateTime.now().year, DateTime.now().month - 3, DateTime.now().day);
                      _startDateController.text = DateFormat('yyyy년 MM월 dd일').format(startDate);
                      _endDateController.text = DateFormat('yyyy년 MM월 dd일').format(endDate);
                      selectRange = false;
                    });
                  }, 
                  child: const Text('3개월')
                ),
                TextButton(
                  onPressed: (){
                    setState(() {
                      endDate = DateTime.now();
                      startDate = DateTime(DateTime.now().year);
                      _startDateController.text = DateFormat('yyyy년 MM월 dd일').format(startDate);
                      _endDateController.text = DateFormat('yyyy년 MM월 dd일').format(endDate);
                      selectRange = false;
                    });
                  }, 
                  child: const Text('YTD')
                ),
                TextButton(
                  onPressed: (){
                    setState(() {
                      selectRange = true;
                    });
                  }, 
                  child: const Text('기간 설정')
                ),
              ],
            ),
          ),
          if(selectRange == true)
          const SizedBox(height: 3),
          if(selectRange == true)
          Container(
            color: Colors.grey[200],
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 1)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null && picked.isBefore(endDate)) {
                      setState(() {
                        _startDateController.text = DateFormat('yyyy년 MM월 dd일').format(picked);
                        startDate = picked;
                      });
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${DateFormat('yyyy년 MM월 dd일').format(endDate)} 이전의 날짜를 선택해주세요'),
                          duration: const Duration(seconds: 2), // Adjust duration as needed
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  ),  
                  child: Text( _startDateController.text)
                ),
                const Text('~'),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null && picked.isAfter(startDate)) {
                      setState(() {
                        _endDateController.text = DateFormat('yyyy년 MM월 dd일').format(picked);
                        endDate = picked;
                      });
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${DateFormat('yyyy년 MM월 dd일').format(startDate)} 이후의 날짜를 선택해주세요'),
                          duration: const Duration(seconds: 2), // Adjust duration as needed
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  ), 
                  child: Text( _endDateController.text)
                ),
              ],
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              DatabaseAdmin().getExInvestmentsByDateRange(startDate, endDate),
              DatabaseAdmin().getNonExInvestmentsByDateRange(startDate, endDate),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<ExpirationInvestment> fetchedExInvestments = snapshot.data?[0] ?? [];
                List<NonexpirationInvestment> fetchedNonExInvestments = snapshot.data?[1] ?? [];
                if (fetchedExInvestments.isEmpty && fetchedNonExInvestments.isEmpty) {
                  return const Expanded(child: Center(child: Text('해당기간 투자 데이터가 없습니다')));
                } else {
                  List<dynamic> mergedInvestments = [];
                  for (var investments in fetchedExInvestments) {
                    mergedInvestments.add(investments);
                  }
                  for (var investments in fetchedNonExInvestments) {
                    mergedInvestments.add(investments);
                  }
                  mergedInvestments.sort((previos, next) => DateFormat('yyyy년 MM월 dd일THH:mm').parse(next.investTime).compareTo(DateFormat('yyyy년 MM월 dd일THH:mm').parse(previos.investTime)));
                  return Expanded(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: mergedInvestments.length,
                          itemBuilder: (context, index) {
                            dynamic transaction = mergedInvestments[index];
                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: transaction.amount > 0 ? [Colors.red.shade200, Colors.red.shade50] : [Colors.blue.shade200, Colors.blue.shade50],
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                    ),
                                  ),
                                  child: investmentListItem(
                                    transaction.investTime,
                                    transaction.investment,
                                    transaction.valuePrice,
                                    transaction.amount.abs(),
                                    transaction.currency,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => 
                                            transaction is ExpirationInvestment
                                              ? InvestAdd(expirationInvestment: transaction)
                                              : InvestAdd(nonExpirationInvestment: transaction),
                                          transitionsBuilder:
                                            (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween = Tween(begin: begin, end: end)
                                                .chain(CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ),
                                      ).then((result) {
                                        setState(() {});
                                      });
                                    },
                                  ),
                                ), 
                                const Divider(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const InvestAdd(),
              transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          ).then((result) {
            setState((){});
          });
        },
        tooltip: '투자 정보 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget investmentListItem(String invetmentTime, String invetmentName, double invetmentAmount, double invetmentPerprice, String invetmentCurrency, {GestureTapCallback? onTap}) {
    
    String getCurrencySymbol(String currency) {
      if (currency == 'KRW') {
        return '₩';
      } else if (currency == 'USD') {
        return '\$';
      } else if (currency == 'JPY') {
        return '¥';
      } else if (currency == 'EUR') {
        return '€';
      } else {
        return '?';
      }
    }

    String formatterK(num number) {
      late String fString;
      late String addon;
      if(number.toString().contains('.')) {
        fString = number.toString().split('.')[0];
        addon = ".${number.toString().split('.')[1]}";
      } else {
        fString = number.toString();
        addon = "";
      }

      final String newText = fString.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
      return '$newText$addon';
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child:Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(invetmentName, style: const TextStyle(fontWeight: FontWeight.bold,  fontSize: 18.0),),
                      const SizedBox(height: 5),
                      Text(invetmentTime, style: const TextStyle(color: Colors.grey,  fontSize: 12.0),),
                    ]
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatterK(invetmentAmount), style: const TextStyle( fontSize: 16.0),),
                      const SizedBox(height: 5),
                      Text('${getCurrencySymbol(invetmentCurrency)}    ${formatterK(invetmentPerprice)}', style: const TextStyle(fontSize: 16.0),),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:invetmentCurrency=="KRW" ? Colors.green.shade800:
                                  invetmentCurrency=="USD" ? Colors.lime.shade400:
                                  invetmentCurrency=="JPY" ? Colors.grey: Colors.black, 
                            width: 3),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          getCurrencySymbol(invetmentCurrency), 
                          style: TextStyle(
                            fontSize: 24.0,
                            color:invetmentCurrency=="KRW" ? Colors.green.shade800:
                                  invetmentCurrency=="USD" ? Colors.lime.shade400:
                                  invetmentCurrency=="JPY" ? Colors.grey: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )
      )
    );
  }
}