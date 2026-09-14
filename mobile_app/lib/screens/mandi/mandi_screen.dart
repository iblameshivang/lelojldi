import 'package:flutter/material.dart';
import '../../services/weather_mandi_service.dart';

/// Mandi price screen with crop-wise price tracking and trends.
class MandiScreen extends StatefulWidget {
  const MandiScreen({super.key});

  @override
  State<MandiScreen> createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> {
  final MandiService _mandiService = MandiService();
  List<MandiPrice> _prices = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() => _isLoading = true);
    final prices = await _mandiService.getPrices();
    setState(() {
      _prices = prices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _prices
        : _prices.where((p) =>
            p.cropNameHi.contains(_searchQuery) ||
            p.cropName.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('💰 मंडी भाव')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'फसल खोजें...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1E1E30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Date info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.white60),
                const SizedBox(width: 4),
                Text(
                  'आज के भाव • ₹ प्रति क्विंटल',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _loadPrices,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('ताज़ा करें', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // Price list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _priceCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard(MandiPrice price) {
    final trendColor = price.trend == 'up' ? Colors.green
        : price.trend == 'down' ? Colors.red : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: trendColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Crop info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price.cropNameHi,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  price.cropName,
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
          // Price & trend
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${price.price.toInt()}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(price.trendEmoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${price.change > 0 ? '+' : ''}${price.change}%',
                    style: TextStyle(color: trendColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
