import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'models.dart';

class BndBox extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final String model;

  const BndBox(this.results, this.previewH, this.previewW, this.screenH, this.screenW,
      this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> renderStrings() {
      double offset = -10;
      return results.map((re) {
        offset = offset + 14;
        return Positioned(
          left: 10,
          top: offset,
          width: screenW,
          height: screenH,
          child: Text(
            "${re["label"]} ",
            style: const TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1.0),
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList();
    }


    return Stack(
      children:
      // model == detectMoney ||
      //     model == detectFruits|| model == detectVegetables ||
      //     model == detectVehicles|| model == detectKitchen ?
      renderStrings(),
          // : model == posenet ? _renderKeypoints() : _renderBoxes(),
    );
  }
}
