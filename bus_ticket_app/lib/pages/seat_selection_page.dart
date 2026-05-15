import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:bus_ticket_app/pages/home_pages.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/contact_info_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/payment_selection_widget.dart';import 'package:bus_ticket_app/widgets/seat_selection_widgets/payment_success_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/seat_diagram_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/step_indicator_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/stop_selection_widget.dart';
import 'package:bus_ticket_app/widgets/seat_selection_widgets/trip_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_navigation.dart';

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
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.stopStatusCheck(); // Dừng polling ngay lập tức
    _viewModel.dispose(); // Hủy toàn bộ timer và dispose ViewModel (do ViewModel là factory)
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    if (_viewModel.isPaymentSuccessful) {
      _viewModel.stopStatusCheck();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessWidget(
            orderId: _viewModel.orderCode ?? '',
            totalPrice: _viewModel.totalPrice,
            contactEmail: _viewModel.contactEmail,
            busCompanyName: widget.busCompanyName,
            date: widget.date,
            time: widget.departureTime,
          ),
        ),
      );
      return;
    }

    if (_viewModel.isTimerExpired) {
      _viewModel.stopPaymentTimer();
      _showTimeoutDialog();
    }
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hết thời gian'),
          content: const Text('Thời gian giữ chỗ của bạn đã hết. Vui lòng thực hiện lại giao dịch.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
                Navigator.of(context).pop(); 
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmationDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.help_outline, size: 50, color: Colors.blue[300]),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bạn cần xem hoặc đổi thông tin?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Nhấn Chi tiết để xem hoặc đổi thông tin.\nNhấn Dừng thanh toán để trở về Trang chủ,\n'),
                    TextSpan(
                      text: 'Vexere sẽ giữ chỗ cho bạn trong tối đa 10 phút.',
                      style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _viewModel.stopStatusCheck(); // Dừng check khi bấm dừng thanh toán
                        Navigator.pop(context); 
                        _showHoldSuccessDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('Dừng thanh toán', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHoldSuccessDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 50, color: Color(0xFF66BB6A)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chỗ sẽ được giữ trong 10 phút',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Bạn có thể thanh toán cho đơn hàng này trong Đơn hàng\nhoặc trong phần Chờ thanh toán ở Trang chủ.\n'),
                    TextSpan(
                      text: 'Sau thời gian trên, chỗ sẽ bị hủy.',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const CustomBottonNav()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2E57),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, SeatSelectionViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: Text(viewModel.errorMessage ?? 'Lỗi đặt vé'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (viewModel.lastErrorCode == 4010) {
                  viewModel.refreshBusDiagram(widget.tripId);
                  viewModel.goToStep(1);
                } else if (viewModel.lastErrorCode == 4013) {
                  Navigator.of(context).pop(); 
                }
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_viewModel.currentStep == 6) {
            _showExitConfirmationDialog();
          } else if (_viewModel.currentStep > 1) {
            _viewModel.previousStep();
          } else {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue[600],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (_viewModel.currentStep == 6) {
                  _showExitConfirmationDialog();
                } else if (_viewModel.currentStep > 1) {
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
      ),
    );
  }

  Widget _buildCurrentStepContent(SeatSelectionViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
      case 6:
        return const PaymentSelectionWidget();
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
    if (viewModel.currentStep == 6 && viewModel.selectedPaymentMethod != null) canContinue = true;

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
                    const Text('Tổng tiền', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Row(
                      children: [
                        Text(
                          _formatPrice(viewModel.totalPrice),
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: canContinue ? () async {
                  if (viewModel.currentStep == 5) {
                    final success = await viewModel.holdSeats(widget.tripId);
                    if (success) {
                      viewModel.nextStep();
                    } else {
                      if (context.mounted) {
                        _showErrorDialog(context, viewModel);
                      }
                    }
                  } else if (viewModel.currentStep < 6) {
                    if (viewModel.currentStep == 1) {
                      viewModel.fetchDepartureStops(widget.departureProvinceId);
                    } else if (viewModel.currentStep == 2) {
                      viewModel.fetchArrivalStops(widget.destinationProvinceId);
                    }
                    viewModel.nextStep();
                  } else {
                    _handlePayment(viewModel);
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (viewModel.currentStep == 6)
                      const Icon(Icons.lock, size: 18),
                    if (viewModel.currentStep == 6)
                      const SizedBox(width: 8),
                    Text(viewModel.currentStep >= 5 ? 'Thanh toán' : 'Tiếp tục', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.currentStep == 6 
              ? 'Sớm nhận biển số xe, số điện thoại tài xế sau khi đặt'
              : (viewModel.currentStep < 4 ? 'Dễ dàng thay đổi điểm đón trả sau khi đặt' : 'Bạn có thể mua thêm tiện ích ở bước tiếp theo'),
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _handlePayment(SeatSelectionViewModel viewModel) {
    // Gọi processPayment() để kích hoạt timer kiểm tra trạng thái
    viewModel.processPayment();
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }
}
