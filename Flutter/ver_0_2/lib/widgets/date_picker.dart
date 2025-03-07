import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget  {
  final TextEditingController controller;
  final void Function(DateTime)? onDateSelected;
  final bool tryValidator;
  

  const DatePicker({required this.controller,this.onDateSelected,this.tryValidator=false,super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSize = (screenWidth * 0.035).clamp(12, 24);
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          controller.text = DateFormat('yyyy년 MM월 dd일').format(picked); // 선택된 날짜를 텍스트 필드에 표시
          if (onDateSelected != null) {
            onDateSelected!(picked); // 선택된 날짜를 콜백으로 전달
          }
        }
      },
      style: TextStyle(fontSize: textSize),
      validator: tryValidator
        ? (value) {
            if (value == null || value.isEmpty) {
              return 'Field is required';
            }
            return null;
          }
        : null,
    );
  }
}

class TimePicker extends StatelessWidget  {
  final TextEditingController controller;
  final void Function(TimeOfDay)? onTimeSelected;
  final void Function() onCancelTimeSet;
  final bool tryValidator;

  const TimePicker({required this.controller,this.onTimeSelected, required this.onCancelTimeSet, this.tryValidator=false,super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSize = (screenWidth * 0.035).clamp(12, 24);
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (picked != null) {
          controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'; // 선택된 날짜를 텍스트 필드에 표시
          if (onTimeSelected != null) {
            onTimeSelected!(picked); // 선택된 날짜를 콜백으로 전달
          }
        }
      },
      style: TextStyle(fontSize: textSize),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: (){
            onCancelTimeSet();
          },
          // iconSize: 10,
          icon: const Icon(Icons.cancel_outlined)
        ),
      ),
      validator: tryValidator
        ? (value) {
            if (value == null || value.isEmpty) {
              return 'Field is required';
            }
            return null;
          }
        : null,
    );
  }
}
