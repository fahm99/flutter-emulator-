// Flutter IDE Mobile - Settings Screen

import 'package:flutter/material.dart';
import '../../core/constants/app_design_system.dart';

/// Settings Screen Widget
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _autoSave = true;
  bool _lineNumbers = true;
  bool _highlightCurrentLine = true;
  double _fontSize = 13.0;
  int _tabSize = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSwitchTile(
            title: 'Dark Mode',
            subtitle: 'Use dark theme for the editor',
            value: _darkMode,
            onChanged: (value) => setState(() => _darkMode = value),
          ),
          _buildSliderTile(
            title: 'Font Size',
            value: _fontSize,
            min: 10,
            max: 24,
            onChanged: (value) => setState(() => _fontSize = value),
          ),
          const Divider(),

          // Editor Section
          _buildSectionHeader('Editor'),
          _buildSwitchTile(
            title: 'Auto Save',
            subtitle: 'Automatically save files when editing',
            value: _autoSave,
            onChanged: (value) => setState(() => _autoSave = value),
          ),
          _buildSwitchTile(
            title: 'Line Numbers',
            subtitle: 'Show line numbers in the gutter',
            value: _lineNumbers,
            onChanged: (value) => setState(() => _lineNumbers = value),
          ),
          _buildSwitchTile(
            title: 'Highlight Current Line',
            subtitle: 'Highlight the line where the cursor is',
            value: _highlightCurrentLine,
            onChanged: (value) => setState(() => _highlightCurrentLine = value),
          ),
          _buildDropdownTile(
            title: 'Tab Size',
            value: _tabSize,
            items: const [2, 4, 8],
            onChanged: (value) => setState(() => _tabSize = value ?? 2),
          ),
          const Divider(),

          // Compiler Section
          _buildSectionHeader('Compiler'),
          _buildInfoTile(
            title: 'Server Status',
            subtitle: 'Connected to localhost:3000',
            icon: Icons.cloud_done,
            iconColor: AppColors.terminalSuccess,
          ),
          _buildInfoTile(
            title: 'Flutter SDK',
            subtitle: 'Detected - version 3.x',
            icon: Icons.flutter_dash,
            iconColor: AppColors.primary,
          ),
          const Divider(),

          // Account Section
          _buildSectionHeader('Account'),
          _buildTile(
            title: 'Sign In',
            subtitle: 'Sync your projects across devices',
            icon: Icons.person_outline,
            onTap: () {},
          ),
          _buildTile(
            title: 'GitHub',
            subtitle: 'Connect your GitHub account',
            icon: Icons.code,
            onTap: () {},
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          _buildInfoTile(
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
            icon: Icons.info_outline,
          ),
          _buildTile(
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () {},
          ),
          _buildTile(
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            icon: Icons.description_outlined,
            onTap: () {},
          ),
          _buildTile(
            title: 'Send Feedback',
            subtitle: 'Help us improve Flutter IDE',
            icon: Icons.feedback_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
      trailing: Text(
        '${value.toInt()}px',
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<int>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text('$e spaces')))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurfaceVariant),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.onSurfaceVariant),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}