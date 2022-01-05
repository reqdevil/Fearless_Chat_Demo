import 'dart:io';
import 'package:fearless_chat_demo/enums.dart';
import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';

Future<File> fixExifRotation(String imagePath,
    NativeDeviceOrientation orientation, CameraType cameraType) async {
  final originalFile = File(imagePath);
  List<int> imageBytes = await originalFile.readAsBytes();

  final originalImage = img.decodeImage(imageBytes);

  final height = originalImage!.height;
  final width = originalImage.width;
  // final exifData = await readExifFromBytes(imageBytes);
  img.Image? fixedImage;
  if (cameraType == CameraType.back) {
    if (orientation == NativeDeviceOrientation.landscapeLeft) {
      fixedImage = img.copyRotate(originalImage, -90);
    } else if (orientation == NativeDeviceOrientation.landscapeRight) {
      fixedImage = img.copyRotate(originalImage, 90);
    } else if (orientation == NativeDeviceOrientation.portraitUp) {
      fixedImage = img.copyRotate(originalImage, 0);
    } else if (orientation == NativeDeviceOrientation.portraitDown) {
      fixedImage = img.copyRotate(originalImage, 180);
    }
  } else if (cameraType == CameraType.front) {
    if (orientation == NativeDeviceOrientation.landscapeLeft) {
      img.Image _fixedImage = img.flipHorizontal(originalImage);
      fixedImage = img.copyRotate(_fixedImage, -90);
    } else if (orientation == NativeDeviceOrientation.landscapeRight) {
      img.Image _fixedImage = img.flipHorizontal(originalImage);
      fixedImage = img.copyRotate(_fixedImage, 90);
    } else if (orientation == NativeDeviceOrientation.portraitUp) {
      fixedImage = img.flipHorizontal(originalImage);
    } else if (orientation == NativeDeviceOrientation.portraitDown) {
      img.Image _fixedImage = img.flipHorizontal(originalImage);
      fixedImage = img.copyRotate(_fixedImage, 180);
    }
  }

  // // Let's check for the image size
  // // This will be true also for upside-down photos but it's ok for me
  // if (height >= width) {
  //   // I'm interested in portrait photos so
  //   // I'll just return here
  //   return originalFile;
  // }

  // We'll use the exif package to read exif data
  // This is map of several exif properties
  // Let's check 'Image Orientation'

  // if (height < width) {
  //   dynamic logger;
  //   logger.logInfo('Rotating image necessary');
  //   // rotate
  //   if (exifData['Image Orientation']!.printable.contains('Horizontal')) {
  //     fixedImage = img.copyRotate(originalImage, 90);
  //   } else if (exifData['Image Orientation']!.printable.contains('180')) {
  //     fixedImage = img.copyRotate(originalImage, -90);
  //   } else if (exifData['Image Orientation']!.printable.contains('CCW')) {
  //     fixedImage = img.copyRotate(originalImage, 180);
  //   } else {
  //     fixedImage = img.copyRotate(originalImage, 0);
  //   }
  // }

  // Here you can select whether you'd like to save it as png
  // or jpg with some compression
  // I choose jpg with 100% quality
  File fixedFile = await originalFile.writeAsBytes(img.encodeJpg(fixedImage!));

  return fixedFile;
}
