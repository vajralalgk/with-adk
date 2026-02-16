import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _smartRepliesEnabled = true;
  bool _friendshipInsightsEnabled = true;
  bool _readReceipts = true;
  bool _lastSeen = true;
  bool _typingIndicator = true;
  bool _autoDownloadMedia = true;
  bool _dataSaver = false;
  bool _biometricLock = false;
  String _chatBackup = 'Weekly';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    'Y',
                    style: TextStyle(
                      fontSize: 28,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Profile',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Tap to edit profile',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile editor coming soon')),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
          const Divider(),
          // AI & Intelligence
          _SectionHeader(title: 'AI & Intelligence', icon: Icons.auto_awesome),
          SwitchListTile(
            title: const Text('Smart Replies'),
            subtitle: const Text('AI-powered reply suggestions in chat'),
            value: _smartRepliesEnabled,
            onChanged: (val) => setState(() => _smartRepliesEnabled = val),
            secondary: const Icon(Icons.smart_toy),
          ),
          SwitchListTile(
            title: const Text('Friendship Insights'),
            subtitle: const Text('AI analysis of relationship patterns'),
            value: _friendshipInsightsEnabled,
            onChanged: (val) => setState(() => _friendshipInsightsEnabled = val),
            secondary: const Icon(Icons.insights),
          ),
          const Divider(),
          // Privacy & Security
          _SectionHeader(title: 'Privacy & Security', icon: Icons.lock),
          SwitchListTile(
            title: const Text('Read Receipts'),
            subtitle: const Text('Let others see when you read messages'),
            value: _readReceipts,
            onChanged: (val) => setState(() => _readReceipts = val),
            secondary: const Icon(Icons.done_all),
          ),
          SwitchListTile(
            title: const Text('Last Seen'),
            subtitle: const Text('Show when you were last active'),
            value: _lastSeen,
            onChanged: (val) => setState(() => _lastSeen = val),
            secondary: const Icon(Icons.access_time),
          ),
          SwitchListTile(
            title: const Text('Typing Indicator'),
            subtitle: const Text('Show when you\'re typing'),
            value: _typingIndicator,
            onChanged: (val) => setState(() => _typingIndicator = val),
            secondary: const Icon(Icons.keyboard),
          ),
          SwitchListTile(
            title: const Text('Biometric Lock'),
            subtitle: const Text('Require fingerprint/face to open app'),
            value: _biometricLock,
            onChanged: (val) => setState(() => _biometricLock = val),
            secondary: const Icon(Icons.fingerprint),
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Contacts'),
            subtitle: const Text('Manage blocked friends'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Blocked contacts management coming soon')),
              );
            },
          ),
          const Divider(),
          // Notifications
          _SectionHeader(title: 'Notifications', icon: Icons.notifications),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive message and event notifications'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            secondary: const Icon(Icons.notifications_active),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Quiet Hours'),
            subtitle: const Text('Mute notifications during set hours'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiet hours settings coming soon')),
              );
            },
          ),
          const Divider(),
          // Data & Storage
          _SectionHeader(title: 'Data & Storage', icon: Icons.storage),
          SwitchListTile(
            title: const Text('Auto-Download Media'),
            subtitle: const Text('Download photos and files automatically'),
            value: _autoDownloadMedia,
            onChanged: (val) => setState(() => _autoDownloadMedia = val),
            secondary: const Icon(Icons.download),
          ),
          SwitchListTile(
            title: const Text('Data Saver'),
            subtitle: const Text('Reduce data usage for media'),
            value: _dataSaver,
            onChanged: (val) => setState(() => _dataSaver = val),
            secondary: const Icon(Icons.data_saver_on),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Chat Backup'),
            subtitle: Text('Backup frequency: $_chatBackup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBackupDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared!')),
              );
            },
          ),
          const Divider(),
          // Integrations
          _SectionHeader(title: 'Integrations', icon: Icons.extension),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar Sync'),
            subtitle: const Text('Sync events with device calendar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendar integration coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contacts),
            title: const Text('Contact Sync'),
            subtitle: const Text('Import contacts from device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact sync coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Cloud Storage'),
            subtitle: const Text('Connect to Google Drive, iCloud, or Dropbox'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cloud storage integration coming soon')),
              );
            },
          ),
          const Divider(),
          // About
          _SectionHeader(title: 'About', icon: Icons.info),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Version'),
            subtitle: const Text('2.0.0 (Future Edition)'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Backup Frequency'),
          children: ['Daily', 'Weekly', 'Monthly', 'Never']
              .map((option) => SimpleDialogOption(
                    onPressed: () {
                      setState(() => _chatBackup = option);
                      Navigator.pop(ctx);
                    },
                    child: Text(option),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
