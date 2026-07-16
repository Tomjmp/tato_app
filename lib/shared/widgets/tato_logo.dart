import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';

/// Símbolo de TÁTO: monograma "tt" — las dos T del nombre unidas por una
/// barra continua (el estante que sostiene el inventario) con el punto
/// menta flotante ("TÁTO notó algo"). Fuente de verdad visual:
/// design/brand/tato_mark.svg. Se pinta con canvas para que escale nítido
/// sin assets ni paquetes extra.
class TatoLogo extends StatelessWidget {
  final double size;
  final Color color;
  final Color dotColor;

  const TatoLogo({
    super.key,
    this.size = 64,
    this.color = TatoColors.logoInk,
    this.dotColor = TatoColors.secondary,
  });

  /// Variante para fondos azules u oscuros (splash, tarjetas de marca).
  const TatoLogo.onDark({super.key, this.size = 64})
      : color = Colors.white,
        dotColor = const Color(0xFF2DD4BF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TatoMarkPainter(color: color, dotColor: dotColor),
      ),
    );
  }
}

class _TatoMarkPainter extends CustomPainter {
  final Color color;
  final Color dotColor;

  const _TatoMarkPainter({required this.color, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Geometría definida sobre una caja de 120x120 (igual que el SVG).
    final s = size.width / 120;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * s
      ..strokeCap = StrokeCap.round;

    final t1 = Path()
      ..moveTo(42 * s, 32 * s)
      ..lineTo(42 * s, 72 * s)
      ..quadraticBezierTo(42 * s, 91 * s, 60 * s, 91 * s);
    canvas.drawPath(t1, stroke);

    final t2 = Path()
      ..moveTo(80 * s, 20 * s)
      ..lineTo(80 * s, 72 * s)
      ..quadraticBezierTo(80 * s, 91 * s, 98 * s, 91 * s);
    canvas.drawPath(t2, stroke);

    canvas.drawLine(Offset(24 * s, 50 * s), Offset(100 * s, 50 * s), stroke);

    canvas.drawCircle(
      Offset(102 * s, 24 * s),
      8 * s,
      Paint()..color = dotColor,
    );
  }

  @override
  bool shouldRepaint(_TatoMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dotColor != dotColor;
}
