import 'package:flutter/material.dart';

class InvestAdd extends StatefulWidget {
  const InvestAdd({super.key});

  @override
  State<InvestAdd> createState() => _InvestAddState();
}

class _InvestAddState extends State<InvestAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _string1Controller = TextEditingController();
  final TextEditingController _intController = TextEditingController();
  final TextEditingController _string2Controller = TextEditingController();
  final TextEditingController _string3Controller = TextEditingController();

  int _selectedButton = 1; // Initially, the first button is selected

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
                  buildRadioButton(1, '지출'),
                  buildRadioButton(2, '수입'),
                  buildRadioButton(3, '이체'),
                ],
              ),
              const SizedBox(height: 16.0), // Add spacing between rows and buttons
              // Date, String, Int, String, String Fields
              buildRow("Date", _dateController),
              buildRow("String", _string1Controller),
              buildRow("Int", _intController),
              buildRow("String", _string2Controller),
              buildRow("String", _string3Controller),
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

  Widget buildRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label),
          ),
          Expanded(
            flex: 2,
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

  Widget buildRadioButton(int value, String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedButton = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2.0, // Border width
          ),
          color: _selectedButton == value ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0), // Adjust the border radius as needed
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0), // Increased horizontal padding
        child: Row(
          children: [
            Text(
              text,
              // textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0, // Increased font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}

