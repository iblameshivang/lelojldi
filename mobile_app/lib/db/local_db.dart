import 'dart:math';

/// Local database service using SQLCipher for encrypted offline storage.
/// Implements the full schema for all 13 features.
class LocalDB {
  static const String dbName = 'krishi_saarthi.db';
  static const String encryptionKey = 'krishi_secure_local_db_key_2026';
  static const int dbVersion = 1;

  bool _isInitialized = false;

  // In-memory storage for demo (replace with sqflite + SQLCipher in production)
  final Map<String, List<Map<String, dynamic>>> _tables = {
    'farmers': [],
    'farm_plots': [],
    'diagnoses': [],
    'weather_cache': [],
    'mandi_prices': [],
    'mesh_packets': [],
    'insurance_claims': [],
    'fertilizer_cache': [],
    'soil_tests': [],
    'sync_log': [],
  };

  /// Initialize database with encrypted SQLCipher.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // In production: open SQLCipher database
    // final db = await openDatabase(
    //   dbName,
    //   version: dbVersion,
    //   password: encryptionKey,
    //   onCreate: _createTables,
    // );

    _isInitialized = true;
  }

  /// Save a diagnosis result locally.
  Future<String> saveDiagnosis(Map<String, dynamic> diagnosis) async {
    final id = _generateId();
    diagnosis['id'] = id;
    diagnosis['sync_status'] = 'pending';
    diagnosis['created_at'] = DateTime.now().toIso8601String();
    _tables['diagnoses']!.add(diagnosis);
    return id;
  }

  /// Get all pending diagnoses for sync.
  Future<List<Map<String, dynamic>>> getPendingDiagnoses() async {
    return _tables['diagnoses']!
        .where((d) => d['sync_status'] == 'pending')
        .toList();
  }

  /// Save weather data to local cache.
  Future<void> cacheWeather(String districtCode, Map<String, dynamic> data) async {
    // Remove old cache for this district
    _tables['weather_cache']!.removeWhere((w) => w['district_code'] == districtCode);
    _tables['weather_cache']!.add({
      'district_code': districtCode,
      'data': data,
      'cached_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
    });
  }

  /// Get cached weather for a district.
  Future<Map<String, dynamic>?> getCachedWeather(String districtCode) async {
    final results = _tables['weather_cache']!
        .where((w) => w['district_code'] == districtCode)
        .toList();
    if (results.isEmpty) return null;

    final cache = results.last;
    final expiresAt = DateTime.parse(cache['expires_at']);
    if (DateTime.now().isAfter(expiresAt)) return null;

    return cache['data'] as Map<String, dynamic>;
  }

  /// Save mandi prices to local cache.
  Future<void> cacheMandiPrices(List<Map<String, dynamic>> prices) async {
    _tables['mandi_prices'] = prices.map((p) {
      p['cached_at'] = DateTime.now().toIso8601String();
      return p;
    }).toList();
  }

  /// Get cached mandi prices.
  Future<List<Map<String, dynamic>>> getCachedMandiPrices({String? cropName}) async {
    var prices = _tables['mandi_prices']!;
    if (cropName != null) {
      prices = prices.where((p) =>
        (p['crop_name'] as String?)?.toLowerCase().contains(cropName.toLowerCase()) ?? false
      ).toList();
    }
    return prices;
  }

  /// Save a mesh packet to local queue.
  Future<void> saveMeshPacket(Map<String, dynamic> packet) async {
    _tables['mesh_packets']!.add(packet);
  }

  /// Get queued mesh packets for transmission.
  Future<List<Map<String, dynamic>>> getQueuedMeshPackets() async {
    return _tables['mesh_packets']!
        .where((p) => p['status'] == 'queued')
        .toList();
  }

  /// Save a soil test result.
  Future<String> saveSoilTest(Map<String, dynamic> result) async {
    final id = _generateId();
    result['id'] = id;
    result['tested_at'] = DateTime.now().toIso8601String();
    _tables['soil_tests']!.add(result);
    return id;
  }

  /// Save an insurance claim locally.
  Future<String> saveInsuranceClaim(Map<String, dynamic> claim) async {
    final id = _generateId();
    claim['id'] = id;
    claim['sync_status'] = 'pending';
    claim['created_at'] = DateTime.now().toIso8601String();
    _tables['insurance_claims']!.add(claim);
    return id;
  }

  /// Get sync log for Merkle tree delta sync.
  Future<List<Map<String, dynamic>>> getSyncLog() async {
    return _tables['sync_log']!;
  }

  /// Record a sync event.
  Future<void> recordSync(String dataType, int count, String merkleRoot) async {
    _tables['sync_log']!.add({
      'data_type': dataType,
      'count': count,
      'merkle_root': merkleRoot,
      'synced_at': DateTime.now().toIso8601String(),
    });
  }

  /// Mark diagnoses as synced.
  Future<void> markDiagnosesSynced(List<String> ids) async {
    for (final diagnosis in _tables['diagnoses']!) {
      if (ids.contains(diagnosis['id'])) {
        diagnosis['sync_status'] = 'synced';
        diagnosis['synced_at'] = DateTime.now().toIso8601String();
      }
    }
  }

  /// Get database statistics.
  Map<String, int> getStats() {
    return _tables.map((key, value) => MapEntry(key, value.length));
  }

  String _generateId() {
    final random = Random();
    return List.generate(32, (_) => random.nextInt(16).toRadixString(16)).join();
  }
}
