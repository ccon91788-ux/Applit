import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifesync/core/theme/app_theme.dart';

void main() {
  testWidgets('Theme builds without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const Scaffold(body: Text('LifeSync')),
      ),
    );
    expect(find.text('LifeSync'), findsOneWidget);
  });
}
