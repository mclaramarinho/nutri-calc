import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ListView separators do not use Expanded in a non-flex parent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.separated(
            itemCount: 2,
            itemBuilder: (context, index) => Text('Item $index'),
            separatorBuilder: (context, index) => const SizedBox(height: 1),
          ),
        ),
      ),
    );

    expect(find.byType(Expanded), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });
}
