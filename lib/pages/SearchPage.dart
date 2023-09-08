import 'dart:developer';

import 'package:chatroom/main.dart';
import 'package:chatroom/models/ChatRoomModel.dart';
import 'package:chatroom/models/UserModel.dart';
import 'package:chatroom/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
   ChatRoomModel? chatRoom;
   
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).where
    ("participants.${targetUser.uid}", isEqualTo: true).get();

    if(snapshot.docs.length > 0){
      //Fetch the exisitng one
      var docData = snapshot.docs[0].data();
      ChatRoomModel exisitngChatroom = ChatRoomModel.fromMap(docData as 
      Map<String, dynamic>);

      chatRoom = exisitngChatroom;
    }
    else{
      //create a new one
     ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true, 
        },
     );

      await FirebaseFirestore.instance.collection("chatrooms").doc
      (newChatroom.chatroomid).set(newChatroom.toMap());

      chatRoom = newChatroom;
      print("New Chatroom Created!");

    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 59, 62),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 6, 155, 192),
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 6, 155, 192),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 6, 155, 192),
                      ),
                    ),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: "Enter email Name",
                    hintStyle: TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Icon(
                      Icons.email,
                      color: Color.fromARGB(255, 6, 155, 192),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                CupertinoButton(
                  onPressed: () {
                    setState(() {});
                  },
                  color: Color.fromARGB(255, 6, 155, 192),
                  child: Text("Search"),
                ),
                SizedBox(
                  height: 30,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .where("email", isEqualTo: searchController.text).where("email",
                        isNotEqualTo: widget.userModel.email).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;

                          if (dataSnapshot.docs.length > 0) {
                            Map<String, dynamic> userMap = dataSnapshot.docs[0]
                                .data() as Map<String, dynamic>;

                            UserModel searchedUser = UserModel.fromMap(userMap);

                            return ListTile(
                              onTap: () async { 
                                ChatRoomModel? ChatroomModel = await
                                getChatroomModel (searchedUser);

                                if(ChatroomModel != null) {
                                     Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder:(context) {
                                  return ChatRoomPage(targetUser: searchedUser, userModel: widget.userModel, firebaseUser: widget.firebaseUser, chatroom: ChatroomModel ,);
                                }));
                                }
                             
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(searchedUser.profilepic!),
                                backgroundColor:Color.fromARGB(255, 6, 155, 192),
                              ),
                              textColor: Colors.white,
                              title: Text(searchedUser.fullname!),
                              subtitle: Text(searchedUser.email!),
                              trailing: Icon(Icons.keyboard_arrow_right,
                              color: Colors.white,
                              ),
                            );
                          } else {
                            return Text(
                              "No Results Found!",
                                style: TextStyle(color: Colors.white),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Text("An Error Occured!",
                            style: TextStyle(color: Colors.white),);
                        } else {
                          return Text(
                            "No Results Found!",
                              style: TextStyle(color: Colors.white),
                          );
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              ],
            )),
      ),
    );
  }
}
