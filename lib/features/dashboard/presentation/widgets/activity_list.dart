import 'package:flutter/material.dart';
import 'package:j_intranet/core/constants/app_text_styles.dart';
import '../../domain/entities/activity.dart';

class ActivityList extends StatelessWidget {
  final List<Activity> activities;
  const ActivityList({super.key, required this.activities});

  Color _typeColor(String type) {
    switch (type) {
      case 'success':
        return const Color(0xFF10B981);
      case 'danger':
        return const Color(0xFFEF4444);
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'info':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 20),
              const SizedBox(width: 8),
              Text('Actividad reciente', style: AppTextStyles.subtitle),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final a = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _typeColor(a.type).withOpacity(0.15),
                  child: Icon(Icons.circle, color: _typeColor(a.type), size: 12),
                ),
                title: Text(a.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                subtitle: Text(a.description, style: AppTextStyles.small.copyWith(color: Colors.black54)),
                trailing: Text(
                  _formatTime(a.timestamp),
                  style: AppTextStyles.small.copyWith(color: Colors.black45),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chevron_right),
              label: const Text('Ver más'),
            ),
          )
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}