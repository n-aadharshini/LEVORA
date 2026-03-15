import 'package:flutter_test/flutter_test.dart';
import 'package:levora/main.dart';

void main() {
  testWidgets('Levora app test', (WidgetTester tester) async {
    await tester.pumpWidget(const LevoraApp());
  });
}
