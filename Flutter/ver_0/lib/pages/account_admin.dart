import 'package:flutter/material.dart';
import 'package:ver_0/pages/account_add.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/bank_account.dart';
import 'package:ver_0/widgets/models/card_account.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});


  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  List<BankAccount> bankAccounts = [];
  List<CardAccount> cardAccounts = [];

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    List<BankAccount> fetchedBankAccounts = await DatabaseAdmin().getAllBankAccounts();
    List<CardAccount> fetchedCardAccounts = await DatabaseAdmin().getAllCardAccounts();
    setState(() {
      bankAccounts = fetchedBankAccounts;
      cardAccounts = fetchedCardAccounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계좌 목록'),
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSectionTitle('은행 계좌'),
                _buildAccountList(bankAccounts),
                _buildSectionTitle('카드 계좌'),
                _buildAccountList(cardAccounts),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountEditPage(),
                  ),
                ).then((result) {
                  setState(() {});
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '+ 자산 추가하기',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountList(List<dynamic> accounts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        // 각 계좌 정보를 보여주는 위젯을 반환합니다.
        // 예를 들어 ListTile을 사용할 수 있습니다.
        // 이곳에 원하는 계좌 정보를 보여주는 위젯을 작성하세요.
        return ListTile(
          title: Text(accounts[index] is BankAccount ? accounts[index].bankName: accounts[index].cardName),
          subtitle: Text(accounts[index] is BankAccount ? accounts[index].accountNumber: accounts[index].cardNumber),
          // 계좌 정보를 탭하면 수정하는 기능을 추가할 수 있습니다.
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => accounts[index] is BankAccount ? AccountEditPage(bankAccount: accounts[index]): AccountEditPage(cardAccount: accounts[index]),
              ),
            ).then((result) {
              setState(() {});
            });
          },
        );
      },
    );
  }
}