import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/fuel_tracker_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/khaata_screen.dart';
import 'screens/profile_sync_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const RideKhaataApp(),
    ),
  );
}

class RideKhaataApp extends StatelessWidget {
  const RideKhaataApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'MotoPulse',
      debugShowCheckedModeBanner: false,
      themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: const SplashScreen(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    if (provider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.two_wheeler_rounded, size: 48, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Loading Ride Khaata...', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    final screens = [
      HomeDashboardScreen(onTabChange: _onTabChange),
      const FuelTrackerScreen(),
      const RemindersScreen(),
      const KhaataScreen(),
      const ProfileSyncScreen(),
    ];

    // Notification badge logic
    final maint = provider.maintenance;
    final hasReminderBadge = maint.isOilChangeDue || maint.isOilChangeDueSoon || maint.isTuningDue || maint.isTuningDueSoon;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChange,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_gas_station_outlined),
            selectedIcon: Icon(Icons.local_gas_station_rounded),
            label: 'Fuel Avg',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: hasReminderBadge,
              backgroundColor: (maint.isOilChangeDue || maint.isTuningDue) ? Colors.red : Colors.orange,
              child: const Icon(Icons.build_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: hasReminderBadge,
              backgroundColor: (maint.isOilChangeDue || maint.isTuningDue) ? Colors.red : Colors.orange,
              child: const Icon(Icons.build_rounded),
            ),
            label: 'Reminders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Khaata',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
