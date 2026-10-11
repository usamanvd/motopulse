import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/motopulse_logo.dart';
import 'vehicle_setup_screen.dart';
import '../main.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  bool _isSigningIn = false;

  final List<Map<String, String>> _availableGoogleAccounts = [
    {
      'name': 'Usama Khan',
      'email': 'usama.ride@gmail.com',
      'initial': 'U',
      'color': '0xFF006B58',
    },
    {
      'name': 'Usama Dev',
      'email': 'usama.dev@gmail.com',
      'initial': 'U',
      'color': '0xFF1A73E8',
    },
  ];

  void _showGoogleAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildGoogleAccountPickerSheet(ctx),
    );
  }

  Widget _buildGoogleAccountPickerSheet(BuildContext sheetContext) {
    final theme = Theme.of(sheetContext);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Google Header
          Row(
            children: [
              _buildGoogleGLogo(24),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose an account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'to continue to MotoPulse',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Google Accounts List
          ..._availableGoogleAccounts.map((acc) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Color(int.parse(acc['color']!)),
                child: Text(
                  acc['initial']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                acc['name']!,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                acc['email']!,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _processGoogleSignIn(acc['name']!, acc['email']!);
              },
            );
          }),

          const Divider(height: 1),

          // Add Another Account Option
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(Icons.person_add_alt_1_rounded, size: 20, color: theme.colorScheme.primary),
            ),
            title: const Text('Add another account', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(sheetContext);
              _showAddAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            _buildGoogleGLogo(22),
            const SizedBox(width: 10),
            const Text('Add Google Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Gmail Address'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final email = emailCtrl.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(ctx);
                _processGoogleSignIn(name.isNotEmpty ? name : 'Google User', email);
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Future<void> _processGoogleSignIn(String name, String email) async {
    setState(() => _isSigningIn = true);

    final provider = Provider.of<AppProvider>(context, listen: false);

    // Show Google Profile fetch and Cloud sync dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGoogleGLogo(40),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Connecting as $name',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fetching profile & enabling Google Cloud Sync...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1600));

    await provider.signInWithGoogle(
      email: email,
      displayName: name,
    );

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loader
      setState(() => _isSigningIn = false);

      // Navigate to setup wizard if not set up, or dashboard
      final target = provider.isSetupCompleted
          ? const MainNavigationShell()
          : const VehicleSetupScreen();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => target),
      );
    }
  }

  Widget _buildGoogleGLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Image.network(
        'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.g_mobiledata_rounded,
          size: size * 0.8,
          color: const Color(0xFF4285F4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Logo & App Name
              const MotoPulseLogo(size: 88),
              const SizedBox(height: 24),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Moto',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Pulse',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                'Welcome! Connect your Google Account for real-time cloud backup & syncing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 2),

              // Feature Highlights Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      context,
                      Icons.cloud_done_rounded,
                      'Google Cloud Sync',
                      'Sync fuel fill-ups and Khaata across your devices',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      context,
                      Icons.speed_rounded,
                      'Smart Fuel Mileage Tracker',
                      'Automatic KM/L calculation with odometer readings',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      context,
                      Icons.oil_barrel_rounded,
                      '1,000 KM & Tuning Reminders',
                      'Configurable oil change and 2-month reverse days alerts',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Google Sign-In Button (Pixel Pill Style)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                  ),
                  onPressed: _isSigningIn ? null : _showGoogleAccountPicker,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGoogleGLogo(24),
                      const SizedBox(width: 14),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Continue as Guest Option
              TextButton(
                onPressed: () {
                  final provider = Provider.of<AppProvider>(context, listen: false);
                  final target = provider.isSetupCompleted
                      ? const MainNavigationShell()
                      : const VehicleSetupScreen();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => target),
                  );
                },
                child: Text(
                  'Skip for now (Use Offline Guest Mode)',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
