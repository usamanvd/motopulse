import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_settings.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceSettings maintenance;
  final VoidCallback onLogOilChange;
  final VoidCallback onLogTuning;
  final VoidCallback onEditThresholds;

  const MaintenanceCard({
    super.key,
    required this.maintenance,
    required this.onLogOilChange,
    required this.onLogTuning,
    required this.onEditThresholds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Oil Change math
    final remainingOilKm = maintenance.remainingOilKm;
    final isOilDue = maintenance.isOilChangeDue;
    final isOilSoon = maintenance.isOilChangeDueSoon;
    final oilProgress = (maintenance.kmSinceLastOilChange / maintenance.oilChangeIntervalKm).clamp(0.0, 1.0);

    Color oilColor = theme.colorScheme.primary;
    if (isOilDue) {
      oilColor = theme.colorScheme.error;
    } else if (isOilSoon) {
      oilColor = Colors.orange.shade800;
    }

    // Tuning math
    final remainingTuningDays = maintenance.remainingTuningDays;
    final isTuningDue = maintenance.isTuningDue;
    final isTuningSoon = maintenance.isTuningDueSoon;
    final daysPassed = DateTime.now().difference(maintenance.lastTuningDate).inDays;
    final tuningProgress = (daysPassed / maintenance.tuningIntervalDays).clamp(0.0, 1.0);

    Color tuningColor = theme.colorScheme.primary;
    if (isTuningDue) {
      tuningColor = theme.colorScheme.error;
    } else if (isTuningSoon) {
      tuningColor = Colors.orange.shade800;
    }

    return Column(
      children: [
        // --- 1. OIL CHANGE CARD ---
        Card(
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: isOilDue
                ? BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.7), width: 1.5)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: oilColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.oil_barrel_rounded, color: oilColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Oil Change Reminder',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Every ${maintenance.oilChangeIntervalKm.toStringAsFixed(0)} KM',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      tooltip: 'Change KM Threshold',
                      onPressed: onEditThresholds,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status message
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: oilColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOilDue
                            ? Icons.error_rounded
                            : (isOilSoon ? Icons.warning_amber_rounded : Icons.check_circle_rounded),
                        color: oilColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isOilDue
                              ? 'Oil Change Overdue by ${(maintenance.kmSinceLastOilChange - maintenance.oilChangeIntervalKm).toStringAsFixed(0)} KM!'
                              : (isOilSoon
                                  ? 'Oil change due soon! Only ${remainingOilKm.toStringAsFixed(0)} KM remaining.'
                                  : '${remainingOilKm.toStringAsFixed(0)} KM remaining until next oil change.'),
                          style: TextStyle(
                            color: oilColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: oilProgress,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(oilColor),
                  ),
                ),
                const SizedBox(height: 10),

                // Reading numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Driven: ${maintenance.kmSinceLastOilChange.toStringAsFixed(0)} KM',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Limit: ${maintenance.oilChangeIntervalKm.toStringAsFixed(0)} KM',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Button: Done Oil Change
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: onLogOilChange,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Log Oil Change Done (Reset KM)'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // --- 2. TUNING REMINDER CARD ---
        Card(
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: isTuningDue
                ? BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.7), width: 1.5)
                : BorderSide.none,
          ),
          child: childTuningCard(
            context,
            theme,
            tuningColor,
            isTuningDue,
            isTuningSoon,
            remainingTuningDays,
            tuningProgress,
          ),
        ),
      ],
    );
  }

  Widget childTuningCard(
    BuildContext context,
    ThemeData theme,
    Color tuningColor,
    bool isTuningDue,
    bool isTuningSoon,
    int remainingTuningDays,
    double tuningProgress,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tuningColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.build_rounded, color: tuningColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bike Tuning Reminder',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Every ${maintenance.tuningIntervalDays} days (~2 Months)',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 20),
                tooltip: 'Change Tuning Interval',
                onPressed: onEditThresholds,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: tuningColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  isTuningDue
                      ? Icons.error_rounded
                      : (isTuningSoon ? Icons.warning_amber_rounded : Icons.event_available_rounded),
                  color: tuningColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTuningDue
                        ? 'Tuning Overdue by ${remainingTuningDays.abs()} days!'
                        : (isTuningSoon
                            ? 'Tuning due soon in $remainingTuningDays days!'
                            : '$remainingTuningDays days remaining until tuning.'),
                    style: TextStyle(
                      color: tuningColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: tuningProgress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(tuningColor),
            ),
          ),
          const SizedBox(height: 10),

          // Last tuning vs Next tuning dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last: ${DateFormat('dd MMM yyyy').format(maintenance.lastTuningDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Due: ${DateFormat('dd MMM yyyy').format(maintenance.nextTuningDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Button: Done Tuning
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onLogTuning,
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Log Tuning Done (Reset to Today)'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
