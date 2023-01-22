// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TotpAdapter extends TypeAdapter<Totp> {
  @override
  final int typeId = 1;

  @override
  Totp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Totp(
      secret: fields[0] as String?,
      label: fields[1] as String?,
      issuer: fields[2] as String?,
      otpauth: fields[3] as String?,
      algorithm: fields[4] as String?,
      scheme: fields[5] as String?,
      digits: fields[6] as int?,
      period: fields[7] as int?,
      uuid: fields[8] as String?,
      count: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Totp obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.secret)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.issuer)
      ..writeByte(3)
      ..write(obj.otpauth)
      ..writeByte(4)
      ..write(obj.algorithm)
      ..writeByte(5)
      ..write(obj.scheme)
      ..writeByte(6)
      ..write(obj.digits)
      ..writeByte(7)
      ..write(obj.period)
      ..writeByte(8)
      ..write(obj.uuid)
      ..writeByte(9)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TotpAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
