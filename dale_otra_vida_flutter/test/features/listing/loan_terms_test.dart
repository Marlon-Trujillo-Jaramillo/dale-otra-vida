import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/listing/listing_detail_logic.dart';
import 'package:dale_otra_vida_flutter/features/listing/loan_terms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final due = DateTime.utc(2026, 11, 10, 12);

  Listing loan({LoanOutcome? outcome, int? deposit = 10000, int? fee = 3000}) =>
      Listing(
        ownerId: 1,
        title: 'Taladro',
        description: 'Taladro percutor.',
        type: ListingType.lend,
        category: Category.tools,
        condition: ItemCondition.good,
        photoUrls: const [],
        neighborhood: 'Laureles',
        latitude: 6.2,
        longitude: -75.5,
        status: ListingStatus.delivered,
        returnDate: due,
        depositAmount: deposit,
        lateFeePerDay: fee,
        loanOutcome: outcome,
      );

  test('days late and the agreed fee, capped at the guarantee', () {
    final onTime = due.subtract(const Duration(hours: 1));
    expect(loanDaysLate(loan(), now: onTime), 0);
    expect(loanLateFeeOwed(loan(), now: onTime), isNull);

    final twoDaysLate = due.add(const Duration(days: 1, hours: 2));
    expect(loanDaysLate(loan(), now: twoDaysLate), 2);
    expect(loanLateFeeOwed(loan(), now: twoDaysLate), 6000);

    final weekLate = due.add(const Duration(days: 7));
    expect(loanLateFeeOwed(loan(), now: weekLate), 10000);
    expect(loanLateFeeOwed(loan(deposit: null), now: weekLate), 24000);
  });

  test('labels follow the loan', () {
    final before = due.subtract(const Duration(days: 1));
    final after = due.add(const Duration(days: 2));
    expect(loanShortLabel(loan(), now: before), 'Prestado');
    expect(loanShortLabel(loan(), now: after), 'Vencido');
    expect(loanShortLabel(loan(outcome: LoanOutcome.returned)), 'Devuelto');
    expect(loanStatusLabel(loan(), now: after), 'Vencido hace 2 días');
    expect(
      loanStatusLabel(loan(outcome: LoanOutcome.notReturned)),
      'No devuelto',
    );
    expect(isLoanOut(loan()), isTrue);
    expect(isLoanOut(loan(outcome: LoanOutcome.returned)), isFalse);
  });
}
