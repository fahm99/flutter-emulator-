// Flutter IDE Mobile - File Tabs Widget

import 'package:flutter/material.dart';
import '../../core/constants/app_design_system.dart';
import '../models/editor_state.dart';

/// File Tabs Widget
/// Displays open file tabs with close buttons and dirty indicators
class FileTabsWidget extends StatelessWidget {
  final List<EditorTabState> tabs;
  final String? activeTabId;
  final Function(String) onTabSelected;
  final Function(String) onTabClosed;

  const FileTabsWidget({
    super.key,
    required this.tabs,
    required this.activeTabId,
    required this.onTabSelected,
    required this.onTabClosed,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return Container(
        height: 36,
        color: AppColors.surfaceContainerLow,
        child: const Center(
          child: Text(
            'No open files',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 36,
      color: AppColors.surfaceContainerLow,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = tab.id == activeTabId;

          return _FileTab(
            tab: tab,
            isActive: isActive,
            onTap: () => onTabSelected(tab.id),
            onClose: () => onTabClosed(tab.id),
          );
        },
      ),
    );
  }
}

class _FileTab extends StatelessWidget {
  final EditorTabState tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _FileTab({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 200,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceContainer : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            right: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File icon
            Icon(
              _getFileIcon(tab.fileName),
              size: 14,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),

            // File name
            Flexible(
              child: Text(
                tab.fileName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Dirty indicator
            if (tab.isDirty)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 4),
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                ),
              ),

            // Close button
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClose,
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.dart')) {
      return Icons.code;
    } else if (fileName.endsWith('.yaml') || fileName.endsWith('.yml')) {
      return Icons.settings;
    } else if (fileName.endsWith('.json')) {
      return Icons.data_object;
    } else if (fileName.endsWith('.md')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }
}

/// Compact File Tab for horizontal scrolling
class CompactFileTab extends StatelessWidget {
  final String fileName;
  final bool isActive;
  final bool isDirty;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const CompactFileTab({
    super.key,
    required this.fileName,
    required this.isActive,
    required this.isDirty,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surfaceContainer : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (isDirty) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClose,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}