// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'VideoModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoModelAdapter extends TypeAdapter<VideoModel> {
  @override
  final int typeId = 1;

  @override
  VideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoModel(
      videoId: fields[0] as String?,
      duration: fields[1] as String?,
      title: fields[2] as String?,
      channelName: fields[3] as String?,
      views: fields[4] as String?,
      uploadDate: fields[5] as String?,
      thumbnailUrls: (fields[6] as List?)?.cast<String>(),
      audioPath: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.channelName)
      ..writeByte(4)
      ..write(obj.views)
      ..writeByte(5)
      ..write(obj.uploadDate)
      ..writeByte(6)
      ..write(obj.thumbnailUrls)
      ..writeByte(7)
      ..write(obj.audioPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
