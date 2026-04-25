// Flutter IDE Mobile - Main Entry Point

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_design_system.dart';
import 'editor/controllers/editor_controller.dart';
import 'editor/widgets/code_editor.dart';
import 'home/screens/home_screen.dart';
import 'emulator/widgets/emulator_panel.dart';
import 'settings/screens/settings_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FlutterIDEMobileApp(),
    ),
  );
}

/// Main Application Widget
class FlutterIDEMobileApp extends StatelessWidget {
  const FlutterIDEMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter IDE Mobile',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      home: const MainScreen(),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceContainerLow,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineMedium: AppTypography.headlineMd,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.labelMd,
      ),
    );
  }
}

/// Main Screen with Bottom Navigation
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    EditorScreen(),
    EmulatorScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code_outlined),
            activeIcon: Icon(Icons.code),
            label: 'Editor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smartphone_outlined),
            activeIcon: Icon(Icons.smartphone),
            label: 'Emulator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Editor Screen
class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: [
          // Save button
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              ref.read(editorControllerProvider.notifier).saveCurrentFile();
            },
            tooltip: 'Save',
          ),
          // Run button
          IconButton(
            icon: editorState.isCompiling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            onPressed: editorState.isCompiling
                ? null
                : () {
                    // Trigger compilation
                    ref.read(editorControllerProvider.notifier).setCompiling(true);
                  },
            tooltip: 'Run',
          ),
          // More options
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save_all',
                child: Row(
                  children: [
                    Icon(Icons.save_all),
                    SizedBox(width: 8),
                    Text('Save All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'format',
                child: Row(
                  children: [
                    Icon(Icons.format_align_left),
                    SizedBox(width: 8),
                    Text('Format Code'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const CodeEditorWidget(),
    );
  }
}

/// Emulator Screen
class EmulatorScreen extends StatelessWidget {
  const EmulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed: () {
              // Rotate emulator
            },
            tooltip: 'Rotate',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reload app
            },
            tooltip: 'Reload',
          ),
        ],
      ),
      body: const EmulatorPanel(),
    );
  }
}

/// Terminal Output Widget
class TerminalPanel extends ConsumerWidget {
  const TerminalPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorControllerProvider);

    return Container(
      color: AppColors.terminalBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terminal header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'TERMINAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: state.isRunning
                        ? AppColors.terminalSuccess.withOpacity(0.2)
                        : AppColors.onSurfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    state.isRunning ? 'running' : 'idle',
                    style: TextStyle(
                      fontSize: 10,
                      color: state.isRunning
                          ? AppColors.terminalSuccess
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 18),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Terminal output
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                state.compilationOutput ?? 'Ready to compile...',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  color: AppColors.terminalText,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}