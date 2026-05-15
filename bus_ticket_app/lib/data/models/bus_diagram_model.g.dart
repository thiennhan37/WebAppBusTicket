// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_diagram_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusDiagramResponse _$BusDiagramResponseFromJson(Map<String, dynamic> json) =>
    BusDiagramResponse(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String?,
      result: json['result'] == null
          ? null
          : BusDiagramData.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BusDiagramResponseToJson(BusDiagramResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'result': instance.result,
    };

BusDiagramData _$BusDiagramDataFromJson(Map<String, dynamic> json) =>
    BusDiagramData(
      busTypeName: json['busTypeName'] as String,
      diagram: Diagram.fromJson(json['diagram'] as Map<String, dynamic>),
      seats: (json['seats'] as List<dynamic>)
          .map((e) => SeatStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BusDiagramDataToJson(BusDiagramData instance) =>
    <String, dynamic>{
      'busTypeName': instance.busTypeName,
      'diagram': instance.diagram,
      'seats': instance.seats,
    };

Diagram _$DiagramFromJson(Map<String, dynamic> json) => Diagram(
      floor: (json['floor'] as num).toInt(),
      row: (json['row'] as num).toInt(),
      column: (json['column'] as num).toInt(),
      seatList: (json['seatList'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map(
                  (e) => (e as List<dynamic>).map((e) => e as String?).toList())
              .toList())
          .toList(),
    );

Map<String, dynamic> _$DiagramToJson(Diagram instance) => <String, dynamic>{
      'floor': instance.floor,
      'row': instance.row,
      'column': instance.column,
      'seatList': instance.seatList,
    };

SeatStatus _$SeatStatusFromJson(Map<String, dynamic> json) => SeatStatus(
      seatId: json['seatId'] as String,
      seatCode: json['seatCode'] as String,
      status: json['status'] as String,
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$SeatStatusToJson(SeatStatus instance) =>
    <String, dynamic>{
      'seatId': instance.seatId,
      'seatCode': instance.seatCode,
      'status': instance.status,
      'price': instance.price,
    };
