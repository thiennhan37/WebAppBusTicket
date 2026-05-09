import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/contact_info_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/seat_diagram_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/step_indicator_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/stop_selection_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/trip_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

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
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('Chi tiết', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
            ),
          ],
        ),
        body: Consumer<SeatSelectionViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                StepIndicatorWidget(currentStep: viewModel.currentStep),
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
        return const SeatDiagramWidget();
      case 2:
        return StopSelectionWidget(
          isDeparture: true,
          stops: viewModel.filteredDepartureStops,
          selectedStop: viewModel.selectedDepartureStop,
          onStopSelected: viewModel.selectDepartureStop,
        );
      case 3:
        return StopSelectionWidget(
          isDeparture: false,
          stops: viewModel.filteredArrivalStops,
          selectedStop: viewModel.selectedArrivalStop,
          onStopSelected: viewModel.selectArrivalStop,
        );
      case 4:
        return const ContactInfoWidget();
      case 5:
        return TripSummaryWidget(date: widget.date);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar(SeatSelectionViewModel viewModel) {
    if (viewModel.selectedSeats.isEmpty && viewModel.currentStep == 1) return const SizedBox();

    bool canContinue = false;
    if (viewModel.currentStep == 1 && viewModel.selectedSeats.isNotEmpty) canContinue = true;
    if (viewModel.currentStep == 2 && viewModel.selectedDepartureStop != null) canContinue = true;
    if (viewModel.currentStep == 3 && viewModel.selectedArrivalStop != null) canContinue = true;
    if (viewModel.currentStep == 4 && viewModel.contactName.isNotEmpty && viewModel.contactPhone.isNotEmpty) canContinue = true;
    if (viewModel.currentStep == 5) canContinue = true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  if (viewModel.currentStep == 1) {
                    viewModel.fetchDepartureStops(widget.departureProvinceId);
                    viewModel.nextStep();
                  } else if (viewModel.currentStep == 2) {
                    viewModel.fetchArrivalStops(widget.destinationProvinceId);
                    viewModel.nextStep();
                  } else if (viewModel.currentStep == 3) {
                    viewModel.nextStep();
                  } else if (viewModel.currentStep == 4) {
                    viewModel.nextStep();
                  } else {
                    // Bước cuối cùng: Xác nhận đặt vé
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
                child: Text(viewModel.currentStep == 5 ? 'Thanh toán' : 'Tiếp tục', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.currentStep < 4 ? 'Dễ dàng thay đổi điểm đón trả sau khi đặt' : 'Bạn có thể mua thêm tiện ích ở bước tiếp theo',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }
}
