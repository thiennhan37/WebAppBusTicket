import 'dart:convert';

import '../../../core/storage/storage_service.dart';
import '../../models/province_model.dart';


class BookingStorage {
  final StorageService _storage;

  BookingStorage(this._storage);

  // --- ĐIỂM XUẤT PHÁT ---
  Future<void> saveDeparture(ProvinceModel? province) async {
    if (province == null) {
      await _storage.delete('saved_departure');
    } else {
      await _storage.writeString('saved_departure', jsonEncode(province.toJson()));
    }
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
  }

  ProvinceModel? getDestination() {
    final data = _storage.readString('saved_destination');
    return data != null ? ProvinceModel.fromJson(jsonDecode(data)) : null;
  }
}