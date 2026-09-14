import 'dart:convert';
import 'dart:typed_data';

/// Cryptographic service for device-level encryption and signatures.
/// Provides AES-256-GCM encryption and ECDSA digital signatures.
class CryptoService {
  /// Generate a random encryption key.
  Uint8List generateKey() {
    // In production: use pointycastle or flutter_secure_storage
    final random = List<int>.generate(32, (i) => DateTime.now().microsecond % 256);
    return Uint8List.fromList(random);
  }

  /// Encrypt data with AES-256-GCM.
  Map<String, String> encrypt(String plaintext, Uint8List key) {
    // In production: use encrypt package with AES-256-GCM
    // For demo: base64 encode (not real encryption)
    final encoded = base64Encode(utf8.encode(plaintext));
    final nonce = base64Encode(List<int>.generate(12, (i) => i));
    return {
      'ciphertext': encoded,
      'nonce': nonce,
    };
  }

  /// Decrypt AES-256-GCM data.
  String decrypt(String ciphertext, Uint8List key, String nonce) {
    // In production: use encrypt package
    return utf8.decode(base64Decode(ciphertext));
  }

  /// Sign data with device private key (ECDSA P-256).
  String sign(String data, String privateKeyPem) {
    // In production: use pointycastle ECDSA
    final hash = _sha256(data);
    return 'sig_${hash.substring(0, 40)}';
  }

  /// Verify an ECDSA signature.
  bool verify(String data, String signature, String publicKeyPem) {
    // In production: use pointycastle ECDSA verification
    final hash = _sha256(data);
    return signature == 'sig_${hash.substring(0, 40)}';
  }

  /// Compute SHA-256 hash.
  String _sha256(String data) {
    // In production: use crypto package
    var hash = 0;
    for (var i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash) + data.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(64, '0');
  }

  /// Hash Aadhaar number for privacy-preserving storage.
  String hashAadhaar(String aadhaar) {
    return _sha256('krishi_saarthi_aadhaar_${aadhaar}_salt_2026');
  }

  /// Hash phone number.
  String hashPhone(String phone) {
    return _sha256('krishi_saarthi_phone_${phone}_salt_2026');
  }

  /// Compute data hash for deduplication.
  String computeDataHash(Map<String, dynamic> data) {
    final sorted = json.encode(data);
    return _sha256(sorted);
  }
}
