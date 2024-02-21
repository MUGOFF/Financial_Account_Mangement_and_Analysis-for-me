import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ver_0/widgets/date_picker.dart';
import 'package:intl/intl.dart';

class BookAdd extends StatefulWidget {
  const BookAdd({super.key});

  @override
  State<BookAdd> createState() => _BookAddState();
}

class _BookAddState extends State<BookAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  final TextEditingController _string1Controller = TextEditingController();
  final TextEditingController _intController = TextEditingController();
  final TextEditingController _string2Controller = TextEditingController();
  final TextEditingController _string3Controller = TextEditingController();

  int _selectedButton = 1; // Initially, the first button is selected

  @override
  void initState() {
    super.initState();
    final initialperiod = TimeOfDay.now().period == DayPeriod.am ? '오전' : '오후';
    _dateController = TextEditingController(text: DateFormat('yyyy년 MM월 dd일').format(DateTime.now()));
    _timeController = TextEditingController(text:'$initialperiod ${TimeOfDay.now().hourOfPeriod}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가계부 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildRadioButton(1, '지출', Colors.red),
                  buildRadioButton(2, '수입', Colors.green),
                  buildRadioButton(3, '이체', Colors.grey),
                ],
              ),
              const SizedBox(height: 16.0), // Add spacing between rows and buttons
              // Date, String, Int, String, String Fields
              buildRow("날짜", _dateController, fieldType: 'datetime',secondController: _timeController),
              buildRow("거래금액", _intController, fieldType: 'numeric'),
              buildRow("거래계좌", _string1Controller),
              buildRow("거래대상", _string2Controller),
              buildRow("거래분류", _string3Controller),
              const SizedBox(height: 16.0), // Add spacing between buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Save data when Save button is pressed
                        // You can access the entered data using the controllers
                        // _dateController.text, _string1Controller.text, etc.
                        // print('Save button pressed');
                        // print('Selected button: $_selectedButton');
                      }
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle Cancel button press
                      // print('Cancel button pressed');
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(String label, TextEditingController controller, {String fieldType = 'text', TextEditingController? secondController}) {
    switch (fieldType) {
      case 'numeric':
        return buildNumericRow(label, controller);
      case 'datetime':
        return buildDateTimeRow(label, controller, secondController);
      default:
        return buildTextRow(label, controller);
    }
  }

  Widget buildTextRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
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
    );
  }

  Widget buildNumericRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              style: const TextStyle(
                fontWeight: FontWeight.bold, // Increased font size
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateTimeRow(String label, TextEditingController controller, TextEditingController? secondController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: DatePicker(
                    controller: controller,
                    tryValidator: true,
                  ),
                ),
                if (secondController != null)
                  Expanded(
                    child: TimePicker(
                      controller: secondController,
                      tryValidator: true,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadioButton(int value, String text, Color color) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedButton = value;
        });
      },
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(const Size(120, 30)),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (_selectedButton == value) {
              return color.withOpacity(0.4);
            }
            return Colors.transparent;
          },
        ),
        side : MaterialStateProperty.resolveWith<BorderSide>(
          (Set<MaterialState> states) {
            if (_selectedButton == value) {
              return const BorderSide(color: Colors.transparent);
            }
            return BorderSide(color: color.withOpacity(0.9));
          },
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0, // Increased font size
        ),
      ),
    );
  }
}

// 금액 형식으로 입력된 값을 변환하여 반환합니다.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 입력된 값을 금액 형식으로 변환합니다.
    final newText = newValue.text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    final formattedText = '  ₩  $newText';
    final selectionIndex = formattedText.length;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

