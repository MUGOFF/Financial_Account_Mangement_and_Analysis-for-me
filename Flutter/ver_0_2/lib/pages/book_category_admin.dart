import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ver_0_2/colorsholo.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/models/transaction_category.dart';

class CategoryAdminPage extends StatefulWidget {
  const CategoryAdminPage({super.key});

  @override
  State<CategoryAdminPage> createState() => _CategoryAdminPageState();
}

class _CategoryAdminPageState extends State<CategoryAdminPage> {
  Logger logger = Logger();
  List<TransactionCategory> categories = [];
  List<String> itemList = [];
  List<String> yearlyCategoryList = [];
  bool addYearlyCategoryList = false;
  String currentCategory = "수입"; // 기본 카테고리 설정
  String selectedCard  = ""; // 선택값  설정
  bool showFA  = true; // 선택값  설정
  PersistentBottomSheetController? bottomSheetController;
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
              buildRadioButton('소비', '소비', HoloColors.ookamiMio),
              buildRadioButton('수입', '수입', HoloColors.ceresFauna),
              buildRadioButton('이체', '이체', HoloColors.shiroganeNoel),
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
                  yearlyCategoryList = categories
                  .firstWhere((category) => category.name == '연간 예산',
                      orElse: () => TransactionCategory(name: '', itemList: []))
                  .itemList ?? [];
                  itemList = categories
                  .firstWhere((category) => category.name == currentCategory,
                      orElse: () => TransactionCategory(name: '', itemList: []))
                  .itemList ?? [];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemCount: itemList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              selectedCard = itemList[index];
                              showFA = false;
                            });
                            _showSeletedModal(context);
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
                                      Icons.check,
                                      size: 36.0,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      itemList[index],
                                      style: TextStyle(
                                        color: yearlyCategoryList.contains(itemList[index]) ? HoloColors.tokinoSora : HoloColors.azkI,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
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
                return StatefulBuilder(
                builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: Text(' $currentCategory 카테고리 추가'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _textFieldController,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox.adaptive(
                                value: addYearlyCategoryList,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    addYearlyCategoryList = value!;
                                    if (value == true) {
                                      yearlyCategoryList.add(_textFieldController.text);
                                    } else {
                                      yearlyCategoryList.remove(_textFieldController.text);
                                    }
                                  });
                                },
                              ),
                              const Text("연간 예산 설정")
                            ],
                          )
                        ]
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            _textFieldController.clear();
                            Navigator.of(context).pop();
                          },
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Implement logic to add item to selected category
                            setState(() {
                              if(!itemList.contains(_textFieldController.text)) {
                                itemList.add(_textFieldController.text);
                                updateDataToDatabase();
                              } else {
                                const snackBar = SnackBar(
                                  content:  Text('중복된 카테고리 입니다.',style: TextStyle(fontSize: 16),),
                                  duration: Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
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
            if (bottomSheetController != null) {
              bottomSheetController!.close();
            }
          });
        },
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all<Size>(const Size(120, 30)),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (currentCategory == value) {
                return color.withOpacity(0.4);
              }
              return Colors.transparent;
            },
          ),
          side : WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
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
    logger.d(selectedCard);
    bottomSheetController = showBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (BuildContext context) {
        return PopScope(
          // onPopInvoked: (didPop) {
          //   setState(() {
          //     selectedCard = "";
          //     showFA = true;
          //   });
          // },
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) async {
            setState(() {
              selectedCard = "";
              showFA = true;
            });
            Navigator.pop(context); // 모달을 닫기
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
                    if (bottomSheetController != null) {
                      bottomSheetController!.close();
                    }                   
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PopScope(
                          // onPopInvoked: (didPop) {
                          //   setState(() {
                          //     selectedCard = "";
                          //     showFA = true;
                          //   });
                          // },
                          onPopInvokedWithResult: (bool didPop, Object? result) async {
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
              SizedBox (
                width: MediaQuery.of(context).size.width * 0.4,
                child:ElevatedButton(
                  onPressed: () {
                    if (bottomSheetController != null) {
                      bottomSheetController!.close();
                    }
                    showFA = true;
                    _textFieldController.text = selectedCard;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setStateDialog) {
                           return PopScope(
                              onPopInvokedWithResult: (bool didPop, Object? result) async {
                                setState(() {
                                  selectedCard = "";
                                  showFA = true;
                                });
                              }, 
                              child: AlertDialog(
                                title: const Text('카테고리 수정'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _textFieldController,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox.adaptive(
                                          value: yearlyCategoryList.contains(selectedCard),
                                          onChanged: (value) {
                                            setStateDialog(() {
                                              if (value == true) {
                                                yearlyCategoryList.add(_textFieldController.text);
                                              } else {
                                                yearlyCategoryList.remove(_textFieldController.text);
                                              }
                                            });
                                          },
                                        ),
                                        const Text("연간 예산 설정")
                                      ],
                                    )
                                  ]
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _textFieldController.clear();
                                          selectedCard = "";
                                          showFA = true;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('취소'),
                                    ),
                                  TextButton(
                                      onPressed: () {
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
                      }
                    );
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
    DatabaseAdmin().updateTransactionCategoryItemList( '연간 예산', yearlyCategoryList);
  }
}
