// Flutter IDE Mobile - Error Markers Widget

import 'package:flutter/material.dart';
import '../../core/constants/app_design_system.dart';
import '../theme/editor_theme.dart';
import '../models/editor_state.dart';

/// Error Markers Widget
/// Displays error and warning indicators in the gutter
class ErrorMarkersWidget extends StatelessWidget {
  final List<EditorError> errors;
  final List<EditorWarning> warnings;
  final ScrollController scrollController;
  final int lineHeight;

  const ErrorMarkersWidget({
    super.key,
    required this.errors,
    required this.warnings,
    required this.scrollController,
    this.lineHeight = 20,
  });

  @override
  Widget build(BuildContext context) {
    // Create a map of line numbers to error/warning counts
    final errorLines = <int, int>{};
    final warningLines = <int, int>{};

    for (final error in errors) {
      errorLines[error.line] = (errorLines[error.line] ?? 0) + 1;
    }

    for (final warning in warnings) {
      warningLines[warning.line] = (warningLines[warning.line] ?? 0) + 1;
    }

    return SizedBox(
      width: 16,
      child: ListView.builder(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        itemCount: _getMaxLine(errorLines, warningLines),
        itemExtent: lineHeight.toDouble(),
        itemBuilder: (context, index) {
          final lineNumber = index + 1;
          final hasError = errorLines.containsKey(lineNumber);
          final hasWarning = warningLines.containsKey(lineNumber);

          if (!hasError && !hasWarning) {
            return const SizedBox.shrink();
          }

          return Container(
            width: 16,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _showErrorDetails(context, lineNumber),
              child: Icon(
                hasError ? Icons.error : Icons.warning,
                size: 12,
                color: hasError
                    ? EditorTheme.errorColor
                    : EditorTheme.warningColor,
              ),
            ),
          );
        },
      ),
    );
  }

  int _getMaxLine(Map<int, int> errors, Map<int, int> warnings) {
    final errorMax = errors.keys.isEmpty ? 0 : errors.keys.reduce((a, b) => a > b ? a : b);
    final warningMax = warnings.keys.isEmpty ? 0 : warnings.keys.reduce((a, b) => a > b ? a : b);
    return (errorMax > warningMax ? errorMax : warningMax) + 1;
  }

  void _showErrorDetails(BuildContext context, int lineNumber) {
    final lineErrors = errors.where((e) => e.line == lineNumber).toList();
    final lineWarnings = warnings.where((w) => w.line == lineNumber).toList();

    if (lineErrors.isEmpty && lineWarnings.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => _ErrorDetailsSheet(
        errors: lineErrors,
        warnings: lineWarnings,
        lineNumber: lineNumber,
      ),
    );
  }
}

class _ErrorDetailsSheet extends StatelessWidget {
  final List<EditorError> errors;
  final List<EditorWarning> warnings;
  final int lineNumber;

  const _ErrorDetailsSheet({
    required this.errors,
    required this.warnings,
    required this.lineNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'Line $lineNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Errors
          ...errors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 16,
                      color: EditorTheme.errorColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error.message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          // Warnings
          ...warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 16,
                      color: EditorTheme.warningColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning.message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Inline Error Display Widget
/// Shows errors inline in the editor
class InlineErrorDisplay extends StatelessWidget {
  final List<EditorError> errors;
  final int lineNumber;
  final double lineHeight;

  const InlineErrorDisplay({
    super.key,
    required this.errors,
    required this.lineNumber,
    this.lineHeight = 20,
  });

  @override
  Widget build(BuildContext context) {
    final lineErrors = errors.where((e) => e.line == lineNumber).toList();
    
    if (lineErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: lineHeight.toDouble(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: EditorTheme.errorColor.withOpacity(0.1),
        border: Border(
          left: BorderSide(
            color: EditorTheme.errorColor,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 12,
            color: EditorTheme.errorColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              lineErrors.first.message,
              style: TextStyle(
                fontSize: 11,
                color: EditorTheme.errorColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error Panel Widget
/// Shows all errors in a panel at the bottom
class ErrorPanelWidget extends StatelessWidget {
  final List<EditorError> errors;
  final List<EditorWarning> warnings;
  final Function(int)? onErrorTap;

  const ErrorPanelWidget({
    super.key,
    required this.errors,
    required this.warnings,
    this.onErrorTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = errors.length + warnings.length;

    return Container(
      height: 120,
      color: AppColors.surfaceContainerLow,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Problems',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                if (errors.isNotEmpty)
                  _buildCountBadge(errors.length, EditorTheme.errorColor),
                if (warnings.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  _buildCountBadge(warnings.length, EditorTheme.warningColor),
                ],
                const Spacer(),
                if (totalCount > 0)
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Clear All',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Error List
          Expanded(
            child: totalCount == 0
                ? Center(
                    child: Text(
                      'No problems detected',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: totalCount,
                    itemBuilder: (context, index) {
                      if (index < errors.length) {
                        return _buildErrorItem(errors[index]);
                      }
                      return _buildWarningItem(
                        warnings[index - errors.length],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildErrorItem(EditorError error) {
    return InkWell(
      onTap: onErrorTap != null ? () => onErrorTap!(error.line) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.error,
              size: 14,
              color: EditorTheme.errorColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    error.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Line ${error.line}, Column ${error.column}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(EditorWarning warning) {
    return InkWell(
      onTap: onErrorTap != null ? () => onErrorTap!(warning.line) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              size: 14,
              color: EditorTheme.warningColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warning.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Line ${warning.line}, Column ${warning.column}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}