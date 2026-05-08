import 'package:bus_ticket_app/data/services/local/booking_storage.dart';
import 'package:bus_ticket_app/pages/searh_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/province_model.dart';
import '../../pages/location_search_pages.dart';

class SearchCard extends StatefulWidget {
  const SearchCard({super.key});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  ProvinceModel? _departure;
  ProvinceModel? _destination;

  bool _isRoundTrip = false;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final _storage = GetIt.I<BookingStorage>(); // Gọi GetIt ra để dùng chung

  @override
  void initState() {
    super.initState();
    _loadSavedLocations(); // Load dữ liệu ngay khi widget vừa render
  }

  // Hàm đọc từ LocalStorage
  void _loadSavedLocations() {
    setState(() {
      _departure = _storage.getDeparture();
      _destination = _storage.getDestination();
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
  }

  // Hàm chọn điểm và LƯU LẠI
  Future<void> _selectLocation(bool isOrigin) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchPage(isOrigin: isOrigin),
      ),
    );

    if (result != null && result is ProvinceModel) {
      setState(() {
        if (isOrigin) {
          _departure = result;
          _storage.saveDeparture(result);
        } else {
          _destination = result;
          _storage.saveDestination(result);
        }
      });
    }
  }

  void _swapLocations() {
    setState(() {
      ProvinceModel? tmp = _departure;
      _departure = _destination;
      _destination = tmp;
    });
    _storage.saveDeparture(_departure);
    _storage.saveDestination(_destination);
  }

  Future<void> _pickDate() async {
    if (_isRoundTrip) {
      DateTimeRange? pickedRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light()),
            child: child!,
          );
        },
      );
      if (pickedRange != null) {
        setState(() {
          _startDate = pickedRange.start;
          _endDate = pickedRange.end;
        });
      }
    } else {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light()),
            child: child!,
          );
        },
      );
      if (pickedDate != null) {
        setState(() {
          _startDate = pickedDate;
        });
      }
    }
  }

  Widget _buildLocationTile(
      IconData icon,
      Color iconColor,
      String title,
      String value,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: value.contains("Chọn điểm") ? FontWeight.w500 : FontWeight.bold,
                      fontSize: 16,
                      color: value.contains("Chọn điểm") ? Colors.grey.shade600 : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/busSearch.svg',
            height: 30,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          const Divider(),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Column(
                children: [
                  // 4. TRUYỀN HÀM onTap VÀ TÊN TỈNH VÀO
                  _buildLocationTile(
                    Icons.circle_outlined,
                    Colors.blue,
                    "Nơi xuất phát",
                    _departure?.name ?? "Chọn điểm đi",
                        () => _selectLocation(true), // isOrigin = true
                  ),
                  const Divider(indent: 40),
                  _buildLocationTile(
                    Icons.location_on,
                    Colors.red,
                    "Bạn muốn đi đâu",
                    _destination?.name ?? "Chọn điểm đến",
                        () => _selectLocation(false), // isOrigin = false
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _swapLocations,
                  icon: const Icon(Icons.swap_vert, size: 20),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRoundTrip && _endDate != null
                                ? "Ngày đi - Ngày về"
                                : "Ngày đi",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            _isRoundTrip && _endDate != null
                                ? "${_formatDate(_startDate)} - ${_formatDate(_endDate!)}"
                                : _formatDate(_startDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  const Text("Khứ hồi"),
                  Switch(
                    value: _isRoundTrip,
                    onChanged: (val) {
                      setState(() {
                        _isRoundTrip = val;
                        if (!val) {
                          _endDate = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD54F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_departure == null || _destination == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn cả điểm xuất phát và điểm đến'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return; // Dừng lại, không cho sang trang
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchResultPage(
                      departureName: _departure!.name,
                      destinationName: _destination!.name,
                      departureId: _departure!.id,
                      destinationId: _destination!.id,
                      startDate: _startDate,
                      endDate: _endDate,
                      isRoundTrip: _isRoundTrip,
                    ),
                  ),
                );

                print("Đang tìm chuyến từ: ${_departure!.name} đến ${_destination!.name}");
              },
              child: const Text(
                'Tìm kiếm',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}