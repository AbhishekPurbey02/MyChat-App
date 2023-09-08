import 'package:chatroom/models/ChatRoomModel.dart';
import 'package:chatroom/models/FirebaseHelper.dart';
import 'package:chatroom/models/UIHelper.dart';
import 'package:chatroom/models/UserModel.dart';
import 'package:chatroom/pages/ChatRoomPage.dart';
import 'package:chatroom/pages/LoginPage.dart';
import 'package:chatroom/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({super.key, required this.userModel, required this.firebaseUser});

  

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 59, 62),
     appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 6, 155, 192),
      centerTitle: true,
      title: Text("Chat Room"),
      actions: [
        IconButton(
          onPressed: () async {
           await FirebaseAuth.instance.signOut();
           Navigator.popUntil(context, (route) => route.isFirst);
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return LoginPage();
              }
            ),
           );
          },
          icon: Icon(Icons.logout),
        ),
      ],
     ),
     body: SafeArea(
      child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("chatrooms").where
          ("participants.${widget.userModel.uid}",isEqualTo: true).
          snapshots(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.active) {
              if(snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as
                QuerySnapshot;

                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap
                    (chatRoomSnapshot.docs[index].data() as Map<String,
                    dynamic>);

                    Map<String, dynamic> participants = chatRoomModel.participants!;

                    List<String> participantsKeys = participants.keys.
                    toList();
                    participantsKeys.remove(widget.userModel.uid);

                    return FutureBuilder(
                      future: FirebaseHelpher.getUserModelById
                      (participantsKeys[0]),
                      builder: (context, userData) {
                        if(userData.connectionState == ConnectionState.done){

                          if(userData.data != null){
                             UserModel targetUser = userData.data as UserModel;

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return ChatRoomPage(
                                  chatroom: chatRoomModel,
                                  firebaseUser: widget.firebaseUser,
                                  userModel: widget.userModel,
                                  targetUser: targetUser,
                                );
                              }),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 6, 155, 192),
                            backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                          ) ,
                          title: Text(targetUser.fullname.toString(),
                          style: TextStyle(fontSize: 16, color: Colors.white), ),


                          subtitle: (chatRoomModel.lastMessage.toString() != "") ? Text(chatRoomModel.lastMessage.
                          toString(),
                           style: TextStyle(fontSize: 16, color: Colors.white),): Text("Say Hi To Your New Friend!",
                           style: TextStyle(fontSize: 16,   color: Color.fromARGB(255, 6, 155, 192),),)
                        );
                          }
                         else{
                          return Container();
                         }
                        }
                        else{
                          return Container();
                        }
                      },
                    );
                  },
                );
              }
              else if(snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              else{
                return Center(
                  child: Text("No Chats"),
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
     floatingActionButton: FloatingActionButton(
      backgroundColor: Color.fromARGB(255, 6, 155, 192),
      onPressed: () {
        
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        
        }));
      },
      child: Icon(Icons.search),
     ),
    );
  }
}
