// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:app/src/app.dart';
import 'package:app/src/core/config/router/routers.dart';
import 'package:app/src/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Nexus login matches mobile reference size', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsOneWidget);
    expect(find.text('Accédez à votre espace Nexus'), findsOneWidget);
    expect(find.text('IDENTIFIANT'), findsOneWidget);
    expect(find.text('MOT DE PASSE'), findsOneWidget);

    await tester.tap(find.text('SE CONNECTER'));
    await tester.pump();

    expect(find.text('Identifiant requis'), findsOneWidget);
    expect(find.text('Mot de passe requis'), findsOneWidget);
  });

  testWidgets('Nexus login matches desktop reference size', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1536, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsOneWidget);
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

    expect(find.text('CONNEXION'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
  });

  testWidgets('Nexus login adapts to tablet portrait without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(768, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
  });

  testWidgets('Nexus login adapts to small mobile without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });

  testWidgets('Nexus login adapts to short compact window without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(724, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('CONNEXION'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });

  testWidgets('Nexus login toggles password visibility', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    final passwordField = find.byKey(const ValueKey('login-password-field'));
    final visibilityButton = find.byKey(
      const ValueKey('login-password-visibility-button'),
    );

    EditableText editableText() {
      return tester.widget<EditableText>(
        find.descendant(of: passwordField, matching: find.byType(EditableText)),
      );
    }

    expect(editableText().obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(visibilityButton);
    await tester.pump();

    expect(editableText().obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(visibilityButton);
    await tester.pump();

    expect(editableText().obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets('Nexus login keeps mobile layout stable with password error', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextFormField).first, 'noxe');
    await tester.tap(find.text('SE CONNECTER'));
    await tester.pump();

    expect(find.text('Mot de passe requis'), findsOneWidget);
  });

  testWidgets('Nexus login opens register page', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    expect(find.text('INSCRIPTION'), findsOneWidget);
    expect(find.text('Créez votre accès Nexus'), findsOneWidget);
    expect(find.text('USERNAME'), findsOneWidget);
    expect(find.text('E-MAIL'), findsOneWidget);
  });

  testWidgets('Nexus register validates required fields', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CRÉER LE COMPTE'));
    await tester.pump();

    expect(find.text('Username requis'), findsOneWidget);
    expect(find.text('Mot de passe requis'), findsOneWidget);
    expect(find.text('Confirmation requise'), findsOneWidget);
  });

  testWidgets('Nexus register fits desktop height without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1526, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CRÉER LE COMPTE'));
    await tester.pump();

    expect(find.text('INSCRIPTION'), findsOneWidget);
    expect(find.text('Confirmation requise'), findsOneWidget);
  });

  testWidgets('Nexus register validates password confirmation', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'noxe');
    await tester.enterText(find.byType(TextFormField).at(2), 'MonPassword123!');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'AutrePassword123!',
    );
    await tester.tap(find.text('CRÉER LE COMPTE'));
    await tester.pump();

    expect(find.text('Les mots de passe ne correspondent pas'), findsOneWidget);
  });

  testWidgets(
    'Nexus register refreshes confirmation error after password edit',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'noxe');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'MonPassword123!',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'AutrePassword123!',
      );
      await tester.tap(find.text('CRÉER LE COMPTE'));
      await tester.pump();

      expect(
        find.text('Les mots de passe ne correspondent pas'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byType(TextFormField).at(2),
        'AutrePassword123!',
      );
      await tester.pump();

      expect(find.text('Les mots de passe ne correspondent pas'), findsNothing);
    },
  );

  testWidgets('Nexus home logout returns to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(routes: PageRouter.routes, home: const MyHomePage()),
    );

    expect(find.text('Déconnexion'), findsOneWidget);

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    expect(find.text('IDENTIFIANT'), findsOneWidget);
  });
}
