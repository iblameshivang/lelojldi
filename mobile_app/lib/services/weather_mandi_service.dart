import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db/local_db.dart';

/// Weather service for local caching and display.
class WeatherService {
  final LocalDB _db;
  
  WeatherService(this._db);

  /// Get weather for a district (cached or fetch).
  Future<Map<String, dynamic>> getWeather(String districtCode) async {
    // 1. Check local DB cache
    final cached = await _db.getCachedWeather(districtCode);
    if (cached != null) {
      final cachedAt = DateTime.parse(cached['cached_at'] as String);
      final expiresAt = cachedAt.add(const Duration(hours: 12));
      final hoursLeft = expiresAt.difference(DateTime.now()).inMinutes / 60.0;
      
      if (hoursLeft > 0) {
        cached['hours_left_in_cache'] = hoursLeft;
        return cached;
      }
    }

    // 2. Fetch from backend API
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/v1/weather/forecast?district_code=$districtCode'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final forecast = data['forecast_data'] as Map<String, dynamic>;
        
        forecast['district_code'] = districtCode;
        forecast['cached_at'] = DateTime.now().toIso8601String();
        
        await _db.cacheWeather(districtCode, forecast);
        
        forecast['hours_left_in_cache'] = 12.0;
        return forecast;
      }
    } catch (e) {
      print('Network error fetching weather: $e');
    }

    // 3. Fallback to demo or expired cache
    if (cached != null) {
      cached['hours_left_in_cache'] = 0.0;
      return cached;
    }
    
    final demo = _generateDemoForecast(districtCode);
    demo['hours_left_in_cache'] = 12.0;
    return demo;
  }

  /// Get USSD-compressed weather string.
  Future<String> getUssdPayload(String districtCode) async {
    final weather = await _db.getCachedWeather(districtCode);
    if (weather == null) return 'WX|$districtCode|NA';

    final current = weather['current'] as Map<String, dynamic>?;
    if (current == null) return 'WX|$districtCode|NA';

    return 'WX|$districtCode|${current['temp_c']}°C|${current['humidity_pct']}%|${current['rainfall_mm']}mm';
  }

  Map<String, dynamic> _generateDemoForecast(String district) {
    return {
      'district_code': district,
      'cached_at': DateTime.now().toIso8601String(),
      'current': {
        'temp_c': 30,
        'humidity_pct': 65,
        'wind_speed_kmh': 12,
        'wind_direction': 'SW',
        'condition': 'Partly Cloudy',
        'condition_hi': 'आंशिक बादल',
        'rainfall_mm': 0,
      },
      'forecast_5day': [
        {'date': '2026-09-13', 'max_c': 31, 'min_c': 24, 'rain_mm': 5, 'condition_hi': 'हल्की बारिश'},
        {'date': '2026-09-14', 'max_c': 30, 'min_c': 23, 'rain_mm': 12, 'condition_hi': 'मध्यम बारिश'},
        {'date': '2026-09-15', 'max_c': 29, 'min_c': 23, 'rain_mm': 8, 'condition_hi': 'हल्की बारिश'},
        {'date': '2026-09-16', 'max_c': 31, 'min_c': 24, 'rain_mm': 0, 'condition_hi': 'धूप'},
        {'date': '2026-09-17', 'max_c': 32, 'min_c': 25, 'rain_mm': 0, 'condition_hi': 'साफ'},
      ],
      'advisory_hi': 'कम बारिश की संभावना। फसल सिंचाई पर ध्यान दें।',
    };
  }
}

/// Mandi price service for local caching and display.
class MandiService {
  final List<MandiPrice> _cachedPrices = [];

  /// Get mandi prices (cached or fetch).
  Future<List<MandiPrice>> getPrices({String? districtCode, String? cropName}) async {
    if (_cachedPrices.isEmpty) {
      _cachedPrices.addAll(_generateDemoPrices());
    }

    var filtered = _cachedPrices.toList();
    if (cropName != null) {
      filtered = filtered.where((p) =>
        p.cropName.toLowerCase().contains(cropName.toLowerCase()) ||
        p.cropNameHi.contains(cropName)
      ).toList();
    }
    return filtered;
  }

  List<MandiPrice> _generateDemoPrices() {
    return [
      MandiPrice(cropName: 'Wheat', cropNameHi: 'गेहूं', price: 2450, trend: 'up', change: 3.2),
      MandiPrice(cropName: 'Rice', cropNameHi: 'चावल', price: 3100, trend: 'stable', change: 0.5),
      MandiPrice(cropName: 'Maize', cropNameHi: 'मक्का', price: 1950, trend: 'down', change: -2.1),
      MandiPrice(cropName: 'Tomato', cropNameHi: 'टमाटर', price: 1800, trend: 'up', change: 8.5),
      MandiPrice(cropName: 'Onion', cropNameHi: 'प्याज', price: 2200, trend: 'up', change: 5.3),
      MandiPrice(cropName: 'Potato', cropNameHi: 'आलू', price: 1200, trend: 'stable', change: 0.2),
      MandiPrice(cropName: 'Soybean', cropNameHi: 'सोयाबीन', price: 4500, trend: 'down', change: -1.8),
      MandiPrice(cropName: 'Cotton', cropNameHi: 'कपास', price: 6200, trend: 'up', change: 2.7),
      MandiPrice(cropName: 'Mustard', cropNameHi: 'सरसों', price: 5100, trend: 'up', change: 4.1),
      MandiPrice(cropName: 'Sugarcane', cropNameHi: 'गन्ना', price: 350, trend: 'stable', change: 0.0),
    ];
  }
}

class MandiPrice {
  final String cropName;
  final String cropNameHi;
  final double price; // ₹ per quintal
  final String trend; // up, down, stable
  final double change; // percentage

  MandiPrice({
    required this.cropName,
    required this.cropNameHi,
    required this.price,
    required this.trend,
    required this.change,
  });

  String get trendEmoji {
    switch (trend) {
      case 'up': return '📈';
      case 'down': return '📉';
      default: return '➡️';
    }
  }
}
