// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trendDevSubBean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendDevSubBean _$TrendDevSubBeanFromJson(Map<String, dynamic> json) {
  return TrendDevSubBean()
    ..name = json['name'] as String
    ..description = json['description'] as String
    ..url = json['url'] as String;
}

Map<String, dynamic> _$TrendDevSubBeanToJson(TrendDevSubBean instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
    };
