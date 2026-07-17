import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oficina_app/main.dart';

void main() {
  testWidgets('App inicia na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: A2MMotosApp()));
    await tester.pumpAndSettle();

    expect(find.text('A2M Motos'), findsOneWidget);
  });
}
