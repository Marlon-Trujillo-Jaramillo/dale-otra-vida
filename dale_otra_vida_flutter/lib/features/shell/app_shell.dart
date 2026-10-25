import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_colors.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_spacing.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_secondary_button.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:dale_otra_vida_flutter/core/widgets/empty_state.dart';
import 'package:dale_otra_vida_flutter/screens/design_gallery_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _tabs = const [
    _PlaceholderTab(
      icon: Icons.home_outlined,
      title: 'Inicio',
      message: 'Aquí verás publicaciones cercanas.',
    ),
    _PlaceholderTab(
      icon: Icons.chat_bubble_outline,
      title: 'Mensajes',
      message: 'Aquí verás tus conversaciones.',
    ),
    _ProfilePlaceholder(),
  ];

  void _openPublish() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _PublishPlaceholderScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPublish,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: AppColors.onPrimary,
        unselectedItemColor: AppColors.onPrimary.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: EmptyState(
        icon: icon,
        title: title,
        message: message,
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyState(
            icon: Icons.person_outline,
            title: 'Perfil',
            message: 'Aquí verás y editarás tu perfil.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: AppSecondaryButton(
              label: 'Cerrar sesión',
              onPressed: () async => client.auth.signOutDevice(),
            ),
          ),
          if (kDebugMode)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const DesignGalleryScreen(),
                  ),
                );
              },
              child: const Text('Design Gallery'),
            ),
        ],
      ),
    );
  }
}

class _PublishPlaceholderScreen extends StatelessWidget {
  const _PublishPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar algo'),
      ),
      body: const Center(
        child: Text('Formulario de publicación próximamente'),
      ),
    );
  }
}
