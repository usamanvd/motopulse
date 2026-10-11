import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/khaata_entry.dart';
import '../widgets/add_entry_sheets.dart';
import '../widgets/report_and_settings_dialogs.dart';

class KhaataScreen extends StatefulWidget {
  const KhaataScreen({super.key});

  @override
  State<KhaataScreen> createState() => _KhaataScreenState();
}

class _KhaataScreenState extends State<KhaataScreen> {
  String _selectedFilter = 'All'; // 'All', 'Income', 'Expense'
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final currency = provider.userProfile.currencySymbol;
    final totalIncome = provider.totalIncome;
    final totalExpense = provider.totalExpense;
    final balance = provider.netBalance;

    // Filter transactions
    var entries = provider.khaataEntries;
    if (_selectedFilter == 'Income') {
      entries = entries.where((e) => e.isIncome).toList();
    } else if (_selectedFilter == 'Expense') {
      entries = entries.where((e) => e.isExpense).toList();
    }
    if (_categoryFilter != null) {
      entries = entries.where((e) => e.category == _categoryFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khaata Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_rounded),
            tooltip: 'View Full Report',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const KhaataReportDialog(),
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
            builder: (_) => const AddKhaataBottomSheet(),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Entry'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          // --- HERO BALANCE & SALARY CARD ---
          Card(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NET SAVINGS / BALANCE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const KhaataReportDialog(),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pie_chart_rounded, size: 14),
                            SizedBox(width: 4),
                            Text('Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$currency ${balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: balance >= 0 ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.error,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.green),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Salary / Inflow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                Text(
                                  '$currency ${totalIncome.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(height: 34, width: 1, color: Colors.black12),
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_upward_rounded, size: 16, color: theme.colorScheme.error),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Kharcha', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                Text(
                                  '$currency ${totalExpense.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.colorScheme.error),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter Segmented Buttons (All, Kharcha, Salary)
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'All', label: Text('All')),
                ButtonSegment(value: 'Expense', label: Text('Kharcha')),
                ButtonSegment(value: 'Income', label: Text('Salary / Income')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (set) {
                setState(() => _selectedFilter = set.first);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Categories'),
                  selected: _categoryFilter == null,
                  onSelected: (sel) {
                    setState(() => _categoryFilter = null);
                  },
                ),
                const SizedBox(width: 8),
                ...['Fuel & Bike', 'Maintenance', 'Salary', 'Food & Dining', 'Grocery', 'Bills', 'Shopping'].map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: _categoryFilter == cat,
                      onSelected: (sel) {
                        setState(() => _categoryFilter = sel ? cat : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions (${entries.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              if (_categoryFilter != null || _selectedFilter != 'All')
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'All';
                      _categoryFilter = null;
                    });
                  },
                  child: const Text('Clear Filters'),
                ),
            ],
          ),

          const SizedBox(height: 8),

          if (entries.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('No transactions match the selected filter.'),
            )
          else
            ...entries.map((entry) => _buildTransactionCard(context, entry, currency, theme)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    KhaataEntry entry,
    String currency,
    ThemeData theme,
  ) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    IconData getCategoryIcon(String cat) {
      switch (cat.toLowerCase()) {
        case 'salary':
          return Icons.wallet_rounded;
        case 'fuel & bike':
          return Icons.two_wheeler_rounded;
        case 'maintenance':
          return Icons.build_rounded;
        case 'grocery':
          return Icons.shopping_basket_rounded;
        case 'food & dining':
          return Icons.restaurant_rounded;
        case 'bills':
          return Icons.receipt_rounded;
        case 'shopping':
          return Icons.shopping_bag_rounded;
        default:
          return Icons.category_rounded;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: entry.isIncome
                ? Colors.green.withValues(alpha: 0.15)
                : theme.colorScheme.errorContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            getCategoryIcon(entry.category),
            color: entry.isIncome ? Colors.green : theme.colorScheme.error,
            size: 22,
          ),
        ),
        title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${DateFormat('dd MMM yyyy').format(entry.date)} • ${entry.category} (${entry.paymentMethod})',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                entry.notes,
                style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.isIncome ? "+" : "-"}$currency ${entry.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: entry.isIncome ? Colors.green.shade700 : theme.colorScheme.error,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 18, color: theme.colorScheme.outline),
              onPressed: () => provider.deleteKhaataEntry(entry.id),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
