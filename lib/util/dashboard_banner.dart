import 'package:flutter/material.dart';

class DashboardBanner extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const DashboardBanner({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  double get progress =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);

  int get percentage => (progress * 100).toInt();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.yellow[400],
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.8)
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.task_alt,
                      size: 20,
                      color: isDark ? Colors.amber : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '$completedCount of $totalCount completed ($percentage%)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.amber : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
