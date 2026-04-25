// Flutter IDE Mobile - Dart Syntax Highlighter

import 'package:flutter/material.dart';
import '../../core/constants/app_design_system.dart';
import '../theme/editor_theme.dart';

/// Syntax highlighting token types
enum TokenType {
  keyword,
  type,
  string,
  function,
  comment,
  number,
  bracket,
  variable,
  className,
  operator,
  annotation,
  directive,
  property,
  plain,
}

/// A single syntax token with position and type
class SyntaxToken {
  final int start;
  final int end;
  final TokenType type;
  final String text;

  const SyntaxToken({
    required this.start,
    required this.end,
    required this.type,
    required this.text,
  });

  int get length => end - start;
}

/// Dart Syntax Highlighter
/// Implements regex-based syntax highlighting for Dart code
/// Performance optimized with lazy rendering for visible lines only
class DartSyntaxHighlighter {
  final SyntaxTheme theme;
  
  // Regex patterns for Dart syntax
  static final RegExp _keywords = RegExp(
    r'\b(abstract|as|assert|async|await|break|case|catch|class|const|continue|covariant|default|deferred|do|dynamic|else|enum|export|extends|extension|external|factory|false|final|finally|for|Function|get|hide|if|implements|import|in|interface|is|late|library|mixin|new|null|on|operator|part|required|rethrow|return|set|show|static|super|switch|sync|this|throw|true|try|typedef|var|void|while|with|yield)\b',
  );

  static final RegExp _types = RegExp(
    r'\b(int|double|num|String|bool|List|Map|Set|Future|Stream|Iterable|Object|dynamic|void|var|Function|Type|num)\b',
  );

  static final RegExp _builtInTypes = RegExp(
    r'\b(Color|MaterialApp|Scaffold|Widget|StatelessWidget|StatefulWidget|BuildContext|State|Text|Container|Row|Column|Stack|Icon|Image|ListView|GridView|TextField|Button|ElevatedButton|TextButton|OutlinedButton|FloatingActionButton|AppBar|BottomNavigationBar|Drawer|TabBar|TabBarView|Card|ListTile|Chip|AlertDialog|Dialog|SnackBar|BoxDecoration|EdgeInsets|BorderRadius|Alignment|Center|Padding|Margin|Expanded|Flexible|Positioned|SizedBox|Opacity|Transform|DecoratedBox|GestureDetector|InkWell)\b',
  );

  static final RegExp _strings = RegExp(
    r'''("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')''',
  );

  static final RegExp _multilineStrings = RegExp(
    r'(""".*?"""|\'\'\'.*?\'\'\')',
    multiLine: true,
    dotAll: true,
  );

  static final RegExp _singleLineComment = RegExp(r'//.*');

  static final RegExp _multilineComment = RegExp(r'/\*[\s\S]*?\*/');

  static final RegExp _numbers = RegExp(
    r'\b(\d+\.?\d*|\.\d+)(e[+-]?\d+)?[fl]?\b',
  );

  static final RegExp _annotations = RegExp(r'@\w+');

  static final RegExp _functionCalls = RegExp(
    r'\b([a-zA-Z_]\w*)\s*(?=\()',
  );

  static final RegExp _classDefinitions = RegExp(
    r'\bclass\s+(\w+)',
  );

  static final RegExp _bracketPatterns = RegExp(r'[\[\]{}()]');

  static final RegExp _operators = RegExp(
    r'[+\-*/%=<>!&|^~?:]+|\.\.\.|\?\?|\?\.',
  );

  static final RegExp _directives = RegExp(
    r'^(import|export|part|library)\s+',
    multiLine: true,
  );

  static final RegExp _imports = RegExp(
    r"'[^']+\.dart'|//[^']+\.dart|\"[^\"]+\.dart\"",
  );

  DartSyntaxHighlighter({SyntaxTheme? theme}) : theme = theme ?? SyntaxTheme.dark;

  /// Get color for a token type
  Color _getColor(TokenType type) {
    switch (type) {
      case TokenType.keyword:
        return theme.keyword;
      case TokenType.type:
        return theme.type;
      case TokenType.string:
        return theme.string;
      case TokenType.function:
        return theme.function;
      case TokenType.comment:
        return theme.comment;
      case TokenType.number:
        return theme.number;
      case TokenType.bracket:
        return theme.bracket;
      case TokenType.variable:
        return theme.variable;
      case TokenType.className:
        return theme.className;
      case TokenType.operator:
        return theme.operator;
      case TokenType.annotation:
        return AppColors.syntaxKeyword;
      case TokenType.directive:
        return AppColors.syntaxKeyword;
      case TokenType.property:
        return theme.variable;
      case TokenType.plain:
        return AppColors.onSurface;
    }
  }

