// Flutter IDE Mobile - Line Numbers Widget

import 'package:flutter/material.dart';
import '../../core/constants/app_design_system.dart';
import '../theme/editor_theme.dart';

/// Line Numbers Widget
/// Displays line numbers synchronized with editor scroll
class LineNumbersWidget extends StatelessWidget {
  final int lineCount;
  final int currentLine;
  final ScrollController scrollController;
  final int lineHeight;

  const LineNumbersWidget({
    super.key,
    required this.lineCount,
    required this.currentLine,
    required this.scrollController,
    this.lineHeight = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      color: EditorTheme.editorLineNumberBackground,
      child: ListView.builder(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        itemCount: lineCount,
        itemExtent: lineHeight.toDouble(),
        itemBuilder: (context, index) {
          final lineNumber = index + 1;
          final isCurrentLine = lineNumber == currentLine;

          return Container(
            height: lineHeight.toDouble(),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 8),
            color: isCurrentLine
                ? EditorTheme.editorCurrentLine.withOpacity(0.3)
                : Colors.transparent,
            child: Text(
              '$lineNumber',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                color: isCurrentLine
                    ? AppColors.onSurface
                    : EditorTheme.editorLineNumber,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
          );
        },
      ),
    );
  }
}

/// Animated Line Numbers Widget
/// Uses explicit animation for smoother performance
class AnimatedLineNumbersWidget extends StatefulWidget {
  final int lineCount;
  final int currentLine;
  final ScrollController scrollController;
  final int lineHeight;

  const AnimatedLineNumbersWidget({
    super.key,
    required this.lineCount,
    required this.currentLine,
    required this.scrollController,
    this.lineHeight = 20,
  });

  @override
  State<AnimatedLineNumbersWidget> createState() => 
      _AnimatedLineNumbersWidgetState();
}

class _AnimatedLineNumbersWidgetState extends State<AnimatedLineNumbersWidget> {
  int _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Only rebuild if scrolled significantly
    final currentOffset = widget.scrollController.offset.toInt();
    if ((currentOffset - _lastScrollOffset).abs() > widget.lineHeight) {
      _lastScrollOffset = currentOffset;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate visible range for lazy rendering
    final scrollOffset = widget.scrollController.hasClients
        ? widget.scrollController.offset.toInt()
        : 0;
    
    final startLine = (scrollOffset / widget.lineHeight).floor();
    final visibleLines = 50; // Approximate visible lines
    final endLine = startLine + visibleLines;

    return Container(
      width: 48,
      color: EditorTheme.editorLineNumberBackground,
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Only render visible lines + buffer
                if (index < startLine - 5 || index > endLine + 5) {
                  return SizedBox(height: widget.lineHeight.toDouble());
                }

                final lineNumber = index + 1;
                final isCurrentLine = lineNumber == widget.currentLine;

                return Container(
                  height: widget.lineHeight.toDouble(),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  color: isCurrentLine
                      ? EditorTheme.editorCurrentLine.withOpacity(0.3)
                      : Colors.transparent,
                  child: Text(
                    '$lineNumber',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: isCurrentLine
                          ? AppColors.onSurface
                          : EditorTheme.editorLineNumber,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
              childCount: widget.lineCount,
            ),
          ),
        ],
      ),
    );
  }
}