import 'package:bus_ticket_app/data/models/stop_model.dart';
import 'package:bus_ticket_app/features/booking/viewmodel/seat_selection_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:string_normalizer/string_normalizer.dart';

class StopSelectionWidget extends StatefulWidget {
  final bool isDeparture;
  final List<StopModel> stops;
  final StopModel? selectedStop;
  final Function(StopModel) onStopSelected;

  const StopSelectionWidget({
    super.key,
    required this.isDeparture,
    required this.stops,
    required this.selectedStop,
    required this.onStopSelected,
  });

  @override
  State<StopSelectionWidget> createState() => _StopSelectionWidgetState();
}

class _StopSelectionWidgetState extends State<StopSelectionWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();
  static const double _itemExtent = 130.0;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _scrollToFirstMatch(List<StopModel> stops, String query) {
    if (query.isEmpty) return;

    final normalizedQuery = normalize(query);

    final index = stops.indexWhere((stop) {
      return normalize(stop.name).contains(normalizedQuery) ||
          normalize(stop.address).contains(normalizedQuery);
    });

    if (index != -1) {
      _scrollController.animateTo(
        index * _itemExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SeatSelectionViewModel>();
    final filteredStops = widget.isDeparture
        ? viewModel.filteredDepartureStops
        : viewModel.filteredArrivalStops;


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchTextController,
            onChanged: (value) {
              viewModel.updateSearchQuery(value);
              _scrollToFirstMatch(widget.stops, value);
            },
            decoration: InputDecoration(
              hintText: 'Tìm điểm ${widget.isDeparture ? "đón" : "trả"} trong danh sách dưới',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: viewModel.searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchTextController.clear();
                  viewModel.updateSearchQuery('');
                },
              )
                  : null,
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
        const SizedBox(height: 12),
        Expanded(
          child: filteredStops.isEmpty
              ? const Center(child: Text('Không tìm thấy điểm nào khớp'))
              : ListView.builder(
            controller: _scrollController,
            itemCount: filteredStops.length,
            itemExtent: _itemExtent,
            itemBuilder: (context, index) {
              final stop = filteredStops[index];
              final isSelected = widget.selectedStop?.id == stop.id;
              final query = viewModel.searchQuery;


              final isHighlighted =
                  viewModel.searchQuery.isNotEmpty &&
                      (
                          normalize(stop.name)
                              .contains(normalize(viewModel.searchQuery)) ||
                              normalize(stop.address)
                                  .contains(normalize(viewModel.searchQuery))
                      );

              return InkWell(
                onTap: () => widget.onStopSelected(stop),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.05)
                        : isHighlighted
                        ? Colors.amber.withOpacity(0.08)
                        : Colors.white,
                    border: Border(
                      left: BorderSide(color: isSelected ? Colors.blue : (isHighlighted ? Colors.amber : Colors.transparent), width: 4),
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? Colors.blue : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('22:31', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(stop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(stop.address, style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  String normalize(String text) {
    return StringNormalizer.normalize(text)
        .toLowerCase()
        .trim();
  }
}