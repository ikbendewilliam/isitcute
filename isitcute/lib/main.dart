import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:isitcute/repository/tensor_repository.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String model;
  String iscute = "Loading...";
  String path;
  Timer timer;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    loadModel();
  }

  Future<void> predict({delete: true}) async {
    try {
      await _initializeControllerFuture;

      path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      await _controller.takePicture(path);
      final predictions = await Tflite.runModelOnImage(
        path: path,
        // imageMean: 0.0,
        // imageStd: 255.0,
        numResults: 1,
        // threshold: 0.2,
        asynch: true,
      );
      // print(predictions);
      iscute = predictions.toString();
      if (delete == true) {
        File tempLocalFile = File(path);
        tempLocalFile.exists().then((value) async {
          if (value) {
            await tempLocalFile.delete(recursive: true);
          }
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  void loadModel() async {
    model = await TensorRepository.loadModel();
    predict();
    setState(() {});
    timer = Timer.periodic(Duration(seconds: 5), (_) {
      predict();
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Is it cute?')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Text(iscute, style: TextStyle(backgroundColor: Colors.black, color: Colors.white)),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          await predict(delete: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayPictureScreen(
                imagePath: path,
                cuteness: iscute,
              ),
            ),
          );
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String cuteness;

  const DisplayPictureScreen({Key key, this.imagePath, this.cuteness}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('path: $imagePath');
    return Scaffold(
        appBar: AppBar(title: Text('Is it cute photo')),
        body: Column(
          children: [
            Text(cuteness),
            Image.file(File(imagePath)),
          ],
        ));
  }
}
