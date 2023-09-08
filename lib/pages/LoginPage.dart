
import 'package:chatroom/models/UserModel.dart';
import 'package:chatroom/pages/HomePage.dart';
import 'package:chatroom/pages/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UIHelper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> { 
  
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkvalues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == "" ){
      //print("please fill all the fields");
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else{
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UIHelper.showLoadingDialog(context, "Logging In... ");
    UserCredential? Credential;

    try{
      Credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

    }on FirebaseAuthException catch(ex){
      //close the loading dailog
      Navigator.pop(context);

      //show alert dailog
      UIHelper.showAlertDialog(context, "An Error Occured", ex.message.toString());
     // print(ex.message.toString());
    }

    if(Credential != null) {
      String uid = Credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as 
      Map<String, dynamic>
      );

      print("Log In Sucessful!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context){
          return HomePage(userModel: userModel
          , firebaseUser: Credential!.user!);
        })
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 59, 62),
      body: SafeArea(
          child: Container(
            
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Image.asset("lib/images/Senza-titolo-7.png"),
              SizedBox(
                height: 30,
              ),
              Text(
                "Chat Room",
                style: TextStyle(
                    color: Color.fromARGB(255, 6, 155, 192),
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
                width: 10,
              ),
              TextField(
                controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 6, 155, 192),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 6, 155, 192),),
                      ),
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: "Enter your email",
                      hintStyle: TextStyle(color: Colors.white),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(
                        Icons.email,
                       color: Color.fromARGB(255, 6, 155, 192),
                      ))),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: passwordController,
                 style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                       color: Color.fromARGB(255, 6, 155, 192),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 6, 155, 192),),
                    ),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: "Enter your password",
                    hintStyle: TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Icon(
                      Icons.visibility,
                      color: Color.fromARGB(255, 6, 155, 192),
                    ),
                  )),
              SizedBox(
                height: 30,
              ),
              CupertinoButton(
                onPressed: () {
                  checkvalues();
                },
                color: Color.fromARGB(255, 6, 155, 192),
                child: Text("Log In",
                ),
              )
            ],
          )),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't Have an Account?",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SignUpPage()));
              },
              child: Text(
                "Sign Up",
                style: TextStyle(fontSize: 16,
                color: Color.fromARGB(255, 6, 155, 192),
                ),
                
                
              ),
            )
          ],
        ),
      ),
    );
  }
}
