import 'package:flutter_test/flutter_test.dart';

import 'package:damstock_homes/core/state/app_state.dart';
import 'package:damstock_homes/core/utils/format.dart';
import 'package:damstock_homes/data/models.dart';

void main() {
  test('price formatting', () {
    expect(fmtPrice(7450000, true), '7.45 مليون ج.م');
    expect(fmtPrice(7450000, false), 'EGP 7.45M');
    expect(fmtNum(1234567), '1,234,567');
  });

  test('egyptian mobile validation', () {
    expect(isEgyptianMobile('01012345678'), isTrue);
    expect(isEgyptianMobile('01312345678'), isFalse);
  });

  test('filters & compare', () {
    final s = AppState();
    s.exploreWith((f) => f.kind = ListingKind.assignment);
    expect(s.filtered.every((p) => p.kind == ListingKind.assignment), isTrue);
    expect(s.toggleCompare('p1'), CompareResult.added);
    s.toggleCompare('p2');
    s.toggleCompare('p3');
    expect(s.toggleCompare('p4'), CompareResult.full);
  });
}
