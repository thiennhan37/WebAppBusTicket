import 'package:bus_ticket_app/core/di/service_locator.dart';
import 'package:bus_ticket_app/features/booking/viewmodel/search_trip_viewmodel.dart';
import 'package:bus_ticket_app/widgets/search_result_widgets/bottom_filter_bar_widget.dart';
import 'package:bus_ticket_app/widgets/search_result_widgets/trip_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../data/models/trip_model.dart';

class SearchResultPage extends StatefulWidget {
  final String departureName;
  final String destinationName;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRoundTrip;

  const SearchResultPage({
    super.key,
    required this.departureName,
    required this.destinationName,
    required this.startDate,
    this.endDate,
    this.isRoundTrip = false,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}


class _SearchResultPageState extends State<SearchResultPage> {
  final List<TripModel> dummyTrips = [];
  final searchTripViewModel = GetIt.I<SearchTripViewModel>();
  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'T2';
      case 2: return 'T3';
      case 3: return 'T4';
      case 4: return 'T5';
      case 5: return 'T6';
      case 6: return 'T7';
      case 7: return 'CN';
      default: return '';
    }
  }

  // Hàm format ngày hiển thị trên AppBar
  String _formatAppBarDate() {
    String startDayStr = "${widget.startDate.day.toString().padLeft(2, '0')}/${widget.startDate.month.toString().padLeft(2, '0')}/${widget.startDate.year}";
    String startWeekday = _getWeekday(widget.startDate.weekday);

    // Nếu là khứ hồi và có ngày về
    if (widget.isRoundTrip && widget.endDate != null) {
      String endDayStr = "${widget.endDate!.day.toString().padLeft(2, '0')}/${widget.endDate!.month.toString().padLeft(2, '0')}/${widget.endDate!.year}";
      // Ví dụ: T4, 06/05/2026 - T6, 08/05/2026
      return "$startWeekday, $startDayStr - ${_getWeekday(widget.endDate!.weekday)}, $endDayStr";
    }

    // Nếu là vé một chiều
    return "$startWeekday, $startDayStr";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void loadData(){
    if (widget.isRoundTrip == false) {
      final searchTripViewModel = GetIt.I<SearchTripViewModel>();

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            '${widget.departureName} ➔ ${widget.destinationName}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  _formatAppBarDate(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Thay đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
        // Tab Icon Xe khách (Chỉ giữ 1 tab duy nhất theo yêu cầu)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Icon(Icons.directions_bus, color: Colors.blue, size: 24),
                    const SizedBox(height: 4),
                    const Text('169K', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(height: 3, width: 60, color: Colors.blue), // Đường gạch chân active
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Danh sách chuyến xe
          ListView.builder(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 80), // Padding bottom để không bị lấp bởi bottom bar
            itemCount: dummyTrips.length, // Render thử 5 thẻ
            itemBuilder: (context, index) {
              return TripCard(
                trip: dummyTrips[index],
                onBookPressed: () {
                  // Xử lý khi user bấm "Chọn chỗ" của chuyến xe này
                  print('Bạn đã chọn chuyến: ${dummyTrips[index].busCompanyName}');
                },
              );
            },
          ),

          // Thanh lọc nổi ở dưới cùng
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomFilterBarWidget(),
          ),
        ],
      ),
    );
  }
}