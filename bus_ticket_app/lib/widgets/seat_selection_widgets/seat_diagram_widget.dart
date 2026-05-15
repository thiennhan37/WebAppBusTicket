import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class SeatDiagramWidget extends StatelessWidget {
  const SeatDiagramWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SeatSelectionViewModel>();
    final busDiagramData = viewModel.busDiagramData;

    if (busDiagramData == null) return const Center(child: Text('Không có dữ liệu sơ đồ'));

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
                    Expanded(child: _buildFloor(viewModel, 0, 'TẦNG DƯỚI')),
                    Container(
                      width: 1,
                      height: 400,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Expanded(child: _buildFloor(viewModel, 1, 'TẦNG TRÊN')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
          _legendItem(const Color(0xFF4CAF50).withOpacity(0.2), Icons.check_box, 'Đang chọn', 
              iconColor: const Color(0xFF4CAF50), textColor: const Color(0xFF4CAF50)),
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

  Widget _buildFloor(SeatSelectionViewModel viewModel, int floorIndex, String title) {
    final diagram = viewModel.busDiagramData!.diagram;
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
            return _buildSeat(viewModel, seatCode);
          },
        ),
      ],
    );
  }

  Widget _buildSeat(SeatSelectionViewModel viewModel, String seatCode) {
    final status = viewModel.getSeatStatus(seatCode);
    final isSelected = viewModel.isSelected(seatCode);

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
      onTap: () => viewModel.toggleSeatSelection(seatCode),
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
}
