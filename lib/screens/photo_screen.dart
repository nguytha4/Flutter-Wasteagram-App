import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import '../wasteagram.dart';

class PhotoScreen extends StatefulWidget {
  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {

  File image;
  LocationData locationData;
  final formKey = GlobalKey<FormState>();
  final post = Post();

  @override
  void initState() {
    super.initState();
    retrieveLocation();
    retrieveDateAndTime();
  }

  void retrieveLocation() async {
    var locationService = Location();
    locationData = await locationService.getLocation();
    post.latitude = locationData.latitude;
    post.longitude = locationData.longitude;
  }

  void retrieveDateAndTime() async {
    post.date = DateTime.now();
    var formatterDateTime = DateFormat('yyyy-MM-dd.H.m.s');
    post.dateTime = formatterDateTime.format(post.date);
  }

  void getImage() async {
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    uploadImage(image);
    setState( () {} );
  }

  void takePhoto() async {
    image = await ImagePicker.pickImage(source: ImageSource.camera);
    uploadImage(image);
    setState( () {} );
  }

  void uploadImage(File image) async {
    StorageReference storageReference =
      FirebaseStorage.instance.ref().child(post.dateTime);
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    final url = await storageReference.getDownloadURL();
    post.imageURL = url;
    setState( () {} );
  }

  @override
  Widget build(BuildContext context) {
    
    // Responsive design
    final pHeight = MediaQuery.of(context).size.height;
    final pWidth = MediaQuery.of(context).size.width;

    // To display to user when user first opens page
    if (image == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Wasteagram"),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            choosePhotoButton(),
            Center(child: Text('or')),
            takePhotoButton(),
          ],
        ),
      );
    } 

    // Wait for photo to upload to database
    else if (post.imageURL == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Wasteagram"),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Display once user chooses or takes a photo
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Wasteagram"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              picture(pHeight, pWidth),
              SizedBox(height: pHeight * .05,),
              Semantics(
                label: 'Field to enter number of food items in photo',
                textField: true,
                hint: 'Click on field to open keyboard to enter a number',
                child: numItemsField(pHeight, pWidth)),
              SizedBox(height: pHeight * .25,),
              Semantics(
                label: 'Upload image to cloud storage on Internet',
                button: true,
                onTapHint: 'Select button will upload image to online storage',
                child: uploadCloudPicture(pHeight, pWidth, image)),
            ],
          ),
        )
      );
    }
  } 

  // ==================================== Widget functions ====================================

  Widget choosePhotoButton() {
    return Semantics(
          label: 'Choose Photo button',
          button: true,
          onTapHint: 'Navigates to phone\'s photo gallery to allow user to select a photo',
          child: RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('Choose Photo'),
              onPressed: () { 
                getImage();
              }
            ),
    );
  }

  Widget takePhotoButton() {
    return  Semantics(
          label: 'Take Photo button',
          button: true,
          onTapHint: 'Opens up the phone\'s camera application to allow user to take photo',
          child: RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('Take Photo'),
                onPressed: () { 
                  takePhoto(); 
                }
              ),
    );
  }

  Widget picture(double pHeight, double pWidth) {
    return Padding(
             padding: const EdgeInsets.all(15.0),
             child: Align(
               child: SizedBox(
                 child: Image.file(image),
                 height: pHeight * .25, 
                 width: pWidth * .9,
               ),
               alignment: Alignment.topCenter,
             ),
           );
  }

  Widget numItemsField(double pHeight, double pWidth) {
    return SizedBox(
             width: pWidth * .375,
             height: pHeight * .1,
             child: Form(
               key: formKey,
               child: TextFormField(
                 keyboardType: TextInputType.number,
                 decoration: InputDecoration(
                   labelText: 'Number of Items', 
                   border: OutlineInputBorder(
                     borderSide: BorderSide(color: Colors.blue, width: 2)
                   ),
                 ),
                 onSaved: (value) {
                   post.quantity = int.parse(value);
                 },
                 validator: (value) {
                   if (value.isEmpty) {
                     return 'Please enter a number';
                   } else {
                     return null;
                   }
                 },
               ),
             ),
           );
  }

  Widget uploadCloudPicture(double pHeight, double pWidth, File image) {
    return InkWell(
          onTap: ()  {
            if (formKey.currentState.validate()) {
              formKey.currentState.save();

              Firestore.instance.collection('posts').add( {
                'date': post.date,
                'latitude': post.latitude,
                'longitude': post.longitude,
                'imageURL': post.imageURL,
                'quantity': post.quantity,
              });

              toListScreen(context);
            }

          },
          child: SizedBox(
               child: Image.asset('assets/uploadcloud.png'),
               width: pWidth * .6, 
               height: pHeight * .18,
             ),
    );
  }

  // ==================================== Functions ====================================

  void toListScreen(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ListScreen()));
  }
}