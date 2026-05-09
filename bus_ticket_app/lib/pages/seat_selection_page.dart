import 'package:bus_ticket_app/data/models/stop_model.dart';
import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:diacritic/diacritic.dart';

class SeatSelectionPage extends StatefulWidget {
  final String tripId;
  final String busCompanyName;
  final String departureTime;
  final String date;
  final String departureProvinceId;
  final String destinationProvinceId;

  const SeatSelectionPage({
    super.key,
    required this.tripId,
    required this.busCompanyName,
    required this.departureTime,
    required this.date,
    required this.departureProvinceId,
    required this.destinationProvinceId,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  late SeatSelectionViewModel _viewModel;

  final ScrollController _departureScrollController = ScrollController();
  final ScrollController _arrivalScrollController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();

  static const double _itemExtent = 160.0;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I<SeatSelectionViewModel>();
    _viewModel.fetchBusDiagram(widget.tripId);
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[600],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _searchTextController.clear();
              if (_viewModel.currentStep > 1) {
                _viewModel.previousStep();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.busCompanyName,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.departureTime} • ${widget.date}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        body: Consumer<SeatSelectionViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                _buildStepIndicator(viewModel.currentStep),
                Expanded(
                  child: _buildCurrentStepContent(viewModel),
                ),
                _buildBottomBar(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(SeatSelectionViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () {
                if (viewModel.currentStep == 1) viewModel.fetchBusDiagram(widget.tripId);
                if (viewModel.currentStep == 2) viewModel.fetchDepartureStops(widget.departureProvinceId);
                if (viewModel.currentStep == 3) viewModel.fetchArrivalStops(widget.destinationProvinceId);
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    switch (viewModel.currentStep) {
      case 1:
        return _buildSeatSelectionStep(viewModel);
      case 2:
        return _buildStopSelectionStep(
          viewModel,
          isDeparture: true,
          stops: viewModel.departureStops,
          selectedStop: viewModel.selectedDepartureStop,
          onStopSelected: viewModel.selectDepartureStop,
        );
      case 3:
        return _buildStopSelectionStep(
          viewModel,
          isDeparture: false,
          stops: viewModel.arrivalStops,
          selectedStop: viewModel.selectedArrivalStop,
          onStopSelected: viewModel.selectArrivalStop,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildSeatSelectionStep(SeatSelectionViewModel viewModel) {
    if (viewModel.busDiagramData == null) return const Center(child: Text('Không có dữ liệu sơ đồ'));
    
    return Column(
      children: [
        _buildLegend(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFloor(0, 'TẦNG DƯỚI')),
                    Container(width: 1, height: 400, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                    Expanded(child: _buildFloor(1, 'TẦNG TRÊN')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStopSelectionStep(
      SeatSelectionViewModel viewModel, {
        required bool isDeparture,
        required List<StopModel> stops,
        required StopModel? selectedStop,
        required Function(StopModel) onStopSelected,
      }) {
    final scrollController = isDeparture ? _departureScrollController : _arrivalScrollController;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchTextController, // ← kết nối controller
            onChanged: (value) {
              viewModel.updateSearchQuery(value);                         // cập nhật ViewModel
              _scrollToFirstMatch(stops, scrollController, value);       // scroll đến item khớp
            },
            decoration: InputDecoration(
              hintText: 'Tìm điểm ${isDeparture ? "đón" : "trả"} trong danh sách dưới',
              prefixIcon: const Icon(Icons.search),
              // Thêm nút xóa khi đang nhập
              suffixIcon: viewModel.searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchTextController.clear();
                  viewModel.updateSearchQuery('');
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            controller: scrollController,        // ← gắn ScrollController
            itemCount: stops.length,
            itemExtent: _itemExtent,             // ← chiều cao cố định để tính offset chính xác
            itemBuilder: (context, index) {
              final stop = stops[index];
              final isSelected = selectedStop?.id == stop.id;

              // Highlight nếu khớp với query đang tìm
              final query = viewModel.searchQuery;

              final normalizedQuery =
              removeDiacritics(query.toLowerCase());

              final normalizedName =
              removeDiacritics(stop.name.toLowerCase());

              final normalizedAddress =
              removeDiacritics(stop.address.toLowerCase());

              final isHighlighted = query.isNotEmpty &&
                  (normalizedName.contains(normalizedQuery) ||
                      normalizedAddress.contains(normalizedQuery));

              return InkWell(
                onTap: () => onStopSelected(stop),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // Ưu tiên màu selected > highlighted > mặc định
                    color: isSelected
                        ? Colors.blue.withOpacity(0.05)
                        : isHighlighted
                        ? Colors.amber.withOpacity(0.08)
                        : Colors.white,
                    border: Border(
                      left: BorderSide(
                        color: isSelected
                            ? Colors.blue
                            : isHighlighted
                            ? Colors.amber
                            : Colors.transparent,
                        width: 4,
                      ),
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? Colors.blue : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(stop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(stop.address, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.directions_bus, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Đón bằng xe trung chuyển', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.blue[600],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepItem('1', 'Chọn chỗ', currentStep >= 1),
          _stepDivider(),
          _stepItem('2', 'Chọn điểm đón', currentStep >= 2),
          _stepDivider(),
          _stepItem('3', 'Chọn điểm trả', currentStep >= 3),
        ],
      ),
    );
  }

  Widget _stepItem(String number, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(color: isActive ? Colors.blue[600] : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _stepDivider() {
    return Container(
      width: 20,
      height: 1,
      color: Colors.white38,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(Colors.white, Icons.check_box_outline_blank, 'Còn trống', borderColor: Colors.grey),
          _legendItem(Colors.grey[300]!, Icons.close, 'Ghế không bán', iconColor: Colors.white),
          _legendItem(const Color(0xFF4CAF50).withOpacity(0.2), Icons.check_box, 'Đang chọn', iconColor: const Color(0xFF4CAF50), textColor: const Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, IconData icon, String label, {Color? borderColor, Color? iconColor, Color? textColor}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
          child: Icon(icon, size: 14, color: iconColor ?? Colors.transparent),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: textColor ?? Colors.black87)),
      ],
    );
  }

  Widget _buildFloor(int floorIndex, String title) {
    final diagram = _viewModel.busDiagramData!.diagram;
    if (floorIndex >= diagram.seatList.length) return const SizedBox();
    final floorSeats = diagram.seatList[floorIndex];

    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 16),
        if (floorIndex == 0) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(MdiIcons.steering, color: Colors.grey, size: 30),
          ),
          const SizedBox(height: 16),
        ] else ...[
          const SizedBox(height: 46),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: diagram.column,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: diagram.row * diagram.column,
          itemBuilder: (context, index) {
            int r = index ~/ diagram.column;
            int c = index % diagram.column;
            if (r >= floorSeats.length || c >= floorSeats[r].length) return const SizedBox();
            final seatCode = floorSeats[r][c];
            if (seatCode == null) return const SizedBox();
            return _buildSeat(seatCode);
          },
        ),
      ],
    );
  }
  void _scrollToFirstMatch(List<StopModel> stops, ScrollController controller, String query) {
    if (query.isEmpty) return;

    final normalizedQuery =
    removeDiacritics(query.toLowerCase());

    final index = stops.indexWhere((stop) {
      final normalizedName =
      removeDiacritics(stop.name.toLowerCase());

      final normalizedAddress =
      removeDiacritics(stop.address.toLowerCase());

      return normalizedName.contains(normalizedQuery) ||
          normalizedAddress.contains(normalizedQuery);
    });

    if (index != -1) {
      controller.animateTo(
        index * _itemExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildSeat(String seatCode) {
    final status = _viewModel.getSeatStatus(seatCode);
    final isSelected = _viewModel.isSelected(seatCode);

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey[400]!;
    Widget? child;

    if (status == 'BOOKED' || status == 'HELD') {
      bgColor = Colors.grey[300]!;
      borderColor = Colors.grey[300]!;
      child = const Icon(Icons.close, size: 16, color: Colors.white);
    } else if (isSelected) {
      bgColor = const Color(0xFF4CAF50).withOpacity(0.1);
      borderColor = const Color(0xFF4CAF50);
      child = const Icon(Icons.check_box, size: 16, color: Color(0xFF4CAF50));
    }

    return GestureDetector(
      onTap: () => _viewModel.toggleSeatSelection(seatCode),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (child != null) child else Container(
              width: 10,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              seatCode,
              style: TextStyle(
                fontSize: 10,
                color: (status == 'BOOKED' || status == 'HELD') ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(SeatSelectionViewModel viewModel) {
    if (viewModel.selectedSeats.isEmpty && viewModel.currentStep == 1) return const SizedBox();

    bool canContinue = false;
    if (viewModel.currentStep == 1 && viewModel.selectedSeats.isNotEmpty) canContinue = true;
    if (viewModel.currentStep == 2 && viewModel.selectedDepartureStop != null) canContinue = true;
    if (viewModel.currentStep == 3 && viewModel.selectedArrivalStop != null) canContinue = true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (viewModel.currentStep > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Sai hoặc thiếu thông tin?',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                    Text('Báo cáo', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tạm tính', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Row(
                      children: [
                        Text(
                          _formatPrice(viewModel.totalPrice),
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const Icon(Icons.keyboard_arrow_up, color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: canContinue ? () {
                  _searchTextController.clear();
                  if (viewModel.currentStep == 1) {
                    viewModel.fetchDepartureStops(widget.departureProvinceId);
                    viewModel.nextStep();
                  } else if (viewModel.currentStep == 2) {
                    viewModel.fetchArrivalStops(widget.destinationProvinceId);
                    viewModel.nextStep();
                  } else {
                    // Xử lý thanh toán hoặc bước tiếp theo
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Tiếp tục', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }
}
