// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:app/src/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('Nexus login matches mobile reference size', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(941, 1672));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsNothing);
    expect(find.text('Accédez à votre espace Nexus'), findsNothing);
    expect(find.text('IDENTIFIANT'), findsOneWidget);
    expect(find.text('MOT DE PASSE'), findsOneWidget);

    await tester.tap(find.text('SE CONNECTER'));
    await tester.pump();

    expect(find.text('Email requis'), findsOneWidget);
    expect(find.text('Mot de passe requis'), findsOneWidget);
  });

  testWidgets('Nexus login matches desktop reference size', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1536, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsNothing);
    expect(find.text('SE CONNECTER'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });

  testWidgets('Nexus login adapts to tablet landscape without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsNothing);
    expect(find.text('SE CONNECTER'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
  });

  testWidgets('Nexus login adapts to tablet portrait without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(768, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsNothing);
    expect(find.text('SE CONNECTER'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
  });

  testWidgets('Nexus login adapts to small mobile without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsNothing);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });

  testWidgets('Nexus login adapts to short compact window without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(724, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsNothing);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });
}
