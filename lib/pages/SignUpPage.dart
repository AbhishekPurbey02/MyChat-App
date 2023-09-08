
import 'package:chatroom/models/UIHelper.dart';
import 'package:chatroom/models/UserModel.dart';
import 'package:chatroom/pages/CompleteProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController =TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController =TextEditingController();
  
  void checkvalues(){
    String email= emailController.text.trim();
    String password= passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();

    if(email == "" || password == "" || cpassword == ""){
     // print("Please fill all the fields");
     UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else if(password != cpassword){
      //print(" Passwords do not match");
      UIHelper.showAlertDialog(context, "Password Mismatched", "Password and ConfirmPassword do not match!");
    }
    else{
      signUp(email, password);
      
    }
  }

  void signUp(String email, String password) async {
   // print(email);
    UIHelper.showLoadingDialog(context, "Creating New Account..");
    UserCredential? Credential;
    
    try {
      Credential = await FirebaseAuth.instance.
      createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      Navigator.pop(context);

      UIHelper.showAlertDialog(context, "An Error Occured", ex.message.toString());
      //print(ex.code.toString());
    }

    if(Credential != null){
      String uid = Credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: ""
      );
      await FirebaseFirestore.instance.collection("users").doc(uid).set
      (newUser.toMap()).then((value){
        print("New User Created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
             return CompleteProfile(userModel: newUser, firebaseUser: Credential!.user! );
            }
          )
        );
      });
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
                height: 20,
              ),
              TextField(
                controller: cpasswordController,
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
                    labelText: "Confirm Password",
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: "Confirm your password",
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
                 // Navigator.of(context).push(MaterialPageRoute(
                   //   builder: (BuildContext context) => CompleteProfile()));
                   checkvalues();
                },
                color: Color.fromARGB(255, 6, 155, 192),
                child: Text("Sign Up"),
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
              "Already Have an Account?",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.of(context).pop(MaterialPageRoute(
                    builder: (BuildContext context) => SignUpPage()));
              },
              child: Text(
                "Log In",
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
