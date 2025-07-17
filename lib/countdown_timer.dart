import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key, required this.start});

  final bool start;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Timer timer;
  int seconds = 0;
  int minutes = 0;

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    super.initState();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds == 59) {
          seconds = 0;
          minutes += minutes;
        } else {
          seconds += seconds;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.start) {
      startTimer();
    }
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Text(
          "$minutes:$seconds",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}
