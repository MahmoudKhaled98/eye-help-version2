import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';



class TextDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const TextDetectionScreen({required this.cameras,super.key});

  @override
  TextDetectionScreenState createState() => TextDetectionScreenState();
}

class TextDetectionScreenState extends State<TextDetectionScreen> {
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
  String recText="NULL";

  void _startTakingPictures() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!_controller.value.isTakingPicture) {
        try {
          final image = await _controller.takePicture();
          recText=  await  RecognizeTextFromCamera().recognizeText(File(image.path));
          setState(() {

            recText;
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
          padding: const EdgeInsets.fromLTRB(100, 100,100,100),
          child: Text(recText,style: TextStyle(color: Colors.cyanAccent,fontSize: 15),),
        )
      ]),
    );
  }
}






class RecognizeTextFromCamera{
  String recognizedText="";

  Future<String>  recognizeText(File? imageFile) async{
    recognizedText = await FlutterTesseractOcr.extractText(imageFile!.path,language: 'ara',args: {
      // recognizedText = await FlutterTesseractOcr.extractText(imageFile!.path,language: 'ara+eng',args: {
      "psm": "4",
      "preserve_interword_spaces": "1",
    });
    // SpeakText().speak(recognizedText);
    print('Here!!!!!!!!!!!!!!!!!! ${recognizedText}');
    return recognizedText;
  }
}
