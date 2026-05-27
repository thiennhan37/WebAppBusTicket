import 'package:bus_ticket_app/features/customer/viewmodels/favorite_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'searh_result_page.dart';

class FavoritePages extends StatefulWidget {
  const FavoritePages({super.key});

  @override
  State<FavoritePages> createState() => _FavoritePagesState();
}

class _FavoritePagesState extends State<FavoritePages> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteViewModel>().loadFavoriteTripsByDate(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Yêu thích',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: Consumer<FavoriteViewModel>(
              builder: (context, favoriteVM, child) {
                if (favoriteVM.favorites.isEmpty) {
                  return _buildEmptyState();
                }

                if (favoriteVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (favoriteVM.errorMessage != null) {
                  return Center(child: Text(favoriteVM.errorMessage!));
                }

                if (favoriteVM.favoriteTrips.isEmpty) {
                  return const Center(
                    child: Text('Không có chuyến xe nào phù hợp'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Lịch trình cho ${_formatFullDate(_selectedDate)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: favoriteVM.favoriteTrips.length,
                        itemBuilder: (context, index) {
                          final trip = favoriteVM.favoriteTrips[index];
                          return _buildFavoriteTripCard(trip);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              context.read<FavoriteViewModel>().loadFavoriteTripsByDate(_selectedDate);
            },
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayLabel(index, date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayLabel(int index, DateTime date) {
    if (index == 0) return 'Hôm nay';
    if (index == 1) return 'Ngày mai';
    switch (date.weekday) {
      case 1: return 'Thứ 2';
      case 2: return 'Thứ 3';
      case 3: return 'Thứ 4';
      case 4: return 'Thứ 5';
      case 5: return 'Thứ 6';
      case 6: return 'Thứ 7';
      case 7: return 'Chủ nhật';
      default: return '';
    }
  }

  String _formatFullDate(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    final dayLabel = _getDayLabel(diff, date);
    return '$dayLabel, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  Widget _buildFavoriteTripCard(dynamic trip) {
    bool isClosed = false;
    final now = DateTime.now();
    final bool isPlaceholder = trip.id.toString().startsWith('fav_');

    if (!isPlaceholder && DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(now)) {
       try {
         final tripTime = DateFormat('HH:mm').parse(trip.departureTime);
         final tripDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, tripTime.hour, tripTime.minute);
         if (tripDateTime.difference(now).inMinutes < 60) {
           isClosed = true;
         }
       } catch (e) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Opacity(
        opacity: isPlaceholder ? 0.7 : 1.0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.departureTime,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(trip.duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        trip.arrivalTime,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      const SizedBox(height: 6),
                      const Icon(Icons.circle_outlined, size: 14, color: Colors.blue),
                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                      const Icon(Icons.location_on, size: 14, color: Colors.red),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          trip.departureStation,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          trip.arrivalStation,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isPlaceholder)
                        const Text(
                          'Không có chuyến đi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
                        )
                      else if (isClosed)
                        const Text(
                          'Ngừng đặt online',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        )
                      else ...[
                        Text(
                          '${NumberFormat('#,###', 'vi_VN').format(trip.price)}đ',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${trip.availableSeats} chỗ trống',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://picsum.photos/seed/${trip.id}/100/100',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade200),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.busCompanyName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          trip.busType,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            final favorite = context.read<FavoriteViewModel>().getFavoriteForTrip(trip.id);
                            if (favorite != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchResultPage(
                                    departureName: favorite.departureProvinceName,
                                    destinationName: favorite.destinationProvinceName,
                                    departureId: favorite.departureProvinceId,
                                    destinationId: favorite.destinationProvinceId,
                                    startDate: _selectedDate,
                                    pickupStopIds: favorite.pickupStopId != null ? [favorite.pickupStopId!] : null,
                                    dropoffStopIds: favorite.dropoffStopId != null ? [favorite.dropoffStopId!] : null,
                                    busCompanyIds: favorite.busCompanyId.isNotEmpty ? [favorite.busCompanyId] : null,
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Xem các khung giờ khác >',
                            style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<FavoriteViewModel>(
                    builder: (context, favoriteVM, child) {
                      final isFav = favoriteVM.isTripFavorite(trip.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          if (isFav) {
                            favoriteVM.removeFavoriteByTripId(trip.id);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã bỏ yêu thích'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.blue.shade200,
              size: 100,
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Bạn chưa lưu chuyến xe nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nhấn vào biểu tượng trái tim trên chuyến xe\nđể lưu và đặt lại trong tích tắc',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
