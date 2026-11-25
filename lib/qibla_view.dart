import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_compass/flutter_compass.dart';

import 'cities.dart';
import 'prayer_logic.dart';
import 'strings.dart';

class QiblaView extends StatefulWidget {
  final City city;
  final Str s;
  const QiblaView({super.key, required this.city, required this.s});

  @override
  State<QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<QiblaView> {
  StreamSubscription<CompassEvent>? _sub;
  double? _heading;
  double? _accuracy;
  bool _noSensor = false;

  @override
  void initState() {
    super.initState();
    final stream = FlutterCompass.events;
    if (stream == null) {
      _noSensor = true;
    } else {
      _sub = stream.listen((e) {
        if (!mounted) return;
        setState(() {
          _heading = e.heading;
          _accuracy = e.accuracy;
        });
      }, onError: (_) {
        if (mounted) setState(() => _noSensor = true);
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final bearing = qiblaBearing(widget.city);
    final h = _heading;
    final delta = h == null ? null : angleDelta(h, bearing);
    final aligned = delta != null && delta.abs() <= 5;
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            '${s.qiblaBearing}: ${bearing.toStringAsFixed(1)}° ${s.fromNorth}',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: CompassPainter(
                heading: h ?? 0,
                qibla: bearing,
                aligned: aligned,
                color: cs.primary,
                text: cs.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_noSensor || (h == null && _sub == null))
          Text(s.noCompass, textAlign: TextAlign.center)
        else if (h == null)
          const Center(child: CircularProgressIndicator())
        else ...[
          Center(
            child: Text(
              aligned ? s.aligned : s.turn(delta!),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: aligned ? Colors.green : null),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${h.toStringAsFixed(0)}°'
            '${_accuracy != null ? '  ±${_accuracy!.toStringAsFixed(0)}°' : ''}',
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        Text(s.calibrate,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  final double heading;
  final double qibla;
  final bool aligned;
  final Color color;
  final Color text;
  CompassPainter({
    required this.heading,
    required this.qibla,
    required this.aligned,
    required this.color,
    required this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = aligned ? Colors.green : color;
    canvas.drawCircle(c, r, ring);

    // Dial rotates opposite to the heading so N points to true north.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180);
    final tick = Paint()..color = text.withValues(alpha: 0.6);
    for (var i = 0; i < 360; i += 10) {
      final a = i * math.pi / 180;
      final len = i % 90 == 0 ? 14.0 : 7.0;
      canvas.drawLine(
        Offset(math.sin(a) * (r - len), -math.cos(a) * (r - len)),
        Offset(math.sin(a) * r, -math.cos(a) * r),
        tick,
      );
    }
    const labels = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    labels.forEach((deg, l) {
      final a = deg * math.pi / 180;
      final tp = TextPainter(
        text: TextSpan(
            text: l,
            style: TextStyle(
                color: deg == 0 ? Colors.red : text,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        textDirection: TextDirection.ltr,
      )..layout();
      final o = Offset(math.sin(a) * (r - 30), -math.cos(a) * (r - 30));
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(heading * math.pi / 180);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    });
    // Qibla needle (on the rotating dial, at the qibla bearing).
    canvas.rotate(qibla * math.pi / 180);
    final needle = Paint()..color = aligned ? Colors.green : color;
    final path = Path()
      ..moveTo(0, -(r - 50))
      ..lineTo(-12, 0)
      ..lineTo(12, 0)
      ..close();
    canvas.drawPath(path, needle);
    canvas.drawCircle(Offset(0, -(r - 62)), 6, Paint()..color = Colors.white);
    canvas.restore();
    canvas.drawCircle(c, 6, Paint()..color = text);
  }

  @override
  bool shouldRepaint(CompassPainter old) =>
      old.heading != heading || old.qibla != qibla || old.aligned != aligned;
}