  /// Highlight a single line of code
  /// Optimized for lazy rendering - only highlights visible lines
  List<SyntaxToken> highlightLine(String line, int lineNumber) {
    final tokens = <SyntaxToken>[];
    String remaining = line;
    int offset = 0;

    while (remaining.isNotEmpty) {
      // Skip whitespace
      final whitespaceMatch = RegExp(r'^\s+').firstMatch(remaining);
      if (whitespaceMatch != null) {
        final text = whitespaceMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.plain,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for annotations first (at start of line or after whitespace)
      final annotationMatch = RegExp(r'^@\w+').firstMatch(remaining);
      if (annotationMatch != null) {
        final text = annotationMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.annotation,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for comments
      final commentMatch = _singleLineComment.firstMatch(remaining);
      if (commentMatch != null) {
        final text = commentMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.comment,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for strings
      final stringMatch = _strings.firstMatch(remaining) ?? 
                          _multilineStrings.firstMatch(remaining);
      if (stringMatch != null) {
        final text = stringMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.string,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for numbers
      final numberMatch = _numbers.firstMatch(remaining);
      if (numberMatch != null) {
        final text = numberMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.number,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for brackets
      final bracketMatch = _bracketPatterns.firstMatch(remaining);
      if (bracketMatch != null) {
        final text = bracketMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.bracket,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for operators
      final operatorMatch = _operators.firstMatch(remaining);
      if (operatorMatch != null) {
        final text = operatorMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.operator,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for keywords
      final keywordMatch = _keywords.firstMatch(remaining);
      if (keywordMatch != null) {
        final text = keywordMatch.group(0)!;
        // Check if it's a class definition
        final classMatch = _classDefinitions.firstMatch(remaining);
        if (classMatch != null && classMatch.start == 0) {
          tokens.add(SyntaxToken(
            start: offset,
            end: offset + text.length,
            type: TokenType.keyword,
            text: text,
          ));
        } else {
          tokens.add(SyntaxToken(
            start: offset,
            end: offset + text.length,
            type: TokenType.keyword,
            text: text,
          ));
        }
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for types (built-in types first, then custom)
      final builtInMatch = _builtInTypes.firstMatch(remaining);
      if (builtInMatch != null) {
        final text = builtInMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.type,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      final typeMatch = _types.firstMatch(remaining);
      if (typeMatch != null) {
        final text = typeMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.type,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // Check for function calls
      final funcMatch = _functionCalls.firstMatch(remaining);
      if (funcMatch != null) {
        final text = funcMatch.group(1)!;
        // Don't match keywords
        if (!_keywords.hasMatch(text)) {
          tokens.add(SyntaxToken(
            start: offset,
            end: offset + text.length,
            type: TokenType.function,
            text: text,
          ));
          offset += text.length;
          remaining = remaining.substring(text.length);
          continue;
        }
      }

      // Check for identifiers/variables
      final identifierMatch = RegExp(r'^[a-zA-Z_]\w*').firstMatch(remaining);
      if (identifierMatch != null) {
        final text = identifierMatch.group(0)!;
        tokens.add(SyntaxToken(
          start: offset,
          end: offset + text.length,
          type: TokenType.variable,
          text: text,
        ));
        offset += text.length;
        remaining = remaining.substring(text.length);
        continue;
      }

      // If nothing matched, treat as plain text (single character)
      tokens.add(SyntaxToken(
        start: offset,
        end: offset + 1,
        type: TokenType.plain,
        text: remaining[0],
      ));
      offset += 1;
      remaining = remaining.substring(1);
    }

    return tokens;
  }

  /// Highlight entire code content
  /// For performance, processes only visible lines
  List<List<SyntaxToken>> highlightCode(String code, {int? visibleStart, int? visibleEnd}) {
    final lines = code.split('\n');
    final result = <List<SyntaxToken>>[];
    
    final start = visibleStart ?? 0;
    final end = visibleEnd ?? lines.length;
    
    for (var i = 0; i < lines.length; i++) {
      if (i >= start && i <= end) {
        result.add(highlightLine(lines[i], i));
      } else {
        // For non-visible lines, return empty list for lazy loading
        result.add(const []);
      }
    }
    
    return result;
  }

  /// Full highlight all lines (for export/clipboard)
  List<List<SyntaxToken>> highlightAll(String code) {
    return highlightCode(code);
  }

  /// Build TextSpan with syntax highlighting
  /// Optimized with lazy rendering
  TextSpan buildSpans(String text, {int? visibleStart, int? visibleEnd}) {
    final lines = text.split('\n');
    final spans = <InlineSpan>[];
    
    final start = visibleStart ?? 0;
    final end = visibleEnd ?? lines.length;
    
    for (var i = 0; i < lines.length; i++) {
      if (i >= start && i <= end) {
        final tokens = highlightLine(lines[i], i);
        for (final token in tokens) {
          spans.add(TextSpan(
            text: token.text,
            style: TextStyle(
              color: _getColor(token.type),
              fontFamily: 'JetBrains Mono',
              fontSize: 13,
              height: 1.5,
            ),
          ));
        }
      }
      
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    
    return TextSpan(children: spans);
  }

  /// Check for bracket matching
  BracketMatch? findMatchingBracket(String code, int position) {
    if (position < 0 || position >= code.length) return null;
    
    final char = code[position];
    String? matching;
    
    switch (char) {
      case '(':
        matching = ')';
        break;
      case ')':
        matching = '(';
        break;
      case '[':
        matching = ']';
        break;
      case ']':
        matching = '[';
        break;
      case '{':
        matching = '}';
        break;
      case '}':
        matching = '{';
        break;
      default:
        return null;
    }
    
    final isOpening = '([{'.contains(char);
    var count = 0;
    
    if (isOpening) {
      for (var i = position + 1; i < code.length; i++) {
        if (code[i] == char) count++;
        if (code[i] == matching && count == 0) {
          return BracketMatch(start: position, end: i, matched: true);
        }
        if (code[i] == matching) count--;
      }
    } else {
      for (var i = position - 1; i >= 0; i--) {
        if (code[i] == char) count++;
        if (code[i] == matching && count == 0) {
          return BracketMatch(start: i, end: position, matched: true);
        }
        if (code[i] == matching) count--;
      }
    }
    
    return BracketMatch(start: position, end: -1, matched: false);
  }
}

/// Bracket match result
class BracketMatch {
  final int start;
  final int end;
  final bool matched;

  const BracketMatch({
    required this.start,
    required this.end,
    required this.matched,
  });
}