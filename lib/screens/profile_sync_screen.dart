import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/report_and_settings_dialogs.dart';
import 'vehicle_setup_screen.dart';

class ProfileSyncScreen extends StatelessWidget {
  const ProfileSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final user = provider.userProfile;
    final maint = provider.maintenance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Sync'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          // --- GOOGLE ACCOUNT CARD ---
          Card(
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.displayName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(width: 6),
                                if (user.isLoggedIn)
                                  const Icon(Icons.verified_rounded, size: 18, color: Colors.blue),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: user.isLoggedIn
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.isLoggedIn ? 'Gmail Account Linked' : 'Guest Mode (Offline)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: user.isLoggedIn ? Colors.green.shade800 : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  if (!user.isLoggedIn)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _showGmailSignInDialog(context, provider),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                        label: const Text('Sign In with Google / Gmail', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => provider.signOut(),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Sign Out'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: provider.isSyncing ? null : () => provider.syncWithCloud(),
                            icon: provider.isSyncing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.sync_rounded, size: 18),
                            label: Text(provider.isSyncing ? 'Syncing...' : 'Sync Now'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- CLOUD SYNC DETAILS ---
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_sync_rounded),
                  title: const Text('Cloud Sync Status', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    user.lastSyncedAt != null
                        ? 'Last Synced: ${DateFormat('dd MMM yyyy, hh:mm a').format(user.lastSyncedAt!)}'
                        : 'Never synced. Sign in to backup your logs.',
                  ),
                  trailing: provider.isSyncing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () => provider.syncWithCloud(),
                        ),
                ),
                if (provider.lastSyncMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      provider.lastSyncMessage!,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- BIKE & REMINDER SETTINGS ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Bike & Reminders Preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          ),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.two_wheeler_rounded),
                  title: const Text('Vehicle Name'),
                  trailing: Text(maint.vehicleName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const EditMaintenanceSettingsDialog(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.oil_barrel_rounded),
                  title: const Text('Oil Change Interval'),
                  subtitle: const Text('Reminder triggers at threshold'),
                  trailing: Text('${maint.oilChangeIntervalKm.toStringAsFixed(0)} KM', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const EditMaintenanceSettingsDialog(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.local_gas_station_rounded),
                  title: const Text('Fuel Tank Capacity'),
                  trailing: Text('${maint.fuelTankCapacityLiters} Litres', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const EditMaintenanceSettingsDialog(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_suggest_rounded, color: Colors.teal),
                  title: const Text('Re-run Bike Setup Wizard'),
                  subtitle: const Text('Reconfigure bike model, tank capacity & preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VehicleSetupScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- APP SETTINGS & THEME ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('App & Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          ),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Google Pixel Charcoal Theme'),
                  value: provider.isDarkMode,
                  onChanged: (_) => provider.toggleDarkMode(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_rounded),
                  title: const Text('Design Language'),
                  subtitle: const Text('Material You (Pixel Material 3)'),
                  trailing: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGmailSignInDialog(BuildContext context, AppProvider provider) {
    final emailController = TextEditingController(text: 'usama.ride@gmail.com');
    final nameController = TextEditingController(text: 'Usama Khan');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mail_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Sign In with Gmail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign in with your Google account to sync your bike fuel entries, reminders, and Khaata records to cloud.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Gmail Address',
                prefixIcon: Icon(Icons.email_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () async {
              final email = emailController.text.trim();
              final name = nameController.text.trim();
              if (email.isNotEmpty) {
                await provider.signInWithGoogle(
                  email: email,
                  displayName: name.isNotEmpty ? name : 'Google Rider',
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Welcome, $name! Synced with Google Account.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.login_rounded),
            label: const Text('Sign In & Sync'),
          ),
        ],
      ),
    );
  }
}
