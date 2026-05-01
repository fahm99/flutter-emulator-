// Flutter IDE Mobile - Editor Controller (Riverpod Provider)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/file_entity.dart';
import '../models/editor_state.dart';
import '../services/file_service.dart';
import '../services/linter_service.dart';
import '../services/syntax_highlighter.dart';

/// Editor Controller State
class EditorControllerState {
  final EditorState editorState;
  final bool isCompiling;
  final String? compilationOutput;
  final bool isRunning;

  const EditorControllerState({
    this.editorState = const EditorState(),
    this.isCompiling = false,
    this.compilationOutput,
    this.isRunning = false,
  });

  EditorControllerState copyWith({
    EditorState? editorState,
    bool? isCompiling,
    String? compilationOutput,
    bool? isRunning,
  }) {
    return EditorControllerState(
      editorState: editorState ?? this.editorState,
      isCompiling: isCompiling ?? this.isCompiling,
      compilationOutput: compilationOutput,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

/// Editor Controller - Manages editor state and operations
class EditorController extends StateNotifier<EditorControllerState> {
  final FileService _fileService;
  final LinterService _linterService;
  final DartSyntaxHighlighter _syntaxHighlighter;
  
  Timer? _autoSaveTimer;
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  EditorController({
    FileService? fileService,
    LinterService? linterService,
    DartSyntaxHighlighter? syntaxHighlighter,
  })  : _fileService = fileService ?? FileService(),
        _linterService = linterService ?? LinterService(),
        _syntaxHighlighter = syntaxHighlighter ?? DartSyntaxHighlighter(),
        super(const EditorControllerState()) {
    _initializeProject();
  }

  /// Get text controller for the editor
  TextEditingController get textController => _textController;

  /// Get scroll controller
  ScrollController get scrollController => _scrollController;

  /// Get syntax highlighter
  DartSyntaxHighlighter get syntaxHighlighter => _syntaxHighlighter;

  /// Initialize with default project
  void _initializeProject() {
    final fileSystem = _fileService.fileSystem;
    final mainFile = fileSystem.findByPath('/lib/main.dart');
    
    if (mainFile != null) {
      final tab = EditorTabState.fromFile(mainFile);
      _textController.text = mainFile.content;
      
      state = state.copyWith(
        editorState: EditorState(
          tabs: [tab],
          activeTabId: tab.id,
          fileSystem: fileSystem,
          currentlyOpenFilePath: mainFile.path,
        ),
      );
    }
  }

  /// Open a file
  void openFile(String fileId) {
    final file = _fileService.getFileById(fileId);
    if (file == null) return;

    // Check if already open
    final existingTab = state.editorState.tabs
        .where((t) => t.fileId == fileId)
        .firstOrNull;

    if (existingTab != null) {
      // Just switch to existing tab
      state = state.copyWith(
        editorState: state.editorState.copyWith(
          activeTabId: existingTab.id,
          currentlyOpenFilePath: file.path,
        ),
      );
      _textController.text = existingTab.content;
      return;
    }

    // Create new tab
    final tab = EditorTabState.fromFile(file);
    _textController.text = file.content;

    final newTabs = [...state.editorState.tabs, tab];
    state = state.copyWith(
      editorState: state.editorState.copyWith(
        tabs: newTabs,
        activeTabId: tab.id,
        currentlyOpenFilePath: file.path,
      ),
    );
  }

  /// Close a tab
  void closeTab(String tabId) {
    final tabs = state.editorState.tabs;
    final tabIndex = tabs.indexWhere((t) => t.id == tabId);
    
    if (tabIndex == -1) return;

    final newTabs = [...tabs]..removeAt(tabIndex);
    
    String? newActiveTabId = state.editorState.activeTabId;
    String? newOpenPath = state.editorState.currentlyOpenFilePath;
    
    if (tabId == state.editorState.activeTabId) {
      if (newTabs.isNotEmpty) {
        final newIndex = tabIndex >= newTabs.length ? newTabs.length - 1 : tabIndex;
        newActiveTabId = newTabs[newIndex].id;
        newOpenPath = newTabs[newIndex].filePath;
        _textController.text = newTabs[newIndex].content;
      } else {
        newActiveTabId = null;
        newOpenPath = null;
        _textController.clear();
      }
    }

    state = state.copyWith(
      editorState: state.editorState.copyWith(
        tabs: newTabs,
        activeTabId: newActiveTabId,
        currentlyOpenFilePath: newOpenPath,
      ),
    );
  }

  /// Switch to a different tab
  void switchToTab(String tabId) {
    final tab = state.editorState.tabs.where((t) => t.id == tabId).firstOrNull;
    if (tab == null) return;

    _textController.text = tab.content;
    state = state.copyWith(
      editorState: state.editorState.copyWith(
        activeTabId: tabId,
        currentlyOpenFilePath: tab.filePath,
      ),
    );
  }

  /// Update content when text changes
  void onContentChanged(String content) {
    final activeTab = state.editorState.activeTab;
    if (activeTab == null) return;

    // Cancel previous auto-save timer
    _autoSaveTimer?.cancel();

    // Update tab with new content
    final updatedTab = activeTab.copyWith(
      content: content,
      isDirty: true,
      lastModified: DateTime.now(),
    );

    final tabIndex = state.editorState.tabs
        .indexWhere((t) => t.id == activeTab.id);
    
    if (tabIndex == -1) return;

    final newTabs = [...state.editorState.tabs];
    newTabs[tabIndex] = updatedTab;

    // Run linter
    final errors = _linterService.analyzeCode(content)
        .map((e) => EditorError(
            line: e.line,
            column: e.column,
            length: e.length,
            message: e.message,
          ))
        .toList();

    newTabs[tabIndex] = updatedTab.copyWith(errors: errors);

    state = state.copyWith(
      editorState: state.editorState.copyWith(
        tabs: newTabs,
      ),
    );

    // Schedule auto-save
    if (state.editorState.settings.autoSave) {
      _autoSaveTimer = Timer(
        Duration(milliseconds: state.editorState.settings.autoSaveDelayMs),
        () => _saveCurrentFile(),
      );
    }
  }

  /// Update cursor position
  void onCursorPositionChanged(int position, {int? selectionStart, int? selectionEnd}) {
    final activeTab = state.editorState.activeTab;
    if (activeTab == null) return;

    final updatedTab = activeTab.copyWith(
      cursorPosition: position,
      selectionStart: selectionStart ?? activeTab.selectionStart,
      selectionEnd: selectionEnd ?? activeTab.selectionEnd,
    );

    final tabIndex = state.editorState.tabs
        .indexWhere((t) => t.id == activeTab.id);
    
    if (tabIndex == -1) return;

    final newTabs = [...state.editorState.tabs];
    newTabs[tabIndex] = updatedTab;

    state = state.copyWith(
      editorState: state.editorState.copyWith(tabs: newTabs),
    );
  }

  /// Update scroll offset
  void onScrollChanged(int scrollOffset) {
    final activeTab = state.editorState.activeTab;
    if (activeTab == null) return;

    final lineHeight = activeTab.lineHeight;
    final visibleStart = (scrollOffset / lineHeight).floor();
    final visibleEnd = visibleStart + 50; // Assume ~50 visible lines

    final updatedTab = activeTab.copyWith(
      scrollOffset: scrollOffset,
      visibleLinesStart: visibleStart,
      visibleLinesEnd: visibleEnd,
    );

    final tabIndex = state.editorState.tabs
        .indexWhere((t) => t.id == activeTab.id);
    
    if (tabIndex == -1) return;

    final newTabs = [...state.editorState.tabs];
    newTabs[tabIndex] = updatedTab;

    state = state.copyWith(
      editorState: state.editorState.copyWith(tabs: newTabs),
    );
  }

  /// Save current file
  Future<void> _saveCurrentFile() async {
    final activeTab = state.editorState.activeTab;
    if (activeTab == null || !activeTab.isDirty) return;

    await _fileService.updateFileContent(activeTab.filePath, activeTab.content);
    await _fileService.saveFile(activeTab.filePath);

    final tabIndex = state.editorState.tabs
        .indexWhere((t) => t.id == activeTab.id);
    
    if (tabIndex == -1) return;

    final newTabs = [...state.editorState.tabs];
    newTabs[tabIndex] = activeTab.copyWith(isDirty: false);

    state = state.copyWith(
      editorState: state.editorState.copyWith(tabs: newTabs),
    );
  }

  /// Force save current file
  Future<void> saveCurrentFile() async {
    await _saveCurrentFile();
  }

  /// Save all files
  Future<void> saveAllFiles() async {
    await _fileService.saveAllFiles();

    final newTabs = state.editorState.tabs
        .map((t) => t.copyWith(isDirty: false))
        .toList();

    state = state.copyWith(
      editorState: state.editorState.copyWith(tabs: newTabs),
    );
  }

  /// Create a new file
  Future<void> createNewFile(String name, {String? className}) async {
    final path = '/lib/$name';
    final file = await _fileService.createDartFile(
      name: name,
      path: path,
      className: className,
    );
    
    openFile(file.id);
  }

  /// Set compiling state
  void setCompiling(bool isCompiling) {
    state = state.copyWith(isCompiling: isCompiling);
  }

  /// Set compilation output
  void setCompilationOutput(String? output) {
    state = state.copyWith(compilationOutput: output);
  }

  /// Set running state
  void setRunning(bool isRunning) {
    state = state.copyWith(isRunning: isRunning);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
}

/// Editor Controller Provider
final editorControllerProvider =
    StateNotifierProvider<EditorController, EditorControllerState>((ref) {
  return EditorController();
});

/// File System Provider
final fileServiceProvider = Provider<FileService>((ref) {
  final service = FileService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Linter Service Provider
final linterServiceProvider = Provider<LinterService>((ref) {
  return LinterService();
});

/// Syntax Highlighter Provider
final syntaxHighlighterProvider = Provider<DartSyntaxHighlighter>((ref) {
  return DartSyntaxHighlighter();
});

/// Active Tab Provider
final activeTabProvider = Provider<EditorTabState?>((ref) {
  final state = ref.watch(editorControllerProvider);
  return state.editorState.activeTab;
});

/// Current Code Provider
final currentCodeProvider = Provider<String>((ref) {
  final tab = ref.watch(activeTabProvider);
  return tab?.content ?? '';
});

/// Errors Provider
final errorsProvider = Provider<List<EditorError>>((ref) {
  final tab = ref.watch(activeTabProvider);
  return tab?.errors ?? [];
});

/// File System Tree Provider
final fileSystemProvider = Provider<FileSystemTree>((ref) {
  final state = ref.watch(editorControllerProvider);
  return state.editorState.fileSystem;
});