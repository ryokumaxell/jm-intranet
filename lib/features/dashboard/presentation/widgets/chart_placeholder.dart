import 'package:flutter/material.dart';
import 'package:j_intranet/core/constants/app_text_styles.dart';

class ChartPlaceholder extends StatelessWidget {
  final String title;
  const ChartPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 260,
        child: Center(
          child: Text('$title (placeholder)', style: AppTextStyles.subtitle),
        ),
      ),
    );
  }
}