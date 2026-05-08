import 'package:bus_ticket_app/features/booking/viewmodel/search_trip_viewmodel.dart';
import 'package:bus_ticket_app/pages/seat_selection_page.dart';
import 'package:bus_ticket_app/widgets/search_result_widgets/bottom_filter_bar_widget.dart';
import 'package:bus_ticket_app/widgets/search_result_widgets/trip_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SearchResultPage extends StatefulWidget {
  final String departureName;
  final String destinationName;
  final String departureId;
  final String destinationId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRoundTrip;

  const SearchResultPage({
    super.key,
    required this.departureName,
    required this.destinationName,
    required this.departureId,
    required this.destinationId,
    required this.startDate,
    this.endDate,
    this.isRoundTrip = false,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}


class _SearchResultPageState extends State<SearchResultPage> {
  late SearchTripViewModel searchTripViewModel;

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

  String _formatAppBarDate() {
    String startDayStr = "${widget.startDate.day.toString().padLeft(2, '0')}/${widget.startDate.month.toString().padLeft(2, '0')}/${widget.startDate.year}";
    String startWeekday = _getWeekday(widget.startDate.weekday);

    if (widget.isRoundTrip && widget.endDate != null) {
      String endDayStr = "${widget.endDate!.day.toString().padLeft(2, '0')}/${widget.endDate!.month.toString().padLeft(2, '0')}/${widget.endDate!.year}";
      return "$startWeekday, $startDayStr - ${_getWeekday(widget.endDate!.weekday)}, $endDayStr";
    }

    return "$startWeekday, $startDayStr";
  }

  @override
  void initState() {
    super.initState();
    searchTripViewModel = GetIt.I<SearchTripViewModel>();
    searchTripViewModel.addListener(_onViewModelChanged);
    loadData();
  }

  @override
  void dispose() {
    searchTripViewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void loadData() {
    String formattedDate = "${widget.startDate.year}-${widget.startDate.month.toString().padLeft(2, '0')}-${widget.startDate.day.toString().padLeft(2, '0')}";
    searchTripViewModel.searchTrip(
      widget.departureId,
      widget.destinationId,
      formattedDate,
    );
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
                Text(_formatAppBarDate(), style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                    Container(height: 3, width: 60, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (searchTripViewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (searchTripViewModel.errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      searchTripViewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: loadData, child: const Text('Thử lại')),
                  ],
                ),
              ),
            )
          else if (searchTripViewModel.trips.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, color: Colors.grey, size: 48),
                  const SizedBox(height: 16),
                  const Text('Không tìm thấy chuyến đi nào', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: loadData, child: const Text('Tìm kiếm lại')),
                ],
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 80),
              itemCount: searchTripViewModel.trips.length,
              itemBuilder: (context, index) {
                final trip = searchTripViewModel.trips[index];
                return TripCard(
                  trip: trip,
                  onBookPressed: () {
                    // Chuyển sang trang sơ đồ ghế
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeatSelectionPage(
                          tripId: trip.id ?? '',
                          busCompanyName: trip.busCompanyName ?? 'Nhà xe',
                          departureTime: trip.departureTime ?? '--:--',
                          date: "${widget.startDate.day.toString().padLeft(2, '0')}/${widget.startDate.month.toString().padLeft(2, '0')}/${widget.startDate.year}",
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          const Align(alignment: Alignment.bottomCenter, child: BottomFilterBarWidget()),
        ],
      ),
    );
  }
}
