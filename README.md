# HElkady-PrayerQibla

Android app (Flutter): prayer times for a chosen city (Cairo by default), Qibla compass, and adhan alerts.
تطبيق أندرويد (فلاتر): مواقيت الصلاة للمدينة المختارة (القاهرة افتراضيًا)، بوصلة القبلة، وتنبيه الأذان.

## English
- 24 built-in cities, each with a sensible calculation method (Egyptian General Authority for Egypt). You can change the method and switch to Hanafi Asr.
- Qibla bearing is calculated from the city. The compass uses the phone's sensor and shows how far to turn.
- Adhan alerts: scheduled notifications for the next 7 days (per-prayer on/off). They are rescheduled when the app opens and after a reboot. The alert uses the phone's default notification sound, not a recorded adhan.
- English and Arabic UI. No internet, no accounts, no location permission. Data stays on the phone.
- Times are calculated with the `adhan` package. Check your local mosque for exact times.

Build: `flutter pub get && flutter test && flutter build apk --debug` (Flutter 3.50, JDK 21, Android SDK 37).

Tested: unit tests for times, qibla bearing, next prayer and alert planning. Not tested on a real device: the compass sensor and notification delivery.

## العربية
- 24 مدينة مدمجة بطريقة حساب مناسبة لكل منها (الهيئة المصرية العامة للمساحة لمصر). يمكن تغيير الطريقة واختيار العصر الحنفي.
- يُحسب اتجاه القبلة من المدينة، وتستخدم البوصلة حساس الهاتف وتعرض مقدار الدوران المطلوب.
- تنبيه الأذان: إشعارات مجدولة للأيام السبعة القادمة (تشغيل أو إيقاف لكل صلاة)، وتُعاد جدولتها عند فتح التطبيق وبعد إعادة تشغيل الهاتف. التنبيه يستخدم صوت الإشعار الافتراضي وليس تسجيل أذان.
- واجهة بالعربية والإنجليزية. بدون إنترنت أو حسابات أو إذن موقع. البيانات تبقى على الهاتف.
- الأوقات محسوبة بحزمة `adhan`. راجع مسجدك المحلي للأوقات الدقيقة.
