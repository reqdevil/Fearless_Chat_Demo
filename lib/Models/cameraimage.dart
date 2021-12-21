import 'package:camera/camera.dart';

class TakenCameraImage {
  String filePath;
  bool isSelected;
  DateTime dateTime;

  TakenCameraImage( this.filePath, this.isSelected, this.dateTime);
}
