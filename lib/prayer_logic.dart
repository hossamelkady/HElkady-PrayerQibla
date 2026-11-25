import 'package:adhan/adhan.dart';
import 'package:timezone/timezone.dart' as tz;

import 'cities.dart';

/// The five daily prayers plus sunrise, in order.
enum Slot { fajr, sunrise, dhuhr, asr, maghrib, isha }

const List<Slot> kAlertSlots = [
  Slot.fajr,
  Slot.dhuhr,
  Slot.asr,
  Slot.maghrib,
  Slot.isha,
];

class DayTimes {
  final DateTime date; // calendar day in the city (only y/m/d matter)
  final Map<Slot, tz.TZDateTime> times;
  const DayTimes(this.date, this.times);
}

CalculationParameters paramsFor(CalculationMethod method, {bool hanafi = false}) {
  final p = method.getParameters();
  p.madhab = hanafi ? Madhab.hanafi : Madhab.shafi;
  return p;
}

/// Prayer times for [day] (y/m/d) in [city], expressed in the city's own time zone.
/// Requires `tz.initializeTimeZones()` to have been called.
DayTimes timesForDay(
  City city,
  DateTime day, {
  CalculationMethod? method,
  bool hanafi = false,
}) {
  final loc = tz.getLocation(city.tz);
  final pt = PrayerTimes.utc(
    Coordinates(city.lat, city.lon),
    DateComponents(day.year, day.month, day.day),
    paramsFor(method ?? city.method, hanafi: hanafi),
  );
  tz.TZDateTime c(DateTime t) => tz.TZDateTime.from(t, loc);
  return DayTimes(day, {
    Slot.fajr: c(pt.fajr),
    Slot.sunrise: c(pt.sunrise),
    Slot.dhuhr: c(pt.dhuhr),
    Slot.asr: c(pt.asr),
    Slot.maghrib: c(pt.maghrib),
    Slot.isha: c(pt.isha),
  });
}

/// The next prayer (of the five obligatory ones) strictly after [now], looking
/// at today and tomorrow. Returns null only if something is badly wrong.
MapEntry<Slot, tz.TZDateTime>? nextPrayer(
  City city,
  tz.TZDateTime now, {
  CalculationMethod? method,
  bool hanafi = false,
}) {
  for (var add = 0; add < 2; add++) {
    final d = DateTime(now.year, now.month, now.day + add);
    final dt = timesForDay(city, d, method: method, hanafi: hanafi);
    for (final s in kAlertSlots) {
      final t = dt.times[s]!;
      if (t.isAfter(now)) return MapEntry(s, t);
    }
  }
  return null;
}

/// Qibla bearing in degrees clockwise from true north.
double qiblaBearing(City city) => Qibla(Coordinates(city.lat, city.lon)).direction;

/// Signed smallest rotation (-180..180] needed to turn from [heading] to [target].
double angleDelta(double heading, double target) {
  var d = (target - heading) % 360;
  if (d > 180) d -= 360;
  if (d <= -180) d += 360;
  return d;
}
