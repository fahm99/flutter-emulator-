// Flutter IDE Mobile - Code Editor Widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_design_system.dart';
import '../controllers/editor_controller.dart';
import '../theme/editor_theme.dart';
import 'line_numbers.dart';
import 'file_tabs.dart';
import 'error_markers.dart';

/// Main Code Editor Widget
/// Implements a full-featured code editor with syntax highlighting
class CodeEditorWidget extends ConsumerStatefulWidget {
  const CodeEditorWidget({super.key});

  @override
  ConsumerState<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends ConsumerState<CodeEditorWidget> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  
  bool _showLineNumbers = true;
  int _lineHeight = 20;

  @override
  void initState() {
    super.initState();
    _verticalScrollController.addListener(_onVerticalScroll);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _onVerticalScroll() {
    ref.read(editorControllerProvider.notifier).onScrollChanged(
      _verticalScrollController.offset.toInt(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorControllerProvider);
    final controller = ref.read(editorControllerProvider.notifier);
    final editorState = state.editorState;
    final activeTab = editorState.activeTab;

    return Container(
      color: EditorTheme.editorBackground,
      child: Column(
        children: [
          // File Tabs
          FileTabsWidget(
            tabs: editorState.tabs,
            activeTabId: editorState.activeTabId,
            onTabSelected: controller.switchToTab,
            onTabClosed: controller.closeTab,
          ),
          
          // Editor Area
          Expanded(
            child: activeTab == null
                ? _buildEmptyState()
                : _buildEditor(activeTab, controller),
          ),
          
          // Keyboard Symbols Helper (Mobile)
          _buildKeyboardHelper(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No file open',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open a file from the project explorer',
            style: TextStyle(
              color: AppColors.onSurfaceVariant.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(dynamic activeTab, EditorController controller) {
    final textController = controller.textController;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line Numbers
        if (_showLineNumbers)
          LineNumbersWidget(
            lineCount: activeTab.lineCount,
            currentLine: activeTab.currentLine,
            scrollController: _verticalScrollController,
            lineHeight: _lineHeight,
          ),

        // Code Area
        Expanded(
          child: Stack(
            children: [
              // Error Markers (Gutter)
              ErrorMarkersWidget(
                errors: activeTab.errors,
                warnings: activeTab.warnings,
                scrollController: _verticalScrollController,
                lineHeight: _lineHeight,
              ),

              // Main Editor
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: SizedBox(
                        width: 2000, // Wide enough for horizontal scroll
                        child: TextField(
                          controller: textController,
                          focusNode: _focusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 13,
                            height: _lineHeight / 13,
                            color: AppColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            isDense: true,
                          ),
                          cursorColor: EditorTheme.editorCursor,
                          cursorWidth: 2,
                          onChanged: (value) {
                            controller.onContentChanged(value);
                          },
                          onTap: () {
                            final position = textController.selection.baseOffset;
                            controller.onCursorPositionChanged(position);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyboardHelper() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSymbolButton('{'),
          _buildSymbolButton('}'),
          _buildSymbolButton('['),
          _buildSymbolButton(']'),
          _buildSymbolButton('('),
          _buildSymbolButton(')'),
          _buildSymbolButton(';'),
          _buildSymbolButton(':'),
          _buildSymbolButton('='),
          _buildSymbolButton('"'),
          _buildSymbolButton("'"),
          _buildSymbolButton('<'),
          _buildSymbolButton('>'),
          _buildSymbolButton('/'),
          _buildSymbolButton('.'),
        ],
      ),
    );
  }

  Widget _buildSymbolButton(String symbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => _insertSymbol(symbol),
          child: Container(
            width: 40,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              symbol,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _insertSymbol(String symbol) {
    final controller = ref.read(editorControllerProvider.notifier).textController;
    final text = controller.text;
    final selection = controller.selection;
    
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      symbol,
    );
    
    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: selection.start + symbol.length,
    );
    
    ref.read(editorControllerProvider.notifier).onContentChanged(newText);
  }
}