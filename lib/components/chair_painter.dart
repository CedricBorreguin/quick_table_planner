import 'package:flutter/material.dart';

class ChairPainter extends CustomPainter {
  ChairPainter({this.text, this.color});

  final String text;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = color;
    paint.style = PaintingStyle.fill;

    //canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), paint);
    //print(size);
    //canvas.drawCircle(Offset(size.width / 2, size.height / 2), 15.0, paint);

    var path = Path();

    path.moveTo(3.657, 0);
    path.lineTo(26.432, 0);
    path.quadraticBezierTo(28.86, 0.964, 30, 3.57);
    path.lineTo(26.066, 22.546);
    path.quadraticBezierTo(25.019, 24.42, 22.575, 25.381);
    path.lineTo(7.476, 25.381);
    path.quadraticBezierTo(4.977, 24.397, 3.947, 22.546);
    path.lineTo(0.09, 4.323);
    path.quadraticBezierTo(1.114, 0.942, 3.657, 0);

    canvas.drawPath(path, paint);

    TextSpan span = TextSpan(
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
        text: text);

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout(
      maxWidth: 30,
      minWidth: 30,
    );
    tp.paint(
        canvas,
        Offset(
          0,
          15 - (tp.height / 2),
        ));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
