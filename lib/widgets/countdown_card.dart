import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/countdown_timer_item.dart';

class CountdownCard extends StatelessWidget {
  final CountdownTimerItem timer;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const CountdownCard({
    super.key,
    required this.timer,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = timer.isExpired;
    final isCompleted = timer.isCompleted;

    Color statusColor = theme.colorScheme.primary;
    if (isCompleted) {
      statusColor = Colors.grey;
    } else if (isExpired) {
      statusColor = theme.colorScheme.error;
    } else if (timer.remainingDays <= 2) {
      statusColor = Colors.orange.shade700;
    }

    return Card(
      color: isCompleted
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
          : theme.colorScheme.surfaceContainer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: isExpired && !isCompleted
            ? BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.6), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category chip & action buttons
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : isExpired
                                ? Icons.warning_rounded
                                : Icons.hourglass_top_rounded,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timer.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isCompleted ? Colors.green : theme.colorScheme.outline,
                  ),
                  tooltip: isCompleted ? 'Mark Active' : 'Mark Done',
                  onPressed: onToggleComplete,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error.withValues(alpha: 0.7)),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              timer.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? theme.colorScheme.outline : theme.colorScheme.onSurface,
              ),
            ),
            if (timer.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                timer.notes,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Reverse Countdown Clock Units
            if (!isCompleted && !isExpired)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeUnit(
                    context,
                    timer.remainingDays.toString().padLeft(2, '0'),
                    'DAYS',
                    statusColor,
                  ),
                  _buildSeparator(context),
                  _buildTimeUnit(
                    context,
                    timer.remainingHours.toString().padLeft(2, '0'),
                    'HOURS',
                    statusColor,
                  ),
                  _buildSeparator(context),
                  _buildTimeUnit(
                    context,
                    timer.remainingMinutes.toString().padLeft(2, '0'),
                    'MIN',
                    statusColor,
                  ),
                  _buildSeparator(context),
                  _buildTimeUnit(
                    context,
                    timer.remainingSeconds.toString().padLeft(2, '0'),
                    'SEC',
                    statusColor,
                  ),
                ],
              )
            else if (isExpired && !isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.alarm_on_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Time Expired! Reminder due now.',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.task_alt_rounded, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // Progress Bar and Target Date text
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: isCompleted ? 1.0 : (isExpired ? 1.0 : timer.progressPercentage),
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : (isExpired ? theme.colorScheme.error : statusColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target: ${DateFormat('dd MMM yyyy, hh:mm a').format(timer.targetDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isCompleted && !isExpired)
                  Text(
                    '${(timer.progressPercentage * 100).toInt()}% elapsed',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(BuildContext context, String value, String unit, Color color) {
    final theme = Theme.of(context);
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
