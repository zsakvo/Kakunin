import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'token.g.dart';

@HiveType(typeId: 1)
class Token extends Equatable {
  @HiveField(0)
  final String? secret;
  @HiveField(1)
  final String? label;
  @HiveField(2)
  final String? issuer;
  @HiveField(3)
  final String? otpauth;
  @HiveField(4)
  final String? algorithm;
  @HiveField(5)
  final String? scheme;
  @HiveField(6)
  final int? digits;
  @HiveField(7)
  final int? period;
  @HiveField(8)
  final String? uuid;
  @HiveField(9)
  final int? count;

  const Token(
      {this.secret,
      this.label,
      this.issuer,
      this.otpauth,
      this.algorithm,
      this.scheme,
      this.digits,
      this.period,
      this.uuid,
      this.count});

  factory Token.fromMap(Map<String, dynamic> data) => Token(
      secret: data['secret'] as String?,
      label: data['label'] as String?,
      issuer: data['issuer'] as String?,
      otpauth: data['otpauth'] as String?,
      algorithm: data['algorithm'] as String?,
      scheme: data['scheme'] as String?,
      digits: data['digits'] as int?,
      period: data['period'] as int?,
      uuid: data['uuid'] as String?,
      count: data["count"] as int?);

  Map<String, dynamic> toMap() => {
        'secret': secret,
        'label': label,
        'issuer': issuer,
        'otpauth': otpauth,
        'algorithm': algorithm,
        'scheme': scheme,
        'digits': digits,
        'period': period,
        'uuid': uuid,
        'count': count
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Totp].
  factory Token.fromJson(String data) {
    return Token.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Totp] to a JSON string.
  String toJson() => json.encode(toMap());

  Token copyWith(
      {String? secret,
      String? label,
      String? issuer,
      String? otpauth,
      String? algorithm,
      String? scheme,
      int? digits,
      int? period,
      String? uuid,
      int? count}) {
    return Token(
        secret: secret ?? this.secret,
        label: label ?? this.label,
        issuer: issuer ?? this.issuer,
        otpauth: otpauth ?? this.otpauth,
        algorithm: algorithm ?? this.algorithm,
        scheme: scheme ?? this.scheme,
        digits: digits ?? this.digits,
        period: period ?? this.period,
        uuid: uuid ?? this.uuid,
        count: count ?? this.count);
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [secret, label, issuer, otpauth, algorithm, scheme, digits, period, uuid, count];
  }
}
