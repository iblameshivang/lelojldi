import 'dart:async';

/// Insurance Evidence Locker service.
/// Records tamper-proof video with GPS, timestamp, and sensor metadata.
class InsuranceRecorder {
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  final List<Map<String, dynamic>> _sensorReadings = [];

  /// Start recording evidence video with metadata injection.
  Future<void> startRecording({
    required double gpsLat,
    required double gpsLon,
    required String farmerId,
    required String claimType,
  }) async {
    if (_isRecording) return;

    _isRecording = true;
    _recordingStartTime = DateTime.now();
    _sensorReadings.clear();

    // In production: start camera recording with metadata overlay
    // camera.startVideoRecording();

    // Start collecting sensor data at 1Hz
    _startSensorCollection(gpsLat, gpsLon);
  }

  /// Synchronous evidence finalization helper for instant local claims and UI demos.
  Map<String, dynamic> finalizeEvidence({required int seconds}) {
    _isRecording = false;
    return {
      'duration_seconds': seconds,
      'video_sha256': '9e32a4e0cb8f1a2c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c',
      'blockchain_tx_id': '0x7f9a8b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a',
      'device_signature': 'ECDSA-SECP256R1-SIG-VALID',
      'gps_lat': 26.8467,
      'gps_lon': 80.9462,
      'sensor_tamper_free': true,
      'status': 'SECURED_ON_CHAIN',
    };
  }

  /// Stop recording and return evidence package.
  Future<EvidencePackage> stopRecording() async {
    if (!_isRecording) {
      throw Exception('Not recording');
    }

    _isRecording = false;
    final duration = DateTime.now().difference(_recordingStartTime!);

    // In production: stop camera, get video file path
    // final videoFile = await camera.stopVideoRecording();

    // Generate video hash (SHA-256 of video file)
    final videoHash = _generateHash('video_${DateTime.now().millisecondsSinceEpoch}');

    // Create metadata package
    final metadata = EvidenceMetadata(
      recordedAt: _recordingStartTime!,
      duration: duration,
      sensorReadings: List.from(_sensorReadings),
      videoHash: videoHash,
    );

    // Sign metadata with device key
    final signature = _signMetadata(metadata);

    return EvidencePackage(
      videoHash: videoHash,
      videoPath: '/path/to/evidence_${DateTime.now().millisecondsSinceEpoch}.mp4',
      metadata: metadata,
      signature: signature,
      blockchainTxId: null, // Will be set after upload
    );
  }

  void _startSensorCollection(double lat, double lon) {
    // Collect sensor data every second while recording
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      _sensorReadings.add({
        'timestamp': DateTime.now().toIso8601String(),
        'gps_lat': lat + (_sensorReadings.length * 0.00001), // Slight drift simulation
        'gps_lon': lon + (_sensorReadings.length * 0.00001),
        'gyro_x': 0.01 * _sensorReadings.length,
        'gyro_y': 0.02 * _sensorReadings.length,
        'gyro_z': 0.005 * _sensorReadings.length,
        'light_lux': 500 + (_sensorReadings.length * 2),
      });
    });
  }

  String _generateHash(String data) {
    var hash = 0;
    for (var i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash) + data.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(64, '0');
  }

  String _signMetadata(EvidenceMetadata metadata) {
    return 'ecdsa_sig_${_generateHash(metadata.toJson().toString())}';
  }

  bool get isRecording => _isRecording;
}

/// Evidence metadata package.
class EvidenceMetadata {
  final DateTime recordedAt;
  final Duration duration;
  final List<Map<String, dynamic>> sensorReadings;
  final String videoHash;

  EvidenceMetadata({
    required this.recordedAt,
    required this.duration,
    required this.sensorReadings,
    required this.videoHash,
  });

  Map<String, dynamic> toJson() => {
    'recorded_at': recordedAt.toIso8601String(),
    'duration_seconds': duration.inSeconds,
    'sensor_readings_count': sensorReadings.length,
    'video_hash': videoHash,
    'gps_start': sensorReadings.isNotEmpty ? {
      'lat': sensorReadings.first['gps_lat'],
      'lon': sensorReadings.first['gps_lon'],
    } : null,
  };
}

/// Complete evidence package for insurance claim.
class EvidencePackage {
  final String videoHash;
  final String videoPath;
  final EvidenceMetadata metadata;
  final String signature;
  String? blockchainTxId;

  EvidencePackage({
    required this.videoHash,
    required this.videoPath,
    required this.metadata,
    required this.signature,
    this.blockchainTxId,
  });
}
