import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cities.dart';
import 'prayer_logic.dart';

class AppSettings {
  String cityId;
  bool arabic;
  bool hanafi;
  CalculationMethod? method; // null = city default
  bool adhanOn;
  Set<Slot> alertSlots;

  AppSettings({
    this.cityId = kDefaultCityId,
    this.arabic = false,
    this.hanafi = false,
    this.method,
    this.adhanOn = true,
    Set<Slot>? alertSlots,
  }) : alertSlots = alertSlots ?? kAlertSlots.toSet();

  City get city => cityById(cityId);
  CalculationMethod get effectiveMethod => method ?? city.method;

  static Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final m = p.getString('method');
    final slots = p.getStringList('slots');
    return AppSettings(
      cityId: p.getString('city') ?? kDefaultCityId,
      arabic: p.getBool('ar') ?? false,
      hanafi: p.getBool('hanafi') ?? false,
      method: m == null
          ? null
          : CalculationMethod.values.where((e) => e.name == m).firstOrNull,
      adhanOn: p.getBool('adhan') ?? true,
      alertSlots: slots == null
          ? null
          : Slot.values.where((s) => slots.contains(s.name)).toSet(),
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('city', cityId);
    await p.setBool('ar', arabic);
    await p.setBool('hanafi', hanafi);
    if (method == null) {
      await p.remove('method');
    } else {
      await p.setString('method', method!.name);
    }
    await p.setBool('adhan', adhanOn);
    await p.setStringList('slots', alertSlots.map((e) => e.name).toList());
  }
}
