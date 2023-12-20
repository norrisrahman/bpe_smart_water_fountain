import 'dart:async';

import 'package:bpe_smart_water_fountain/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Add a delay of 3 seconds before navigating to the next screen
    Timer(
      Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => BLEScanner(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            var curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            var opacityAnimation = animation.drive(tween);

            return FadeTransition(
              opacity: opacityAnimation,
              child: child,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Color(0xff181B31),
          body: Center(
            // color: Color(0xff181B31),
            // alignment: Alignment.center,
            child: Stack(
              // mainAxisAlignment: MainAxisAlignment.end,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "BPE",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 65,
                          fontWeight: FontWeight.w900),
                    ),
                    Text(
                      "Smart Water Fountain System",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                Container(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Suported by:",
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(
                          width: 95,
                          height: 60,
                          child: Row(
                            children: [
                              Container(
                                  // color: Colors.amber,
                                  height: 50,
                                  width: 50,
                                  child: Image.asset('assets/its.png')),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                child: Image.asset(
                                  'assets/tf.png',
                                  width: 30,
                                  height: 30,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ))
              ],
            ),
          )),
    );
  }
}
