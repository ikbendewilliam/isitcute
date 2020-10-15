import 'package:tflite/tflite.dart';

class TensorRepository {
  static Future<String> loadModel() async => Tflite.loadModel(
        model: "assets/model/iscute.tflite",
        labels: "assets/model/labels.txt",
        isAsset: true,
      );
}
