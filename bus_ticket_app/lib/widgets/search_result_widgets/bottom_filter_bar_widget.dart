import 'package:bus_ticket_app/features/booking/viewmodel/search_trip_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class BottomFilterBarWidget extends StatefulWidget {
  const BottomFilterBarWidget({super.key});

  @override
  State<BottomFilterBarWidget> createState() => _BottomFilterBarWidgetState();
}

class _BottomFilterBarWidgetState extends State<BottomFilterBarWidget> {
  late SearchTripViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I<SearchTripViewModel>();
  }

  // Helper để format giờ gửi lên API: 24:00 -> 23:59 để tránh lỗi Java LocalTime
  String _formatTimeForApi(double hour) {
    int h = hour.round();
    if (h >= 24) return "23:59";
    return "${h.toString().padLeft(2, '0')}:00";
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SortSheet(viewModel: _viewModel),
    );
  }

  void _showTimeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TimeFilterSheet(
        viewModel: _viewModel,
        formatFn: _formatTimeForApi,
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MainFilterSheet(
        viewModel: _viewModel,
        formatFn: _formatTimeForApi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF152A47),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterItem(Icons.tune, 'Lọc', onTap: _showFilterSheet),
          _buildDivider(),
          _buildFilterItem(Icons.sort, 'Sắp xếp', onTap: _showSortSheet),
          _buildDivider(),
          _buildFilterItem(Icons.access_time, 'Giờ đi', onTap: _showTimeSheet),
        ],
      ),
    );
  }

  Widget _buildFilterItem(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 16,
      color: Colors.white.withOpacity(0.3),
    );
  }
}

// --- Common UI Components ---

class _SheetHeader extends StatelessWidget {
  final String title;
  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _BottomActionButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onApply;
  final String applyText;

