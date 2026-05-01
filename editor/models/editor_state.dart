// Flutter IDE Mobile - Editor State Model

import 'package:flutter/foundation.dart';
import '../../core/models/file_entity.dart';

/// Represents the state of a single editor tab
@immutable
class EditorTabState {
  final String id;
  final String fileId;
  final String fileName;
  final String filePath;
  final String content;
  final int cursorPosition;
  final int selectionStart;
  final int selectionEnd;
  final int scrollOffset;
  final int lineHeight;
  final int visibleLinesStart;
  final int visibleLinesEnd;
  final bool isDirty;
  final List<EditorError> errors;
  final List<EditorWarning> warnings;
  final DateTime openedAt;
  final DateTime lastModified;

  const EditorTabState({
    required this.id,
    required this.fileId,
    required this.fileName,
    required this.filePath,
    required this.content,
    this.cursorPosition = 0,
    this.selectionStart = 0,
    this.selectionEnd = 0,
    this.scrollOffset = 0,
    this.lineHeight = 20,
    this.visibleLinesStart = 0,
    this.visibleLinesEnd = 100,
    this.isDirty = false,
    this.errors = const [],
    this.warnings = const [],
    required this.openedAt,
    required this.lastModified,
  });

  /// Create from a file entity
  factory EditorTabState.fromFile(FileEntity file) {
    final now = DateTime.now();
    return EditorTabState(
      id: 'tab_${file.id}',
      fileId: file.id,
      fileName: file.name,
      filePath: file.path,
      content: file.content,
      openedAt: now,
      lastModified: now,
    );
  }

  /// Get current line number
  int get currentLine {
    if (content.isEmpty) return 1;
    final lines = content.substring(0, cursorPosition.clamp(0, content.length));
    return lines.split('\n').length;
  }

  /// Get current column number
  int get currentColumn {
    if (content.isEmpty) return 1;
    final lines = content.substring(0, cursorPosition.clamp(0, content.length)).split('\n');
    return (lines.isNotEmpty ? lines.last.length : 0) + 1;
  }

  /// Get all lines
  List<String> get lines => content.split('\n');

  /// Get total line count
  int get lineCount => lines.length;

  /// Get selected text
  String get selectedText {
    if (selectionStart == selectionEnd) return '';
    final start = selectionStart.clamp(0, content.length);
    final end = selectionEnd.clamp(0, content.length);
    return content.substring(start, end);
  }

  /// Has selection
  bool get hasSelection => selectionStart != selectionEnd;

