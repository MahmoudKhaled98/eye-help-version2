import 'package:flutter/material.dart';

class GetAddressScreen extends StatefulWidget {
  final String address;
  const GetAddressScreen({required this.address,super.key});

  @override
  State<GetAddressScreen> createState() => _GetAddressScreenState();
}

class _GetAddressScreenState extends State<GetAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color(0xFF446879),
      appBar: AppBar(
        leading:GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title:  Center(
            child: Padding(
              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/7.3),
              child: const Text(
                'التعرف على العنوان',
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Center(
          child: Container(width: 200,height: 100,
            decoration: const BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Center(
              child: Text(
                widget.address,
                softWrap: true,
                style: const TextStyle(
                    fontFamily: 'Kufi',
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold), textAlign: TextAlign.center,// Larger text size),
                      ),
            )),
        )
      ],),
    );
  }
}
