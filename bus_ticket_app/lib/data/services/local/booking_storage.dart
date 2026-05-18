import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/storage/storage_service.dart';
import '../../models/province_model.dart';
import '../../models/recent_search_model.dart';

class BookingStorage extends ChangeNotifier {
  final StorageService _storage;

  BookingStorage(this._storage);

  // --- ĐIỂM XUẤT PHÁT ---
  Future<void> saveDeparture(ProvinceModel? province) async {
    if (province == null) {
      await _storage.delete('saved_departure');
    } else {
      await _storage.writeString('saved_departure', jsonEncode(province.toJson()));
    }
    notifyListeners();
  }

  ProvinceModel? getDeparture() {
    final data = _storage.readString('saved_departure');
    return data != null ? ProvinceModel.fromJson(jsonDecode(data)) : null;
  }

  // --- ĐIỂM ĐẾN ---
  Future<void> saveDestination(ProvinceModel? province) async {
    if (province == null) {
      await _storage.delete('saved_destination');
    } else {
      await _storage.writeString('saved_destination', jsonEncode(province.toJson()));
    }
    notifyListeners();
  }

  ProvinceModel? getDestination() {
    final data = _storage.readString('saved_destination');
    return data != null ? ProvinceModel.fromJson(jsonDecode(data)) : null;
  }

  // --- TÌM KIẾM GẦN ĐÂY ---
  List<RecentSearchModel> getRecentSearches() {
    try {
      final String? data = _storage.readString('recent_searches');
      if (data == null || data.isEmpty) return <RecentSearchModel>[];

      final dynamic decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded.map<RecentSearchModel>((item) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(item as Map);
          return RecentSearchModel.fromJson(map);
        }).toList();
      }
      return <RecentSearchModel>[];
    } catch (e) {
      debugPrint("Error loading recent searches: $e");
      return <RecentSearchModel>[];
    }
  }

  Future<void> addRecentSearch(RecentSearchModel search) async {
    final List<RecentSearchModel> searches = getRecentSearches();
    
     searches.removeWhere((item) =>
        item.departureId == search.departureId &&
        item.destinationId == search.destinationId &&
        item.date == search.date &&
        item.endDate == search.endDate);

    searches.insert(0, search);

    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }

    final String encoded = jsonEncode(searches.map((e) => e.toJson()).toList());
    await _storage.writeString('recent_searches', encoded);

    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    await _storage.delete('recent_searches');
    notifyListeners();
  }
}
