import 'package:flutter/material.dart';
import '../../services/weather_mandi_service.dart';
import '../../db/local_db.dart';
import '../../utils/design_tokens.dart';

/// Feature 6 — Weather Forecast & Agricultural Advisory
/// Open-Meteo API + 12-hour offline cache with red alert
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService(LocalDB());
  Map<String, dynamic>? _weather;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _locationLabel = 'लखनऊ, उत्तर प्रदेश';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather([String? location]) async {
    setState(() => _isLoading = true);
    final weather = await _weatherService.getWeather(location ?? 'UP001');
    setState(() { _weather = weather; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBg,
      appBar: buildKrishiAppBar(
        context: context,
        title: 'मौसम पूर्वानुमान',
        subtitle: 'WEATHER FORECAST & ADVISORY',
        emoji: '🌤️',
        actions: [
          IconButton(
            onPressed: _loadWeather,
            icon: const Icon(Icons.refresh_rounded, color: colorPrimary, size: 20),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              color: colorPrimary,
              onRefresh: _loadWeather,
              child: _buildWeatherUI(),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorPrimary, strokeWidth: 2),
          SizedBox(height: 16),
          Text('मौसम डेटा लोड हो रहा है...', style: tsBodySm),
        ],
      ),
    );
  }

  Widget _buildWeatherUI() {
    final current = _weather?['current'] as Map<String, dynamic>? ?? {};
    final forecast = _weather?['forecast_5day'] as List? ?? [];
    final advisory = _weather?['advisory_hi'] as String? ?? '';
    final hoursLeft = _weather?['hours_left_in_cache'] as double? ?? 12.0;
    final isOffline = _weather?['is_cached'] as bool? ?? false;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cache warning
          if (hoursLeft < 1.0) ...[
            buildCriticalAlert('⚠️ कैश पुराना है! इंटरनेट कनेक्ट करें — मौसम डेटा अपडेट करना ज़रूरी है।'),
            const SizedBox(height: spacingMd),
          ] else if (isOffline) ...[
            buildInfoBanner(
              'ऑफलाइन मोड — ${hoursLeft.toStringAsFixed(1)} घंटे पुराना डेटा दिखाया जा रहा है',
              icon: Icons.cloud_off_rounded,
              color: colorWarning,
              bgColor: colorWarningBg,
            ),
            const SizedBox(height: spacingMd),
          ],

          // Search bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: colorCard,
              borderRadius: BorderRadius.circular(radiusMd),
              border: Border.all(color: colorHairline),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded, color: colorStoneMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: tsHeadlineSm.copyWith(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'जिला / गांव खोजें...',
                      hintStyle: TextStyle(fontFamily: 'NotoSansDevanagari', fontSize: 13, color: colorStoneMuted),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (v) {
                      if (v.isNotEmpty) {
                        setState(() => _locationLabel = v);
                        _loadWeather(v);
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final v = _searchController.text;
                    if (v.isNotEmpty) { setState(() => _locationLabel = v); _loadWeather(v); }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(radiusSm)),
                    child: const Text('खोजें', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: spacingMd),

          // Current weather hero
          buildSectionHeader('01', 'CURRENT CONDITIONS'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(spacingLg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
              ),
              borderRadius: BorderRadius.circular(radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${current['temp_c'] ?? 28}°',
                      style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 56, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current['condition'] ?? 'आंशिक बादल',
                          style: const TextStyle(fontFamily: 'NotoSansDevanagari', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _locationLabel,
                          style: TextStyle(fontFamily: 'NotoSansDevanagari', fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _weatherStat('💧', '${current['humidity'] ?? 65}%', 'नमी'),
                    _weatherStat('💨', '${current['wind_kmh'] ?? 12} km/h', 'हवा'),
                    _weatherStat('🌧️', '${current['rain_prob'] ?? 20}%', 'बारिश'),
                    _weatherStat('☀️', '${current['uv_index'] ?? 7}', 'UV Index'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: spacingLg),

          // 5-day forecast
          buildSectionHeader('02', '5-DAY FORECAST'),
          buildCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (forecast.isEmpty)
                  ..._buildDefaultForecast()
                else
                  ...forecast.asMap().entries.map((e) => _buildForecastRow(e.value as Map<String, dynamic>, e.key, forecast.length)),
              ],
            ),
          ),
          const SizedBox(height: spacingLg),

          // Agricultural Advisory
          if (advisory.isNotEmpty) ...[
            buildSectionHeader('03', 'AGRI ADVISORY'),
            buildCard(
              bgColor: colorPrimarySoft,
              borderColor: colorPrimaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.agriculture_rounded, color: colorPrimary, size: 18),
                      SizedBox(width: 8),
                      Text('कृषि सलाह', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700, color: colorPrimary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(advisory, style: tsBody.copyWith(color: colorPrimaryDeep)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _weatherStat(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(label, style: TextStyle(fontFamily: 'NotoSansDevanagari', fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildForecastRow(Map<String, dynamic> day, int index, int total) {
    final isLast = index == total - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: 12),
      decoration: BoxDecoration(
        border: !isLast ? const Border(bottom: BorderSide(color: colorHairline, width: 1)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(day['day_hi'] ?? 'सोमवार', style: tsDevanagari.copyWith(fontSize: 13)),
          ),
          Text(day['icon'] ?? '⛅', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(day['condition'] ?? 'बादल', style: tsBodySm)),
          Text(
            '${day['high'] ?? 32}° / ${day['low'] ?? 22}°',
            style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, fontWeight: FontWeight.w500, color: colorStoneText),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDefaultForecast() {
    final days = [
      {'day_hi': 'कल', 'icon': '🌤️', 'condition': 'आंशिक बादल', 'high': 31, 'low': 21},
      {'day_hi': 'बुध', 'icon': '🌧️', 'condition': 'हल्की बारिश', 'high': 27, 'low': 19},
      {'day_hi': 'गुरु', 'icon': '⛈️', 'condition': 'भारी बारिश', 'high': 25, 'low': 18},
      {'day_hi': 'शुक्र', 'icon': '☁️', 'condition': 'बादल छाए', 'high': 29, 'low': 20},
      {'day_hi': 'शनि', 'icon': '☀️', 'condition': 'धूप', 'high': 33, 'low': 22},
    ];
    return days.asMap().entries.map((e) => _buildForecastRow(Map<String, dynamic>.from(e.value), e.key, days.length)).toList();
  }
}
