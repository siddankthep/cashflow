import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraProvider extends ChangeNotifier {
  CameraDescription? _firstCamera;

  CameraDescription? get firstCamera => _firstCamera;

  void setFirstCamera(CameraDescription camera) {
    _firstCamera = camera;
    notifyListeners();
  }
}