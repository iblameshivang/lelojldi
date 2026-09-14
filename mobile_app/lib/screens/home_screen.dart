import 'package:flutter/material.dart';

import 'diagnosis/diagnosis_screen.dart';
import 'weather/weather_screen.dart';
import 'mandi/mandi_screen.dart';
import 'mesh/mesh_screen.dart';
import 'voice_chat/voice_chat_screen.dart';
import 'counterfeit/counterfeit_screen.dart';
import 'ar_spray/ar_spray_screen.dart';
import 'soil_test/soil_test_screen.dart';
import 'insurance/insurance_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'settings/settings_screen.dart';
import 'telecom/ussd_sms_screen.dart';

/// Krishi-Saarthi OS — Editorial Field Sanctuary Design System
/// Implemented directly from Google Stitch architecture & design palette
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Stitch Design Tokens — Tactile Pragmatism & Editorial Field Sanctuary
  static const Color colorBg = Color(0xFFFAF8F5);
  static const Color colorSurface = Color(0xFFFDFBF7);
  static const Color colorCard = Color(0xFFFFFFFF);
  static const Color colorPrimary = Color(0xFF1B4332);
  static const Color colorPrimaryForest = Color(0xFF153324);
  static const Color colorPrimaryDeep = Color(0xFF081810);
  static const Color colorPrimaryLight = Color(0xFF2D6A4F);
  static const Color colorPrimarySoft = Color(0xFFE8F0EC);
  static const Color colorSecondary = Color(0xFF8B5A2B);
  static const Color colorBronze = Color(0xFFA3824C);
  static const Color colorBronzeLight = Color(0xFFC2A268);
  static const Color colorBronzeMuted = Color(0xFFEADBCE);
  static const Color colorEarthAlert = Color(0xFF9B4522);
  static const Color colorOchre = Color(0xFFC87D32);
  static const Color colorOchreLight = Color(0xFFFAF3E8);
  static const Color colorStoneText = Color(0xFF1E2420);
  static const Color colorStoneMuted = Color(0xFF6E756F);
  static const Color colorHairline = Color(0xFFE7E4DC);

  String _currentLanguage = 'Hinglish';
  AnimationController? _waveController;

  AnimationController get waveController {
    if (_waveController == null) {
      _waveController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    }
    return _waveController!;
  }

  @override
  void initState() {
    super.initState();
    waveController;
  }

  @override
  void dispose() {
    _waveController?.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBg,
      body: Stack(
        children: [
          // Scrollable Page Content
          CustomScrollView(
            slivers: [
              _buildStitchHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 18),
                      _buildAlertAndWeatherGrid(),
                      const SizedBox(height: 24),
                      _buildDailyEssentialTools(),
                      const SizedBox(height: 20),
                      _buildVoiceSaarthiLiveBanner(),
                      const SizedBox(height: 20),
                      _buildGaonMeshNotes(),
                      const SizedBox(height: 24),
                      _buildSpecializedAgronomySuite(),
                      const SizedBox(height: 100), // Space for floating bottom dock
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Navigation Dock
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildFloatingBottomDock(),
          ),

          // Kisan AI Floating Action Button
          Positioned(
            right: 16,
            bottom: 90,
            child: _buildKisanAiFab(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. STITCH HEADER
  // ==========================================
  Widget _buildStitchHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: colorBg.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      toolbarHeight: 64,
      title: Row(
        children: [
          const Text(
            'Krishi-Saarthi',
            style: TextStyle(
              color: colorPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.spa_rounded, color: Color(0xFF2D6A4F), size: 19),
          const SizedBox(width: 4),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      actions: [
        // Language Selector Pill Button
        InkWell(
          onTap: _showLanguagePicker,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colorSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorHairline),
            ),
            child: Row(
              children: [
                Text(
                  _currentLanguage,
                  style: const TextStyle(
                    color: colorPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.expand_more_rounded, size: 16, color: colorStoneMuted),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 13 Features Menu Button
        InkWell(
          onTap: _showFeaturesDrawer,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorHairline),
            ),
            child: const Icon(Icons.menu_rounded, size: 20, color: colorStoneText),
          ),
        ),
        const SizedBox(width: 8),

        // Google Profile Avatar
        InkWell(
          onTap: _showProfileModal,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF3B82F6)],
              ),
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'RS',
                  style: TextStyle(
                    color: colorPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  // ==========================================
  // 2. ATMOSPHERIC HERO VIGNETTE & TELEMETRY
  // ==========================================
  Widget _buildHeroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 275,
        decoration: BoxDecoration(
          color: colorPrimaryDeep,
          border: Border.all(color: colorHairline),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Authentic Farmer Portrait Image
            Image.asset(
              'assets/images/farmer_portrait.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://lh3.googleusercontent.com/aida/AEtjO1WYcoQNGHoFRLDscuKY3iCLESkUWdPip4Nxaw3WAVcE31lVwXSmkxYvOubgX8z6TzGRZ4WA_gYAbOGpX64cTjsebSwb_ZBkqZMGsVZfdFMkUbQXZqfWCJY3gbvdbjy1UB2Y6-OqrQhUd-IQB1qmaS4TMLfhv1eZLUKNJCCkIiEfSD61NhUIZLgYvb6mrEhAh_NIJ3SGPcDpCuNpqWuoGIk4xNRKDRR4wRVkfua2-axcpQBQxCQYchHYGJ0',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF081810), Color(0xFF153324), Color(0xFF1B4332)],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Editorial Contrast Gradients
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    colorPrimaryForest.withValues(alpha: 0.65),
                    colorPrimaryDeep.withValues(alpha: 0.96),
                  ],
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Telemetry Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: colorBronzeLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '001 • LIVE CANOPY TELEMETRY',
                              style: TextStyle(
                                color: Color(0xFFEADBCE),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: const Text(
                          'RABI SEASON 2024-25',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Middle: Editorial Greeting & Microclimate Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ram-Ram Rameshwar Ji — Khet surakshit hai',
                        style: TextStyle(
                          color: Color(0xFFFAF8F5),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Khet mein nami 42% hai. Agle 4 ghante mein barish ki sambhavna hai.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Refined Tri-Metric Glass Bar
                      Row(
                        children: [
                          Expanded(
                            child: _buildTriMetricPill(
                              value: '42%',
                              label: 'MITTI NAMI',
                              sublabel: 'Moisture',
                              onTap: () => _navigateTo(const DashboardScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTriMetricPill(
                              value: '31°C',
                              label: 'SONIPAT',
                              sublabel: 'Air Temp',
                              onTap: () => _navigateTo(const WeatherScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTriMetricPill(
                              value: '0.78',
                              label: 'NDVI HEALTH',
                              sublabel: 'Canopy',
                              onTap: () => _navigateTo(const DashboardScreen()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriMetricPill({
    required String value,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFC2A268),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              sublabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. SECTION 01 / VECTOR INTELLIGENCE & TELEMETRY
  // ==========================================
  Widget _buildAlertAndWeatherGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '01 / ',
                  style: TextStyle(
                    color: colorBronze,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'VECTOR INTELLIGENCE & TELEMETRY',
                  style: TextStyle(
                    color: colorStoneText,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const Text(
              'Spatiotemporal Drift',
              style: TextStyle(
                color: colorStoneMuted,
                fontSize: 9.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Vector Alert Card (Earth-Alert Strip)
        InkWell(
          onTap: () => _navigateTo(const DiagnosisScreen()),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorHairline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Terracotta red left accent border
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: colorEarthAlert,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: colorEarthAlert,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'PATHOGEN VECTOR ALERT · 12KM RADIUS',
                                style: TextStyle(
                                  color: colorEarthAlert,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.warning_amber_rounded, size: 16, color: colorEarthAlert),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Hawa mein Peela Ratua (Yellow Rust) ka risk mila hai',
                        style: TextStyle(
                          color: colorStoneText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pass ke 12km khet mein fafund ka asar hai. Dophar barish se pehle neem-tail ya bio-spray protocol check karein.',
                        style: TextStyle(
                          color: colorStoneMuted,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: colorHairline, height: 1),
                      const SizedBox(height: 8),

                      // Calibrated Action Line
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recommended: 5% Neem Bio-Emulsion',
                            style: TextStyle(
                              color: colorBronze,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Protocol View',
                                style: TextStyle(
                                  color: colorPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '→',
                                style: TextStyle(
                                  color: colorPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Weather & Soil Telemetry Card
        InkWell(
          onTap: () => _navigateTo(const WeatherScreen()),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorHairline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colorPrimarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.cloud_queue_rounded, color: colorPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Sonipat, Haryana · 31°C',
                              style: TextStyle(
                                color: colorStoneText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorPrimarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Live Synced',
                                style: TextStyle(
                                  color: colorPrimary,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Halki Nami · 4 ghante mein barish expected',
                          style: TextStyle(color: colorStoneMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: colorHairline)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Mitti Nami:',
                        style: TextStyle(
                          color: colorStoneMuted,
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '42%',
                            style: TextStyle(
                              color: colorPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. SECTION 02 / THE ESSENTIAL PROTOCOLS (2x2 GRID)
  // ==========================================
  Widget _buildDailyEssentialTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '02 / ',
                  style: TextStyle(
                    color: colorBronze,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'THE ESSENTIAL PROTOCOLS',
                  style: TextStyle(
                    color: colorStoneText,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const Text(
              'Daily Essential Tools',
              style: TextStyle(
                color: colorStoneMuted,
                fontSize: 9.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Grid of 4 Physical Cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: [
            _buildDailyToolCard(
              indexNum: '01',
              tag: 'MobileNetV4 · ONNX',
              title: 'AI Fasal Doctor',
              subtitle: 'Patti ka photo lein aur bimaari ka upchar payein.',
              actionLabel: 'Photo Scan',
              icon: Icons.psychology_outlined,
              iconBg: colorPrimarySoft,
              iconColor: colorPrimary,
              onTap: () => _navigateTo(const DiagnosisScreen()),
            ),
            _buildDailyToolCard(
              indexNum: '02',
              tag: 'Dialect · Sherpa-STT',
              title: 'Voice Saarthi',
              subtitle: 'Apni boli mein bolkar kheti ki koi bhi salah lein.',
              actionLabel: 'Bolkar Poochhein',
              icon: Icons.record_voice_over_outlined,
              iconBg: const Color(0xFFFBF5EE),
              iconColor: colorSecondary,
              onTap: () => _navigateTo(const VoiceChatScreen()),
            ),
            _buildDailyToolCard(
              indexNum: '03',
              tag: 'MSP & Spot · USSD',
              title: 'Mandi Bhav Radar',
              subtitle: 'Gehu ₹2,325/qtl · Sonipat mandi bina internet.',
              actionLabel: 'Bhav Dekhein',
              icon: Icons.candlestick_chart_outlined,
              iconBg: const Color(0xFFF4F6F4),
              iconColor: colorPrimary,
              onTap: () => _navigateTo(const MandiScreen()),
            ),
            _buildDailyToolCard(
              indexNum: '04',
              tag: 'Hologram · Bloom Filter',
              title: 'Khaad Parakh',
              subtitle: 'Asli ya nakli? Khad bori barcode check karein.',
              actionLabel: 'Bori Jaanch',
              icon: Icons.verified_outlined,
              iconBg: colorOchreLight,
              iconColor: colorOchre,
              onTap: () => _navigateTo(const CounterfeitScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyToolCard({
    required String indexNum,
    required String tag,
    required String title,
    required String subtitle,
    required String actionLabel,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorHairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: Index Number & Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      indexNum,
                      style: const TextStyle(
                        color: colorBronze,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: colorStoneText,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tag.toUpperCase(),
                  style: const TextStyle(
                    color: colorStoneMuted,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: colorStoneMuted,
                    fontSize: 10.5,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      actionLabel,
                      style: const TextStyle(
                        color: colorPrimary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Text(
                      '→',
                      style: TextStyle(
                        color: colorPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 5. SECTION 03 / NATURAL DIALECT SYNTHESIS
  // ==========================================
  Widget _buildVoiceSaarthiLiveBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '03 / ',
                  style: TextStyle(
                    color: colorBronze,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'NATURAL DIALECT SYNTHESIS',
                  style: TextStyle(
                    color: colorStoneText,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const Text(
              'NPU Low-Latency',
              style: TextStyle(
                color: colorStoneMuted,
                fontSize: 9.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Deep Monolith Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D2418), Color(0xFF153324)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorBronze.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: colorBronzeLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'VOICE SAARTHI • CONTINUOUS LISTENING',
                        style: TextStyle(
                          color: Color(0xFFEADBCE),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Zero Latency',
                      style: TextStyle(
                        color: Color(0xFFD1FAE5),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '“Gehu me doosra paani kab lagayein aur urea kitna daalein?”',
                style: TextStyle(
                  color: Color(0xFFFAF8F5),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Bina internet phone par boli mein baat karein. Tap Live Talk.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Delicate Sound Bar Visualizer
                  AnimatedBuilder(
                    animation: waveController,
                    builder: (context, child) {
                      return Row(
                        children: [
                          _buildWaveBar(10 + (waveController.value * 12)),
                          const SizedBox(width: 4),
                          _buildWaveBar(18 - (waveController.value * 10)),
                          const SizedBox(width: 4),
                          _buildWaveBar(8 + (waveController.value * 16)),
                          const SizedBox(width: 4),
                          _buildWaveBar(20 - (waveController.value * 12)),
                          const SizedBox(width: 4),
                          _buildWaveBar(12 + (waveController.value * 8)),
                          const SizedBox(width: 4),
                          _buildWaveBar(6 + (waveController.value * 10)),
                        ],
                      );
                    },
                  ),

                  // Live Talk Pill Button
                  ElevatedButton.icon(
                    onPressed: () => _navigateTo(const VoiceChatScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorPrimaryDeep,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      elevation: 0,
                    ),
                    icon: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    label: const Text(
                      'LIVE TALK (बात करें)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaveBar(double height) {
    return Container(
      width: 3,
      height: height.clamp(4.0, 22.0),
      decoration: BoxDecoration(
        color: colorBronzeLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ==========================================
  // 6. SECTION 04 / GAON MESH TELEMETRY & NOTES
  // ==========================================
  Widget _buildGaonMeshNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '04 / ',
                  style: TextStyle(
                    color: colorBronze,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'GAON MESH TELEMETRY & NOTES',
                  style: TextStyle(
                    color: colorStoneText,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const Text(
              'Peer-to-Peer Relay',
              style: TextStyle(
                color: colorStoneMuted,
                fontSize: 9.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dispatches Container
        InkWell(
          onTap: () => _navigateTo(const MeshScreen()),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorHairline),
            ),
            child: Column(
              children: [
                // Dispatch 1
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'JAGBIR SINGH',
                                style: TextStyle(
                                  color: colorPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Text(' / ', style: TextStyle(color: colorStoneMuted)),
                              const Text(
                                'MURTHAL SECTOR',
                                style: TextStyle(
                                  color: colorStoneMuted,
                                  fontSize: 9.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '15 MIN AGO',
                            style: TextStyle(
                              color: colorStoneMuted,
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Mera gehu 45 din ka ho gaya hai. Kal sham ko halki sinchai ki thi, nami badhiya ban gayi hai.',
                        style: TextStyle(
                          color: colorStoneText,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Text(
                            'PLOT: 3.8 ACRES',
                            style: TextStyle(
                              color: colorStoneMuted,
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text('  •  ', style: TextStyle(color: colorStoneMuted)),
                          Text(
                            'MOISTURE: OPTIMAL (44%)',
                            style: TextStyle(
                              color: colorBronze,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: colorHairline, height: 1),

                // Dispatch 2
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'MUKESH SHARMA',
                                style: TextStyle(
                                  color: colorPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Text(' / ', style: TextStyle(color: colorStoneMuted)),
                              const Text(
                                'RAI MANDI ZONE',
                                style: TextStyle(
                                  color: colorStoneMuted,
                                  fontSize: 9.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '1 HR AGO',
                            style: TextStyle(
                              color: colorStoneMuted,
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Rai mandi mein sarson ka bhav ₹5,450/qtl mila aaj. Kisaan bhai dhyan dein.',
                        style: TextStyle(
                          color: colorStoneText,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Text(
                            'COMMODITY: MUSTARD',
                            style: TextStyle(
                              color: colorStoneMuted,
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text('  •  ', style: TextStyle(color: colorStoneMuted)),
                          Text(
                            '₹5,450 / QTL SPOT',
                            style: TextStyle(
                              color: colorBronze,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: colorHairline, height: 1),

                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tap to open village mesh radar & notes',
                        style: TextStyle(
                          color: colorStoneMuted,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'Mesh Relay →',
                        style: TextStyle(
                          color: colorPrimary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 6. SECTION 05 / SPECIALIZED AGRONOMY SUITE (FULL 13 SUITE)
  // ==========================================
  Widget _buildSpecializedAgronomySuite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '05 / ',
                  style: TextStyle(
                    color: colorBronze,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'SPECIALIZED AGRONOMY SUITE',
                  style: TextStyle(
                    color: colorStoneText,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const Text(
              'Extended Operations',
              style: TextStyle(
                color: colorStoneMuted,
                fontSize: 9.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Grid of 6 Specialized Tools
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: [
            _buildDailyToolCard(
              indexNum: '05',
              tag: 'Geofence · NDVI',
              title: 'Khet Geofencing',
              subtitle: 'Sub-meter boundary mapping aur satellite se canopy health.',
              actionLabel: 'Plot Map',
              icon: Icons.satellite_alt_outlined,
              iconBg: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF2E7D32),
              onTap: () => _navigateTo(const DashboardScreen()),
            ),
            _buildDailyToolCard(
              indexNum: '06',
              tag: 'PMFBY · Satellite',
              title: 'Fasal Bima Claim',
              subtitle: 'Barish/sokha nuksaan ka sat-geotagged claim estimate.',
              actionLabel: 'Claim Jaanch',
              icon: Icons.security_outlined,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF1D4ED8),
              onTap: () => _navigateTo(const InsuranceScreen()),
            ),
            _buildDailyToolCard(
              indexNum: '07',
              tag: 'KVK · NPK Ratio',
              title: 'Soil Testing Lab',
              subtitle: 'Mitti jaanch lab booking aur NPK urvarak salah.',
              actionLabel: 'Lab Booking',
              icon: Icons.science_outlined,
              iconBg: const Color(0xFFFDF2F8),
              iconColor: const Color(0xFFBE185D),
              onTap: () => _navigateTo(const SoilTestScreen()),
            ),
            _buildDailyToolCard(
              indexNum: '08',
              tag: 'AR Guided · Nozzle',
              title: 'AR Spray Guide',
              subtitle: 'Hawa ki disha aur nozzle height dekh kar safe chhidkaw.',
              actionLabel: 'AR Start',
              icon: Icons.view_in_ar_outlined,
              iconBg: const Color(0xFFF5F3FF),
              iconColor: const Color(0xFF6D28D9),
              onTap: () => _navigateTo(const ArSprayScreen()),
            ),
            _buildDailyToolCard(
              indexNum: '09',
              tag: '*99# · SMS Bridge',
              title: 'USSD Offline Bridge',
              subtitle: 'Bina internet feature phone se mandi aur bima SMS sync.',
              actionLabel: 'USSD Dial',
              icon: Icons.cell_tower_outlined,
              iconBg: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFB45309),
              onTap: () => _navigateTo(const UssdSmsScreen()),
            ),
            _buildDailyToolCard(
              indexNum: '10',
              tag: 'Ledger · Drone Hub',
              title: 'Krishi Yantra Hub',
              subtitle: 'Chhidkaw drone, rotavator aur khet diary kharch lein.',
              actionLabel: 'Hub Kholein',
              icon: Icons.precision_manufacturing_outlined,
              iconBg: const Color(0xFFF1F5F9),
              iconColor: const Color(0xFF334155),
              onTap: () => _navigateTo(const SettingsScreen()),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // 7. FLOATING BOTTOM NAVIGATION DOCK
  // ==========================================
  Widget _buildFloatingBottomDock() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorHairline),
        boxShadow: [
          BoxShadow(
            color: colorPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home
          _buildDockItem(
            icon: Icons.yard_rounded,
            label: 'Khet',
            isActive: true,
            onTap: () {},
          ),

          // 2. Mandi
          _buildDockItem(
            icon: Icons.storefront_rounded,
            label: 'Mandi',
            isActive: false,
            onTap: () => _navigateTo(const MandiScreen()),
          ),

          // 3. Center Elevated AI Scan Button
          GestureDetector(
            onTap: () => _navigateTo(const DiagnosisScreen()),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [colorPrimary, colorPrimaryLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorPrimary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(Icons.document_scanner_rounded, color: Color(0xFFFDE68A), size: 22),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -8),
                  child: const Text(
                    'AI Scan',
                    style: TextStyle(
                      color: colorPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Mesh
          _buildDockItem(
            icon: Icons.hub_rounded,
            label: 'Mesh',
            isActive: false,
            onTap: () => _navigateTo(const MeshScreen()),
          ),

          // 5. More Features Menu
          _buildDockItem(
            icon: Icons.grid_view_rounded,
            label: '13 Features',
            isActive: false,
            onTap: _showFeaturesDrawer,
          ),
        ],
      ),
    );
  }

  Widget _buildDockItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? colorPrimary : colorStoneMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? colorPrimary : colorStoneMuted,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 7. KISAN AI FLOATING BUTTON (FAB)
  // ==========================================
  Widget _buildKisanAiFab() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorPrimary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _showKisanAiModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: const Color(0xFFFDE68A).withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          elevation: 0,
        ),
        icon: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFDE68A), size: 16),
        ),
        label: const Text(
          'Kisan AI ✨',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  // ==========================================
  // 8. 13 FEATURES OFF-CANVAS SHEET
  // ==========================================
  void _showFeaturesDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: colorBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: colorSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: colorHairline)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorPrimarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.grid_view_rounded, color: colorPrimary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Krishi-Saarthi OS',
                              style: TextStyle(
                                color: colorPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'All 13 Features · Offline Architecture',
                              style: TextStyle(color: colorStoneMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: colorStoneMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Feature List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildFeatureTile(
                      code: 'F-01',
                      title: 'AI Leaf Disease Scanner',
                      desc: 'Zero-network leaf disease inference using on-device ONNX/TFLite runtime.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const DiagnosisScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-02',
                      title: 'Offline Llama Treatment Advisor',
                      desc: 'Autonomous organic & bio-chemical spray prescriptions tailored to crop stage.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const VoiceChatScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-03',
                      title: 'Bilingual Voice Saarthi',
                      desc: 'Low-latency acoustic speech recognition and voice back in Hinglish & local dialect.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const VoiceChatScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-04',
                      title: 'P2P Nearby Mesh Ferry',
                      desc: 'Syncs pest alerts and village advisories peer-to-peer with no cellular network.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const MeshScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-05',
                      title: 'Farm Plot Geofencing & Canopy',
                      desc: 'Sub-meter boundary mapping, NDVI canopy monitoring and microclimate history.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const DashboardScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-06',
                      title: 'APMC Mandi Bhav Radar',
                      desc: 'Nearest grain markets, historical crop prices, and MSP comparison trends.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const MandiScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-07',
                      title: 'Khaad Parakh (Fertilizer Verifier)',
                      desc: 'Asli ya nakli? Hologram, QR + cryptographic Bloom filter check for DAP/Urea bags.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const CounterfeitScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-08',
                      title: 'Blockchain Insurance Claim Locker',
                      desc: 'Tamper-proof evidence locker with Merkle proof for PMFBY disaster claim audit.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const InsuranceScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-09',
                      title: 'Kriging Vector GIS Risk Surface',
                      desc: 'Continuous spatial interpolation for disease hotspot contagion visualization.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const DashboardScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-10',
                      title: 'Soil Testing & NPK Diagnostic',
                      desc: 'Camera Munsell color pH estimation and organic compost ratio calculator.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const SoilTestScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-11',
                      title: 'AR Spray Guidance System',
                      desc: 'Augmented reality overlay for nozzle distance, drift correction & microdose control.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const ArSprayScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-12',
                      title: '2G USSD & SMS Gateway (*123#)',
                      desc: 'Feature phone backward compatibility for weather & mandi advisory over 2G cellular.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const UssdSmsScreen());
                      },
                    ),
                    _buildFeatureTile(
                      code: 'F-13',
                      title: 'Kisan Settings & Offline Engine',
                      desc: 'Quantized INT4 weights management, storage cache purge and profile settings.',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(const SettingsScreen());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureTile({
    required String code,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorHairline),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorPrimarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      color: colorPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: colorStoneText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: const TextStyle(
                          color: colorStoneMuted,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: colorStoneMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 9. LANGUAGE PICKER MODAL
  // ==========================================
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: colorSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.language_rounded, color: colorPrimary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Bhasha Chunein (Language)',
                        style: TextStyle(
                          color: colorStoneText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: colorStoneMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLangOption('Hinglish', 'Hindi & English bolchal · Kisan youth', 'Hn'),
              _buildLangOption('हिन्दी', 'शुद्ध देवनागरी हिन्दी · पारम्परिक सलाह', 'हिं'),
              _buildLangOption('English', 'Standard English · Agronomy guide', 'EN'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangOption(String label, String subtitle, String code) {
    final bool isSelected = _currentLanguage == label;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? colorPrimarySoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() => _currentLanguage = label);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? colorPrimary : colorHairline),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorHairline),
                  ),
                  child: Center(
                    child: Text(
                      code,
                      style: const TextStyle(
                        color: colorPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: colorStoneText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: colorStoneMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: colorPrimary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 10. GOOGLE PROFILE MODAL
  // ==========================================
  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: colorSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: colorPrimarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'RS',
                        style: TextStyle(
                          color: colorPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rameshwar Singh',
                          style: TextStyle(
                            color: colorStoneText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'rameshwar.kisan@gmail.com',
                          style: TextStyle(color: colorStoneMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: colorStoneMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: colorHairline),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_rounded, color: colorPrimary),
                title: const Text('Kisan Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: const Text('Murthal, Sonipat · 4.2 Acres Gehu', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateTo(const DashboardScreen());
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_edu_rounded, color: colorSecondary),
                title: const Text('Activity History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: const Text('18 Leaf Scans · 6 Mandi alerts · 3 Mesh transfers', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateTo(const InsuranceScreen());
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings_rounded, color: colorStoneMuted),
                title: const Text('Account & Offline Settings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateTo(const SettingsScreen());
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 11. KISAN AI CHATBOT MODAL
  // ==========================================
  void _showKisanAiModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _KisanAiSheet();
      },
    );
  }
}

/// Interactive Kisan AI Assistant Modal Sheet
class _KisanAiSheet extends StatefulWidget {
  const _KisanAiSheet();

  @override
  State<_KisanAiSheet> createState() => _KisanAiSheetState();
}

class _KisanAiSheetState extends State<_KisanAiSheet> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'user',
      'text': 'गेहूं में पीला रतुआ (Yellow Rust) के लक्षण दिखे तो बिना इंटरनेट क्या तुरंत उपाय करें?',
    },
    {
      'role': 'ai',
      'text':
          'रामेश्वर जी, मुरथल क्षेत्र में आर्द्रता 42% है। पीला रतुआ के लिए प्रोपिकोनाज़ोल 25% EC (200 मिली प्रति 200 ली पानी) या 5% नीम तेल का छिड़काव दोपहर 3 बजे से पहले करें।',
    },
  ];

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': query.trim()});
      _messages.add({
        'role': 'ai',
        'text':
            'रामेश्वर जी, आपके प्रश्न पर परामर्श: खेत में नमी 42% है। अगले 4 घंटे में बारिश होने की संभावना है, इसलिए कीटनाशक या यूरिया का छिड़काव बारिश थमने तक स्थगित रखें। अधिक जानकारी के लिए "लाइव बात करें" टैप करें।',
      });
    });
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFDFBF7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: Color(0xFFE7E4DC))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: Color(0xFF1B4332), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Kisan AI Assistant',
                      style: TextStyle(
                        color: Color(0xFF1B4332),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VoiceChatScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.mic_rounded, size: 14, color: Color(0xFF92400E)),
                            SizedBox(width: 4),
                            Text(
                              'Live Talk',
                              style: TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF6E756F)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Suggestion Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip('🌾 पीला रतुआ लक्षण', () {
                    _sendMessage('पीला रतुआ (Yellow Rust) के शुरुआती लक्षण क्या हैं?');
                  }),
                  const SizedBox(width: 8),
                  _buildChip('💧 गेहूं में दूसरी सिंचाई', () {
                    _sendMessage('गेहूं में दूसरी सिंचाई कब करनी चाहिए?');
                  }),
                  const SizedBox(width: 8),
                  _buildChip('💰 आज का मंडी भाव', () {
                    _sendMessage('सोनीपत मंडी में आज गेहूं और सरसों का क्या भाव है?');
                  }),
                ],
              ),
            ),
          ),

          // Message Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1B4332) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isUser ? null : Border.all(color: const Color(0xFFE7E4DC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kisan AI Saarthi',
                                style: TextStyle(
                                  color: Color(0xFF1B4332),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '⚡ Local AI INT4',
                                style: TextStyle(
                                  color: Color(0xFF6E756F),
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          msg['text']!,
                          style: TextStyle(
                            color: isUser ? Colors.white : const Color(0xFF1E2420),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Form
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFDFBF7),
              border: Border(top: BorderSide(color: Color(0xFFE7E4DC))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_camera_rounded, color: Color(0xFF6E756F)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DiagnosisScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mic_rounded, color: Color(0xFF6E756F)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VoiceChatScreen()),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'अपनी बोली में पूछें / Ask offline...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF6E756F)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFE7E4DC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFE7E4DC)),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF1B4332)),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E4DC)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF1E2420)),
        ),
      ),
    );
  }
}
