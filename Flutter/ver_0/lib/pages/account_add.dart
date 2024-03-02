import 'package:flutter/material.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/pages/account_admin.dart';
import 'package:ver_0/widgets/models/bank_account.dart';
import 'package:ver_0/widgets/models/card_account.dart';

class AccountEditPage extends StatefulWidget {
  final BankAccount? bankAccount;
  final CardAccount? cardAccount;

  const AccountEditPage({this.bankAccount, this.cardAccount, super.key,});


  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  final GlobalKey<FormState> _accountFormKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _issuerController = TextEditingController();
  final TextEditingController _issuerdisplayController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  late String _pageType; 


  @override
  void initState() {
    super.initState();
    if(widget.bankAccount != null || widget.cardAccount != null) {
      _pageType = "수정";
    } else {
      _pageType = "입력";
    }
    _initializeControllers(); 
  }

  Future<void> _initializeControllers() async {
  // 페이지가 초기화될 때 받아온 정보를 사용하여 상태를 업데이트합니다.
    if (widget.bankAccount != null) {
      _typeController.text = '은행';
      _idController.text = widget.bankAccount!.id.toString();
      _nameController.text = widget.bankAccount!.bankName;
      _numberController.text = widget.bankAccount!.accountNumber ?? '';
      _memoController.text = widget.bankAccount!.memo ?? '';
    } else if (widget.cardAccount != null) {
      _typeController.text = '카드';
      _idController.text = widget.cardAccount!.id.toString();
      _nameController.text = widget.cardAccount!.cardName;
      _issuerController.text = widget.cardAccount!.cardIssuer.toString();
      if (widget.cardAccount!.cardIssuer != null) {
        var issuerBankAccount = await DatabaseAdmin().getBankAccountById(widget.cardAccount!.cardIssuer ?? 0);
        _issuerdisplayController.text = issuerBankAccount!.bankName;
      } 
      _numberController.text = widget.cardAccount!.cardNumber ?? '';
      _memoController.text = widget.cardAccount!.memo ?? '';
    } else {
      _typeController.text = '미설정';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자산 편집'),
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 30, 30),
        child: Form(
          key: _accountFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "종류",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      readOnly: true, // 사용자 입력 방지
                      onTap: () {
                        _showAccountTypeModal(context);
                      },
                      controller: _typeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Field is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "이름",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if(_typeController.text == "카드")
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "연동 계좌",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          readOnly: true, // 사용자 입력 방지
                          onTap: () {
                            _showCardIssuerModal(context);
                          },
                          controller: _issuerdisplayController,
                          validator: (value) {
                            if (_typeController.text == "카드" && (value == null || value.isEmpty)) {
                              return 'Field is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  if(_typeController.text == "카드")
                  const SizedBox(height: 20),
                ]
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "번호",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "메모",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _memoController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if(_pageType == "수정") 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4, // 화면의 40%를 차지하도록 조절
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('삭제 확인'),
                              content: const Text('데이터를 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteDataFromDatabase(); // Delete data
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AccountListPage()),
                                    ); // Close the dialog
                                  },
                                  child: const Text('삭제'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text('취소'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        '삭제',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4, // 화면의 40%를 차지하도록 조절
                    child: ElevatedButton(
                      onPressed: _accountFormKey.currentState?.validate() ?? false? () {
                        // Handle Save button press
                        if (_accountFormKey.currentState?.validate() ?? false) {
                          // Save data when Save button is pressed
                          updateDataToDatabase();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccountListPage()),
                          );
                        }
                      }: null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // 원하는 모양으로 조절
                        ),
                      ),
                      child: const Text('수정'),
                    ),
                  ),
                ],
              ),
              if(_pageType == "입력")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4, // 화면의 40%를 차지하도록 조절
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle Cancel button press
                        // print('Cancel button pressed');
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom( // 아웃라인 색상을 primary로 지정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4, // 화면의 40%를 차지하도록 조절
                    child: ElevatedButton(
                      onPressed: _accountFormKey.currentState?.validate() ?? false? () {
                        // Handle Save button press
                        if (_accountFormKey.currentState?.validate() ?? false) {
                          // Save data when Save button is pressed
                          insertDataToDatabase();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccountListPage()),
                          );
                        }
                      }: null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // 원하는 모양으로 조절
                        ),
                      ),
                      child: const Text('저장'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountTypeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('은행 계좌'),
              onTap: () {
                setState(() {
                  _typeController.text = '은행';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('카드 계좌'),
              onTap: () {
                setState(() {
                  _typeController.text = '카드';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCardIssuerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<BankAccount>>(
          future: DatabaseAdmin().getAllBankAccounts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // 데이터 로딩 중이면 로딩 인디케이터 표시
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            List<BankAccount>? fetchedBankAccounts = snapshot.data;
            if (fetchedBankAccounts == null || fetchedBankAccounts.isEmpty) {
              return const Text('No data available'); // 데이터가 없을 경우
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: fetchedBankAccounts.map((bankAccount) {
                return ListTile(
                  title: Text(bankAccount.bankName),
                  onTap: () {
                    setState(() {
                      _issuerController.text = bankAccount.id.toString();
                      _issuerdisplayController.text = bankAccount.bankName.toString();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  void insertDataToDatabase() {
    if (_typeController.text == '은행') {
    // 은행 계좌 정보 생성
    BankAccount bankAccount = BankAccount(
      bankName: _nameController.text,
      accountNumber: _numberController.text, // 이 부분은 적절한 정보로 수정해야 합니다.
      memo: _memoController.text,
    );
    // 데이터베이스에 은행 계좌 정보 삽입
    DatabaseAdmin().insertBankAccount(bankAccount);
    } else if (_typeController.text == '카드') {
      // 카드 계좌 정보 생성
      CardAccount cardAccount = CardAccount(
        cardIssuer: int.parse(_issuerController.text), // 이 부분은 적절한 정보로 수정해야 합니다.
        cardName: _nameController.text,
        cardNumber: _numberController.text, // 이 부분은 적절한 정보로 수정해야 합니다.
        memo: _memoController.text,
      );
      // 데이터베이스에 카드 계좌 정보 삽입
      DatabaseAdmin().insertCardAccount(cardAccount);
    }
  }

  void updateDataToDatabase() {
    if (_typeController.text == '은행') {
      // 은행 계좌 정보 생성
      BankAccount bankAccount = BankAccount(
        id: int.parse(_idController.text),
        bankName: _nameController.text,
        accountNumber: _numberController.text, // 이 부분은 적절한 정보로 수정해야 합니다.
        memo: _memoController.text,
      );
      // 데이터베이스에 은행 계좌 정보 장장
      DatabaseAdmin().updateBankAccount(bankAccount);
    } else if (_typeController.text == '카드') {
      // 카드 계좌 정보 생성
      CardAccount cardAccount = CardAccount(
        id: int.parse(_idController.text), // 이 부분은 적절한 정보로 수정해야 합니다.
        cardIssuer: int.parse(_issuerController.text), // 이 부분은 적절한 정보로 수정해야 합니다.
        cardName: _nameController.text,
        cardNumber: _numberController.text, // 이 부분은 적절한 정보로 수정해야 합니다.
        memo: _memoController.text,
      );
      // 데이터베이스에 카드 계좌 정보 정정
      DatabaseAdmin().updateCardAccount(cardAccount);
    }
  }

  void deleteDataFromDatabase() {
    if (_typeController.text == '은행') {
    // 데이터베이스에 은행 계좌 정보 삭제
      DatabaseAdmin().deleteBankAccount(int.parse(_idController.text));
    } else if (_typeController.text == '카드') {
      // 데이터베이스에 카드 계좌 정보 삭제
      DatabaseAdmin().deleteCardAccount(int.parse(_idController.text));
    }
  }
}