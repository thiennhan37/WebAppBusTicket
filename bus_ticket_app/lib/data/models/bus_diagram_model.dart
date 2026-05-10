import 'package:json_annotation/json_annotation.dart';

part 'bus_diagram_model.g.dart';

@JsonSerializable()
class BusDiagramResponse {
  final int code;
  final String? message;
  final BusDiagramData? result;

  BusDiagramResponse({required this.code, this.message, this.result});

  factory BusDiagramResponse.fromJson(Map<String, dynamic> json) => _$BusDiagramResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BusDiagramResponseToJson(this);
}

@JsonSerializable()
class BusDiagramData {
  final String busTypeName;
  final Diagram diagram;
  final List<SeatStatus> seats;

  BusDiagramData({required this.busTypeName, required this.diagram, required this.seats});

  factory BusDiagramData.fromJson(Map<String, dynamic> json) => _$BusDiagramDataFromJson(json);
  Map<String, dynamic> toJson() => _$BusDiagramDataToJson(this);
}

@JsonSerializable()
class Diagram {
  final int floor;
  final int row;
  final int column;
  final List<List<List<String?>>> seatList;

  Diagram({required this.floor, required this.row, required this.column, required this.seatList});

  factory Diagram.fromJson(Map<String, dynamic> json) => _$DiagramFromJson(json);
  Map<String, dynamic> toJson() => _$DiagramToJson(this);
}

@JsonSerializable()
class SeatStatus {
  final String seatId;
  final String seatCode;
  final String status;
  final int price;

  SeatStatus({required this.seatId ,required this.seatCode, required this.status, required this.price});

  factory SeatStatus.fromJson(Map<String, dynamic> json) => _$SeatStatusFromJson(json);
  Map<String, dynamic> toJson() => _$SeatStatusToJson(this);
}
