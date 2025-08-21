// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 0;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      nickname: fields[0] as String?,
      password: fields[1] as String?,
      isDarkMode: fields[2] as bool?,
      commentedRooms: (fields[3] as List?)?.cast<int>(),
      commentIds: (fields[4] as List?)?.cast<int>(),
      roomSentiments: (fields[5] as Map?)?.cast<int, String>(),
      commentReactions: (fields[6] as Map?)?.cast<int, String>(),
      lastUpdated: fields[7] as DateTime?,
      installDate: fields[8] as DateTime?,
      isPushNotificationEnabled: fields[9] as bool,
      discussionHomeLastTabIndex: fields[10] as int,
      historyHomeLastTabIndex: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.nickname)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.isDarkMode)
      ..writeByte(3)
      ..write(obj.commentedRooms)
      ..writeByte(4)
      ..write(obj.commentIds)
      ..writeByte(5)
      ..write(obj.roomSentiments)
      ..writeByte(6)
      ..write(obj.commentReactions)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.installDate)
      ..writeByte(9)
      ..write(obj.isPushNotificationEnabled)
      ..writeByte(10)
      ..write(obj.discussionHomeLastTabIndex)
      ..writeByte(11)
      ..write(obj.historyHomeLastTabIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
