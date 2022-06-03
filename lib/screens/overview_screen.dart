import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';


class OverviewScreen extends StatefulWidget {
  const OverviewScreen({Key key}) : super(key: key);

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {

  File my_image;
  XFile image;
  XFile camera;
  Position _position;

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _position = position;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(

            children: [
              SizedBox(height: 40,),
              Container(
                width: 250.0,
                height: 100,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontFamily: 'Canterbury',
                  ),
                  child: Center(
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [

                        ScaleAnimatedText('Take Picture',textStyle: TextStyle(color: Colors.black)),
                        ScaleAnimatedText('SPOT GARBAGE',textStyle: TextStyle(color: Colors.black),textAlign: TextAlign.center),
                        ScaleAnimatedText('Send',textStyle: TextStyle(color: Colors.black)),
                      ],
                      onTap: () {
                        print("Tap Event");
                      },
                    ),
                  ),
                ),
              ),

              Divider(),
              SizedBox(height: 10,),
              Container(
                height: 350,
                width: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),

                ),
                child: camera==null? Center(child: Text('Photo')): Image.file(File(camera.path),fit: BoxFit.contain,),
              ),
              InkWell(
                onTap: () {
                  camerapicker();
                },
                child: AvatarGlow(
                  glowColor: Colors.blue,
                  endRadius: 60.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Camera',style: TextStyle(color: Colors.white),),
                          Icon(Icons.camera_alt_outlined,color: Colors.white,)
                        ]
                    ),
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  submit();
                  addUserDetails();
                },
                child: AvatarGlow(
                  glowColor: Colors.blue,
                  endRadius: 60.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Upload',style: TextStyle(color: Colors.white),),
                          Icon(Icons.upload_file_outlined,color: Colors.white,)
                        ]
                    ),
                  ),
                ),
              ),

              // Container(
              //   height: 50,
              //   width: 100,
              //   decoration: BoxDecoration(
              //     color: Colors.green,
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Center(child: Text('Send',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
              // ),




            ],
          ),
        ],
      ),
    );
  }
  Future<void> filepicker() async {
    final selectimage = await ImagePicker().pickImage(source: ImageSource.gallery);
    print (selectimage.path);
    setState(() {
      image = selectimage;
    });
  }

  Future<void> camerapicker() async {
    final selecteimage = await ImagePicker().pickImage(source: ImageSource.camera, maxHeight: 1280, maxWidth: 720);
    if (selecteimage == null) return;
    print (selecteimage.path);
    setState(() {
      camera = selecteimage;
    });
  }

  Future<void> submit() async{
    final path = 'test/${camera.name}';
    final file = File(camera.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);
    final x = FirebaseAuth.instance.currentUser.email;
    print(x);
  }

  Future addUserDetails() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
    });
    print(position);
    print(position.runtimeType);
    final coordinates = new Coordinates(position.latitude, position.longitude);
    await FirebaseFirestore.instance.collection('records').add({
      'email':FirebaseAuth.instance.currentUser.email,
      'file': camera.name,
      'date': DateTime.now(),
      'location': GeoPoint(_position.latitude, _position.longitude)
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error('Location Permission Denied');
      }
    }
    return await Geolocator.getCurrentPosition();

  }




  // Future<void> camerapicker() async {
  //   final selecteimage = await ImagePicker().pickImage(source: ImageSource.camera, maxHeight: 1280, maxWidth: 720);
  //   if (selecteimage == null) return;
  //   print('HERE');
  //   final file = File(selecteimage.path);
  //   setState(() => this.my_image = file);
  //   final path = 'test/${selecteimage.name}';
  //   final ref = FirebaseStorage.instance.ref().child(path);
  //   ref.putFile(file);
  //   print (selecteimage.path);
  //   setState(() {
  //     camera = selecteimage;
  //   });
  // }


  }

class SliderImageAnimation extends StatefulWidget {
  const SliderImageAnimation({Key key}) : super(key: key);

  @override
  _SliderImageAnimationState createState() => _SliderImageAnimationState();
}

class _SliderImageAnimationState extends State<SliderImageAnimation>
    with SingleTickerProviderStateMixin {
  final Tween<double> _scaleTween = Tween<double>(begin: 1, end: 1.4);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: _scaleTween,
      duration: const Duration(seconds: 3),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/unthis.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
