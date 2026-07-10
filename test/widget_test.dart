// Basic smoke test: the app boots on the Splash screen without crashing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tato_app/main.dart';

void main() {
  testWidgets('TatoApp boots on Splash', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TatoApp()));
    await tester.pump();

    expect(find.text('TÁTO'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
