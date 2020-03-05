import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
          padding: const EdgeInsets.all(30.0), child: CustomPainterPractice()),
    );
  }
}

class CustomPainterPractice extends StatefulWidget {
  @override
  _CustomPainterPracticeState createState() => _CustomPainterPracticeState();
}

class _CustomPainterPracticeState extends State<CustomPainterPractice>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  double drawTime = 0.0;
  double drawDuration = 2.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(seconds: drawDuration.toInt()));
    animation =
        Tween<double>(begin: 0.001, end: drawDuration).animate(controller)
          ..addListener(() {
            setState(() {
              drawTime = animation.value;
            });
          });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(padding: const EdgeInsets.all(30),
      child: CustomPaint(
        painter: BobRoss(drawDuration: drawDuration, drawTime: drawTime),
      ),),
    );
  }
}

class BobRoss extends CustomPainter {
  final double drawTime;
  final double drawDuration;

  BobRoss({this.drawTime, this.drawDuration});


  @override
  void paint(Canvas canvas, Size size) {
    Paint rectPaint = Paint();
    rectPaint.style = PaintingStyle.fill;
    rectPaint.color = Colors.greenAccent;

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width * (drawTime/drawDuration), 50), rectPaint);
  }

  @override
  bool shouldRepaint(BobRoss oldDelegate) => true;
}

class Signature extends StatefulWidget {
  @override
  _SignatureState createState() => _SignatureState();
}

class _SignatureState extends State<Signature> {
  List<Offset> _points = <Offset>[];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails details) {
        setState(() {
          RenderBox renderBox = context.findRenderObject();
          Offset lp = renderBox.globalToLocal(details.globalPosition);
          _points = List.from(_points)..add(lp);
        });
      },
      onPanEnd: (DragEndDetails details) => _points.add(null),
      child: CustomPaint(
        painter: SignaturePainter(_points),
        size: Size.infinite,
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset> points;

  SignaturePainter(this.points);

  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null)
        canvas.drawLine(
            points[i], points[i + 1], paint); // Draw line đến các point
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) =>
      oldDelegate.points != points;
}
