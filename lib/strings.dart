import 'package:adhan/adhan.dart';

import 'prayer_logic.dart';

class Str {
  final bool ar;
  const Str(this.ar);

  String get appTitle => ar ? 'مواقيت الصلاة والقبلة' : 'Prayer Times & Qibla';
  String get times => ar ? 'المواقيت' : 'Times';
  String get qibla => ar ? 'القبلة' : 'Qibla';
  String get settings => ar ? 'الإعدادات' : 'Settings';
  String get city => ar ? 'المدينة' : 'City';
  String get method => ar ? 'طريقة الحساب' : 'Calculation method';
  String get methodDefault => ar ? 'افتراضي المدينة' : 'City default';
  String get hanafi => ar ? 'العصر على المذهب الحنفي' : 'Hanafi Asr';
  String get adhanAlerts => ar ? 'تنبيه الأذان' : 'Adhan alerts';
  String get alertsFor => ar ? 'التنبيه للصلوات' : 'Alert for';
  String get language => ar ? 'العربية' : 'Arabic (العربية)';
  String get next => ar ? 'الصلاة القادمة' : 'Next prayer';
  String get in_ => ar ? 'بعد' : 'in';
  String get today => ar ? 'اليوم' : 'Today';
  String get qiblaBearing => ar ? 'اتجاه القبلة' : 'Qibla bearing';
  String get fromNorth => ar ? 'من الشمال الحقيقي' : 'from true north';
  String get noCompass => ar
      ? 'لا يوجد حساس بوصلة في هذا الجهاز. استخدم زاوية الاتجاه أعلاه مع بوصلة أخرى.'
      : 'No compass sensor on this device. Use the bearing above with another compass.';
  String get calibrate => ar
      ? 'حرّك الهاتف على شكل 8 لمعايرة البوصلة، وابتعد عن المعادن.'
      : 'Move the phone in a figure 8 to calibrate, and keep away from metal.';
  String get aligned => ar ? 'أنت في اتجاه القبلة' : 'You are facing the Qibla';
  String turn(double d) {
    final a = d.abs().round();
    final right = d > 0;
    return ar
        ? 'لف $a° ${right ? 'يمينًا' : 'يسارًا'}'
        : 'Turn $a° ${right ? 'right' : 'left'}';
  }
  String get notifPerm => ar ? 'السماح بالإشعارات' : 'Allow notifications';
  String get adhanBody => ar ? 'حان وقت الصلاة' : 'It is time to pray';
  String get note => ar
      ? 'الأوقات محسوبة تقريبيًا بحسب المدينة المختارة. تحقق من أوقات مسجدك المحلي.'
      : 'Times are calculated for the chosen city. Check your local mosque for exact times.';

  String slot(Slot s) {
    switch (s) {
      case Slot.fajr:
        return ar ? 'الفجر' : 'Fajr';
      case Slot.sunrise:
        return ar ? 'الشروق' : 'Sunrise';
      case Slot.dhuhr:
        return ar ? 'الظهر' : 'Dhuhr';
      case Slot.asr:
        return ar ? 'العصر' : 'Asr';
      case Slot.maghrib:
        return ar ? 'المغرب' : 'Maghrib';
      case Slot.isha:
        return ar ? 'العشاء' : 'Isha';
    }
  }

  String methodName(CalculationMethod m) {
    const arNames = {
      CalculationMethod.egyptian: 'الهيئة المصرية العامة للمساحة',
      CalculationMethod.muslim_world_league: 'رابطة العالم الإسلامي',
      CalculationMethod.karachi: 'جامعة العلوم الإسلامية كراتشي',
      CalculationMethod.umm_al_qura: 'أم القرى',
      CalculationMethod.dubai: 'الخليج / دبي',
      CalculationMethod.qatar: 'قطر',
      CalculationMethod.kuwait: 'الكويت',
      CalculationMethod.turkey: 'تركيا (ديانت)',
      CalculationMethod.north_america: 'أمريكا الشمالية (ISNA)',
    };
    const enNames = {
      CalculationMethod.egyptian: 'Egyptian General Authority',
      CalculationMethod.muslim_world_league: 'Muslim World League',
      CalculationMethod.karachi: 'Karachi (UISK)',
      CalculationMethod.umm_al_qura: 'Umm al-Qura',
      CalculationMethod.dubai: 'Gulf / Dubai',
      CalculationMethod.qatar: 'Qatar',
      CalculationMethod.kuwait: 'Kuwait',
      CalculationMethod.turkey: 'Turkey (Diyanet)',
      CalculationMethod.north_america: 'North America (ISNA)',
    };
    return (ar ? arNames : enNames)[m] ?? m.name;
  }
}

const List<CalculationMethod> kMethods = [
  CalculationMethod.egyptian,
  CalculationMethod.muslim_world_league,
  CalculationMethod.karachi,
  CalculationMethod.umm_al_qura,
  CalculationMethod.dubai,
  CalculationMethod.qatar,
  CalculationMethod.kuwait,
  CalculationMethod.turkey,
  CalculationMethod.north_america,
];
