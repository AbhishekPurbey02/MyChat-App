import 'package:chatroom/models/FirebaseHelper.dart';
import 'package:chatroom/models/UserModel.dart';
import 'package:chatroom/pages/CompleteProfile.dart';
import 'package:chatroom/pages/LoginPage.dart';
import 'package:chatroom/pages/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatroom/pages/HomePage.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null) {
    //Logged In
    UserModel? thisUserModel = await FirebaseHelpher.getUserModelById(currentUser.uid);
    if(thisUserModel != null){
     runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
      //runApp(MyApp());
     
    }
    else{
      runApp(MyApp());
    }
    

  }
  else {
    //not logged in
    runApp( MyApp());
  }

  
}
//Not Logged In
class MyApp extends StatelessWidget {
   const MyApp({Key? key}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
//Already loggedin
class MyAppLoggedIn extends StatelessWidget {
   final UserModel userModel;
   final User firebaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser)
    );
  }
}

