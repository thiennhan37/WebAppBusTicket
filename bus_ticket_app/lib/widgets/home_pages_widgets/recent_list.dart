import 'package:bus_ticket_app/data/models/recent_search_model.dart';
import 'package:bus_ticket_app/data/services/local/booking_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RecentList extends StatefulWidget {
  const RecentList({super.key});

  @override
  State<RecentList> createState() => _RecentListState();
}

class _RecentListState extends State<RecentList> {
  final _storage = GetIt.I<BookingStorage>();
  List<RecentSearchModel> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _storage.addListener(_loadRecentSearches);
  }

  @override
  void dispose() {
    _storage.removeListener(_loadRecentSearches);
    super.dispose();
  }

  void _loadRecentSearches() {
    if (mounted) {
      setState(() {
        _recentSearches = _storage.getRecentSearches();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tìm kiếm gần đây',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  await _storage.clearRecentSearches();
                },
                child: const Text(
                  'Xóa tất cả',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final item = _recentSearches[index];
              return _buildRecentCard(
                from: item.departureName,
                to: item.destinationName,
                date: item.isRoundTrip && item.endDate != null 
                    ? "${item.date} - ${item.endDate}" 
                    : item.date,
              );
            },
          ),
        ),
      ],
    );
  }

  // Hàm build từng thẻ card
  Widget _buildRecentCard({
    required String from,
    required String to,
    required String date,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              children: [
                _buildCircleDot(Colors.blue),
                _buildDottedLine(),
                _buildCircleDot(Colors.red),
              ],
            ),
          ),
          const SizedBox(width: 12),
          //Cột chứa text địa điểm và thời gian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  from,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  to,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(Icons.arrow_forward, size: 20, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Hàm vẽ dấu chấm tròn ở giữa
  Widget _buildCircleDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: Colors.white,
      ),
    );
  }

  //Hàm vẽ đường nét đức giữa hai vòng tròn
  Widget _buildDottedLine() {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          width: 1.5,
          height: 3,
          margin: const EdgeInsets.symmetric(vertical: 1.5),
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
