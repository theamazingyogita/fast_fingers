import 'dart:async';

import 'package:flutter/material.dart';

import 'countdown_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool start = false;
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
        if (seconds <= 59) {
          seconds = seconds + 1;
        } else {
          timer.cancel();
          seconds = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "FAST FINGERS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 50),
              Stack(
                children: [
                  TextFormField(
                    enabled: false,
                    textAlign: TextAlign.start,
                    minLines: 6,
                    maxLines: 6,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 50,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          "But I did not know how to make my apology. The words that had strung themselves so easily to make a blunder in the drawing room would not come now that I wished the blunder remedied.  I stood there below her window, tongue-tied and ashamed.  Suddenly I saw her turn and stretch behind her, and then she leant forward once again and threw something at me from the window.  It struck me on the cheek and fell to the ground.  I stooped to pick it up.  It was one of the flowers from her bowl, an autumn crocus.",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                  TextFormField(
                    textAlign: TextAlign.start,
                    showCursor: true,
                    cursorColor: Colors.amber,
                    minLines: 6,
                    maxLines: 6,

                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 50,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                    onChanged: (value) {
                      print("got here inside stat timere out fusm vmfd");
                      startTimer();
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Start typing to see how fast you are ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(80),
                    ),
                    padding: EdgeInsets.all(30),
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {
                        return Text(
                          "$minutes:$seconds",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
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
}
