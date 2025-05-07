import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoadingDialog extends StatefulWidget {
  final String message;
  final VoidCallback? onReady;
  static GlobalKey<LoadingDialogState> dialogKey = GlobalKey<LoadingDialogState>();

  const LoadingDialog({super.key, this.message = "진행 중...", this.onReady});

  @override
  State<LoadingDialog> createState() => LoadingDialogState();
  /// 외부에서 진행도를 업데이트할 수 있도록 `updateProgress`를 저장
  static late void Function(double) updateProgress;

   static Future<void> show(BuildContext context, {String message = "진행 중...", VoidCallback? onReady}) async {
    // 다이얼로그를 띄우고 context와 GlobalKey를 사용
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LoadingDialog(message: message, key: dialogKey, onReady: onReady);
      },
    );
  }

  static void hide() {
    if (dialogKey.currentState != null && dialogKey.currentState!.mounted) {
      dialogKey.currentState!.closeDialog();
    }
  }
}

class LoadingDialogState extends State<LoadingDialog> {
  double progress = 0.0;
  bool isIndeterminate = false;
  Logger logger = Logger();

  void closeDialog() {
    // logger.d('close');
    Navigator.of(context).pop(); // 다이얼로그 닫기
  }

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onReady != null) widget.onReady!(); // 다이얼로그가 그려지고 나서 호출
    });
    LoadingDialog.updateProgress = (value) {
      if (mounted) {
        setState(() {
          if (value == -1) {
            isIndeterminate = true;
          } else {
            isIndeterminate = false;
            progress = value;
          }
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 방지
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isIndeterminate
              ? const CircularProgressIndicator() // value 없이 무한 회전
              : CircularProgressIndicator(value: progress / 100), // 진행도 표시
            const SizedBox(height: 16),
            Text(widget.message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            if (!isIndeterminate) ...[
              const SizedBox(height: 8),
              Text("${progress.toInt()}%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  } 
}