import 'package:photo_gallery/photo_gallery.dart';

class TakenCameraMedia {
  String filePath;
  bool isSelected;
  DateTime dateTime;
  FileType fileType;
  Medium? medium;
  TakenCameraMedia(this.filePath, this.isSelected, this.dateTime, this.fileType,
      [this.medium = null]);
}

enum FileType { photo, video }
