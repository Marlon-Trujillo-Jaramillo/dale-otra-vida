import 'package:flutter/material.dart';

import '../core/models/category_ui.dart';
import '../core/models/listing_type_ui.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/widgets.dart';

class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  int _segmentIndex = 0;
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Design System'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.l,
          ),
          children: [
            _section(
              'Typography',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display', style: AppTheme.light.textTheme.displayLarge),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Headline',
                    style: AppTheme.light.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text('Title', style: AppTheme.light.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.s),
                  Text('Section label', style: AppTypography.sectionLabel),
                  const SizedBox(height: AppSpacing.s),
                  Text('Body', style: AppTheme.light.textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Body strong',
                    style: AppTheme.light.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text('Caption', style: AppTheme.light.textTheme.labelSmall),
                ],
              ),
            ),
            _section(
              'Buttons',
              Column(
                children: [
                  AppPrimaryButton(
                    label: 'Primary button',
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const AppPrimaryButton(
                    label: 'Primary loading',
                    isLoading: true,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppSecondaryButton(
                    label: 'Secondary button',
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const AppSecondaryButton(
                    label: 'Secondary loading',
                    isLoading: true,
                  ),
                ],
              ),
            ),
            _section(
              'Text field',
              const AppTextField(
                label: 'Correo electrónico',
                hint: 'tu@email.com',
              ),
            ),
            _section(
              'Segmented control',
              AppSegmentedControl(
                options: const ['Ingresar', 'Crear cuenta'],
                selectedIndex: _segmentIndex,
                onChanged: (index) => setState(() => _segmentIndex = index),
              ),
            ),
            _section(
              'Filter chips',
              FilterChipRow(
                options: const [
                  'Todo',
                  'Donar',
                  'Intercambiar',
                  'Vender',
                  'Prestar',
                ],
                selected: _selectedFilter,
                onSelected: (value) => setState(
                  () =>
                      _selectedFilter = value == _selectedFilter ? null : value,
                ),
              ),
            ),
            _section(
              'Type badges',
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: ListingTypeUi.values
                    .map((type) => TypeBadge(type: type))
                    .toList(),
              ),
            ),
            _section(
              'Category tiles',
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CategoryUi.values
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.s),
                          child: CategoryTile(category: category),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            _section(
              'Listing card',
              const ListingCard(
                title: 'Silla de madera maciza',
                type: ListingTypeUi.donar,
                meta: 'Publicado hace 2 horas',
                location: 'Barrio',
                distance: '0,8 km',
              ),
            ),
            _section(
              'Avatar',
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAvatar(initials: 'MR'),
                  SizedBox(width: AppSpacing.m),
                  AppAvatar(initials: 'AL', size: 56),
                ],
              ),
            ),
            _section(
              'Section header',
              const SectionHeader(
                label: 'Cerca de ti',
                actionLabel: 'Ver mapa',
              ),
            ),
            _section(
              'Empty state',
              const EmptyState(
                icon: Icons.search_off,
                title: 'No encontramos resultados',
                message: 'Prueba con otra búsqueda o cambia los filtros.',
                actionLabel: 'Limpiar filtros',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.title),
          const SizedBox(height: AppSpacing.m),
          child,
        ],
      ),
    );
  }
}
