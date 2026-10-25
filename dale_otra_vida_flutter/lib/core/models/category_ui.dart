import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum CategoryUi {
  alimentos(
    label: 'Alimentos',
    icon: Icons.restaurant,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  ),
  ropa(
    label: 'Ropa',
    icon: Icons.checkroom,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  ),
  libros(
    label: 'Libros',
    icon: Icons.menu_book,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  ),
  muebles(
    label: 'Muebles',
    icon: Icons.chair,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  ),
  juguetes(
    label: 'Juguetes',
    icon: Icons.toys,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  ),
  tecnologia(
    label: 'Tecnología',
    icon: Icons.devices,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  ),
  herramientas(
    label: 'Herramientas',
    icon: Icons.handyman,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  ),
  hogar(
    label: 'Hogar',
    icon: Icons.home,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  ),
  utiles(
    label: 'Útiles',
    icon: Icons.edit,
    circleColor: AppColors.categoryCircle,
    textColor: AppColors.textPrimary,
  );

  const CategoryUi({
    required this.label,
    required this.icon,
    required this.circleColor,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final Color circleColor;
  final Color textColor;
}
