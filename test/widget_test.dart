import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:montager/main.dart';

void main() {
  testWidgets('Montager app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('AI Video Editor'), findsOneWidget);
    expect(find.text('Create stunning videos with AI'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Navigates to folder selection', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.folder_open), findsWidgets);
  });
}
