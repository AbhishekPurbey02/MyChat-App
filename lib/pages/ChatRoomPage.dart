import 'dart:developer';

import 'package:chatroom/main.dart';
import 'package:chatroom/models/ChatRoomModel.dart';
import 'package:chatroom/models/MessageModel.dart';
import 'package:chatroom/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({super.key, required this.targetUser, required this.chatroom, required this.userModel, required this.firebaseUser});
 

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {

  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
      String msg = messageController.text.trim();
      messageController.clear();
    
    if(msg != "") {
      //Send Message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false
      );

      FirebaseFirestore.instance.collection("chatrooms").doc(widget.
      chatroom.chatroomid).collection("messages").doc(newMessage.messageid).
      set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.
      chatroom.chatroomid).set(widget.chatroom.toMap(),);

      log("Message Sent");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 59, 62),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 6, 155, 192),
        title: Row(
          children: [

            CircleAvatar(
              backgroundColor:Color.fromARGB(248, 84, 83, 83),
              backgroundImage: NetworkImage(widget.targetUser.profilepic.toString()),
            ),

            SizedBox(width: 10,),

            Text(widget.targetUser.fullname.toString()),

          ],
        ) ,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              //This is where the chats will go
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection
                    ("chatrooms").doc(widget.chatroom.chatroomid).collection
                    ("messages").orderBy("createdon", descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.active) {
                        if(snapshot.hasData) {
                           QuerySnapshot dataSnapshot = snapshot.data as
                           QuerySnapshot;

                           return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                                MessageModel currentMessage = MessageModel.
                                fromMap(dataSnapshot.docs[index].data() as
                              Map<String, dynamic>);
                            
                              return Row(
                                mainAxisAlignment: (currentMessage.sender
                                == widget.userModel.uid) ?
                                MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  Container(
                                   
                                    margin: EdgeInsets.symmetric(
                                      vertical: 2,
                                    ) ,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color:(currentMessage.sender ==
                                      widget.userModel.uid) ?Color.fromARGB(255, 99, 98, 98) :Color.fromARGB(255, 6, 155, 192),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(currentMessage.text.toString(),
                                      style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold,  
                                      ),)),
                                ],
                              );
                            },

                           );
                        }
                        else if (snapshot.hasError) {
                           return Center(
                            child: Text("An Error Occured! Please Check Your Internet Connection.",
                             style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        else {
                          return Center(
                            child: Text("Say Hi To Your New Friend",
                             style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      }
                      else{
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ), 

              Container(
                color: Color.fromARGB(248, 84, 83, 83),
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Message",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 6, 155, 192),
                      ),
                      
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
