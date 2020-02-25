import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = Color(0xFFFFFFFF);

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), paint);

    paint.color = Color(0xFFd59f01);

    canvas.drawRect(Rect.fromLTWH(2000.0, 150.0, 1700.0, 500.0), paint);

    TextSpan span = TextSpan(
        style: TextStyle(
          color: Colors.white,
          fontSize: 150.0,
          fontWeight: FontWeight.bold,
        ),
        text: 'Escenario');

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout(
      maxWidth: 1700,
      minWidth: 1700,
    );
    tp.paint(
        canvas,
        Offset(
          2000,
          400.0 - (tp.height / 2),
        ));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
