import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skillswap/app.dart';

void main() {
  testWidgets('SkillSwapApp démarre sans erreur', (WidgetTester tester) async {
    await tester.pumpWidget(const SkillSwapApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}