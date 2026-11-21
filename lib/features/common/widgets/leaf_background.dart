import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class LeafBackground extends StatelessWidget {
  final Widget child;

  const LeafBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.creamBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Elegant Decorative Leaf/Botanical Watermark at bottom (Excluded from semantics)
          Positioned(
            bottom: -40,
            right: -40,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.eco_rounded,
                  size: 260,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
          ),

          // Top botanical watermark (Excluded from semantics)
          Positioned(
            top: -20,
            left: -30,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.spa_rounded,
                  size: 180,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
          ),

          // Main content
          child,
        ],
      ),
    );
  }
}


