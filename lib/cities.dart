import 'package:adhan/adhan.dart';

class City {
  final String id;
  final String en;
  final String ar;
  final double lat;
  final double lon;
  final String tz;
  final CalculationMethod method;
  const City(this.id, this.en, this.ar, this.lat, this.lon, this.tz, this.method);
}

const kDefaultCityId = 'cairo';

const List<City> kCities = [
  City('cairo', 'Cairo', 'القاهرة', 30.0444, 31.2357, 'Africa/Cairo', CalculationMethod.egyptian),
  City('alexandria', 'Alexandria', 'الإسكندرية', 31.2001, 29.9187, 'Africa/Cairo', CalculationMethod.egyptian),
  City('giza', 'Giza', 'الجيزة', 30.0131, 31.2089, 'Africa/Cairo', CalculationMethod.egyptian),
  City('shorouk', 'El Shorouk', 'الشروق', 30.1189, 31.6050, 'Africa/Cairo', CalculationMethod.egyptian),
  City('aswan', 'Aswan', 'أسوان', 24.0889, 32.8998, 'Africa/Cairo', CalculationMethod.egyptian),
  City('makkah', 'Makkah', 'مكة المكرمة', 21.3891, 39.8579, 'Asia/Riyadh', CalculationMethod.umm_al_qura),
  City('madinah', 'Madinah', 'المدينة المنورة', 24.5247, 39.5692, 'Asia/Riyadh', CalculationMethod.umm_al_qura),
  City('riyadh', 'Riyadh', 'الرياض', 24.7136, 46.6753, 'Asia/Riyadh', CalculationMethod.umm_al_qura),
  City('jeddah', 'Jeddah', 'جدة', 21.4858, 39.1925, 'Asia/Riyadh', CalculationMethod.umm_al_qura),
  City('dubai', 'Dubai', 'دبي', 25.2048, 55.2708, 'Asia/Dubai', CalculationMethod.dubai),
  City('doha', 'Doha', 'الدوحة', 25.2854, 51.5310, 'Asia/Qatar', CalculationMethod.qatar),
  City('kuwait', 'Kuwait City', 'مدينة الكويت', 29.3759, 47.9774, 'Asia/Riyadh', CalculationMethod.kuwait),
  City('amman', 'Amman', 'عمّان', 31.9454, 35.9284, 'Asia/Amman', CalculationMethod.muslim_world_league),
  City('jerusalem', 'Jerusalem', 'القدس', 31.7683, 35.2137, 'Asia/Jerusalem', CalculationMethod.muslim_world_league),
  City('beirut', 'Beirut', 'بيروت', 33.8938, 35.5018, 'Asia/Beirut', CalculationMethod.muslim_world_league),
  City('baghdad', 'Baghdad', 'بغداد', 33.3152, 44.3661, 'Asia/Baghdad', CalculationMethod.muslim_world_league),
  City('casablanca', 'Casablanca', 'الدار البيضاء', 33.5731, -7.5898, 'Africa/Casablanca', CalculationMethod.muslim_world_league),
  City('tunis', 'Tunis', 'تونس', 36.8065, 10.1815, 'Africa/Tunis', CalculationMethod.muslim_world_league),
  City('algiers', 'Algiers', 'الجزائر', 36.7538, 3.0588, 'Africa/Algiers', CalculationMethod.muslim_world_league),
  City('khartoum', 'Khartoum', 'الخرطوم', 15.5007, 32.5599, 'Africa/Khartoum', CalculationMethod.egyptian),
  City('istanbul', 'Istanbul', 'إسطنبول', 41.0082, 28.9784, 'Europe/Istanbul', CalculationMethod.turkey),
  City('karachi', 'Karachi', 'كراتشي', 24.8607, 67.0011, 'Asia/Karachi', CalculationMethod.karachi),
  City('london', 'London', 'لندن', 51.5074, -0.1278, 'Europe/London', CalculationMethod.muslim_world_league),
  City('newyork', 'New York', 'نيويورك', 40.7128, -74.0060, 'America/New_York', CalculationMethod.north_america),
];

City cityById(String id) =>
    kCities.firstWhere((c) => c.id == id, orElse: () => kCities.first);
