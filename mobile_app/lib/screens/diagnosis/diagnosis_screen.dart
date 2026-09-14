import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/cv_service.dart';
import '../../utils/design_tokens.dart';

/// Feature 1 — AI Crop Disease Diagnosis
/// Tactile Pragmatism design: sunlight-resilient, high-contrast, field-ready
class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen>
    with TickerProviderStateMixin {
  final CVService _cvService = CVService();
  DiagnosisResult? _result;
  bool _isAnalyzing = false;
  bool _showTreatment = true;
  late AnimationController _pulseController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _cvService.initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBg,
      appBar: buildKrishiAppBar(
        context: context,
        title: 'फसल निदान AI',
        subtitle: 'CROP DISEASE DIAGNOSIS',
        emoji: '🔬',
        actions: [
          buildStatusPill(
            label: 'TFLite ON-DEVICE',
            color: colorAiEdge,
            bgColor: colorAiEdgeBg,
            borderColor: colorAiEdgeBorder,
            icon: Icons.memory_rounded,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _result == null ? _buildCameraView() : _buildResultView(),
    );
  }

  Widget _buildCameraView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoBanner(
              'सर्वोत्तम परिणाम के लिए: एक पत्ती को प्राकृतिक रोशनी में फोटो लें',
              icon: Icons.tips_and_updates_rounded,
              color: colorEarth,
              bgColor: colorOchreLight,
            ),
            const SizedBox(height: spacingMd),

            // Camera Viewfinder Card
            buildCard(
              padding: EdgeInsets.zero,
              radius: radiusLg,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radiusLg),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                      ),
                      borderRadius: BorderRadius.circular(radiusLg),
                    ),
                    child: Stack(
                      children: [
                        // Corner brackets
                        ..._buildCornerBrackets(),

                        // Animated scan line
                        if (_isAnalyzing) _buildScanLine(),

                        // Center content
                        Center(
                          child: _isAnalyzing
                              ? _buildAnalyzingState()
                              : _buildIdleState(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: spacingMd),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: buildPrimaryButton(
                    label: 'फोटो लें',
                    icon: Icons.camera_alt_rounded,
                    onTap: _isAnalyzing ? () {} : _takePhoto,
                    isLoading: _isAnalyzing,
                  ),
                ),
                const SizedBox(width: spacingSm),
                Expanded(
                  child: GestureDetector(
                    onTap: _isAnalyzing ? null : _pickFromGallery,
                    child: Container(
                      height: touchTarget,
                      decoration: BoxDecoration(
                        color: colorSurface,
                        borderRadius: BorderRadius.circular(radiusMd),
                        border: Border.all(color: colorHairline),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_rounded, color: colorPrimary, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'गैलरी',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacingMd),

            // How it works
            buildSectionHeader('01', 'HOW IT WORKS'),
            buildCard(
              child: Column(
                children: [
                  _buildStepRow('1', 'पत्ती की फोटो लें', 'कैमरा या गैलरी से', Icons.camera_alt_rounded),
                  const Divider(color: colorHairline, height: 1),
                  _buildStepRow('2', 'AI विश्लेषण', 'TFLite मॉडल ऑन-डिवाइस चलता है', Icons.psychology_rounded),
                  const Divider(color: colorHairline, height: 1),
                  _buildStepRow('3', 'निदान + उपचार', 'बीमारी का नाम, दवाई की खुराक', Icons.medical_services_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String num, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(color: colorPrimary, shape: BoxShape.circle),
            child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: colorPrimaryLight, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tsHeadlineSm.copyWith(fontSize: 14)),
                Text(desc, style: tsBodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (ctx, _) => Container(
            width: 80 + (_pulseController.value * 8),
            height: 80 + (_pulseController.value * 8),
            decoration: BoxDecoration(
              color: colorPrimary.withValues(alpha: 0.08 + (_pulseController.value * 0.05)),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorPrimary.withValues(alpha: 0.3 + (_pulseController.value * 0.2)),
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.camera_alt_outlined, color: colorPrimary, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'पत्ती की फोटो लें',
          style: TextStyle(
            fontFamily: 'NotoSansDevanagari',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Capture leaf for AI diagnosis', style: tsBodySm),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: colorPrimarySoft,
            shape: BoxShape.circle,
            border: Border.all(color: colorPrimaryContainer, width: 2),
          ),
          child: const Icon(Icons.document_scanner_rounded, color: colorPrimary, size: 32),
        ),
        const SizedBox(height: 16),
        const Text(
          'AI विश्लेषण हो रहा है...',
          style: TextStyle(fontFamily: 'NotoSansDevanagari', fontSize: 14, fontWeight: FontWeight.w600, color: colorPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          width: 120, height: 4,
          decoration: BoxDecoration(color: colorHairline, borderRadius: BorderRadius.circular(2)),
          child: AnimatedBuilder(
            animation: _scanController,
            builder: (_, __) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _scanController.value,
              child: Container(decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(2))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanLine() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (_, __) => Positioned(
        top: MediaQuery.of(context).size.height * 0.5 * _scanController.value,
        left: 20, right: 20,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent, colorPrimary.withValues(alpha: 0.6), Colors.transparent,
            ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 24.0;
    const thickness = 2.5;
    const color = colorPrimary;
    const offset = 12.0;

    Widget bracket(Alignment alignment, double rx, double ry) {
      return Positioned(
        top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? offset : null,
        bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? offset : null,
        left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? offset : null,
        right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? offset : null,
        child: SizedBox(
          width: size, height: size,
          child: CustomPaint(painter: _BracketPainter(rx: rx, ry: ry, color: color, thickness: thickness)),
        ),
      );
    }

    return [
      bracket(Alignment.topLeft, 0, 0),
      bracket(Alignment.topRight, 1, 0),
      bracket(Alignment.bottomLeft, 0, 1),
      bracket(Alignment.bottomRight, 1, 1),
    ];
  }

  Widget _buildResultView() {
    final result = _result!;
    final severityColor = _getSeverityColor(result.severity);
    final severityBg = _getSeverityBg(result.severity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(spacingLg),
            decoration: BoxDecoration(
              color: severityBg,
              borderRadius: BorderRadius.circular(radiusLg),
              border: Border.all(color: severityColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    buildStatusPill(
                      label: result.isHealthy ? '✅ स्वस्थ' : '⚠️ बीमारी पाई गई',
                      color: severityColor,
                      bgColor: Colors.white,
                      borderColor: severityColor.withValues(alpha: 0.4),
                    ),
                    const Spacer(),
                    Text(
                      '${(result.confidence * 100).toInt()}%',
                      style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 22, fontWeight: FontWeight.w700, color: severityColor),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(result.diseaseNameHi, style: tsHeadlineLg.copyWith(color: colorStoneText)),
                const SizedBox(height: 2),
                Text(result.diseaseName, style: tsBody.copyWith(color: colorStoneMuted)),
                const SizedBox(height: 16),
                // Severity bar
                Row(
                  children: [
                    Text('गंभीरता:', style: tsLabel),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _severityLevel(result.severity) / 5.0,
                          backgroundColor: colorHairline,
                          valueColor: AlwaysStoppedAnimation(severityColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_severityTextHi(result.severity), style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w700, color: severityColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: spacingMd),

          // Treatment section
          GestureDetector(
            onTap: () => setState(() => _showTreatment = !_showTreatment),
            child: buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(color: colorPrimarySoft, shape: BoxShape.circle),
                        child: const Icon(Icons.medical_services_rounded, color: colorPrimary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('उपचार सलाह', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700, color: colorStoneText)),
                      ),
                      Icon(_showTreatment ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: colorStoneMuted),
                    ],
                  ),
                  if (_showTreatment) ...[
                    const SizedBox(height: 12),
                    const Divider(color: colorHairline, height: 1),
                    const SizedBox(height: 12),
                    Text(result.treatmentHi, style: tsBody),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: spacingMd),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: buildPrimaryButton(
                  label: 'नई फोटो',
                  icon: Icons.camera_alt_rounded,
                  onTap: () => setState(() { _result = null; }),
                ),
              ),
              const SizedBox(width: spacingSm),
              Expanded(
                child: buildAmberButton(
                  label: 'रिपोर्ट भेजें',
                  icon: Icons.share_rounded,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));
    final result = await _cvService.diagnose(File(''));
    setState(() { _result = result; _isAnalyzing = false; _showTreatment = true; });
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));
    final result = await _cvService.diagnose(File(''));
    setState(() { _result = result; _isAnalyzing = false; _showTreatment = true; });
  }

  Color _getSeverityColor(String s) {
    switch (s) {
      case 'critical': return colorCritical;
      case 'high': return colorTerracotta;
      case 'medium': return colorWarning;
      case 'low': return colorAmber;
      case 'healthy': return colorMeshActive;
      default: return colorStoneMuted;
    }
  }

  Color _getSeverityBg(String s) {
    switch (s) {
      case 'critical': return colorCriticalBg;
      case 'high': return const Color(0xFFFFF7ED);
      case 'medium': return colorWarningBg;
      case 'low': return colorOchreLight;
      case 'healthy': return colorMeshActiveBg;
      default: return colorSurface;
    }
  }

  int _severityLevel(String s) {
    switch (s) {
      case 'critical': return 5;
      case 'high': return 4;
      case 'medium': return 3;
      case 'low': return 2;
      case 'healthy': return 1;
      default: return 0;
    }
  }

  String _severityTextHi(String s) {
    switch (s) {
      case 'critical': return 'अत्यधिक';
      case 'high': return 'गंभीर';
      case 'medium': return 'मध्यम';
      case 'low': return 'हल्का';
      case 'healthy': return 'स्वस्थ';
      default: return '';
    }
  }
}

class _BracketPainter extends CustomPainter {
  final double rx, ry, thickness;
  final Color color;
  const _BracketPainter({required this.rx, required this.ry, required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = thickness..style = PaintingStyle.stroke..strokeCap = StrokeCap.square;
    final w = size.width; final h = size.height;
    final xs = rx == 0 ? 0.0 : w;
    final ys = ry == 0 ? 0.0 : h;
    final xe = rx == 0 ? w * 0.6 : w * 0.4;
    final ye = ry == 0 ? h * 0.6 : h * 0.4;
    canvas.drawLine(Offset(xs, ys), Offset(xe, ys), paint);
    canvas.drawLine(Offset(xs, ys), Offset(xs, ye), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
