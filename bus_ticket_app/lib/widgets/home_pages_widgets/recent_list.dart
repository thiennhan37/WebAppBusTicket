import 'package:bus_ticket_app/data/models/recent_search_model.dart';
import 'package:bus_ticket_app/data/services/local/booking_storage.dart';
import 'package:bus_ticket_app/pages/searh_result_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

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

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }
    return DateTime.now();
  }

  void _handleRecentSearchTap(RecentSearchModel item) async {
    DateTime itemDate = _parseDate(item.date);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (itemDate.isAtSameMomentAs(today) || itemDate.isAfter(today)) {
      // Ngày trong tương lai hoặc hôm nay -> nhảy tới trang tìm kiếm
      _navigateToSearchResult(item, itemDate);
    } else {
      // Ngày cũ -> Hiện lịch chọn ngày mới
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate: today,
        lastDate: today.add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        // Cập nhật lại ngày trong storage
        final updatedItem = RecentSearchModel(
          departureName: item.departureName,
          destinationName: item.destinationName,
          departureId: item.departureId,
          destinationId: item.destinationId,
          date: DateFormat('dd/MM/yyyy').format(pickedDate),
          isRoundTrip: item.isRoundTrip,
          endDate: item.endDate,
        );
        _storage.addRecentSearch(updatedItem);
        
        _navigateToSearchResult(item, pickedDate);
      }
    }
  }

  void _navigateToSearchResult(RecentSearchModel item, DateTime startDate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultPage(
          departureName: item.departureName,
          destinationName: item.destinationName,
          departureId: item.departureId,
          destinationId: item.destinationId,
          startDate: startDate,
          isRoundTrip: item.isRoundTrip,
          endDate: item.endDate != null ? _parseDate(item.endDate!) : null,
        ),
      ),
    );
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
              return InkWell(
                onTap: () => _handleRecentSearchTap(item),
                borderRadius: BorderRadius.circular(12),
                child: _buildRecentCard(
                  from: item.departureName,
                  to: item.destinationName,
                  date: item.isRoundTrip && item.endDate != null 
                      ? "${item.date} - ${item.endDate}" 
                      : item.date,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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
