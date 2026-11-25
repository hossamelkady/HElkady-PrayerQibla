import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'prayer_logic.dart';
import 'settings.dart';
import 'strings.dart';

final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

const int kDaysAhead = 7;

Future<void> initNotifications() async {
  await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
}

Future<void> requestNotificationPermissions() async {
  final a = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await a?.requestNotificationsPermission();
  await a?.requestExactAlarmsPermission();
}

AndroidNotificationDetails _details(Str s) => AndroidNotificationDetails(
      'adhan_alerts',
      s.adhanAlerts,
      channelDescription: s.adhanAlerts,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      category: AndroidNotificationCategory.alarm,
    );

/// Pure helper (unit-tested): which (id, time, slot) alerts should exist.
List<({int id, tz.TZDateTime time, Slot slot})> planAlerts(
  AppSettings st,
  tz.TZDateTime now,
) {
  final out = <({int id, tz.TZDateTime time, Slot slot})>[];
  if (!st.adhanOn) return out;
  for (var d = 0; d < kDaysAhead; d++) {
    final day = DateTime(now.year, now.month, now.day + d);
    final times = timesForDay(st.city, day,
        method: st.effectiveMethod, hanafi: st.hanafi);
    for (final s in kAlertSlots) {
      if (!st.alertSlots.contains(s)) continue;
      final t = times.times[s]!;
      if (t.isAfter(now)) {
        out.add((id: d * 10 + s.index, time: t, slot: s));
      }
    }
  }
  return out;
}

Future<void> rescheduleAlerts(AppSettings st) async {
  await _plugin.cancelAll();
  final s = Str(st.arabic);
  final loc = tz.getLocation(st.city.tz);
  final now = tz.TZDateTime.now(loc);
  final a = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  final exactOk = await a?.canScheduleExactNotifications() ?? false;
  for (final p in planAlerts(st, now)) {
    await _plugin.zonedSchedule(
      id: p.id,
      title: s.slot(p.slot),
      body: '${s.adhanBody} - ${st.arabic ? st.city.ar : st.city.en}',
      scheduledDate: p.time,
      notificationDetails: NotificationDetails(android: _details(s)),
      androidScheduleMode: exactOk
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
