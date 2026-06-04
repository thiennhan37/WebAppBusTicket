
import 'package:bus_ticket_app/data/models/trip_model.dart';

class PaginatedTripResult{
  final List<TripModel> trips;
  final int currentPage;
  final int? totalPages;
  final int? totalElements;
  const PaginatedTripResult({
    required this.trips,
    required this.currentPage,
    this.totalPages,
    this.totalElements,
  });
  bool get hasNextPage{
    if(totalPages == null) return false;
    return currentPage + 1 < totalPages!;
  }
}