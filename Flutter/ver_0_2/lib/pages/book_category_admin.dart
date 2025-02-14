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
  String currentCategory = "수입"; // 기본 카테고리 설정
  String selectedCard  = ""; // 선택값  설정
  bool showFA  = true; // 선택값  설정
  PersistentBottomSheetController? bottomSheetController;
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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
                          onLongPress: () {
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
                                  // Implement logic to add item to selected category
                                  setState(() {
                                    if(selectedCard != '특별 예산'){
                                      itemList.remove(selectedCard);
                                      updateDataToDatabase();
                                    } else {
                                      const snackBar = SnackBar(
                                        content:  Text('삭제가 불가능한 카테고리 입니다',style: TextStyle(fontSize: 16),),
                                        duration: Duration(seconds: 2),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
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
                    if (bottomSheetController != null) {
                      bottomSheetController!.close();
                    }
                    showFA = true;
                    _textFieldController.text = selectedCard;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PopScope(
                          // onPopInvoked: (didPop) {
                          //   setState(() {
                          //     selectedCard = "";
                          //   });
                          // },
                          onPopInvokedWithResult: (bool didPop, Object? result) async {
                            setState(() {
                              selectedCard = "";
                              showFA = true;
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
                                      if(selectedCard != '특별 예산'){
                                        int itemIndex = itemList.indexOf(selectedCard);
                                        if (_textFieldController.text.isNotEmpty && itemIndex != -1) {
                                          itemList[itemIndex] = _textFieldController.text;
                                        }
                                        updateDataToDatabase();
                                      } else {
                                        const snackBar = SnackBar(
                                          content:  Text('수정이 불가능한 카테고리 입니다',style: TextStyle(fontSize: 16),),
                                          duration: Duration(seconds: 2),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
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
