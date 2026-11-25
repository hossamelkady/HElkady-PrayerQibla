import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helkady_prayer_qibla/cities.dart';
import 'package:helkady_prayer_qibla/notifier.dart';
import 'package:helkady_prayer_qibla/prayer_logic.dart';
import 'package:helkady_prayer_qibla/settings.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('Cairo prayer times are in order and plausible (Nov 25 2026)', () {
    final t = timesForDay(cityById('cairo'), DateTime(2026, 11, 25));
    final v = Slot.values.map((s) => t.times[s]!).toList();
    for (var i = 1; i < v.length; i++) {
      expect(v[i].isAfter(v[i - 1]), isTrue);
    }
    // Cairo in late November (UTC+2): Fajr ~5am, Dhuhr ~11:45, Maghrib ~5pm.
    expect(t.times[Slot.fajr]!.hour, inInclusiveRange(4, 5));
    expect(t.times[Slot.dhuhr]!.hour, inInclusiveRange(11, 12));
    expect(t.times[Slot.maghrib]!.hour, inInclusiveRange(16, 17));
    expect(t.times[Slot.isha]!.hour, inInclusiveRange(18, 19));
    expect(t.times[Slot.fajr]!.timeZoneOffset, const Duration(hours: 2));
  });

  test('Qibla bearing from Cairo is about 136 degrees', () {
    expect(qiblaBearing(cityById('cairo')), inInclusiveRange(134, 138));
  });

  test('Qibla from London is about 119 degrees', () {
    expect(qiblaBearing(cityById('london')), inInclusiveRange(117, 121));
  });

  test('angleDelta wraps correctly', () {
    expect(angleDelta(350, 10), 20);
    expect(angleDelta(10, 350), -20);
    expect(angleDelta(0, 180), 180);
    expect(angleDelta(90, 90), 0);
  });

  test('nextPrayer rolls over to tomorrow Fajr after Isha', () {
    final loc = tz.getLocation('Africa/Cairo');
    final late = tz.TZDateTime(loc, 2026, 11, 25, 23, 30);
    final n = nextPrayer(cityById('cairo'), late)!;
    expect(n.key, Slot.fajr);
    expect(n.value.day, 26);
  });

  test('planAlerts: 7 days x 5 prayers from midnight, respects toggles', () {
    final loc = tz.getLocation('Africa/Cairo');
    final now = tz.TZDateTime(loc, 2026, 11, 25, 0, 1);
    final st = AppSettings();
    expect(planAlerts(st, now).length, 35);
    st.alertSlots = {Slot.fajr};
    expect(planAlerts(st, now).length, 7);
    st.adhanOn = false;
    expect(planAlerts(st, now), isEmpty);
    final ids = planAlerts(AppSettings(), now).map((e) => e.id).toSet();
    expect(ids.length, 35);
  });

  test('every city has a valid tz and sane times', () {
    for (final c in kCities) {
      final t = timesForDay(c, DateTime(2026, 6, 21), method: CalculationMethod.muslim_world_league);
      expect(t.times[Slot.fajr]!.isBefore(t.times[Slot.isha]!), isTrue, reason: c.id);
    }
  });
}