  const _BottomActionButtons({
    required this.onClear,
    required this.onApply,
    this.applyText = 'Áp dụng',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              onPressed: onClear,
              child: const Text('Xóa lọc', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2E57),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: onApply,
              child: Text(applyText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Sheets ---

class _SortSheet extends StatefulWidget {
  final SearchTripViewModel viewModel;
  const _SortSheet({required this.viewModel});

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late String _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.viewModel.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      {'label': 'Mặc định', 'value': 'departure_asc'},
      {'label': 'Giờ đi sớm nhất', 'value': 'departure_asc'},
      {'label': 'Giờ đi muộn nhất', 'value': 'departure_desc'},
      {'label': 'Đánh giá cao nhất', 'value': 'rating_desc'},
      {'label': 'Giá giảm dần', 'value': 'price_desc'},
      {'label': 'Giá tăng dần', 'value': 'price_asc'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHeader(title: 'Sắp xếp'),
          ...options.map((opt) => RadioListTile<String>(
            title: Text(opt['label']!, style: const TextStyle(fontSize: 16)),
            value: opt['value']!,
            groupValue: _selectedSort,
            activeColor: Colors.blue,
            onChanged: (val) {
              setState(() => _selectedSort = val!);
              widget.viewModel.sortBy = val!;
              Navigator.pop(context);
            },
            controlAffinity: ListTileControlAffinity.trailing,
          )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TimeFilterSheet extends StatefulWidget {
  final SearchTripViewModel viewModel;
  final String Function(double) formatFn;
  const _TimeFilterSheet({required this.viewModel, required this.formatFn});

  @override
  State<_TimeFilterSheet> createState() => _TimeFilterSheetState();
}

class _TimeFilterSheetState extends State<_TimeFilterSheet> {
  RangeValues _currentRange = const RangeValues(0, 24);
  String _tempSort = 'departure_asc';

  @override
  void initState() {
    super.initState();
    _tempSort = widget.viewModel.sortBy;
    
    if (widget.viewModel.departureTimeFrom != null && widget.viewModel.departureTimeTo != null) {
      try {
        double start = double.parse(widget.viewModel.departureTimeFrom!.split(':')[0]);
        String toStr = widget.viewModel.departureTimeTo!;
        double end = (toStr == "23:59") ? 24 : double.parse(toStr.split(':')[0]);
        _currentRange = RangeValues(start, end);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHeader(title: 'Giờ đi'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                RangeSlider(
                  values: _currentRange,
                  min: 0,
                  max: 24,
                  divisions: 24,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey[200],
                  onChanged: (values) => setState(() => _currentRange = values),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _timeBox('Từ', '${_currentRange.start.round().toString().padLeft(2, '0')}:00'),
                    const Text('-', style: TextStyle(fontSize: 24, color: Colors.grey)),
                    _timeBox('Đến', _currentRange.end.round() == 24 ? "24:00" : '${_currentRange.end.round().toString().padLeft(2, '0')}:00'),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                RadioListTile<String>(
                  title: const Text('Mặc định'),
                  value: 'departure_asc',
                  groupValue: _tempSort,
                  activeColor: Colors.blue,
                  onChanged: (v) => setState(() => _tempSort = v!),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
                RadioListTile<String>(
                  title: const Text('Giờ đi sớm nhất'),
                  value: 'departure_asc',
                  groupValue: _tempSort,
                  activeColor: Colors.blue,
                  onChanged: (v) => setState(() => _tempSort = v!),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
                RadioListTile<String>(
                  title: const Text('Giờ đi muộn nhất'),
                  value: 'departure_desc',
                  groupValue: _tempSort,
                  activeColor: Colors.blue,
                  onChanged: (v) => setState(() => _tempSort = v!),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ],
            ),
          ),
          _BottomActionButtons(
            onClear: () {
              widget.viewModel.departureTimeFrom = null;
              widget.viewModel.departureTimeTo = null;
              widget.viewModel.applyFilters();
              Navigator.pop(context);
            },
            onApply: () {
              widget.viewModel.departureTimeFrom = widget.formatFn(_currentRange.start);
              widget.viewModel.departureTimeTo = widget.formatFn(_currentRange.end);
              widget.viewModel.sortBy = _tempSort;
              widget.viewModel.applyFilters();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String label, String time) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MainFilterSheet extends StatefulWidget {
  final SearchTripViewModel viewModel;
  final String Function(double) formatFn;
  const _MainFilterSheet({required this.viewModel, required this.formatFn});

  @override
  State<_MainFilterSheet> createState() => _MainFilterSheetState();
}

class _MainFilterSheetState extends State<_MainFilterSheet> {
  double? _minRating;
  RangeValues _priceRange = const RangeValues(0, 2000000);
  RangeValues _timeRange = const RangeValues(0, 24);

  @override
  void initState() {
    super.initState();
    _minRating = widget.viewModel.minRating;
    _priceRange = RangeValues(
      widget.viewModel.minPrice?.toDouble() ?? 0,
      widget.viewModel.maxPrice?.toDouble() ?? 2000000,
    );
    
    if (widget.viewModel.departureTimeFrom != null && widget.viewModel.departureTimeTo != null) {
      try {
        double start = double.parse(widget.viewModel.departureTimeFrom!.split(':')[0]);
        String toStr = widget.viewModel.departureTimeTo!;
        double end = (toStr == "23:59") ? 24 : double.parse(toStr.split(':')[0]);
        _timeRange = RangeValues(start, end);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const _SheetHeader(title: 'Lọc'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Giờ đi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _timeRange,
                    min: 0,
                    max: 24,
                    divisions: 24,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey[200],
                    onChanged: (val) => setState(() => _timeRange = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _smallTimeBox('Từ', '${_timeRange.start.round().toString().padLeft(2, '0')}:00'),
                      const Text('-', style: TextStyle(color: Colors.grey)),
                      _smallTimeBox('Đến', _timeRange.end.round() == 24 ? "24:00" : '${_timeRange.end.round().toString().padLeft(2, '0')}:00'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  _buildListFilterItem('Nhà xe', widget.viewModel.busCompanyId != null ? "Đã chọn" : 'Tất cả'),
                  _buildListFilterItem('Điểm đón', 'Tất cả'),
                  _buildListFilterItem('Điểm trả', 'Tất cả'),
                  const Divider(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Giá', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${currencyFormat.format(_priceRange.start)} - ${currencyFormat.format(_priceRange.end)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 2000000,
                    divisions: 20,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey[200],
                    onChanged: (val) => setState(() => _priceRange = val),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text('Đánh giá', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [4.0, 4.5, 4.7].map((r) => InkWell(
                      onTap: () => setState(() => _minRating = _minRating == r ? null : r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: _minRating == r ? Colors.blue : Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Text('≥ $r ', style: TextStyle(color: _minRating == r ? Colors.blue : Colors.black, fontWeight: FontWeight.bold)),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          _BottomActionButtons(
            onClear: () {
              widget.viewModel.clearFilters();
              Navigator.pop(context);
            },
            onApply: () {
              widget.viewModel.minPrice = _priceRange.start.toInt();
              widget.viewModel.maxPrice = _priceRange.end.toInt();
              widget.viewModel.minRating = _minRating;
              widget.viewModel.departureTimeFrom = widget.formatFn(_timeRange.start);
              widget.viewModel.departureTimeTo = widget.formatFn(_timeRange.end);
              widget.viewModel.applyFilters();
              Navigator.pop(context);
            },
            applyText: 'Xem chuyến',
          ),
        ],
      ),
    );
  }

  Widget _smallTimeBox(String label, String time) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildListFilterItem(String title, String trailing) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailing, style: const TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: () {
         if (title == 'Nhà xe') {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) => _BusCompanySheet(viewModel: widget.viewModel),
            );
         }
      },
    );
  }
}

class _BusCompanySheet extends StatefulWidget {
  final SearchTripViewModel viewModel;
  const _BusCompanySheet({required this.viewModel});

  @override
  State<_BusCompanySheet> createState() => _BusCompanySheetState();
}

class _BusCompanySheetState extends State<_BusCompanySheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedCompanies = [];
  
  final List<Map<String, dynamic>> _allCompanies = [
    {'id': '1', 'name': 'Anh Thư (Buôn Hồ)', 'rating': 4.0},
    {'id': '2', 'name': 'Anh Phụng', 'rating': 4.3},
    {'id': '3', 'name': 'An Phát Kbang (Gia Lai)', 'rating': 4.5},
    {'id': '4', 'name': 'An Đạt', 'rating': 4.6},
    {'id': '5', 'name': 'An Hoà Hiệp', 'rating': 4.3},
    {'id': '6', 'name': 'An Phú Buslines', 'rating': 4.7},
    {'id': '7', 'name': 'Bốn Luyện Express', 'rating': 4.0},
    {'id': '8', 'name': 'Bình Phương', 'rating': 3.9},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.viewModel.busCompanyId != null) {
      _selectedCompanies = widget.viewModel.busCompanyId!.split(',');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const _SheetHeader(title: 'Nhà xe'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm nhà xe trong danh sách dưới',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _allCompanies.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
              itemBuilder: (context, index) {
                final company = _allCompanies[index];
                final isSelected = _selectedCompanies.contains(company['id']);
                return ListTile(
                  title: Text(company['name'], style: const TextStyle(fontSize: 16)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${company['rating']} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: isSelected,
                        activeColor: const Color(0xFF0D2E57),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          setState(() {
                            if (val!) {
                              _selectedCompanies.add(company['id']);
                            } else {
                              _selectedCompanies.remove(company['id']);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _BottomActionButtons(
            onClear: () {
              setState(() => _selectedCompanies = []);
            },
            onApply: () {
              widget.viewModel.busCompanyId = _selectedCompanies.isEmpty ? null : _selectedCompanies.join(',');
              widget.viewModel.applyFilters();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
