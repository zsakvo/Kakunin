import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'config.g.dart';

@HiveType(typeId: 2)
class Config extends Equatable {
  @HiveField(0)
  final bool? autoStart;
  @HiveField(1)
  final bool? showNotification;
  @HiveField(2)
  final bool? skipDock;

  const Config({this.autoStart, this.showNotification, this.skipDock});

  factory Config.fromMap(Map<String, dynamic> data) => Config(
        autoStart: data['autoStart'] as bool?,
        showNotification: data['showNotification'] as bool?,
        skipDock: data['skipDock'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'autoStart': autoStart,
        'showNotification': showNotification,
        'skipDock': skipDock,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Config].
  factory Config.fromJson(String data) {
    return Config.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Config] to a JSON string.
  String toJson() => json.encode(toMap());

  Config copyWith({
    bool? autoStart,
    bool? showNotification,
    bool? skipDock,
  }) {
    return Config(
      autoStart: autoStart ?? this.autoStart,
      showNotification: showNotification ?? this.showNotification,
      skipDock: skipDock ?? this.skipDock,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [autoStart, showNotification, skipDock];
}
