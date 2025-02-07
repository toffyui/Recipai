import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../core/constants/colors.dart';

class LoadingWidget extends StatefulWidget {
  final List<String> messages;

  const LoadingWidget({Key? key, required this.messages}) : super(key: key);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  int _currentMessageIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 3秒ごとにメッセージを変更
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % widget.messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LoadingAnimationWidget.discreteCircle(
              color: Colors.white,
              secondRingColor: AppColors.primary,
              thirdRingColor: AppColors.accent,
              size: 160,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.messages[_currentMessageIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
