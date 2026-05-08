import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class SeatSelectionPage extends StatefulWidget {
  final String tripId;
  final String busCompanyName;
  final String departureTime;
  final String date;

  const SeatSelectionPage({
    super.key,
    required this.tripId,
    required this.busCompanyName,
    required this.departureTime,
    required this.date,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  late SeatSelectionViewModel _viewModel;

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
            onPressed: () => Navigator.pop(context),
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
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('Chi tiết xe', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
            ),
          ],
        ),
        body: Consumer<SeatSelectionViewModel>(
          builder: (context, viewModel, child) {
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
                      onPressed: () => viewModel.fetchBusDiagram(widget.tripId),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.busDiagramData == null) {
              return const Center(child: Text('Không có dữ liệu'));
            }

            return Column(
              children: [
                _buildStepIndicator(),
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
                _buildBottomBar(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.blue[600],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepItem('1', 'Chọn chỗ', true),
          _stepDivider(),
          _stepItem('2', 'Chọn điểm đón', false),
          _stepDivider(),
          _stepItem('3', 'Chọn điểm trả', false),
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
        ]
        else ...[
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
    if (viewModel.selectedSeats.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${viewModel.selectedSeats.length} chỗ: ${viewModel.selectedSeats.join(", ")}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${_formatPrice(viewModel.totalPrice)}',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Chuyển sang bước tiếp theo
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tiếp tục', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }
}
