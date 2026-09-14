import 'dart:async';

/// P2P Mesh Networking service using Google Nearby Connections API.
/// Enables offline data sharing between farmer devices.
class MeshService {
  static const String serviceId = 'com.krishisaarthi.mesh';
  static const int maxHops = 5;
  static const int defaultTtlHours = 24;
  static const int maxPayloadBytes = 4096;

  bool _isAdvertising = false;
  bool _isDiscovering = false;
  final List<MeshPeer> _connectedPeers = [];
  final List<MeshPacket> _packetQueue = [];
  final Set<String> _seenPacketHashes = {};

  // Callbacks
  Function(MeshPeer)? onPeerFound;
  Function(MeshPeer)? onPeerLost;
  Function(MeshPacket)? onPacketReceived;
  Function(String)? onStatusChanged;

  /// Start advertising this device as a mesh node.
  Future<void> startAdvertising(String deviceName) async {
    if (_isAdvertising) return;

    try {
      // In production: use Nearby Connections API
      // NearbyConnections.startAdvertising(deviceName, serviceId, strategy: Strategy.P2P_CLUSTER)
      _isAdvertising = true;
      onStatusChanged?.call('advertising');
    } catch (e) {
      print('Mesh advertising error: $e');
    }
  }

  /// Start discovering nearby mesh nodes.
  Future<void> startDiscovery() async {
    if (_isDiscovering) return;

    try {
      // In production: use Nearby Connections API
      // NearbyConnections.startDiscovery(serviceId, strategy: Strategy.P2P_CLUSTER)
      _isDiscovering = true;
      onStatusChanged?.call('discovering');
    } catch (e) {
      print('Mesh discovery error: $e');
    }
  }

  /// Stop all mesh operations.
  Future<void> stop() async {
    _isAdvertising = false;
    _isDiscovering = false;
    _connectedPeers.clear();
    onStatusChanged?.call('stopped');
  }

  /// Send a packet to all connected peers (flood).
  Future<void> broadcastPacket(MeshPacket packet) async {
    if (_seenPacketHashes.contains(packet.payloadHash)) return;
    _seenPacketHashes.add(packet.payloadHash);

    // Increment hop count
    final updatedPacket = packet.copyWith(hopCount: packet.hopCount + 1);

    if (updatedPacket.hopCount >= updatedPacket.maxHops) {
      return; // TTL exceeded
    }

    for (final peer in _connectedPeers) {
      try {
        // In production: NearbyConnections.sendBytesPayload(peer.endpointId, packet.toBytes())
        onStatusChanged?.call('sent_to_${peer.deviceName}');
      } catch (e) {
        print('Mesh send error to ${peer.deviceName}: $e');
      }
    }

    // Queue for later if no peers connected
    if (_connectedPeers.isEmpty) {
      _packetQueue.add(updatedPacket);
    }
  }

  /// Send a packet to a specific peer.
  Future<void> sendToPeer(String endpointId, MeshPacket packet) async {
    // In production: NearbyConnections.sendBytesPayload(endpointId, packet.toBytes())
  }

  /// Create a diagnosis packet for mesh sharing.
  MeshPacket createDiagnosisPacket({
    required String deviceId,
    required String diseaseName,
    required double confidence,
    required double gpsLat,
    required double gpsLon,
  }) {
    final payload = {
      'type': 'diagnosis',
      'disease': diseaseName,
      'confidence': confidence,
      'lat': gpsLat,
      'lon': gpsLon,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return MeshPacket(
      originDeviceId: deviceId,
      packetType: 'diagnosis',
      payload: payload,
      payloadHash: _generateHash(payload.toString()),
      priority: 3,
      ttlHours: defaultTtlHours,
      hopCount: 0,
      maxHops: maxHops,
    );
  }

  /// Create a weather alert packet for mesh sharing.
  MeshPacket createWeatherAlertPacket({
    required String deviceId,
    required String alertMessage,
    required String districtCode,
  }) {
    final payload = {
      'type': 'weather_alert',
      'message': alertMessage,
      'district': districtCode,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return MeshPacket(
      originDeviceId: deviceId,
      packetType: 'alert',
      payload: payload,
      payloadHash: _generateHash(payload.toString()),
      priority: 1, // High priority for alerts
      ttlHours: 12,
      hopCount: 0,
      maxHops: maxHops,
    );
  }

  /// Get mesh network statistics.
  Map<String, dynamic> getStats() {
    return {
      'connected_peers': _connectedPeers.length,
      'queued_packets': _packetQueue.length,
      'seen_hashes': _seenPacketHashes.length,
      'is_advertising': _isAdvertising,
      'is_discovering': _isDiscovering,
    };
  }

  List<MeshPeer> get connectedPeers => List.unmodifiable(_connectedPeers);

  String _generateHash(String data) {
    // Simple hash for demo; in production use SHA-256
    var hash = 0;
    for (var i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash) + data.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}

/// Represents a peer device in the mesh network.
class MeshPeer {
  final String endpointId;
  final String deviceName;
  final DateTime connectedAt;
  final int signalStrength;

  MeshPeer({
    required this.endpointId,
    required this.deviceName,
    DateTime? connectedAt,
    this.signalStrength = -50,
  }) : connectedAt = connectedAt ?? DateTime.now();
}

/// A packet transmitted over the mesh network.
class MeshPacket {
  final String originDeviceId;
  final String? destinationDeviceId;
  final String packetType;
  final Map<String, dynamic> payload;
  final String payloadHash;
  final int priority;
  final int ttlHours;
  final int hopCount;
  final int maxHops;
  final DateTime createdAt;

  MeshPacket({
    required this.originDeviceId,
    this.destinationDeviceId,
    required this.packetType,
    required this.payload,
    required this.payloadHash,
    this.priority = 5,
    this.ttlHours = 24,
    this.hopCount = 0,
    this.maxHops = 5,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MeshPacket copyWith({int? hopCount}) {
    return MeshPacket(
      originDeviceId: originDeviceId,
      destinationDeviceId: destinationDeviceId,
      packetType: packetType,
      payload: payload,
      payloadHash: payloadHash,
      priority: priority,
      ttlHours: ttlHours,
      hopCount: hopCount ?? this.hopCount,
      maxHops: maxHops,
      createdAt: createdAt,
    );
  }

  bool get isExpired =>
      DateTime.now().isAfter(createdAt.add(Duration(hours: ttlHours)));
}
