import 'package:camera/camera.dart';

class TakenCameraImage {
  String filePath;
  bool isSelected;
  DateTime dateTime;
  FileType fileType;

  TakenCameraImage(
      this.filePath, this.isSelected, this.dateTime, this.fileType);
}

enum FileType { photo, video }
