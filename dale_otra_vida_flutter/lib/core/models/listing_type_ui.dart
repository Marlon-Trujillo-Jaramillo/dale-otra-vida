import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

enum ListingTypeUi {
  donar(
    label: 'Donar',
    description: 'Regálalo a quien lo necesite',
    badgeBackground: Color(0xFFE4EBE3),
    badgeText: Color(0xFF1E3A2F),
  ),
  intercambiar(
    label: 'Intercambiar',
    description: 'Cámbialo por otra cosa',
    badgeBackground: Color(0xFFF6E3CF),
    badgeText: Color(0xFF6E300B),
  ),
  vender(
    label: 'Vender',
    description: 'Ofrécelo a un precio accesible',
    badgeBackground: Color(0xFFDEE3EE),
    badgeText: Color(0xFF2B3A6B),
  ),
  prestar(
    label: 'Prestar',
    description: 'Por un tiempo y te lo devuelven',
    badgeBackground: Color(0xFFE9E2D2),
    badgeText: Color(0xFF4F5E57),
  );

  const ListingTypeUi({
    required this.label,
    required this.description,
    required this.badgeBackground,
    required this.badgeText,
  });

  final String label;
  final String description;
  final Color badgeBackground;
  final Color badgeText;

  ListingType get toServer {
    return switch (this) {
      ListingTypeUi.donar => ListingType.donate,
      ListingTypeUi.intercambiar => ListingType.exchange,
      ListingTypeUi.vender => ListingType.sell,
      ListingTypeUi.prestar => ListingType.lend,
    };
  }

  static ListingTypeUi fromServer(ListingType type) {
    return switch (type) {
      ListingType.donate => ListingTypeUi.donar,
      ListingType.exchange => ListingTypeUi.intercambiar,
      ListingType.sell => ListingTypeUi.vender,
      ListingType.lend => ListingTypeUi.prestar,
    };
  }
}
