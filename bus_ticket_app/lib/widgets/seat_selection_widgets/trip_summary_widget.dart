import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripSummaryWidget extends StatelessWidget {
  final String date;
  const TripSummaryWidget({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SeatSelectionViewModel>();
    final busDiagram = viewModel.busDiagramData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chuyến đi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Thẻ thông tin chuyến xe
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_bus, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network('https://picsum.photos/100/100', width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(busDiagram?.busTypeName ?? 'Nhà xe', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('${viewModel.selectedSeats.length} ghế • ${viewModel.selectedSeats.join(", ")}', 
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.favorite_border, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Lộ trình
                _buildTimelineItem(
                  location: viewModel.selectedDepartureStop?.name ?? 'Điểm đón',
                  address: viewModel.selectedDepartureStop?.address ?? '',
                  isStart: true,
                ),
                _buildTimelineItem(
                  location: viewModel.selectedArrivalStop?.name ?? 'Điểm trả',
                  address: viewModel.selectedArrivalStop?.address ?? '',
                  isStart: false,
                ),
                
                const Divider(height: 32),
                Text('Phí hủy 30% trước ${date}',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Thông tin liên hệ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thông tin liên hệ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => viewModel.previousStep(),
                child: const Text('Chỉnh sửa', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Họ tên', viewModel.contactName),
          _buildInfoRow('Điện thoại', viewModel.contactPhone),
          _buildInfoRow('Email', viewModel.contactEmail),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({required String location, required String address, required bool isStart}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isStart ? Colors.blue : Colors.red, width: 2),
              ),
            ),
            if (isStart) Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(address, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Thay đổi', style: TextStyle(color: Colors.blue, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
