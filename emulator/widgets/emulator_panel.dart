// Flutter IDE Mobile - Emulator Panel Widget

import 'package:flutter/material.dart';
import '../../core/constants/app_design_system.dart';
import '../theme/editor_theme.dart';

/// Emulator Panel Widget
/// Displays a mobile device frame with the running app
class EmulatorPanel extends StatefulWidget {
  const EmulatorPanel({super.key});

  @override
  State<EmulatorPanel> createState() => _EmulatorPanelState();
}

class _EmulatorPanelState extends State<EmulatorPanel> {
  bool _isPortrait = true;
  String _selectedDevice = 'iPhone 14 Pro';
  bool _isRunning = false;
  String _appUrl = '';

  final List<Map<String, dynamic>> _devices = [
    {'name': 'iPhone 14 Pro', 'width': 393, 'height': 852, 'type': 'phone'},
    {'name': 'iPhone 14 Pro Max', 'width': 430, 'height': 932, 'type': 'phone'},
    {'name': 'iPhone SE', 'width': 375, 'height': 667, 'type': 'phone'},
    {'name': 'iPad Pro 12.9"', 'width': 1024, 'height': 1366, 'type': 'tablet'},
    {'name': 'Pixel 7', 'width': 412, 'height': 915, 'type': 'phone'},
    {'name': 'Samsung Galaxy S23', 'width': 360, 'height': 780, 'type': 'phone'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Device Selector Toolbar
        _buildToolbar(),

        // Emulator Area
        Expanded(
          child: Center(
            child: _buildDeviceFrame(),
          ),
        ),

        // Device Controls
        _buildControls(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Device dropdown
          Expanded(
            child: DropdownButton<String>(
              value: _selectedDevice,
              isExpanded: true,
              underline: const SizedBox(),
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device['name'],
                  child: Row(
                    children: [
                      Icon(
                        device['type'] == 'phone'
                            ? Icons.smartphone
                            : Icons.tablet_android,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(device['name']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDevice = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceFrame() {
    final device = _devices.firstWhere((d) => d['name'] == _selectedDevice);
    final width = _isPortrait ? device['width'] : device['height'];
    final height = _isPortrait ? device['height'] : device['width'];
    final scale = _calculateScale(width, height);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width * scale,
      height: height * scale,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(40 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bezel (speaker, camera)
          Container(
            height: 24 * scale,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(40 * scale),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8 * scale,
                  height: 8 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 60 * scale),
                Container(
                  width: 60 * scale,
                  height: 16 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8 * scale),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Screen area
          Expanded(
            child: Container(
              margin: EdgeInsets.all(4 * scale),
              decoration: BoxDecoration(
                color: EditorTheme.editorBackground,
                borderRadius: BorderRadius.circular(32 * scale),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32 * scale),
                child: _isRunning
                    ? _buildWebView()
                    : _buildEmptyScreen(),
              ),
            ),
          ),

          // Bottom bezel (home indicator)
          Container(
            height: 24 * scale,
            margin: EdgeInsets.only(bottom: 4 * scale),
            child: Center(
              child: Container(
                width: 100 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_android,
            size: 48,
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Run your code to see it here',
            style: TextStyle(
              color: AppColors.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isRunning = true;
                _appUrl = 'http://localhost:3001';
              });
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run App'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    // In a real app, this would use webview_flutter package
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Status bar
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '9:41',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.signal_cellular_alt, size: 16),
                    const SizedBox(width: 4),
                    const Icon(Icons.battery_full, size: 16),
                  ],
                ),
              ],
            ),
          ),

          // App content placeholder
          Expanded(
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'Flutter App Running',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rotate button
          _buildControlButton(
            icon: Icons.rotate_right,
            label: 'Rotate',
            onPressed: () {
              setState(() => _isPortrait = !_isPortrait);
            },
          ),

          // Reload button
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reload',
            onPressed: () {
              // Reload the app
            },
          ),

          // Stop button
          _buildControlButton(
            icon: Icons.stop,
            label: 'Stop',
            color: AppColors.error,
            onPressed: () {
              setState(() {
                _isRunning = false;
                _appUrl = '';
              });
            },
          ),

          // Screenshot button
          _buildControlButton(
            icon: Icons.screenshot,
            label: 'Screenshot',
            onPressed: () {
              // Take screenshot
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color ?? AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateScale(double width, double height) {
    // Calculate scale to fit the screen
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    final maxHeight = (MediaQuery.of(context).size.height - 200) * 0.8;

    final scaleX = maxWidth / width;
    final scaleY = maxHeight / height;

    return scaleX < scaleY ? scaleX : scaleY;
  }
}