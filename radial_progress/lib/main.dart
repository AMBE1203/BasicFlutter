import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Experiments',
      theme: ThemeData(),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            title: Text(
              "Flutter Experiments",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  letterSpacing: 1.0),
            ),
            backgroundColor: Color(0xFF2979FF),
            centerTitle: true),
        body: HomeContent());
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  double percentage;

  @override
  void initState() {
    super.initState();
    setState(() {
      percentage = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200.0,
        width: 200.0,
        child: CustomPaint(
          foregroundPainter: MyPainter(
              lineColor: Colors.amber,
              completeColor: Colors.blueAccent,
              completePercent: percentage,
              width: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
                color: Colors.purple,
                splashColor: Colors.blueAccent,
                shape: CircleBorder(),
                child: Text("Click"),
                onPressed: () {
                  setState(() {
                    percentage += 10.0;
                    if (percentage > 100.0) {
                      percentage = 0.0;
                    }
                  });
                }),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;

  MyPainter(
      {this.lineColor, this.completeColor, this.completePercent, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete = Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);
    double arcAngle = 2 * pi * (completePercent / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
