import 'package:auth_api_test/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders auth api test controls', (tester) async {
    await tester.pumpWidget(const AuthApiTestApp());

    expect(find.text('Nexus Auth API Test'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
    expect(find.text('OAuth Login'), findsOneWidget);
  });
}
