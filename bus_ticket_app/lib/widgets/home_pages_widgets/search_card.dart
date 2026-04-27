import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchCard extends StatefulWidget {
  const SearchCard({super.key});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  String _departure = "Hồ Chí Minh";
  String _destination = "Đắk Lắk";
  bool _isRoundTrip = false;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
  }

  Future<void> _pickDate() async {
    if (_isRoundTrip) {
      DateTimeRange? pickedRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(
              context,
            ).copyWith(colorScheme: const ColorScheme.light()),
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
            data: Theme.of(
              context,
            ).copyWith(colorScheme: const ColorScheme.light()),
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
    iconColor,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                  _buildLocationTile(
                    Icons.circle_outlined,
                    Colors.blue,
                    "Nơi xuất phát",
                    _departure,
                  ),
                  const Divider(indent: 40),
                  _buildLocationTile(
                    Icons.location_on,
                    Colors.red,
                    "Bạn muốn đi đâu",
                    _destination,
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
                  onPressed: () {
                    setState(() {
                      String tmp = _departure;
                      _departure = _destination;
                      _destination = tmp;
                    });
                  },
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
                      Icon(Icons.calendar_today, color: Colors.blue),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRoundTrip && _endDate != null
                                ? "Ngày đi - Ngày về"
                                : "Ngày đi",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
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
                  Text("Khứ hồi"),
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
              onPressed: () {},
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
