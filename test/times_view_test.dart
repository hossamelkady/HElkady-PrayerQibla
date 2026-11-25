import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:helkady_prayer_qibla/main.dart';
import 'package:helkady_prayer_qibla/strings.dart';
import 'package:helkady_prayer_qibla/settings.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(() async {
    tzdata.initializeTimeZones();
    await initializeDateFormatting('en');
  });
  testWidgets('times view renders rows', (t) async {
    await t.pumpWidget(MaterialApp(home: Scaffold(body: TimesView(st: AppSettings(), s: Str(false)))));
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
  });
}
