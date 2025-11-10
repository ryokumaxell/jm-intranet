import 'package:flutter/material.dart';
import 'package:j_intranet/core/constants/app_colors.dart';
import 'package:j_intranet/core/constants/app_text_styles.dart';

class SummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor = AppColors.info,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        elevation: _hovered ? 6 : 2,
        color: Colors.white,
        shadowColor: Colors.black26,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(widget.icon, color: widget.accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(widget.title, style: AppTextStyles.subtitle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      style: AppTextStyles.small.copyWith(color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}