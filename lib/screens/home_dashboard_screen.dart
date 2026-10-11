import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/pixel_stat_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/add_entry_sheets.dart';
import '../widgets/motopulse_logo.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const HomeDashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final currency = provider.userProfile.currencySymbol;
    final maint = provider.maintenance;
    final user = provider.userProfile;

    final isOilDue = maint.isOilChangeDue;
    final isOilSoon = maint.isOilChangeDueSoon;
    final isTuningDue = maint.isTuningDue;
    final isTuningSoon = maint.isTuningDueSoon;

    final activeCountdowns = provider.countdowns.where((c) => !c.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const MotoPulseLogo(size: 38),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Moto',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Pulse',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${maint.vehicleName}${maint.registrationNumber.isNotEmpty ? " • ${maint.registrationNumber}" : ""} (${maint.fuelTankCapacityLiters}L)',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Cloud Sync Status Pill
          InkWell(
            onTap: () {
              provider.syncWithCloud();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: user.isLoggedIn
                    ? Colors.green.withValues(alpha: 0.15)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    provider.isSyncing
                        ? Icons.sync_rounded
                        : (user.isLoggedIn ? Icons.cloud_done_rounded : Icons.cloud_off_rounded),
                    size: 16,
                    color: user.isLoggedIn ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    provider.isSyncing
                        ? 'Syncing'
                        : (user.isLoggedIn ? 'Gmail Synced' : 'Offline'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: user.isLoggedIn ? Colors.green.shade800 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => provider.toggleDarkMode(),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.syncWithCloud();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgent Alerts if Oil or Tuning is due
              if (isOilDue || isOilSoon || isTuningDue || isTuningSoon) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isOilDue || isTuningDue)
                          ? theme.colorScheme.errorContainer.withValues(alpha: 0.6)
                          : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isOilDue || isTuningDue)
                            ? theme.colorScheme.error.withValues(alpha: 0.5)
                            : Colors.orange.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (isOilDue || isTuningDue) ? Icons.warning_rounded : Icons.notification_important_rounded,
                          color: (isOilDue || isTuningDue) ? theme.colorScheme.error : Colors.orange.shade800,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOilDue
                                    ? 'OIL CHANGE OVERDUE!'
                                    : (isOilSoon
                                        ? 'Oil Change Due Soon'
                                        : (isTuningDue ? 'TUNING OVERDUE!' : 'Tuning Due Soon')),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: (isOilDue || isTuningDue) ? theme.colorScheme.error : Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isOilDue
                                    ? 'Bike chal chuki hai! Oil change krwa len.'
                                    : (isOilSoon
                                        ? '${maint.remainingOilKm.toStringAsFixed(0)} KM bache hain oil change ke liye.'
                                        : (isTuningDue
                                            ? '2 months complete ho chukay hain. Tuning krwa len.'
                                            : '${maint.remainingTuningDays} din bache hain tuning ke liye.')),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => onTabChange(2), // go to reminders tab
                          child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Hero Overview Cards Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: PixelStatCard(
                        title: 'Fuel Average',
                        value: provider.overallAverageKmL > 0
                            ? '${provider.overallAverageKmL.toStringAsFixed(1)} KM/L'
                            : '-- KM/L',
                        subtitle: 'Average',
                        icon: Icons.local_gas_station_rounded,
                        color: theme.colorScheme.primary,
                        onTap: () => onTabChange(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PixelStatCard(
                        title: 'Next Oil Due',
                        value: isOilDue
                            ? 'OVERDUE'
                            : '${maint.remainingOilKm.toStringAsFixed(0)} KM',
                        subtitle: 'Threshold: ${maint.oilChangeIntervalKm.toStringAsFixed(0)} KM',
                        icon: Icons.oil_barrel_rounded,
                        color: isOilDue ? theme.colorScheme.error : (isOilSoon ? Colors.orange : Colors.teal),
                        onTap: () => onTabChange(2),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: PixelStatCard(
                        title: 'Khaata Balance',
                        value: '$currency ${provider.netBalance.toStringAsFixed(0)}',
                        subtitle: 'Savings',
                        icon: Icons.account_balance_wallet_rounded,
                        color: provider.netBalance >= 0 ? Colors.green.shade700 : theme.colorScheme.error,
                        onTap: () => onTabChange(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PixelStatCard(
                        title: 'Tuning In',
                        value: isTuningDue
                            ? 'OVERDUE'
                            : '${maint.remainingTuningDays} Days',
                        subtitle: '2 Mo Interval',
                        icon: Icons.build_circle_rounded,
                        color: isTuningDue ? theme.colorScheme.error : Colors.indigo,
                        onTap: () => onTabChange(2),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Action Buttons (Pixel Style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const AddFuelBottomSheet(),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Fuel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const AddKhaataBottomSheet(),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_rounded),
                        label: const Text('Add Kharcha'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- ACTIVE COUNTDOWN TIMERS (REVERSE DAYS TIMERS) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hourglass_bottom_rounded, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Reverse Days Timers',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => onTabChange(2),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),

              if (activeCountdowns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    color: theme.colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, color: theme.colorScheme.outline),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'No active countdowns. Set a reverse timer for any task (e.g. Chain lubing, Air filter).',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => const AddCountdownBottomSheet(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...activeCountdowns.take(2).map((item) {
                  return CountdownCard(
                    timer: item,
                    onToggleComplete: () => provider.toggleCountdownComplete(item.id),
                    onDelete: () => provider.deleteCountdown(item.id),
                  );
                }),

              const SizedBox(height: 20),

              // --- RECENT FUEL LOGS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_rounded, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Recent Fuel Logs',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => onTabChange(1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),

              if (provider.fuelEntries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text('No fuel entries logged yet. Tap "Add Fuel" to log your first fill-up!'),
                )
              else
                ...provider.fuelEntries.take(3).map((entry) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.local_gas_station_rounded, color: theme.colorScheme.primary),
                      ),
                      title: Text(
                        '${entry.odometerKm.toStringAsFixed(0)} KM (${entry.liters.toStringAsFixed(2)} L)',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${DateFormat('dd MMM yyyy').format(entry.date)} • ${entry.fuelStation.isNotEmpty ? entry.fuelStation : "Petrol"}',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$currency ${entry.amountSpent.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          if (entry.averageKmL != null)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${entry.averageKmL!.toStringAsFixed(1)} KM/L',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),

              // --- RECENT KHAATA TRANSACTIONS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Recent Khaata',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => onTabChange(3),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),

              if (provider.khaataEntries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text('No transactions recorded yet.'),
                )
              else
                ...provider.khaataEntries.take(3).map((entry) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: entry.isIncome
                              ? Colors.green.withValues(alpha: 0.15)
                              : theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          entry.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: entry.isIncome ? Colors.green : theme.colorScheme.error,
                        ),
                      ),
                      title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        '${DateFormat('dd MMM').format(entry.date)} • ${entry.category} (${entry.paymentMethod})',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                      trailing: Text(
                        '${entry.isIncome ? "+" : "-"}$currency ${entry.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: entry.isIncome ? Colors.green.shade700 : theme.colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
