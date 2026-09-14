import 'dart:async';
import 'dart:convert';

/// Counterfeit fertilizer verification service.
/// Uses QR scanning, Bloom filter lookup, and seal pattern analysis.
class CounterfeitVerifier {
  // Bloom filter for offline registry verification
  // In production: load from assets/bloom_filter.bin
  final Set<String> _offlineRegistry = {};
  bool _isInitialized = false;

  /// Initialize Bloom filter from bundled registry.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // In production: load Bloom filter binary from assets
    // For demo: pre-populate with known-good hashes
    _offlineRegistry.addAll([
      'iffco_urea_batch_2026_001',
      'iffco_urea_batch_2026_002',
      'iffco_dap_batch_2026_001',
      'coromandel_npk_2026_001',
      'zuari_mop_2026_001',
      'rcf_urea_2026_001',
      'gnfc_urea_2026_001',
      'gsfc_dap_2026_001',
    ]);

    _isInitialized = true;
  }

  /// Synchronous verification helper for UI testing and demos
  Map<String, dynamic> verifyProduct({required String code}) {
    final lower = code.toLowerCase();
    final isGenuine = lower.contains('genuine') || 
                      lower.contains('iffco') || 
                      lower.contains('kribhco');
    return {
      'is_authentic': isGenuine,
      'is_revoked': false,
      'confidence': isGenuine ? 0.96 : 0.22,
      'message': isGenuine ? '✅ प्रमाणित असली उत्पाद (AUTHENTIC)' : '❌ नकली उर्वरक (COUNTERFEIT)',
      'message_en': isGenuine ? '✅ Verified Authentic Product' : '❌ Counterfeit Fertilizer Detected',
      'product_name': isGenuine ? 'IFFCO नीम लेपित यूरिया (45kg)' : 'अज्ञात नकली DAP/यूरिया',
      'manufacturer': isGenuine ? 'IFFCO आंवला इकाई' : 'अनाधिकृत निर्माता (UNAUTHORIZED)',
      'batch_number': isGenuine ? 'IFFCO-UP-2026-B82' : 'FAKE-BATCH-99',
      'checks': {'qr_format': true, 'registry': isGenuine, 'hologram': isGenuine},
    };
  }

  /// Verify product via QR code data.
  Future<VerificationResult> verifyQR(String qrData) async {
    if (!_isInitialized) await initialize();

    try {
      // Parse QR data
      final data = _parseQRData(qrData);
      if (data == null) {
        return VerificationResult(
          isAuthentic: false,
          confidence: 0.0,
          message: '❌ QR कोड पढ़ने में त्रुटि',
          messageEn: '❌ Invalid QR code format',
          checks: {'qr_format': false},
        );
      }

      // Check offline registry (Bloom filter)
      final registryKey = '${data['manufacturer']}_${data['product']}_${data['batch']}';
      final inRegistry = _offlineRegistry.contains(registryKey.toLowerCase());

      if (!inRegistry) {
        return VerificationResult(
          isAuthentic: false,
          confidence: 0.85,
          message: '❌ उत्पाद रजिस्ट्री में नहीं मिला। संभवतः नकली।',
          messageEn: '❌ Product NOT found in registry. Likely COUNTERFEIT.',
          productName: data['product'],
          manufacturer: data['manufacturer'],
          batchNumber: data['batch'],
          checks: {'qr_format': true, 'registry': false},
        );
      }

      return VerificationResult(
        isAuthentic: true,
        confidence: 0.95,
        message: '✅ उत्पाद प्रामाणिक है।',
        messageEn: '✅ Product is AUTHENTIC.',
        productName: data['product'],
        manufacturer: data['manufacturer'],
        batchNumber: data['batch'],
        validUntil: data['expiry'],
        checks: {'qr_format': true, 'registry': true},
      );
    } catch (e) {
      return VerificationResult(
        isAuthentic: false,
        confidence: 0.0,
        message: '⚠️ सत्यापन त्रुटि: $e',
        messageEn: '⚠️ Verification error: $e',
        checks: {},
      );
    }
  }

  /// Analyze packaging seal image for authenticity.
  Future<SealAnalysisResult> analyzeSeal({
    required double avgBrightness,
    required double colorUniformity,
    required bool hasHolographicPattern,
  }) async {
    double score = 0;
    final checks = <String, bool>{};

    // Check holographic pattern
    checks['holographic'] = hasHolographicPattern;
    if (hasHolographicPattern) score += 30;

    // Check color uniformity (genuine seals have consistent colors)
    checks['color_uniform'] = colorUniformity > 0.7;
    if (colorUniformity > 0.7) score += 25;

    // Check brightness (genuine holographic seals have specific brightness)
    checks['brightness'] = avgBrightness > 120 && avgBrightness < 200;
    if (avgBrightness > 120 && avgBrightness < 200) score += 25;

    // Font consistency check (simplified)
    checks['print_quality'] = colorUniformity > 0.6;
    if (colorUniformity > 0.6) score += 20;

    final isAuthentic = score >= 60;

    return SealAnalysisResult(
      isAuthentic: isAuthentic,
      confidence: score / 100,
      checks: checks,
      message: isAuthentic
          ? '✅ सील प्रामाणिक दिखती है (${score.toInt()}% विश्वास)'
          : '❌ सील संदिग्ध है (${score.toInt()}% विश्वास)',
      messageEn: isAuthentic
          ? '✅ Seal appears authentic (${score.toInt()}% confidence)'
          : '❌ Seal appears suspicious (${score.toInt()}% confidence)',
    );
  }

  Map<String, dynamic>? _parseQRData(String qrData) {
    try {
      // Try JSON format first
      return json.decode(qrData) as Map<String, dynamic>;
    } catch (_) {
      // Try pipe-delimited format: MANUFACTURER|PRODUCT|BATCH|EXPIRY
      final parts = qrData.split('|');
      if (parts.length >= 3) {
        return {
          'manufacturer': parts[0],
          'product': parts[1],
          'batch': parts[2],
          'expiry': parts.length > 3 ? parts[3] : null,
        };
      }
      return null;
    }
  }
}

class VerificationResult {
  final bool isAuthentic;
  final double confidence;
  final String message;
  final String messageEn;
  final String? productName;
  final String? manufacturer;
  final String? batchNumber;
  final String? validUntil;
  final Map<String, bool> checks;

  VerificationResult({
    required this.isAuthentic,
    required this.confidence,
    required this.message,
    required this.messageEn,
    this.productName,
    this.manufacturer,
    this.batchNumber,
    this.validUntil,
    required this.checks,
  });
}

class SealAnalysisResult {
  final bool isAuthentic;
  final double confidence;
  final Map<String, bool> checks;
  final String message;
  final String messageEn;

  SealAnalysisResult({
    required this.isAuthentic,
    required this.confidence,
    required this.checks,
    required this.message,
    required this.messageEn,
  });
}
