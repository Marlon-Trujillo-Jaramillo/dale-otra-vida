import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/core/models/account_type_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every account type has Spanish copy', () {
    expect(accountTypeLabel(AccountType.person), 'Persona');
    expect(accountTypeLabel(AccountType.business), 'Comercio');
    expect(accountTypeLabel(AccountType.organization), 'Organización');
    for (final type in AccountType.values) {
      expect(accountTypeDescription(type), isNotEmpty);
    }
  });
}
