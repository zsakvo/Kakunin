import 'dart:convert';

import 'package:equatable/equatable.dart';

class Totp extends Equatable {
  final String? secret;
  final String? label;
  final String? issuer;
  final String? otpauth;
  final String? sha;
  final int? digits;
  final int? period;

  const Totp({
    this.secret,
    this.label,
    this.issuer,
    this.otpauth,
    this.sha,
    this.digits,
    this.period,
  });

  factory Totp.fromMap(Map<String, dynamic> data) => Totp(
        secret: data['secret'] as String?,
        label: data['label'] as String?,
        issuer: data['issuer'] as String?,
        otpauth: data['otpauth'] as String?,
        sha: data['sha'] as String?,
        digits: data['digits'] as int?,
        period: data['period'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'secret': secret,
        'label': label,
        'issuer': issuer,
        'otpauth': otpauth,
        'sha': sha,
        'digits': digits,
        'period': period,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Totp].
  factory Totp.fromJson(String data) {
    return Totp.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Totp] to a JSON string.
  String toJson() => json.encode(toMap());

  Totp copyWith({
    String? secret,
    String? label,
    String? issuer,
    String? otpauth,
    String? sha,
    int? digits,
    int? period,
  }) {
    return Totp(
      secret: secret ?? this.secret,
      label: label ?? this.label,
      issuer: issuer ?? this.issuer,
      otpauth: otpauth ?? this.otpauth,
      sha: sha ?? this.sha,
      digits: digits ?? this.digits,
      period: period ?? this.period,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      secret,
      label,
      issuer,
      otpauth,
      sha,
      digits,
      period,
    ];
  }
}