  /// Copy with new values
  EditorTabState copyWith({
    String? id,
    String? fileId,
    String? fileName,
    String? filePath,
    String? content,
    int? cursorPosition,
    int? selectionStart,
    int? selectionEnd,
    int? scrollOffset,
    int? lineHeight,
    int? visibleLinesStart,
    int? visibleLinesEnd,
    bool? isDirty,
    List<EditorError>? errors,
    List<EditorWarning>? warnings,
    DateTime? openedAt,
    DateTime? lastModified,
  }) {
    return EditorTabState(
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      selectionStart: selectionStart ?? this.selectionStart,
      selectionEnd: selectionEnd ?? this.selectionEnd,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      lineHeight: lineHeight ?? this.lineHeight,
      visibleLinesStart: visibleLinesStart ?? this.visibleLinesStart,
      visibleLinesEnd: visibleLinesEnd ?? this.visibleLinesEnd,
      isDirty: isDirty ?? this.isDirty,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      openedAt: openedAt ?? this.openedAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorTabState &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Editor error marker
@immutable
class EditorError {
  final int line;
  final int column;
  final int length;
  final String message;
  final String? source;

  const EditorError({
    required this.line,
    required this.column,
    required this.length,
    required this.message,
    this.source,
  });

  factory EditorError.fromJson(Map<String, dynamic> json) {
    return EditorError(
      line: json['line'] as int? ?? 0,
      column: json['column'] as int? ?? 0,
      length: json['length'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      source: json['source'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorError &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          column == other.column;

  @override
  int get hashCode => line.hashCode ^ column.hashCode;
}

/// Editor warning marker
@immutable
class EditorWarning {
  final int line;
  final int column;
  final int length;
  final String message;
  final String? source;

  const EditorWarning({
    required this.line,
    required this.column,
    required this.length,
    required this.message,
    this.source,
  });

  factory EditorWarning.fromJson(Map<String, dynamic> json) {
    return EditorWarning(
      line: json['line'] as int? ?? 0,
      column: json['column'] as int? ?? 0,
      length: json['length'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      source: json['source'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorWarning &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          column == other.column;

  @override
  int get hashCode => line.hashCode ^ column.hashCode;
}

/// Complete editor state
@immutable
class EditorState {
  final List<EditorTabState> tabs;
  final String? activeTabId;
  final FileSystemTree fileSystem;
  final String? currentlyOpenFilePath;
  final bool isLoading;
  final String? errorMessage;
  final EditorSettings settings;

  const EditorState({
    this.tabs = const [],
    this.activeTabId,
    this.fileSystem = const FileSystemTree(roots: []),
    this.currentlyOpenFilePath,
    this.isLoading = false,
    this.errorMessage,
    this.settings = const EditorSettings(),
  });

  /// Get active tab
  EditorTabState? get activeTab {
    if (activeTabId == null) return null;
    for (final tab in tabs) {
      if (tab.id == activeTabId) return tab;
    }
    return null;
  }

  /// Get active tab index
  int get activeTabIndex {
    if (activeTabId == null) return -1;
    return tabs.indexWhere((tab) => tab.id == activeTabId);
  }

  /// Has unsaved changes
  bool get hasUnsavedChanges => tabs.any((tab) => tab.isDirty);

  /// Get all errors across all tabs
  List<EditorError> get allErrors {
    return tabs.expand((tab) => tab.errors).toList();
  }

  /// Get all warnings across all tabs
  List<EditorWarning> get allWarnings {
    return tabs.expand((tab) => tab.warnings).toList();
  }

  /// Copy with new values
  EditorState copyWith({
    List<EditorTabState>? tabs,
    String? activeTabId,
    FileSystemTree? fileSystem,
    String? currentlyOpenFilePath,
    bool? isLoading,
    String? errorMessage,
    EditorSettings? settings,
  }) {
    return EditorState(
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
      fileSystem: fileSystem ?? this.fileSystem,
      currentlyOpenFilePath: currentlyOpenFilePath ?? this.currentlyOpenFilePath,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      settings: settings ?? this.settings,
    );
  }
}

/// Editor settings
@immutable
class EditorSettings {
  final bool autoSave;
  final int autoSaveDelayMs;
  final bool showLineNumbers;
  final bool highlightCurrentLine;
  final bool enableAutoIndentation;
  final bool matchBrackets;
  final int tabSize;
  final bool useSpaces;
  final String fontFamily;
  final double fontSize;
  final double lineHeight;

  const EditorSettings({
    this.autoSave = true,
    this.autoSaveDelayMs = 2000,
    this.showLineNumbers = true,
    this.highlightCurrentLine = true,
    this.enableAutoIndentation = true,
    this.matchBrackets = true,
    this.tabSize = 2,
    this.useSpaces = true,
    this.fontFamily = 'JetBrains Mono',
    this.fontSize = 13.0,
    this.lineHeight = 1.5,
  });

  EditorSettings copyWith({
    bool? autoSave,
    int? autoSaveDelayMs,
    bool? showLineNumbers,
    bool? highlightCurrentLine,
    bool? enableAutoIndentation,
    bool? matchBrackets,
    int? tabSize,
    bool? useSpaces,
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
  }) {
    return EditorSettings(
      autoSave: autoSave ?? this.autoSave,
      autoSaveDelayMs: autoSaveDelayMs ?? this.autoSaveDelayMs,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      highlightCurrentLine: highlightCurrentLine ?? this.highlightCurrentLine,
      enableAutoIndentation: enableAutoIndentation ?? this.enableAutoIndentation,
      matchBrackets: matchBrackets ?? this.matchBrackets,
      tabSize: tabSize ?? this.tabSize,
      useSpaces: useSpaces ?? this.useSpaces,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

/// Empty file system tree constant
class FileSystemTree {
  final List<dynamic> roots;
  final Map<String, dynamic> fileMap;

  const FileSystemTree({
    this.roots = const [],
    this.fileMap = const {},
  });
}