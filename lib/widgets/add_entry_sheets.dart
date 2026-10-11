import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/khaata_entry.dart';

class AddFuelBottomSheet extends StatefulWidget {
  const AddFuelBottomSheet({super.key});

  @override
  State<AddFuelBottomSheet> createState() => _AddFuelBottomSheetState();
}

class _AddFuelBottomSheetState extends State<AddFuelBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _amountController = TextEditingController();
  final _litersController = TextEditingController();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _addToKhaata = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final lastOdo = provider.latestOdometer;
    if (lastOdo > 0) {
      _odometerController.text = (lastOdo + 200).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _amountController.dispose();
    _litersController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final currency = provider.userProfile.currencySymbol;
    final lastOdo = provider.latestOdometer;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.local_gas_station_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add Fuel Entry',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Picker Tile
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(_selectedDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Odometer Reading Input
              TextFormField(
                controller: _odometerController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Current Odometer Reading (KM)',
                  hintText: 'e.g. 12650',
                  prefixIcon: const Icon(Icons.speed_rounded),
                  suffixText: 'KM',
                  helperText: lastOdo > 0 ? 'Last recorded reading: ${lastOdo.toStringAsFixed(0)} KM' : null,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter odometer reading';
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) return 'Enter valid KM';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount and Liters Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount Spent',
                        hintText: 'e.g. 1500',
                        prefixText: '$currency ',
                        prefixIcon: const Icon(Icons.payments_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter amount';
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal <= 0) return 'Invalid';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _litersController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Fuel Volume',
                        hintText: 'e.g. 5.25',
                        suffixText: 'L',
                        prefixIcon: Icon(Icons.opacity_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter liters';
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal <= 0) return 'Invalid';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),

              // Live Rate Calculation preview if amount and liters entered
              if (_amountController.text.isNotEmpty && _litersController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Builder(
                  builder: (_) {
                    final a = double.tryParse(_amountController.text) ?? 0;
                    final l = double.tryParse(_litersController.text) ?? 0;
                    if (a > 0 && l > 0) {
                      final rate = a / l;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Estimated Fuel Rate: $currency ${rate.toStringAsFixed(2)} / Litre',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Station / Pump
              TextFormField(
                controller: _stationController,
                decoration: const InputDecoration(
                  labelText: 'Fuel Station (Optional)',
                  hintText: 'e.g. Shell, Total Parco, PSO',
                  prefixIcon: Icon(Icons.place_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Station chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['PSO', 'Shell', 'Total Parco', 'Attock', 'Hascol'].map((pump) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(pump),
                        onPressed: () {
                          _stationController.text = pump;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Khaata Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _addToKhaata,
                title: const Text('Add to Khaata automatically', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Creates an expense entry in your personal ledger'),
                onChanged: (val) => setState(() => _addToKhaata = val),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final odo = double.parse(_odometerController.text.trim());
                      final amt = double.parse(_amountController.text.trim());
                      final lit = double.parse(_litersController.text.trim());

                      await provider.addFuelEntry(
                        date: _selectedDate,
                        odometerKm: odo,
                        amountSpent: amt,
                        liters: lit,
                        fuelStation: _stationController.text.trim(),
                        notes: _notesController.text.trim(),
                        addToKhaata: _addToKhaata,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white),
                                const SizedBox(width: 10),
                                Text('Fuel entry logged at ${odo.toStringAsFixed(0)} KM!'),
                              ],
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save Fuel Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ADD KHAATA BOTTOM SHEET (SALARY / INCOME / EXPENSE) ---
class AddKhaataBottomSheet extends StatefulWidget {
  const AddKhaataBottomSheet({super.key});

  @override
  State<AddKhaataBottomSheet> createState() => _AddKhaataBottomSheetState();
}

class _AddKhaataBottomSheetState extends State<AddKhaataBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  KhaataType _type = KhaataType.expense;
  String _category = 'Fuel & Bike';
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'Fuel & Bike',
    'Maintenance',
    'Food & Dining',
    'Grocery',
    'Bills',
    'Shopping',
    'Medical',
    'Others',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Side Gig / Freelance',
    'Business',
    'Bonus',
    'Received / Loan',
    'Other Income',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final currency = provider.userProfile.currencySymbol;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _type == KhaataType.income ? 'Log Salary / Income' : 'Log Expense',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Segmented Button: Income vs Expense
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<KhaataType>(
                  segments: const [
                    ButtonSegment(
                      value: KhaataType.expense,
                      label: Text('Kharcha (Expense)'),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                    ButtonSegment(
                      value: KhaataType.income,
                      label: Text('Salary / Income'),
                      icon: Icon(Icons.arrow_downward_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (set) {
                    setState(() {
                      _type = set.first;
                      _category = _type == KhaataType.income ? 'Salary' : 'Fuel & Bike';
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: 'Amount ($currency)',
                  hintText: '0.00',
                  prefixText: '$currency ',
                  prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  prefixIcon: Icon(
                    _type == KhaataType.income ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                    color: _type == KhaataType.income ? Colors.green : theme.colorScheme.error,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount';
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Title / Description Input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _type == KhaataType.income ? 'Income Source / Title' : 'Expense Title',
                  hintText: _type == KhaataType.income ? 'e.g. October Monthly Salary' : 'e.g. Bike Petrol / Groceries',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter title';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_type == KhaataType.income ? _incomeCategories : _expenseCategories).map((cat) {
                  final isSelected = _category == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _category = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Payment Method & Date Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _paymentMethod,
                      decoration: const InputDecoration(labelText: 'Payment Method'),
                      items: ['Cash', 'Bank Transfer', 'EasyPaisa', 'JazzCash', 'Card']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMethod = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(
                          DateFormat('dd MMM').format(_selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _type == KhaataType.income ? Colors.green.shade700 : theme.colorScheme.primary,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final amt = double.parse(_amountController.text.trim());
                      await provider.addKhaataEntry(
                        title: _titleController.text.trim(),
                        amount: amt,
                        type: _type,
                        category: _category,
                        date: _selectedDate,
                        paymentMethod: _paymentMethod,
                        notes: _notesController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(
                    _type == KhaataType.income ? 'Save Salary / Income' : 'Save Expense',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ADD COUNTDOWN TIMER BOTTOM SHEET (REVERSE DAYS TIMER) ---
class AddCountdownBottomSheet extends StatefulWidget {
  const AddCountdownBottomSheet({super.key});

  @override
  State<AddCountdownBottomSheet> createState() => _AddCountdownBottomSheetState();
}

class _AddCountdownBottomSheetState extends State<AddCountdownBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _targetDate = DateTime.now().add(const Duration(days: 7));
  String _category = 'Bike';

  final List<String> _categories = ['Bike', 'Maintenance', 'Personal', 'Bills', 'Work'];

  void _addDays(int days) {
    setState(() {
      _targetDate = DateTime.now().add(Duration(days: days));
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.timer_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Set Countdown Timer',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task / Reminder Name',
                  hintText: 'e.g. Chain Lubing, Air Filter, Insurance, etc.',
                  prefixIcon: Icon(Icons.alarm_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter reminder title';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quick Presets chips
              const Text('Quick Time Presets:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(label: const Text('+3 Days'), onPressed: () => _addDays(3)),
                  ActionChip(label: const Text('+7 Days (1 Week)'), onPressed: () => _addDays(7)),
                  ActionChip(label: const Text('+15 Days'), onPressed: () => _addDays(15)),
                  ActionChip(label: const Text('+30 Days (1 Mo)'), onPressed: () => _addDays(30)),
                  ActionChip(label: const Text('+60 Days (2 Mo)'), onPressed: () => _addDays(60)),
                ],
              ),
              const SizedBox(height: 16),

              // Target Date & Time Tile
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (pickedDate != null && context.mounted) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_targetDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _targetDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target Date & Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            DateFormat('EEEE, dd MMM yyyy - hh:mm a').format(_targetDate),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selector
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _category == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _category = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await provider.addCountdown(
                        title: _titleController.text.trim(),
                        category: _category,
                        targetDate: _targetDate,
                        notes: _notesController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Start Reverse Countdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
