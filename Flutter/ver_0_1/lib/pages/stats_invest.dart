import 'package:flutter/material.dart';
import 'package:ver_0_1/widgets/models/current_holdings.dart';


///현재 보유 자산 목록
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