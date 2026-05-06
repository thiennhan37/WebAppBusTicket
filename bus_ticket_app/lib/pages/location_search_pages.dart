import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../data/models/province_model.dart';
import '../features/booking/viewmodel/location_viewmodel.dart';

class LocationSearchPage extends StatefulWidget {
  final bool isOrigin; // true: Nơi xuất phát, false: Nơi đến

  const LocationSearchPage({super.key, required this.isOrigin});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String title = widget.isOrigin ? 'Nơi xuất phát' : 'Bạn muốn đi đâu?';
    final IconData inputIcon = widget.isOrigin ? Icons.circle : Icons.location_on;
    final Color inputIconColor = widget.isOrigin ? Colors.blue : Colors.red;
    final double iconSize = widget.isOrigin ? 16.0 : 20.0;

    return ChangeNotifierProvider<LocationViewModel>(
      create: (_) => GetIt.I<LocationViewModel>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(inputIcon, color: inputIconColor, size: iconSize),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<LocationViewModel>(
                      builder: (context, viewModel, child) {
                        return TextField(
                          controller: _searchController,
                          onChanged: viewModel.onSearchChanged,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Tên tỉnh/thành phố, quận/huyện',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                            border: InputBorder.none,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),

            // Tiêu đề "Địa danh phổ biến" hoặc "Kết quả tìm kiếm"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Địa danh phổ biến',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Danh sách kết quả
            Expanded(
              child: Consumer<LocationViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.provinces.isEmpty) {
                    return const Center(child: Text('Không tìm thấy kết quả'));
                  }

                  return ListView.separated(
                    itemCount: viewModel.provinces.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Colors.black12,
                      indent: 48, // Thụt lề gạch chân giống UI
                    ),
                    itemBuilder: (context, index) {
                      final ProvinceModel province = viewModel.provinces[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                        ),
                        title: Text(
                          province.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          // Trả kết quả về màn hình trước đó
                          Navigator.pop(context, province);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}