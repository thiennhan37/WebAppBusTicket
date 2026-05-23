import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/trip_model.dart';

class FavoriteViewModel extends ChangeNotifier {
  static const String _storageKey = 'favorite_trips';
  List<TripModel> _favorites = [];

  List<TripModel> get favorites => _favorites;

  FavoriteViewModel() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_storageKey);
    if (favoritesJson != null) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      _favorites = decoded.map((item) => TripModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(TripModel trip) async {
    final index = _favorites.indexWhere((item) => item.id == trip.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(trip);
    }
    notifyListeners();
    await _saveToDisk();
  }

  bool isFavorite(String tripId) {
    return _favorites.any((item) => item.id == tripId);
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_favorites.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
