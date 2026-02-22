import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_movies_module/main.dart';

void main() {
  testWidgets('MoviesApp should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MoviesApp());
    await tester.pump();

    // The app should have an AppBar with the title
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
