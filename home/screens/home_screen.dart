// Flutter IDE Mobile - Home Screen

import 'package:flutter/material.dart';
import '../../core/constants/app_design_system.dart';

/// Home Screen Widget
/// Displays project overview and quick actions
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter IDE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // Recent Projects
            _buildRecentProjects(context),
            const SizedBox(height: 24),

            // Templates
            _buildTemplates(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.secondary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flutter_dash,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Flutter IDE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Build beautiful mobile apps',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add,
                label: 'New Project',
                color: AppColors.primary,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.folder_open,
                label: 'Open Project',
                color: AppColors.secondary,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.code,
                label: 'New File',
                color: AppColors.tertiary,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.download,
                label: 'Import',
                color: AppColors.error,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProjects(BuildContext context) {
    final projects = [
      _ProjectInfo(name: 'my_app', path: '/workspace/my_app', lastOpened: DateTime.now()),
      _ProjectInfo(name: 'flutter_demo', path: '/workspace/flutter_demo', lastOpened: DateTime.now().subtract(const Duration(days: 1))),
      _ProjectInfo(name: 'shopping_app', path: '/workspace/shopping_app', lastOpened: DateTime.now().subtract(const Duration(days: 3))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...projects.map((project) => _buildProjectItem(project)),
      ],
    );
  }

  Widget _buildProjectItem(_ProjectInfo project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.folder,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Text(
          project.path,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.onSurfaceVariant,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildTemplates(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Templates',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTemplateCard('Counter App', Icons.add_circle_outline),
              const SizedBox(width: 12),
              _buildTemplateCard('Todo List', Icons.checklist),
              const SizedBox(width: 12),
              _buildTemplateCard('Weather', Icons.cloud),
              const SizedBox(width: 12),
              _buildTemplateCard('E-Commerce', Icons.shopping_cart),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(String name, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProjectInfo {
  final String name;
  final String path;
  final DateTime lastOpened;

  _ProjectInfo({
    required this.name,
    required this.path,
    required this.lastOpened,
  });
}