import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oficina_app/main.dart';

void main() {
  testWidgets('App inicia na tela principal', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OficinaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Oficina'), findsOneWidget);
    expect(find.text('Atendimento'), findsOneWidget);
  });
}
