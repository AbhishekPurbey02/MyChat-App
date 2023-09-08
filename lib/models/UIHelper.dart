
import 'package:flutter/material.dart';

class UIHelper {
  static void showLoadingDialog(BuildContext context, String title) {
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
      
          CircularProgressIndicator(
            color: Color.fromARGB(255, 6, 155, 192),
          ),
      
          SizedBox(height: 30,),
      
          Text(title),
      
        ]),
      ),
    );

  showDialog(
    context: context, 
    barrierDismissible: false,
    builder: (context) {
      return loadingDialog;
  });

  }

  static void showAlertDialog(BuildContext context, String title, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK",
          style: TextStyle(color:  Color.fromARGB(255, 6, 155, 192),),),
        ),
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return alertDialog;
    });
  }
}
