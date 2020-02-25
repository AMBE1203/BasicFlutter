import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart' show timeDilation;

void main() => runApp(MaterialApp(home: MyApp(),));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    timeDilation = 5.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Hero animation'),
      ),
      body: Center(
        child: PhotoHero(
          photo: 'images/flippers-alpha.png',
          width: 300.0,
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context){
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Flippers Page'),
                  ),
                  body: Container(
                    color: Colors.lightBlueAccent,
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.topLeft,
                    child: PhotoHero(
                      photo: 'images/flippers-alpha.png',
                      width: 100.0,
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              }
            ));

          },
        ),
      ),
    );
  }
}

class PhotoHero extends StatelessWidget {
  final String photo;
  final VoidCallback onTap;
  final double width;

  const PhotoHero({Key key, this.photo, this.onTap, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Hero(
            tag: photo,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Image.asset(
                  photo,
                  fit: BoxFit.contain,
                ),
              ),
            )),
      );
}
