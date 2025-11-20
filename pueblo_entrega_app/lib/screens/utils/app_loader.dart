import 'package:flutter/material.dart';

void showAppLoader(BuildContext context, {String text = "Cargando..."}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.white,
    builder: (_) => _FullScreenLoader(text: text),
  );
}

void hideAppLoader(BuildContext context) {
  try {
    Navigator.of(context, rootNavigator: true).pop();
  } catch (_) {}
}

class _FullScreenLoader extends StatefulWidget {
  final String text;

  const _FullScreenLoader({required this.text});

  @override
  State<_FullScreenLoader> createState() => _FullScreenLoaderState();
}

class _FullScreenLoaderState extends State<_FullScreenLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _controller,
            child: CustomPaint(
              painter: _ElegantCirclePainter(color: Colors.green.shade800),
              size: const Size(80, 80),
            ),
          ),
          const SizedBox(height: 22),

          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }
}

class _ElegantCirclePainter extends CustomPainter {
  final Color color;

  _ElegantCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final rect = Offset.zero & size;

    final bgPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Círculo
    canvas.drawArc(rect, 0, 6.3, false, bgPaint);

    // Arco
    canvas.drawArc(rect, 0, 3.5, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Widget appLoaderWidget({String text = "Cargando..."}) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    color: Colors.white,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation(Colors.green.shade800),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
