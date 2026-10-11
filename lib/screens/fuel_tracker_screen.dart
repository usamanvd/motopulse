import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/fuel_entry.dart';
import '../widgets/add_entry_sheets.dart';

class FuelTrackerScreen extends StatelessWidget {
  const FuelTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final currency = provider.userProfile.currencySymbol;
    final entries = provider.fuelEntries;
    final avgKmL = provider.overallAverageKmL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel & Mileage Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'How Average is calculated',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('Mileage Calculation Formula'),
                  content: const Text(
                    'When you enter your odometer reading at each fuel fill-up, the app calculates:\n\n'
                    '• Distance = Current Odometer - Previous Odometer\n'
                    '• Average = Distance (KM) ÷ Fuel Litres\n'
                    '• Cost per KM = Amount Spent ÷ Distance (KM)\n\n'
                    'The first entry establishes the base odometer baseline; every next entry computes your real bike mileage!',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddFuelBottomSheet(),
          );
        },
        icon: const Icon(Icons.local_gas_station_rounded),
        label: const Text('Add Fuel Entry'),
      ),
      body: entries.isEmpty
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
                    child: Icon(Icons.local_gas_station_rounded, size: 48, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text('No Fuel Entries Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Log your first fuel entry with your current odometer reading to start tracking your bike average.',
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
                        builder: (_) => const AddFuelBottomSheet(),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add First Entry'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                // --- HERO SUMMARY CARD ---
                Card(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.speed_rounded, size: 16, color: theme.colorScheme.onPrimary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'OVERALL MILEAGE',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${entries.length} Fill-ups',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          avgKmL > 0 ? '${avgKmL.toStringAsFixed(1)} KM/L' : 'Calculating...',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          avgKmL > 0
                              ? 'Your bike is averaging ${avgKmL.toStringAsFixed(1)} kilometers per liter.'
                              : 'Add one more fuel log to calculate your exact mileage.',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHeroMetric(
                              context,
                              'Total Spent',
                              '$currency ${provider.totalFuelSpent.toStringAsFixed(0)}',
                              Icons.payments_rounded,
                            ),
                            _buildHeroMetric(
                              context,
                              'Total Fuel',
                              '${provider.totalFuelLiters.toStringAsFixed(1)} L',
                              Icons.opacity_rounded,
                            ),
                            _buildHeroMetric(
                              context,
                              'Current Odometer',
                              '${provider.latestOdometer.toStringAsFixed(0)} KM',
                              Icons.pin_drop_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // History Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fuel Log History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${entries.length} entries',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List of fuel cards
                ...entries.map((entry) => _buildFuelEntryCard(context, entry, currency)),
              ],
            ),
    );
  }

  Widget _buildHeroMetric(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildFuelEntryCard(BuildContext context, FuelEntry entry, String currency) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.local_gas_station_rounded, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.odometerKm.toStringAsFixed(0)} KM',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${DateFormat('dd MMM yyyy, hh:mm a').format(entry.date)} • ${entry.fuelStation.isNotEmpty ? entry.fuelStation : "Fuel Station"}',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$currency ${entry.amountSpent.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Chips / Badges
            Row(
              children: [
                // Liters chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.opacity_rounded, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.liters.toStringAsFixed(2)} Litres',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Distance traveled chip
                if (entry.distanceTraveled != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.indigo),
                        const SizedBox(width: 4),
                        Text(
                          '+${entry.distanceTraveled!.toStringAsFixed(0)} KM',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),

                // Mileage Average Chip
                if (entry.averageKmL != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.averageKmL!.toStringAsFixed(1)} KM/L',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Baseline Log',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                  ),
              ],
            ),

            if (entry.costPerKm != null || entry.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (entry.costPerKm != null)
                    Text(
                      'Cost: $currency ${entry.costPerKm!.toStringAsFixed(2)} / KM',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    )
                  else
                    const SizedBox.shrink(),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: theme.colorScheme.error.withValues(alpha: 0.7)),
                    onPressed: () => provider.deleteFuelEntry(entry.id),
                    tooltip: 'Delete Entry',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
