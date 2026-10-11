import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/add_entry_sheets.dart';
import '../widgets/report_and_settings_dialogs.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final maint = provider.maintenance;
    final countdowns = provider.countdowns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance & Timers'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.build_rounded), text: 'Bike Maintenance'),
            Tab(icon: Icon(Icons.hourglass_top_rounded), text: 'Reverse Timers'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddCountdownBottomSheet(),
          );
        },
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text('Set Reverse Timer'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: BIKE MAINTENANCE (OIL CHANGE 1000 KM & TUNING 2 MONTHS)
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              MaintenanceCard(
                maintenance: maint,
                onLogOilChange: () => _showLogOilChangeDialog(context, provider),
                onLogTuning: () => _showLogTuningDialog(context, provider),
                onEditThresholds: () {
                  showDialog(
                    context: context,
                    builder: (_) => const EditMaintenanceSettingsDialog(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Settings banner
              Card(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: const Text('Configure Interval Limits', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Change default 1000 KM oil change or 2-month tuning interval'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const EditMaintenanceSettingsDialog(),
                    );
                  },
                ),
              ),
            ],
          ),

          // TAB 2: CUSTOM REVERSE DAYS TIMERS
          countdowns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.timer_outlined, size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 18),
                      const Text('No Reverse Countdown Timers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Add a reverse days timer for any bike or personal task. It counts down days, hours, and minutes live!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const AddCountdownBottomSheet(),
                          );
                        },
                        icon: const Icon(Icons.alarm_add_rounded),
                        label: const Text('Create Reverse Timer'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'Active Reverse Countdown Timers (${countdowns.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    ...countdowns.map((item) {
                      return CountdownCard(
                        timer: item,
                        onToggleComplete: () => provider.toggleCountdownComplete(item.id),
                        onDelete: () => provider.deleteCountdown(item.id),
                      );
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  void _showLogOilChangeDialog(BuildContext context, AppProvider provider) {
    final costController = TextEditingController(text: '1200');
    final notesController = TextEditingController(text: 'Havoline / ZIC Engine Oil');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.oil_barrel_rounded, color: Colors.teal),
            SizedBox(width: 10),
            Text('Log Oil Change'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resetting oil change cycle at current odometer: ${provider.latestOdometer.toStringAsFixed(0)} KM.\n\n'
              'Optionally enter oil cost to record it automatically in Khaata:',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Oil Cost (${provider.userProfile.currencySymbol})',
                prefixText: '${provider.userProfile.currencySymbol} ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Brand / Grade',
                hintText: 'e.g. Havoline 20W-50',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final cost = double.tryParse(costController.text.trim()) ?? 0.0;
              provider.logOilChangeDone(cost: cost, notes: notesController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Oil change cycle reset and logged in Khaata!')),
              );
            },
            child: const Text('Confirm Oil Change'),
          ),
        ],
      ),
    );
  }

  void _showLogTuningDialog(BuildContext context, AppProvider provider) {
    final costController = TextEditingController(text: '800');
    final notesController = TextEditingController(text: 'Bike full tuning & service');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.build_rounded, color: Colors.indigo),
            SizedBox(width: 10),
            Text('Log Bike Tuning Done'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resetting tuning reminder to today. Next tuning will be in 2 months (60 days).\n\n'
              'Optionally enter tuning charges to record in Khaata:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tuning Cost (${provider.userProfile.currencySymbol})',
                prefixText: '${provider.userProfile.currencySymbol} ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Service Notes',
                hintText: 'e.g. Carburetor cleaning, tappet tuning, plug check',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final cost = double.tryParse(costController.text.trim()) ?? 0.0;
              provider.logTuningDone(cost: cost, notes: notesController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tuning logged! Next reminder scheduled in 2 months.')),
              );
            },
            child: const Text('Confirm Tuning'),
          ),
        ],
      ),
    );
  }
}
