import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/transaction_category.dart';

class CategoryAdminPage extends StatefulWidget {
  const CategoryAdminPage({super.key});

  @override
  State<CategoryAdminPage> createState() => _CategoryAdminPageState();
}

class _CategoryAdminPageState extends State<CategoryAdminPage> {
  List<TransactionCategory> categories = [];
  List<String> itemList = [];
  String currentCategory = "수입"; // 기본 카테고리 설정
  String selectedCard  = ""; // 선택값  설정
  bool showFA  = true; // 선택값  설정
  late PersistentBottomSheetController bottomSheetController;
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildRadioButton('소비', '소비', Colors.red),
              buildRadioButton('수입', '수입', Colors.green),
              buildRadioButton('이체', '이체', Colors.grey),
            ],
          ),
          const Divider(
            thickness: 16.0,
            color: Colors.grey,
          ),
          Expanded(
            child: FutureBuilder<List<TransactionCategory>>(
              future: DatabaseAdmin().getAllTransactionCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                      categories = snapshot.data!;
                      itemList = categories
                      .firstWhere((category) => category.name == currentCategory,
                          orElse: () => TransactionCategory(name: '', itemList: []))
                      .itemList ?? [];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8.0, // 주축(main axis) 방향의 간격을 8.0 픽셀로 설정합니다.
                        crossAxisSpacing: 8.0, // 교차축(cross axis) 방향의 간격을 8.0 픽셀로 설정합니다.
                      ),
                      itemCount: itemList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCard = itemList[index];
                              showFA = false; // 홀드 상태일 때 selectedCard에 텍스트 값 저장
                            });
                            _showSeletedModal(context);
                            // 여기서 화면을 변경하거나 다른 작업을 수행할 수 있습니다.
                          },
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            dashPattern: const [8, 8],
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              child: Card(
                                color: selectedCard == itemList[index] ? Colors.blue : Colors.transparent,
                                elevation: 0,
                                child: Center(
                                  child: selectedCard == itemList[index]
                                  ? const Icon(
                                      Icons.check, // 홀드 상태일 때 아이콘 체크를 표시
                                      size: 36.0, // 아이콘 크기 설정
                                      color: Colors.white, // 아이콘 색상 설정
                                    )
                                  : Text(
                                      itemList[index], // 홀드 상태가 아닐 때 카드 내용을 표시
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0, // Increased font size
                                      ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: showFA,
        child:FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(' $currentCategory 카테고리 추가'),
                  content: TextField(
                    controller: _textFieldController,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implement logic to add item to selected category
                        setState(() {
                          itemList.add(_textFieldController.text);
                          updateDataToDatabase();
                        });
                        _textFieldController.clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text('추가'),
                    ),
                  ],
                );
              },
            );
          },
          tooltip: '기록 데이터 추가',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildRadioButton(String value, String text, Color color) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child:OutlinedButton(
        onPressed: () {
          setState(() {
            currentCategory = value;
            selectedCard = "";
            showFA = true;
          });
          bottomSheetController.close();
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(const Size(120, 30)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (currentCategory == value) {
                return color.withOpacity(0.4);
              }
              return Colors.transparent;
            },
          ),
          side : MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
              if (currentCategory == value) {
                return const BorderSide(color: Colors.transparent);
              }
              return BorderSide(color: color.withOpacity(0.9));
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child:Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0, // Increased font size
            ),
          ),
        ),
      ),
    );
  }

  void _showSeletedModal(BuildContext context) {
    bottomSheetController = showBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvoked: (didPop) {
            setState(() {
              selectedCard = "";
              showFA = true;
            });
          },
          child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox (
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  onPressed: () {
                    bottomSheetController.close();                    
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PopScope(
                          onPopInvoked: (didPop) {
                            setState(() {
                              selectedCard = "";
                              showFA = true;
                            });
                          },
                          child: AlertDialog(
                            title: Text(' $selectedCard 를 삭제하시겠습니까?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedCard = "";
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Implement logic to add item to selected category
                                  setState(() {
                                    itemList.remove(selectedCard);
                                    updateDataToDatabase();
                                    selectedCard = "";
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    // 첫 번째 버튼을 눌렀을 때 수행할 작업
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('삭제', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
               // 간격 조절
              SizedBox (
                width: MediaQuery.of(context).size.width * 0.4,
                child:ElevatedButton(
                  onPressed: () {
                    bottomSheetController.close();
                    showFA = true;
                    _textFieldController.text = selectedCard;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PopScope(
                          onPopInvoked: (didPop) {
                            setState(() {
                              selectedCard = "";
                            });
                          },
                          child: AlertDialog(
                            title: const Text('카테고리 수정'),
                            content: TextField(
                              controller: _textFieldController, // 초기 값으로 선택한 카테고리 설정
                            ),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedCard = "";
                                      showFA = true;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('취소'),
                                ),
                              TextButton(
                                  onPressed: () {
                                    // Implement logic to add item to selected category
                                    setState(() {
                                      int itemIndex = itemList.indexOf(selectedCard);
                                      if (_textFieldController.text.isNotEmpty && itemIndex != -1) {
                                        itemList[itemIndex] = _textFieldController.text;
                                      }
                                      updateDataToDatabase();
                                      _textFieldController.clear();
                                      selectedCard = "";
                                      showFA = true;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('수정'),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                    // 두 번째 버튼을 눌렀을 때 수행할 작업
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('수정'),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  void updateDataToDatabase() {
    // 데이터베이스에 정정
    DatabaseAdmin().updateTransactionCategoryItemList( currentCategory, itemList);
  }
}
