import 'package:bus_ticket_app/data/models/order_model.dart';
import 'package:bus_ticket_app/data/models/province_model.dart';
import 'package:bus_ticket_app/data/repositories/location_repository.dart';
import 'package:bus_ticket_app/data/services/local/booking_storage.dart';
import 'package:bus_ticket_app/features/customer/viewmodels/my_tickets_viewmodel.dart';
import 'package:bus_ticket_app/pages/order_detail_page.dart';
import 'package:bus_ticket_app/pages/seat_selection_page.dart';
import 'package:bus_ticket_app/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class TicketCardWidget extends StatelessWidget {
  final OrderModel order;

  const TicketCardWidget({
    super.key,
    required this.order,
  });

  Future<ProvinceModel?> _findProvince(String name) async {
    try {
      final repository = GetIt.I<LocationRepository>();
      final results = await repository.searchProvinces(name);
      if (results.isNotEmpty) {
        return results.firstWhere(
              (p) => p.name.toLowerCase() == name.toLowerCase(),
          orElse: () => results.first,
        );
      }
    } catch (e) {
      debugPrint('Error finding province: $e');
    }
    return null;
  }

  void _handleRebooking(BuildContext context, {bool isReturn = false}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final departureProv = await _findProvince(order.departureProvince);
    final destinationProv = await _findProvince(order.destinationProvince);

    if (context.mounted) {
      Navigator.pop(context);

      if (departureProv != null && destinationProv != null) {
        final storage = GetIt.I<BookingStorage>();
        if (isReturn) {
          await storage.saveDeparture(destinationProv);
          await storage.saveDestination(departureProv);
        } else {
          await storage.saveDeparture(departureProv);
          await storage.saveDestination(destinationProv);
        }

        final navState = context.findAncestorStateOfType<CustomBottonNavState>();
        if (navState != null) {
          navState.changeTab(0);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lấy thông tin địa điểm. Vui lòng thử lại.')),
        );
      }
    }
  }

  void _showStatusDialog(BuildContext context, {required bool isSuccess, required String message, String? subMessage}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              if (subMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  subMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext outerContext) {
    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final viewModel = outerContext.read<MyTicketsViewModel>();
              final orderId = order.orderId;

              Navigator.pop(dialogContext);

              final success = await viewModel.cancelOrder(orderId);

              if (outerContext.mounted) {
                if (success) {
                  _showStatusDialog(
                      outerContext,
                      isSuccess: true,
                      message: 'Hủy đơn hàng thành công',
                      subMessage: 'Đơn hàng $orderId của bạn đã được hủy bỏ thành công.'
                  );
                } else {
                  _showStatusDialog(
                      outerContext,
                      isSuccess: false,
                      message: 'Hủy đơn thất bại',
                      subMessage: viewModel.errorMessage ?? 'Đã có lỗi xảy ra, vui lòng thử lại sau.'
                  );
                }
              }
            },
            child: const Text('Hủy đơn', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showStatusDialogAfterRating(BuildContext context, Map<String, dynamic> response) {
    if (response['code'] == 0) {
      _showStatusDialog(
        context,
        isSuccess: true,
        message: 'Đánh giá thành công',
        subMessage: 'Cảm ơn bạn đã đóng góp ý kiến giúp VeXeDat ngày càng hoàn thiện hơn!',
      );
    } else if (response['code'] == 4015) {
      _showStatusDialog(
        context,
        isSuccess: false,
        message: 'Thông báo',
        subMessage: response['message'] ?? 'Chuyến đi này đã được đánh giá rồi.',
      );
    } else {
      _showStatusDialog(
        context,
        isSuccess: false,
        message: 'Đánh giá thất bại',
        subMessage: response['message'] ?? 'Đã có lỗi xảy ra, vui lòng thử lại sau.',
      );
    }
  }

  void _showRatingDialog(BuildContext outerContext) {
    int serviceQuality = 5;
    int punctuality = 5;
    int safety = 5;
    int cleanliness = 5;

    final viewModel = outerContext.read<MyTicketsViewModel>();

    showDialog(
      context: outerContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Text(
                'Đánh giá chuyến đi',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingCategory('Chất lượng dịch vụ', serviceQuality, (val) => setState(() => serviceQuality = val)),
                  _buildRatingCategory('Đúng giờ', punctuality, (val) => setState(() => punctuality = val)),
                  _buildRatingCategory('An toàn', safety, (val) => setState(() => safety = val)),
                  _buildRatingCategory('Vệ sinh', cleanliness, (val) => setState(() => cleanliness = val)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
               ElevatedButton(
                 onPressed: () async {
                   final response = await viewModel.rateOrder(order.orderId, {
                     "serviceQuality": serviceQuality,
                     "punctuality": punctuality,
                     "safety": safety,
                     "cleanliness": cleanliness,
                   });

                   // Use dialogContext to ensure we have a valid context
                   // dialogContext is from the dialog itself, so it's always valid
                   if (!dialogContext.mounted) {
                     debugPrint('Dialog context unmounted');
                     return;
                   }

                   // Close the rating dialog
                   try {
                     Navigator.pop(dialogContext);
                   } catch (e) {
                     debugPrint('Error closing dialog: $e');
                     return;
                   }

                   // Get the context for showing status dialog
                   // Use the parent context of dialogContext to show the status dialog
                   if (!outerContext.mounted) {
                     debugPrint('Outer context unmounted, trying to get new context');
                     // If outerContext is unmounted, try to get context from Navigator
                     try {
                       final navContext = Navigator.of(dialogContext).context;
                       if (navContext.mounted) {
                        _showStatusDialogAfterRating(navContext, response);
                       }
                     } catch (e) {
                       debugPrint('Could not get valid context: $e');
                     }
                     return;
                   }

                   _showStatusDialogAfterRating(outerContext, response);
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF1E88E5),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                 ),
                 child: const Text('Gửi đánh giá', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
               ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingCategory(String label, int rating, Function(int) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onRatingChanged(index + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime departureDateTime = DateTime.parse(order.departureTime);
    String timeStr = DateFormat('HH:mm').format(departureDateTime);
    String dateStr = DateFormat('dd/MM/yyyy').format(departureDateTime);
    String totalCostStr = NumberFormat('#,###', 'vi_VN').format(order.totalCost) + 'đ';

    final bool isPast = departureDateTime.isBefore(DateTime.now());

    String statusText = '';
    Color statusColor = Colors.grey;
    bool isPending = false;
    bool showStamp = false;
    bool isPaid = false;

    switch (order.orderStatus) {
      case 'HOLDING':
        statusText = 'Chờ thanh toán';
        statusColor = Colors.orange;
        isPending = true;
        break;
      case 'PAID':
        statusText = 'Đã thanh toán';
        statusColor = Colors.green;
        isPaid = true;
        if (isPast) showStamp = true;
        break;
      case 'CANCELLED':
        statusText = 'Đã hủy';
        statusColor = Colors.red;
        break;
      case 'EXPIRED':
        statusText = 'Hết hạn';
        statusColor = Colors.red;
        break;
      default:
        statusText = order.orderStatus;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_bus, color: Color(0xFF1E88E5), size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'VeXeDat',
                          style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(orderId: order.orderId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                            child: const Icon(Icons.directions_bus, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.departureProvince} → ${order.destinationProvince}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Nhà xe', order.busCompanyName),
                            const SizedBox(height: 4),
                            _buildInfoRow('Mã đơn', order.orderId),
                            const SizedBox(height: 4),
                            _buildInfoRow('Tổng tiền', totalCostStr),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (isPaid && isPast) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showRatingDialog(context),
                          icon: const Icon(Icons.star, size: 18),
                          label: const Text('Đánh giá chuyến đi', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (isPending) {
                                _showCancelDialog(context);
                              } else {
                                _handleRebooking(context, isReturn: false);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isPending ? Colors.red : const Color(0xFF0D47A1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor: isPending ? Colors.white : const Color(0xFF0D47A1),
                            ),
                            child: Text(
                              isPending ? 'Hủy đơn hàng' : 'Đặt lại',
                              style: TextStyle(
                                color: isPending ? Colors.red : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (isPending) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeatSelectionPage(
                                      tripId: '',
                                      busCompanyName: order.busCompanyName,
                                      departureTime: timeStr,
                                      date: dateStr,
                                      departureProvinceId: '',
                                      destinationProvinceId: '',
                                      existingOrderId: order.orderId,
                                      totalPrice: order.totalCost,
                                    ),
                                  ),
                                );
                              } else {
                                _handleRebooking(context, isReturn: true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPending ? const Color(0xFF1E88E5) : const Color(0xFFFFD54F),
                              foregroundColor: isPending ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                            child: Text(
                              isPending ? 'Thanh toán' : 'Đặt chiều về',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showStamp)
            Positioned(
              right: 20,
              bottom: 120,
              child: Transform.rotate(
                angle: -math.pi / 12,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.withOpacity(0.4), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ĐÃ ĐI',
                      style: TextStyle(
                        color: Colors.red.withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
