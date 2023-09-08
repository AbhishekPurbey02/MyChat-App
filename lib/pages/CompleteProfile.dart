import 'dart:developer';
import 'dart:io';
import 'package:chatroom/models/UIHelper.dart';
import 'package:chatroom/models/UserModel.dart';
import 'package:chatroom/pages/HomePage.dart';
import 'package:chatroom/pages/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfile({Key? key, required this.userModel, required this.firebaseUser}) :super(key: key);
  
  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

   File? imageFile;
  TextEditingController fullnameControllerr = TextEditingController();


  void SelectImage(ImageSource source) async {
    XFile? pickedFile= await ImagePicker().pickImage(source: source);

    if(pickedFile != null){
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20
      );
  

    if(croppedImage != null){
      setState(() {
        imageFile =  File(croppedImage.path);
      });
    }
  }
  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  SelectImage(ImageSource.gallery);
                },
                leading: Icon(Icons.photo_album),
                title: Text("Select from Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  SelectImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera_alt),
                title: Text("Take a Photo"),
              ),
            ]),
          );
        });
  }

  void checkvalues(){
    String fullname = fullnameControllerr.text.trim();

    if(fullname == "" || imageFile == null){
      /* print("Please fill all the fields"); */
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields and Upload a profile picture");
    }
    else{
       log("uploading data...");
      uploadData();
    }
  }

  void uploadData() async {

    UIHelper.showLoadingDialog(context, "Uploading Image..");

    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepictures").
    child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullnameControllerr.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance.collection("users").doc(widget.
    userModel .uid).set(widget.userModel.toMap()).then((value){
      log("Data uploaded");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context){
        return LoginPage();
        })
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 59, 62),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 6, 155, 192),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(
                height: 30,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 6, 155, 192),
                  radius: 60,
                  backgroundImage: (imageFile != null) ? FileImage(imageFile!) : null,
                  child:(imageFile == null) ? Icon(Icons.person, size: 60) : null,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: fullnameControllerr,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 6, 155, 192),
                        ),
                      ),
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: "Enter your fullname",
                      hintStyle: TextStyle(color: Colors.white),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(
                        Icons.comment,
                        color: Color.fromARGB(255, 6, 155, 192),
                      ))),
              SizedBox(
                height: 30,
              ),
              CupertinoButton(
                onPressed: () {
                  checkvalues();
                },
                color: Color.fromARGB(255, 6, 155, 192),
                child: Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
