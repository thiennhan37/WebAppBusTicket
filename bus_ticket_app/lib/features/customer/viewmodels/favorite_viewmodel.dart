import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/favorite_search_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/repositories/trip_repository.dart';

class FavoriteViewModel extends ChangeNotifier {
  static const String _storageKey = 'favorite_searches';

  final TripRepository _tripRepository;

  FavoriteViewModel(this._tripRepository) {
    _loadFavorites();
  }

  List<FavoriteSearchModel> _favorites = [];
  List<FavoriteSearchModel> get favorites => _favorites;

  List<TripModel> _favoriteTrips = [];
  List<TripModel> get favoriteTrips => _favoriteTrips;

  // Mapping tripId to its corresponding favorite configuration
  final Map<String, FavoriteSearchModel> _tripToFavorite = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_storageKey);
    if (favoritesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        _favorites = decoded
            .map((item) =>
            FavoriteSearchModel.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error decoding favorites: $e');
      }
    }
  }

  Future<void> toggleFavorite(FavoriteSearchModel favorite) async {
    final index = _favorites.indexWhere((item) =>
        item.departureProvinceId == favorite.departureProvinceId &&
        item.destinationProvinceId == favorite.destinationProvinceId &&
        item.busCompanyId == favorite.busCompanyId &&
        item.departureTime == favorite.departureTime &&
        item.pickupStopId == favorite.pickupStopId &&
        item.dropoffStopId == favorite.dropoffStopId);

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(favorite);
    }
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> removeFavoriteByTripId(String tripId) async {
    final favorite = _tripToFavorite[tripId];
    if (favorite != null) {
      await toggleFavorite(favorite);
      // Immediately update UI
      _favoriteTrips.removeWhere((t) => t.id == tripId);
      _tripToFavorite.remove(tripId);
      notifyListeners();
    }
  }

  FavoriteSearchModel? getFavoriteForTrip(String tripId) {
    return _tripToFavorite[tripId];
  }

  bool isFavorite(FavoriteSearchModel favorite) {
    return _favorites.any((item) =>
        item.departureProvinceId == favorite.departureProvinceId &&
        item.destinationProvinceId == favorite.destinationProvinceId &&
        item.busCompanyId == favorite.busCompanyId &&
        item.departureTime == favorite.departureTime &&
        item.pickupStopId == favorite.pickupStopId &&
        item.dropoffStopId == favorite.dropoffStopId);
  }

  bool isTripFavorite(String tripId) {
    return _tripToFavorite.containsKey(tripId);
  }

  Future<void> loadFavoriteTripsByDate(DateTime selectedDate) async {
    if (_favorites.isEmpty) {
      _favoriteTrips = [];
      _tripToFavorite.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
    final List<TripModel> allTrips = [];
    _tripToFavorite.clear();

    try {
      for (final favorite in _favorites) {
        final result = await _tripRepository.searchTrip(
          startProvince: favorite.departureProvinceId, // ID tỉnh (VD: DLK)
          endProvince: favorite.destinationProvinceId, // ID tỉnh (VD: HCM)
          date: formattedDate,
          busCompanyIds: favorite.busCompanyId.isNotEmpty ? [favorite.busCompanyId] : null,
          pickupStopIds: favorite.pickupStopId != null ? [favorite.pickupStopId!] : null,
          dropoffStopIds: favorite.dropoffStopId != null ? [favorite.dropoffStopId!] : null,
          departureTimeFrom: favorite.departureTime,
          departureTimeTo: favorite.departureTime,
          sortBy: 'departure_asc',
        );
        
        if (result.isEmpty) {
          // Add a placeholder trip if no matches found for this favorite on the selected date
          final placeholderId = 'fav_${favorite.departureProvinceId}_${favorite.destinationProvinceId}_${favorite.busCompanyId}_${favorite.departureTime.replaceAll(':', '')}';
          final placeholderTrip = TripModel(
            id: placeholderId,
            departureTime: favorite.departureTime,
            arrivalTime: '--:--',
            duration: '--',
            departureStation: favorite.pickupStopName ?? favorite.departureProvinceName,
            arrivalStation: favorite.dropoffStopName ?? favorite.destinationProvinceName,
            price: 0,
            availableSeats: 0,
            busCompanyName: favorite.busCompanyName,
            busType: 'Chưa có lịch chạy',
            rating: 5.0,
            reviewCount: 0,
          );
          allTrips.add(placeholderTrip);
          _tripToFavorite[placeholderId] = favorite;
        } else {
          for (var trip in result) {
            allTrips.add(trip);
            _tripToFavorite[trip.id] = favorite;
          }
        }
      }
      
      // Distinct by trip ID
      final ids = <String>{};
      _favoriteTrips = allTrips.where((t) => ids.add(t.id)).toList();

    } catch (e) {
      _errorMessage = 'Không thể tải chuyến xe yêu thích: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_favorites.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
