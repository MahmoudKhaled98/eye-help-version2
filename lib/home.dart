import 'package:eye_help_second/text_detection.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:math' as math;
import 'address_screen.dart';
import 'camera.dart';
import 'bndbox.dart';
import 'color_detection_screen.dart';
import 'custom_button.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
  }

  loadModel() async {
    String? res;
    switch (_model) {
      case detectMoney:
        res = await Tflite.loadModel(
            model: "assets/models_and_labels/money_model.tflite",
            labels: "assets/models_and_labels/money_labels.txt");
        break;

      case detectFruits:
        res = await Tflite.loadModel(
          model: "assets/models_and_labels/fruits_model.tflite",
          labels: "assets/models_and_labels/fruits_labels.txt",
        );
        break;
      case detectVegetables:
        res = await Tflite.loadModel(
            model: "assets/models_and_labels/vegetables_model.tflite",
            labels: "assets/models_and_labels/vegetables_labels.txt");
        break;
      case detectKitchen:
        res = await Tflite.loadModel(
            model: "assets/models_and_labels/kitchen_model.tflite",
            labels: "assets/models_and_labels/kitchen_labels.txt");
        break;
      case detectVehicles:
        res = await Tflite.loadModel(
            model: "assets/models_and_labels/vehicle_model.tflite",
            labels: "assets/models_and_labels/vehicle_labels.txt");
        break;

      default:
        res = await Tflite.loadModel(
            model: "assets/models_and_labels/money_model.tflite",
            labels: "assets/models_and_labels/money_labels.txt");
    }
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _model = "";
        });

        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF446879),
        appBar: AppBar(
          leading: _model == ''
              ? Container()
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _model = "";
                    });
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
              'التعرف على الأشياء',
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
        body: _model == ""
            ? SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomButton(
                        onPressed: () => onSelect(detectMoney),
                        buttonName: detectMoney,
                      ),
                      CustomButton(
                        onPressed: () {
                          Navigator.push(
                            context, // BuildContext of the current widget
                            MaterialPageRoute(
                                builder: (context) => ColorDetectionScreen(
                                      cameras: widget.cameras,
                                    )), // Route definition
                          );
                        },
                        buttonName: 'التعرف على الألوان',
                      ),
                      CustomButton(
                        onPressed: () {
                          Navigator.push(
                            context, // BuildContext of the current widget
                            MaterialPageRoute(
                                builder: (context) => TextDetectionScreen(
                                  cameras: widget.cameras,
                                )), // Route definition
                          );
                        },
                        buttonName: 'التعرف على النصوص',
                      ),
                      CustomButton(
                        onPressed: () async {
                          await GetAddress()
                              .getAddress()
                              .then((value) => Navigator.push(
                                    context, // BuildContext of the current widget
                                    MaterialPageRoute(
                                        builder: (context) => GetAddressScreen(
                                            address:
                                                value)), // Route definition
                                  ));
                        },
                        buttonName: "التعرف على العنوان",
                      ),
                      CustomButton(
                        onPressed: () => onSelect(detectVegetables),
                        buttonName: detectVegetables,
                      ),
                      CustomButton(
                        onPressed: () => onSelect(detectFruits),
                        buttonName: detectFruits,
                      ),
                      CustomButton(
                        onPressed: () => onSelect(detectKitchen),
                        buttonName: detectKitchen,
                      ),
                      CustomButton(
                        onPressed: () => onSelect(detectVehicles),
                        buttonName: detectVehicles,
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  Camera(
                    widget.cameras,
                    setRecognitions,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: BndBox(
                        _recognitions,
                        math.max(_imageHeight, _imageWidth),
                        math.min(_imageHeight, _imageWidth),
                        screen.height,
                        screen.width,
                        _model),
                  ),
                ],
              ),
      ),
    );
  }
}

class GetAddress {
  String address = '';

  Future<String> getAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permission = await Geolocator.requestPermission();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placeMarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
        localeIdentifier: 'ar');

    Placemark place = placeMarks[0];

    address =
        "${place.administrativeArea}-- ${place.subAdministrativeArea}-- ${place.thoroughfare}-- ${place.street} Street ";
    String modifiedAddress =
    address;
    // address!.replaceAll(RegExp(r'[a-zA-Z0-9+]'), ''); // Exclude English characters
    // SpeakText().speak(" شارع$modifiedAddress");

    return modifiedAddress;
  }
}
