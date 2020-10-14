import 'package:tflite_flutter/tflite_flutter.dart';

class TensorRepository {
  static Future<Interpreter> loadModel() async => Interpreter.fromAsset('model/iscute.tflite');
}
