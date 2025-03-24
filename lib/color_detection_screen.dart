import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:palette_generator/palette_generator.dart';

import 'color_names.dart';


class ColorDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ColorDetectionScreen({required this.cameras,super.key});

  @override
  ColorDetectionScreenState createState() => ColorDetectionScreenState();
}

class ColorDetectionScreenState extends State<ColorDetectionScreen> {
  late CameraController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.ultraHigh);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      _controller.setFlashMode(FlashMode.off);
      _startTakingPictures();
    });
  }
  String recColor="";

  void _startTakingPictures() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      if (!_controller.value.isTakingPicture) {
        try {
          final image = await _controller.takePicture();
      recColor=  await  RecognizeColorFromCamera().recognizeColor(File(image.path));
      setState(() {

        recColor;
      });
          // Do something with the captured image
        } catch (e) {
          print("Error: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
     appBar:  AppBar(
        leading:GestureDetector(
            onTap: () {
            Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Center(
            child: Padding(
              padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width / 7.3),
              child: const Text(
                'التعرف على الألوان',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Kufi',
                ),
              ),
            )),
        backgroundColor: const Color(0xFFacc8d7),
      ),
      body: Stack(children: [
        CameraPreview(_controller),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 100,0,0),
          child: Text(recColor,style: TextStyle(color: Colors.cyanAccent,fontSize: 15),),
        )
      ]),
    );
  }
}




class RecognizeColorFromCamera{
  String? _colorName;
  Color color=const Color(0xFF000000);
  Future<String> recognizeColor(File? imageFile) async{
    final imageProvider = FileImage(imageFile!);
    final palette = await PaletteGenerator.fromImageProvider(
      imageProvider, size: const Size(100, 100),
      // Set the size of the region for palette generation
      region: Offset.zero & const Size(100, 100),
    );

    // Get the dominant color from the generated palette
    color = palette.dominantColor!.color;
    print('Here !!!!!!!!!!!!!!!! $color');
    String classifyColor(Color color) {
      String closestColor = "Unknown";
      double minDistance = double.infinity;
      colorMap.forEach((name, value) {
        double distance = ((color.red - value.red).abs() +
            (color.green - value.green).abs() +
            (color.blue - value.blue).abs()).toDouble();
        if (distance < minDistance) {
          minDistance = distance;
          closestColor = name;
        }
      });
      return closestColor;
    }

    Color? myColor = color;
    String colorName = classifyColor(myColor);
    _colorName = colorName;
    print(myColor);
    // SpeakText().speak(colorName);
    return colorName;
  }
}