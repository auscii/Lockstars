import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("running loading.");
    return Container(
      color: Colors.blue[100],
      child: Center(
        //child: SpinKitChasingDots(
        child: SpinKitCubeGrid(
          color: Colors.white,
          size: 100.0,
        ),
      ),
    );
  }
}
