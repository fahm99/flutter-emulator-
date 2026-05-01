// Flutter IDE Mobile - Linter Service

import '../models/editor_state.dart';

/// Linter Service - Static Analysis for Dart Code
/// Performs basic syntax and style checking without requiring the full Dart SDK
class LinterService {
  /// Analyze code and return errors
  List<EditorError> analyzeCode(String code) {
    final errors = <EditorError>[];
    final lines = code.split('\n');
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNumber = i + 1;
      
      // Check for common syntax errors
      errors.addAll(_checkLine(line, lineNumber));
    }
    
    // Check for balanced brackets
    errors.addAll(_checkBalancedBrackets(code));
    
    // Check for balanced strings
    errors.addAll(_checkBalancedStrings(code));
    
    return errors;
  }

  /// Check a single line for errors
  List<EditorError> _checkLine(String line, int lineNumber) {
    final errors = <EditorError>[];
    
    // Check for unclosed brackets on the same line
    final openBrackets = '({['.allMatches(line).length;
    final closeBrackets = ')}]'.allMatches(line).length;
    
    // Check for missing semicolon (common error)
    // Only check lines that should end with semicolon
    final trimmed = line.trim();
    if (trimmed.isNotEmpty && 
        !trimmed.endsWith('{') && 
        !trimmed.endsWith('}') &&
        !trimmed.endsWith(';') &&
        !trimmed.endsWith(',') &&
        !trimmed.endsWith('(') &&
        !trimmed.endsWith('[') &&
        !trimmed.endsWith(':') &&
        !trimmed.endsWith('\\') &&
        !trimmed.startsWith('//') &&
        !trimmed.startsWith('/*') &&
        !trimmed.startsWith('*') &&
        trimmed != '' &&
        !_isControlStatement(trimmed) &&
        !_isClassDeclaration(trimmed)) {
      // Don't report missing semicolon as error - Dart is forgiving
    }
    
    // Check for invalid identifier
    if (RegExp(r'^[0-9]').hasMatch(trimmed) && trimmed.isNotEmpty) {
      errors.add(EditorError(
        line: lineNumber,
        column: 1,
        length: trimmed.length,
        message: 'Invalid identifier: cannot start with a digit',
      ));
    }
    
    // Check for duplicate import
    // This is a simplified check
    
    // Check for TODO without proper format
    if (RegExp(r'todo', caseSensitive: false).hasMatch(trimmed) &&
        !RegExp(r'//\s*TODO\(', caseSensitive: false).hasMatch(trimmed) &&
        !RegExp(r'//\s*TODO:', caseSensitive: false).hasMatch(trimmed)) {
      // Allow TODO comments
    }
    
    return errors;
  }

  /// Check for balanced brackets across the entire code
  List<EditorError> _checkBalancedBrackets(String code) {
    final errors = <EditorError>[];
    final stack = <_BracketPos>[];
    final lines = code.split('\n');
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Skip comments
      final codeOnly = _removeComments(line);
      
      for (var j = 0; j < codeOnly.length; j++) {
        final char = codeOnly[j];
        
        if ('({['.contains(char)) {
          stack.add(_BracketPos(line: i + 1, column: j + 1, char: char));
        } else if (')}]'.contains(char)) {
          if (stack.isEmpty) {
            errors.add(EditorError(
              line: i + 1,
              column: j + 1,
              length: 1,
              message: 'Unmatched closing bracket "$char"',
            ));
          } else {
            final last = stack.removeLast();
            if (!_isMatchingPair(last.char, char)) {
              errors.add(EditorError(
                line: i + 1,
                column: j + 1,
                length: 1,
                message: 'Mismatched bracket: expected "${_getMatchingBracket(last.char)}" but found "$char"',
              ));
            }
          }
        }
      }
    }
    
    // Report unclosed brackets
    for (final bracket in stack) {
      errors.add(EditorError(
        line: bracket.line,
        column: bracket.column,
        length: 1,
        message: 'Unclosed bracket "${bracket.char}"',
      ));
    }
    
    return errors;
  }

  /// Check for balanced strings
  List<EditorError> _checkBalancedStrings(String code) {
    final errors = <EditorError>[];
    var inString = false;
    var stringChar = '';
    var stringStartLine = 0;
    var stringStartColumn = 0;
    final lines = code.split('\n');
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      for (var j = 0; j < line.length; j++) {
        final char = line[j];
        
        if (!inString) {
          if (char == '"' || char == "'") {
            // Check for triple-quoted strings
            if (j + 2 < line.length && 
                line.substring(j, j + 3) == '"""' ||
                line.substring(j, j + 3) == "'''") {
              // Multi-line string - skip for now
              j += 2;
            } else {
              inString = true;
              stringChar = char;
              stringStartLine = i + 1;
              stringStartColumn = j + 1;
            }
          }
        } else {
          // In a string - check for escaped char
          if (char == '\\' && j + 1 < line.length) {
            j++; // Skip escaped character
          } else if (char == stringChar) {
            inString = false;
          }
        }
      }
    }
    
    if (inString) {
      errors.add(EditorError(
        line: stringStartLine,
        column: stringStartColumn,
        length: 1,
        message: 'Unclosed string',
      ));
    }
    
    return errors;
  }

  /// Remove comments from a line of code
  String _removeComments(String line) {
    // Remove single-line comments
    var result = line;
    final commentIndex = result.indexOf('//');
    if (commentIndex >= 0) {
      // Make sure it's not inside a string
      final beforeComment = result.substring(0, commentIndex);
      final quoteCount = '"'.allMatches(beforeComment).length + 
                         "'".allMatches(beforeComment).length;
      if (quoteCount % 2 == 0) {
        result = beforeComment;
      }
    }
    return result;
  }

  /// Check if a bracket pair matches
  bool _isMatchingPair(String open, String close) {
    return (open == '(' && close == ')') ||
           (open == '[' && close == ']') ||
           (open == '{' && close == '}');
  }

  /// Get the matching bracket
  String _getMatchingBracket(String bracket) {
    switch (bracket) {
      case '(':
        return ')';
      case '[':
        return ']';
      case '{':
        return '}';
      case ')':
        return '(';
      case ']':
        return '[';
      case '}':
        return '{';
      default:
        return '';
    }
  }

  /// Check if line is a control statement
  bool _isControlStatement(String line) {
    return line.startsWith('if') ||
           line.startsWith('for') ||
           line.startsWith('while') ||
           line.startsWith('switch') ||
           line.startsWith('catch') ||
           line.startsWith('return') ||
           line.startsWith('throw');
  }

  /// Check if line is a class declaration
  bool _isClassDeclaration(String line) {
    return line.startsWith('class ') ||
           line.startsWith('abstract class ') ||
           line.startsWith('mixin ') ||
           line.startsWith('enum ');
  }
}

/// Helper class for tracking bracket positions
class _BracketPos {
  final int line;
  final int column;
  final String char;

  const _BracketPos({
    required this.line,
    required this.column,
    required this.char,
  });
}

/// Linter result with suggestions
class LinterResult {
  final List<EditorError> errors;
  final List<EditorWarning> warnings;
  final List<LinterSuggestion> suggestions;

  const LinterResult({
    this.errors = const [],
    this.warnings = const [],
    this.suggestions = const [],
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isEmpty => errors.isEmpty && warnings.isEmpty && suggestions.isEmpty;
}

/// Linter suggestion for code improvement
class LinterSuggestion {
  final int line;
  final int column;
  final String message;
  final String? fix;

  const LinterSuggestion({
    required this.line,
    required this.column,
    required this.message,
    this.fix,
  });
}