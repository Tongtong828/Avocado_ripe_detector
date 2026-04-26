import 'dart:math';
import 'package:flutter/material.dart';

class ResultCardOverlay extends StatefulWidget {
  final String label;
  final double confidence;
  final VoidCallback onClose;

  const ResultCardOverlay({
    super.key,
    required this.label,
    required this.confidence,
    required this.onClose,
  });

  @override
  State<ResultCardOverlay> createState() => _ResultCardOverlayState();
}

class _ResultCardOverlayState extends State<ResultCardOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flipController.isAnimating) return;

    if (_flipController.value < 0.5) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  String get _displayLabel {
    switch (widget.label.toLowerCase()) {
      case 'unripe':
        return 'Unripe';
      case 'ready':
        return 'Ready';
      case 'overripe':
        return 'Overripe';
      default:
        return widget.label;
    }
  }

  String get _description {
    switch (widget.label.toLowerCase()) {
      case 'unripe':
        return 'This avocado is still firm and needs more time before eating.';
      case 'ready':
        return 'This avocado looks ready to eat. Great for slicing or serving.';
      case 'overripe':
        return 'This avocado is very soft and best used quickly.';
      default:
        return 'Recognition completed.';
    }
  }

  String get _assetPath {
    switch (widget.label.toLowerCase()) {
      case 'unripe':
        return 'assets/avocado/unripe.png';
      case 'ready':
        return 'assets/avocado/ready.png';
      case 'overripe':
        return 'assets/avocado/overripe.png';
      default:
        return 'assets/avocado/ready.png';
    }
  }

  Color get _accentColor {
    switch (widget.label.toLowerCase()) {
      case 'unripe':
        return const Color(0xFF5FAE4E);
      case 'ready':
        return const Color(0xFF86B94D);
      case 'overripe':
        return const Color(0xFF8A6A4A);
      default:
        return const Color(0xFF6BAF6D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = min(MediaQuery.of(context).size.width * 0.82, 360);
    final double cardHeight =
        min(MediaQuery.of(context).size.height * 0.68, 520);

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.42),
        child: GestureDetector(
          onTap: widget.onClose,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedBuilder(
                      animation: _flipController,
                      builder: (context, child) {
                        final double angle = _flipController.value * pi;
                        final bool showBack = angle < pi / 2;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateY(angle),
                          child: showBack
                              ? _buildBackCard()
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildFrontCard(),
                                ),
                        );
                      },
                    ),
                    Positioned(
                      top: -12,
                      right: -12,
                      child: Material(
                        color: Colors.white,
                        elevation: 6,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: widget.onClose,
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF4C5C47),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return GestureDetector(
      onTap: _toggleFlip,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F5E6),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DiamondPatternPainter(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  children: [
                    const Spacer(),
                    const Text(
                      'Cut open your avocado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF35513A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 18,
                            color: Color(0xFF4B6551),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Click to flip and view the result',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4B6551),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return GestureDetector(
      onTap: _toggleFlip,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  _assetPath,
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  _displayLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _accentColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF4D5A49),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Confidence',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8775),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(widget.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2F3A2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: widget.confidence,
                          backgroundColor: const Color(0xFFE2EADF),
                          valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6EF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFDCE7D8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 18,
                        color: Color(0xFF5D6E56),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tap card to flip back',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5D6E56),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 1.1;

    const double spacing = 26;

    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    for (double x = 0; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}