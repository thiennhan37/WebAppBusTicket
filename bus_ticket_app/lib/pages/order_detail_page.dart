import 'package:bus_ticket_app/data/models/order_detail_model.dart';
import 'package:bus_ticket_app/data/repositories/customer_repository.dart';
import 'package:bus_ticket_app/features/customer/viewmodels/favorite_viewmodel.dart';
import 'package:bus_ticket_app/data/models/favorite_search_model.dart';
import 'package:bus_ticket_app/data/models/trip_rating_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<OrderDetailModel> _orderDetailFuture;
  late Future<TripRatingModel?> _tripRatingFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailFuture = GetIt.I<CustomerRepository>().getOrderDetail(widget.orderId);
    _tripRatingFuture = GetIt.I<CustomerRepository>().getOrderRating(widget.orderId);
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[date.weekday % 7];
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${_getDayOfWeek(dateTime)}, ${DateFormat('dd/MM/yyyy').format(dateTime)}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatFullDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${DateFormat('HH:mm').format(dateTime)} • ${_getDayOfWeek(dateTime)}, ${DateFormat('dd/MM/yyyy').format(dateTime)}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatPrice(int price) {
    return NumberFormat('#,###', 'vi_VN').format(price) + 'đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám nhạt cho toàn bộ trang
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chi tiết chuyến đi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_orderDetailFuture, _tripRatingFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.length < 2) {
            return const Center(child: Text('Không tìm thấy dữ liệu'));
          }

          final order = snapshot.data![0] as OrderDetailModel;
          final rating = snapshot.data![1] as TripRatingModel?;
          final departureDateTime = DateTime.parse(order.departureTime);
          final bool isPast = departureDateTime.isBefore(DateTime.now());

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Colors.black.withOpacity(0.4),
                  child: Text(
                    isPast
                        ? 'Chuyến đi đã hoàn thành lúc ${DateFormat('HH:mm • dd/MM/yyyy').format(departureDateTime)}'
                        : 'Chuyến đi dự kiến khởi hành lúc ${DateFormat('HH:mm • dd/MM/yyyy').format(departureDateTime)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                ),

                // 1. Thẻ vé tóm tắt (Timeline)
                _buildTripSummaryCard(order, departureDateTime, isPast),

                // 2. Khung Thông tin chuyến đi
                _buildInfoSection(
                  title: 'Thông tin chuyến đi',
                  children: [
                    _buildDetailRow('Mã đơn hàng', order.bookingOrderId),
                    _buildDetailRow('Tuyến', '${order.pickupProvince} - ${order.dropoffProvince}'),
                    _buildDetailRow('Nhà xe', order.busCompanyName),
                    _buildDetailRow('Chuyến', _formatFullDateTime(order.departureTime)),
                    _buildDetailRow('Loại xe', order.busType),
                    _buildDetailRow('Số lượng', '${order.seatCount} chỗ'),
                    _buildDetailRow('Mã ghế/giường', order.seatCodes.join(', ')),
                    _buildDetailRow('Tổng tiền', _formatPrice(order.totalAmount), isPrice: true),
                  ],
                ),

                const SizedBox(height: 8),

                // 3. Khung Thông tin liên hệ
                _buildInfoSection(
                  title: 'Thông tin liên hệ',
                  children: [
                    _buildDetailRow('Họ tên', order.contactName),
                    _buildDetailRow('Điện thoại', order.contactPhone),
                    _buildDetailRow('Email', order.contactEmail),
                  ],
                ),

                if (rating != null) ...[
                  const SizedBox(height: 8),
                  _buildRatingSection(rating),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingSection(TripRatingModel rating) {
    return _buildInfoSection(
      title: 'Đánh giá chuyến đi',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Đánh giá trung bình',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              children: [
                Text(
                  rating.averageStars.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.amber, size: 20),
              ],
            ),
          ],
        ),
        const Divider(height: 24),
        _buildRatingStarsRow('Chất lượng dịch vụ', rating.serviceQuality),
        _buildRatingStarsRow('Đúng giờ', rating.punctuality),
        _buildRatingStarsRow('An toàn', rating.safety),
        _buildRatingStarsRow('Vệ sinh', rating.cleanliness),
        if (rating.description != null && rating.description!.isNotEmpty) ...[
          const Divider(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Nhận xét',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              rating.description!,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingStarsRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < score ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard(OrderDetailModel order, DateTime departureDateTime, bool isPast) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_bus, color: Color(0xFF1E88E5), size: 20),
                    const SizedBox(width: 8),
                    const Text('VeXeDat', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(_formatDateTime(order.departureTime), style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.busCompanyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(order.busType, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        Consumer<FavoriteViewModel>(
                          builder: (context, favoriteVM, child) {
                            final favoriteInfo = FavoriteSearchModel(
                              departureProvinceId: order.pickupProvinceId,
                              departureProvinceName: order.pickupProvince,
                              destinationProvinceId: order.dropoffProvinceId,
                              destinationProvinceName: order.dropoffProvince,
                              pickupStopId: order.pickupStopId,
                              pickupStopName: order.pickupStop,
                              dropoffStopId: order.dropoffStopId,
                              dropoffStopName: order.dropoffStop,
                              busCompanyId: order.busCompanyId,
                              busCompanyName: order.busCompanyName,
                              departureTime: DateFormat('HH:mm').format(DateTime.parse(order.departureTime)),
                            );
                            final bool isFav = favoriteVM.isFavorite(favoriteInfo);
                            return IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                favoriteVM.toggleFavorite(favoriteInfo);
                                
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(!isFav ? 'Đã thêm vào yêu thích' : 'Đã bỏ yêu thích'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTimeline(departureDateTime, order),
                  ],
                ),
              ),
            ],
          ),
          if (isPast)
            Positioned(
              right: 20,
              top: 60,
              child: Transform.rotate(
                angle: -math.pi / 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ĐÃ ĐI',
                    style: TextStyle(color: Colors.red.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeline(DateTime departure, OrderDetailModel order) {
    return Row(
      children: [
        Column(
          children: [
            const Icon(Icons.radio_button_checked, color: Color(0xFF1E88E5), size: 16),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            const Icon(Icons.location_on, color: Colors.red, size: 16),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(order.pickupStop, style: const TextStyle(fontSize: 14))),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: Text(order.dropoffStop, style: const TextStyle(fontSize: 14))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (isPrice) ...[
                  const SizedBox(width: 4),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
