import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../constants.dart';

class MarqueeTicker extends StatelessWidget {
  final String text;
  const MarqueeTicker({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: cNavy,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 6),
            child: Icon(Icons.campaign, color: cGold, size: 14),
          ),
          Expanded(
            child: Marquee(
              text: '$text    •    $text',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              scrollAxis: Axis.horizontal,
              velocity: 40,
              blankSpace: 60,
              fadingEdgeStartFraction: 0.05,
              fadingEdgeEndFraction: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
