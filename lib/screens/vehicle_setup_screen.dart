import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/motopulse_logo.dart';
import '../main.dart';

class VehicleSetupScreen extends StatefulWidget {
  const VehicleSetupScreen({super.key});

  @override
  State<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends State<VehicleSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _bikeNameCtrl = TextEditingController(text: 'Honda CG 125');
  final _regNumCtrl = TextEditingController(text: 'LEZ-24');
  final _tankCapacityCtrl = TextEditingController(text: '9.2');
  final _odometerCtrl = TextEditingController(text: '12450');
  final _oilIntervalCtrl = TextEditingController(text: '1000');
  final _tuningIntervalCtrl = TextEditingController(text: '60');
  final _salaryCtrl = TextEditingController(text: '85000');
  String _currency = 'Rs.';

  final List<String> _popularBikes = [
    'Honda CG 125',
    'Honda CD 70',
    'Yamaha YBR 125',
    'Suzuki GS 150',
    'Suzuki GR 150',
    'United 70',
  ];

  final List<double> _tankPresets = [9.2, 12.0, 13.0, 14.0, 16.0];

  @override
  void dispose() {
    _bikeNameCtrl.dispose();
    _regNumCtrl.dispose();
    _tankCapacityCtrl.dispose();
    _odometerCtrl.dispose();
    _oilIntervalCtrl.dispose();
    _tuningIntervalCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Setup Your Ride'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // Header Card with Logo
              Center(
                child: Column(
                  children: [
                    const MotoPulseLogo(size: 68),
                    const SizedBox(height: 14),
                    const Text(
                      'Welcome to MotoPulse',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your bike specifications to activate mileage tracking and automated maintenance alerts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SECTION 1: BIKE DETAILS ---
              _buildSectionHeader(theme, Icons.two_wheeler_rounded, 'Bike Specifications'),
              const SizedBox(height: 12),

              Card(
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _bikeNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Bike Model & Make',
                          hintText: 'e.g. Honda CG 125',
                          prefixIcon: Icon(Icons.two_wheeler_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter bike name' : null,
                      ),
                      const SizedBox(height: 12),

                      // Quick Bike Chips
                      const Text(
                        'Popular Models:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _popularBikes.map((bike) {
                          return ActionChip(
                            label: Text(bike, style: const TextStyle(fontSize: 12)),
                            onPressed: () {
                              setState(() {
                                _bikeNameCtrl.text = bike;
                                if (bike.contains('70')) _tankCapacityCtrl.text = '8.5';
                                if (bike.contains('125')) _tankCapacityCtrl.text = '9.2';
                                if (bike.contains('150')) _tankCapacityCtrl.text = '12.0';
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _regNumCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Number Plate / Reg No (Optional)',
                          hintText: 'e.g. LEZ-24-1234',
                          prefixIcon: Icon(Icons.badge_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tank Capacity and Current Odometer Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tankCapacityCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Tank Capacity',
                                hintText: '9.2',
                                suffixText: 'L',
                                prefixIcon: Icon(Icons.local_gas_station_rounded),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Enter capacity';
                                if ((double.tryParse(v) ?? 0) <= 0) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _odometerCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Current Odometer',
                                hintText: '12450',
                                suffixText: 'KM',
                                prefixIcon: Icon(Icons.speed_rounded),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Enter KM';
                                if ((double.tryParse(v) ?? -1) < 0) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tank Presets
                      Row(
                        children: [
                          const Text('Presets: ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ..._tankPresets.map((t) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () => setState(() => _tankCapacityCtrl.text = t.toString()),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('${t}L', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- SECTION 2: REMINDERS THRESHOLDS ---
              _buildSectionHeader(theme, Icons.build_rounded, 'Maintenance Thresholds'),
              const SizedBox(height: 12),

              Card(
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _oilIntervalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Oil Change Interval',
                          helperText: 'Default: 1,000 KM (as requested in specifications)',
                          prefixIcon: Icon(Icons.oil_barrel_rounded),
                          suffixText: 'KM',
                        ),
                        validator: (v) => ((double.tryParse(v ?? '') ?? 0) <= 0) ? 'Enter valid KM' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tuningIntervalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tuning Interval (Days)',
                          helperText: 'Default: 60 Days (~2 Months)',
                          prefixIcon: Icon(Icons.build_circle_rounded),
                          suffixText: 'Days',
                        ),
                        validator: (v) => ((int.tryParse(v ?? '') ?? 0) <= 0) ? 'Enter valid days' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- SECTION 3: KHAATA & SALARY STARTER ---
              _buildSectionHeader(theme, Icons.account_balance_wallet_rounded, 'Khaata Financial Starter (Optional)'),
              const SizedBox(height: 12),

              Card(
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _salaryCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Monthly Salary / Inflow',
                                hintText: '85000',
                                prefixText: '$_currency ',
                                prefixIcon: const Icon(Icons.wallet_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 100,
                            child: DropdownButtonFormField<String>(
                              initialValue: _currency,
                              decoration: const InputDecoration(labelText: 'Currency'),
                              items: ['Rs.', '\$', '€', '£', '₹', 'AED']
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _currency = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Launch Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final name = _bikeNameCtrl.text.trim();
                      final reg = _regNumCtrl.text.trim();
                      final tank = double.parse(_tankCapacityCtrl.text.trim());
                      final odo = double.parse(_odometerCtrl.text.trim());
                      final oilKm = double.parse(_oilIntervalCtrl.text.trim());
                      final tuningDays = int.parse(_tuningIntervalCtrl.text.trim());
                      final salary = double.tryParse(_salaryCtrl.text.trim());

                      await provider.completeVehicleSetup(
                        vehicleName: name,
                        registrationNumber: reg,
                        fuelTankCapacityLiters: tank,
                        currentOdometerKm: odo,
                        oilChangeIntervalKm: oilKm,
                        tuningIntervalDays: tuningDays,
                        initialSalary: salary,
                        currencySymbol: _currency,
                      );

                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text(
                    'Complete Setup & Launch Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
