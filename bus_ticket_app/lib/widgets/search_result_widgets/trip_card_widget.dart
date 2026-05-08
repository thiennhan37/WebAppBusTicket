import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onBookPressed; // Hàm xử lý khi nhấn "Chọn chỗ"

  const TripCard({
    super.key,
    required this.trip,
    required this.onBookPressed,
  });
  // Hàm phụ trợ để format giá tiền (VD: 250000 -> 250.000đ)
  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PHẦN 1: THỜI GIAN, ĐỊA ĐIỂM, GIÁ VÉ ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột Thời gian
              Column(
                children: [
                  Text(trip.departureTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(trip.duration, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(trip.arrivalTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 12),

              // Cột Timeline
              Column(
                children: [
                  const SizedBox(height: 6),
                  const Icon(Icons.circle_outlined, size: 14, color: Colors.blue),
                  Container(
                    width: 2,
                    height: 24,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey.shade300,
                  ),
                  const Icon(Icons.location_on, size: 14, color: Colors.red),
                ],
              ),
              const SizedBox(width: 12),

              // Cột Địa điểm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(trip.departureStation, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    Text(trip.arrivalStation, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  ],
                ),
              ),

              // Cột Giá & Ghế trống
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatPrice(trip.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text('${trip.availableSeats} chỗ trống', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),

          const Divider(height: 24, color: Colors.black12),

          // --- PHẦN 2: THÔNG TIN NHÀ XE ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh xe
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos/seed/bus/100/100',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60, height: 60, color: Colors.grey[200],
                    child: const Icon(Icons.directions_bus, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Tên & Đánh giá
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.busCompanyName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(trip.busType, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(trip.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(' (${trip.reviewCount} đánh giá)', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.favorite_border, color: Colors.grey),
            ],
          ),

          const SizedBox(height: 12),

          // --- PHẦN 3: TIỆN ÍCH & NÚT CHỌN CHỖ ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Cột Tiện ích (Dùng vòng lặp để render mảng amenities)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ['Không cần thanh toán trước',
                    'Đón trả tận nơi',
                    'Xác nhận chỗ ngay lập tức'].map((amenity) => _buildAmenity(Icons.check_circle_outline, amenity)).toList(),
                ),
              ),

              // Nút Chọn chỗ
              ElevatedButton(
                onPressed: onBookPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Chọn chỗ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenity(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.green),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}