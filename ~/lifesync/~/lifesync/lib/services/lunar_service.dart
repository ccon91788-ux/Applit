import 'package:vnlunar/vnlunar.dart';

/// Cached Vietnamese lunar calendar conversion.
class LunarService {
  static final Map<String, String> _cache = {};
  static const int _maxCache = 500;

  static String formatLunar(DateTime solar) {
    final key =
        '${solar.year}-${solar.month.toString().padLeft(2, '0')}-${solar.day.toString().padLeft(2, '0')}';
    if (_cache.containsKey(key)) return _cache[key]!;

    try {
      final lunar = Lunar(createdFromSolar: true, date: solar);
      final day = lunar.day;
      final month = lunar.month;
      final leap = (lunar.leapMonth == true) ? ' (nhuận)' : '';
      final result =
          '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')} ÂL$leap';
      if (_cache.length >= _maxCache) {
        _cache.remove(_cache.keys.first);
      }
      _cache[key] = result;
      return result;
    } catch (_) {
      return '';
    }
  }

  static void clearCache() => _cache.clear();
}
