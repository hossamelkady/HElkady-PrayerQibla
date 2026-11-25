import 'dart:async';

import 'package:adhan/adhan.dart' show CalculationMethod;

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'cities.dart';
import 'notifier.dart';
import 'prayer_logic.dart';
import 'qibla_view.dart';
import 'settings.dart';
import 'strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  await initNotifications();
  final st = await AppSettings.load();
  runApp(PrayerApp(initial: st));
}

class PrayerApp extends StatefulWidget {
  final AppSettings initial;
  const PrayerApp({super.key, required this.initial});

  @override
  State<PrayerApp> createState() => _PrayerAppState();
}

class _PrayerAppState extends State<PrayerApp> {
  late AppSettings st = widget.initial;

  Future<void> _apply() async {
    await st.save();
    setState(() {});
    try {
      await rescheduleAlerts(st);
    } catch (_) {
      // Scheduling can fail on devices that deny alarms; the UI keeps working.
    }
  }

  @override
  void initState() {
    super.initState();
    rescheduleAlerts(st).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final s = Str(st.arabic);
    return MaterialApp(
      title: s.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        useMaterial3: true,
      ),
      builder: (context, child) => Directionality(
        textDirection: st.arabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: HomePage(st: st, s: s, onChanged: _apply),
    );
  }
}

class HomePage extends StatefulWidget {
  final AppSettings st;
  final Str s;
  final Future<void> Function() onChanged;
  const HomePage({super.key, required this.st, required this.s, required this.onChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final pages = [
      TimesView(st: widget.st, s: s),
      QiblaView(key: ValueKey(widget.st.cityId), city: widget.st.city, s: s),
      SettingsView(st: widget.st, s: s, onChanged: widget.onChanged),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle)),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.access_time), label: s.times),
          NavigationDestination(icon: const Icon(Icons.explore), label: s.qibla),
          NavigationDestination(icon: const Icon(Icons.settings), label: s.settings),
        ],
      ),
    );
  }
}

class TimesView extends StatefulWidget {
  final AppSettings st;
  final Str s;
  const TimesView({super.key, required this.st, required this.s});

  @override
  State<TimesView> createState() => _TimesViewState();
}

class _TimesViewState extends State<TimesView> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(tz.TZDateTime t) => DateFormat('hh:mm a', widget.s.ar ? 'en' : 'en').format(t);

  @override
  Widget build(BuildContext context) {
    final st = widget.st;
    final s = widget.s;
    final loc = tz.getLocation(st.city.tz);
    final now = tz.TZDateTime.now(loc);
    final today = timesForDay(st.city, DateTime(now.year, now.month, now.day),
        method: st.effectiveMethod, hanafi: st.hanafi);
    final nxt = nextPrayer(st.city, now,
        method: st.effectiveMethod, hanafi: st.hanafi);
    final left = nxt?.value.difference(now);
    String remaining() {
      if (left == null) return '';
      final h = left.inHours;
      final m = left.inMinutes % 60;
      return h > 0 ? '${h}h ${m}m' : '${m}m';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(st.arabic ? st.city.ar : st.city.en,
            style: Theme.of(context).textTheme.headlineSmall),
        Text('${s.today}: ${DateFormat('EEE d MMM yyyy').format(now)}'),
        const SizedBox(height: 12),
        if (nxt != null)
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text(s.next),
                Text(s.slot(nxt.key),
                    style: Theme.of(context).textTheme.headlineMedium),
                Text('${_fmt(nxt.value)}  (${s.in_} ${remaining()})'),
              ]),
            ),
          ),
        const SizedBox(height: 8),
        for (final slot in Slot.values)
          ListTile(
            key: ValueKey('row-${slot.name}'),
            leading: Icon(slot == nxt?.key ? Icons.notifications_active : Icons.schedule),
            title: Text(s.slot(slot)),
            trailing: Text(_fmt(today.times[slot]!),
                style: Theme.of(context).textTheme.titleMedium),
            selected: slot == nxt?.key,
          ),
        const SizedBox(height: 12),
        Text(s.note, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class SettingsView extends StatelessWidget {
  final AppSettings st;
  final Str s;
  final Future<void> Function() onChanged;
  const SettingsView({super.key, required this.st, required this.s, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        ListTile(
          title: Text(s.city),
          trailing: DropdownButton<String>(
            value: st.cityId,
            items: [
              for (final c in kCities)
                DropdownMenuItem(value: c.id, child: Text(s.ar ? c.ar : c.en)),
            ],
            onChanged: (v) {
              if (v == null) return;
              st.cityId = v;
              onChanged();
            },
          ),
        ),
        ListTile(
          title: Text(s.method),
          trailing: DropdownButton<CalculationMethod?>(
            value: st.method,
            items: [
              DropdownMenuItem(value: null, child: Text(s.methodDefault)),
              for (final m in kMethods)
                DropdownMenuItem(value: m, child: Text(s.methodName(m))),
            ],
            onChanged: (v) {
              st.method = v;
              onChanged();
            },
          ),
        ),
        SwitchListTile(
          title: Text(s.hanafi),
          value: st.hanafi,
          onChanged: (v) {
            st.hanafi = v;
            onChanged();
          },
        ),
        SwitchListTile(
          title: Text(s.language),
          value: st.arabic,
          onChanged: (v) {
            st.arabic = v;
            onChanged();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: Text(s.adhanAlerts),
          value: st.adhanOn,
          onChanged: (v) async {
            st.adhanOn = v;
            if (v) await requestNotificationPermissions();
            await onChanged();
          },
        ),
        if (st.adhanOn) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(s.alertsFor),
          ),
          for (final slot in kAlertSlots)
            CheckboxListTile(
              title: Text(s.slot(slot)),
              value: st.alertSlots.contains(slot),
              onChanged: (v) {
                if (v == true) {
                  st.alertSlots.add(slot);
                } else {
                  st.alertSlots.remove(slot);
                }
                onChanged();
              },
            ),
        ],
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(s.notifPerm),
          onTap: requestNotificationPermissions,
        ),
      ],
    );
  }
}
