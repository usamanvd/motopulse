import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ride_khaata/main.dart';
import 'package:ride_khaata/providers/app_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final provider = AppProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const RideKhaataApp(),
      ),
    );
    // Advance past splash animation timer
    await tester.pump(const Duration(milliseconds: 3000));
    provider.dispose();
  });
}
