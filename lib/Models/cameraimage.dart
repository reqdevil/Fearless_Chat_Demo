class TakenCameraMedia {
  String filePath;
  bool isSelected;
  DateTime dateTime;
  FileType fileType;

  TakenCameraMedia(
      this.filePath, this.isSelected, this.dateTime, this.fileType);
}

enum FileType { photo, video }
