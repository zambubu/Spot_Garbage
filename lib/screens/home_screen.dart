import 'package:authentifaction_app/screens/history.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/user_model.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? camera;
  Position? _position;
  String? imageUrl;

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  Future<void> camerapicker() async {
    final selectedimage = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1280, maxWidth: 720);
    if (selectedimage == null) return;
    // print (selectedimage.path);
    setState(() {
      camera = selectedimage;
    });
  }

  Future<void> uploadPicture() async {
    final path = 'test/${camera!.name}';
    final file = File(camera!.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);
  }

  Future addUserDetails() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
    });
    print(position);
    print(position.runtimeType);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('records')
        .doc(camera!.name)
        .set({
      'file': camera!.name,
      'date': DateTime.now(),
      'location': GeoPoint(_position!.latitude, _position!.longitude),
      'resolved': false
    }).then((value) => setState(() {
              camera = null;
            }));
    Fluttertoast.showToast(msg: "Upload Successful!");
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission Denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final captureButton = Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(30),
      color: Colors.lightGreenAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            camerapicker();
          },
          child: Text(
            "Take Picture",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          )),
    );

    final submitButton = Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(30),
      color: Colors.green[500],
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            uploadPicture();
            addUserDetails();
          },
          child: Text(
            "Upload Picture",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          )),
    );

    final logOut = Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(30),
      color: Colors.red[300],
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            logout(context);
          },
          child: Text(
            "Logout",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          )),
    );

    return Scaffold(
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Container(
          color: Colors.white,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              "${loggedInUser.firstName} ${loggedInUser.secondName}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              )),
                          Text("${loggedInUser.email}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              )),
                        ]),
                  )),
              ListTile(
                  leading: Icon(Icons.history),
                  title: Text('History'),
                  onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => History()),
                        ),
                      }),
              ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.red[400],
                  ),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    logout(context);
                  }),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (camera != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: Image.file(
                          File(camera!.path),
                          height: 350,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      )
                    else
                      SizedBox(
                        height: 160,
                        child: Image.asset("assets/images/truck.png",
                            fit: BoxFit.contain),
                      ),
                    SizedBox(height: 20)
                  ]),
              Text(
                "Hi ${loggedInUser.firstName} ${loggedInUser.secondName}!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Found garbage on the street? \n Send us a picture and we'll be there! ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 40,
              ),
              captureButton,
              SizedBox(
                height: 15,
              ),
              submitButton,
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
