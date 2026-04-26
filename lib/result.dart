import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String label;
  final double confidence;

  const ResultCard({
    super.key,
    required this.label,
    required this.confidence,
  });

  Map<String, dynamic> _getConfig() {
    switch (label) {
      case 'unripe':
        return {
          'title': 'Unripe',
          'subtitle': 'Not ready yet',
          'advice': 'Leave it for a few more days',
          'asset': 'assets/avocado/unripe.png',
          'color': const Color(0xFFF2EFA7),
        };
      case 'ready':
        return {
          'title': 'Ready',
          'subtitle': 'Perfect to eat',
          'advice': 'Best time to enjoy',
          'asset': 'assets/avocado/ready.png',
          'color': const Color(0xFFCFEFBE),
        };
      case 'overripe':
        return {
          'title': 'Overripe',
          'subtitle': 'Use soon',
          'advice': 'Best for immediate use',
          'asset': 'assets/avocado/overripe.png',
          'color': const Color(0xFFE6D0A8),
        };
      default:
        return {
          'title': 'Unknown',
          'subtitle': 'No result',
          'advice': 'Try again',
          'asset': 'assets/avocado/ready.png',
          'color': const Color(0xFFEAEAEA),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config['color'] as Color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x1A000000),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            config['asset'] as String,
            width: 110,
            height: 110,
          ),
          const SizedBox(height: 14),
          Text(
            config['title'] as String,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2A1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            config['subtitle'] as String,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF465346),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2B3B2B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            config['advice'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF465346),
            ),
          ),
        ],
      ),
    );
  }
}