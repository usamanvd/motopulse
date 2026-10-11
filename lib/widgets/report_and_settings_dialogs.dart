import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

// --- EDIT MAINTENANCE SETTINGS DIALOG ---
class EditMaintenanceSettingsDialog extends StatefulWidget {
  const EditMaintenanceSettingsDialog({super.key});

  @override
  State<EditMaintenanceSettingsDialog> createState() => _EditMaintenanceSettingsDialogState();
}

class _EditMaintenanceSettingsDialogState extends State<EditMaintenanceSettingsDialog> {
  late TextEditingController _vehicleController;
  late TextEditingController _regController;
  late TextEditingController _tankController;
  late TextEditingController _odometerController;
  late TextEditingController _oilIntervalController;
  late TextEditingController _tuningIntervalController;

  @override
  void initState() {
    super.initState();
    final maint = Provider.of<AppProvider>(context, listen: false).maintenance;
    _vehicleController = TextEditingController(text: maint.vehicleName);
    _regController = TextEditingController(text: maint.registrationNumber);
    _tankController = TextEditingController(text: maint.fuelTankCapacityLiters.toString());
    _odometerController = TextEditingController(text: maint.currentOdometerKm.toStringAsFixed(0));
    _oilIntervalController = TextEditingController(text: maint.oilChangeIntervalKm.toStringAsFixed(0));
    _tuningIntervalController = TextEditingController(text: maint.tuningIntervalDays.toString());
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _regController.dispose();
    _tankController.dispose();
    _odometerController.dispose();
    _oilIntervalController.dispose();
    _tuningIntervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          const Text('Bike Settings & Intervals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customize your bike details and reminder thresholds (e.g. 1000 KM oil change, 2 months tuning).',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vehicleController,
              decoration: const InputDecoration(
                labelText: 'Bike / Vehicle Name',
                prefixIcon: Icon(Icons.two_wheeler_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _regController,
              decoration: const InputDecoration(
                labelText: 'Registration / Plate No',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tankController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Tank Capacity',
                      prefixIcon: Icon(Icons.local_gas_station_rounded),
                      suffixText: 'L',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Odometer (KM)',
                      prefixIcon: Icon(Icons.speed_rounded),
                      suffixText: 'KM',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _oilIntervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Oil Change Interval',
                helperText: 'Default: 1000 KM (as requested)',
                prefixIcon: Icon(Icons.oil_barrel_rounded),
                suffixText: 'KM',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tuningIntervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tuning Interval (Days)',
                helperText: 'Default: 60 Days (~2 Months)',
                prefixIcon: Icon(Icons.build_rounded),
                suffixText: 'Days',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final vehicle = _vehicleController.text.trim();
            final reg = _regController.text.trim();
            final tank = double.tryParse(_tankController.text.trim()) ?? provider.maintenance.fuelTankCapacityLiters;
            final odo = double.tryParse(_odometerController.text.trim()) ?? provider.maintenance.currentOdometerKm;
            final oilKm = double.tryParse(_oilIntervalController.text.trim()) ?? 1000.0;
            final tuningDays = int.tryParse(_tuningIntervalController.text.trim()) ?? 60;

            await provider.updateMaintenanceSettings(
              vehicleName: vehicle.isNotEmpty ? vehicle : 'My Bike',
              registrationNumber: reg,
              fuelTankCapacityLiters: tank,
              currentOdometerKm: odo,
              oilChangeIntervalKm: oilKm,
              tuningIntervalDays: tuningDays,
            );

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Save Settings'),
        ),
      ],
    );
  }
}

// --- COMPREHENSIVE KHAATA REPORT DIALOG ---
class KhaataReportDialog extends StatelessWidget {
  const KhaataReportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final currency = provider.userProfile.currencySymbol;
    final totalIncome = provider.totalIncome;
    final totalExpense = provider.totalExpense;
    final balance = provider.netBalance;
    final categoryBreakdown = provider.expensesByCategory;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 680),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.assessment_rounded, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Financial Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        Text('Khaata Summary & Breakdown', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main Stat Balance Cards
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text(
                    'NET SAVINGS / BALANCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$currency ${balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: balance >= 0 ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Income / Salary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            '$currency ${totalIncome.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.green),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.black12),
                      Column(
                        children: [
                          const Text('Total Kharcha (Expenses)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            '$currency ${totalExpense.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Expense Breakdown by Category',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // Category breakdown list
            Expanded(
              child: categoryBreakdown.isEmpty
                  ? const Center(child: Text('No expense transactions recorded yet.'))
                  : ListView(
                      children: categoryBreakdown.entries.map((entry) {
                        final percentage = totalExpense > 0 ? (entry.value / totalExpense) : 0.0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  Text(
                                    '$currency ${entry.value.toStringAsFixed(0)} (${(percentage * 100).toStringAsFixed(1)}%)',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  minHeight: 6,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 12),

            // Close button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
