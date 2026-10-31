import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

String accountTypeLabel(AccountType type) {
  return switch (type) {
    AccountType.person => 'Persona',
    AccountType.business => 'Comercio',
    AccountType.organization => 'Organización',
  };
}

String accountTypeDescription(AccountType type) {
  return switch (type) {
    AccountType.person => 'Comparto lo que ya no uso en casa',
    AccountType.business => 'Una tienda, restaurante o negocio con excedentes',
    AccountType.organization => 'Fundación, colectivo o comedor comunitario',
  };
}

IconData accountTypeIcon(AccountType type) {
  return switch (type) {
    AccountType.person => Icons.person_outline,
    AccountType.business => Icons.storefront_outlined,
    AccountType.organization => Icons.diversity_3_outlined,
  };
}
