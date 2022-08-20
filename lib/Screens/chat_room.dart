import 'package:chat_app1/Screens/video_call_screen2.dart';
import 'package:chat_app1/Screens/video_call_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatRoom extends StatelessWidget {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, dynamic>? userMap;
  final String chatRoomId;
  ChatRoom({Key? key, this.userMap, required this.chatRoomId})
      : super(key: key);

  // ChatRoom({required this.chatRoomId, this.userMap});
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        // "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(userMap!['name']),
        actions: [
          IconButton(
            onPressed: () =>
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_)=>const VideoCallScreen())
            ),
            icon: Icon(Icons.video_camera_front),
          )
      
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy('time', descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          // return Text(snapshot.data?.docs[index]['message']);
                          return messages(size, map);
                        });
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: size.height / 17,
                        width: size.width / 1.3,
                        child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                            hintText: 'Send Message',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            onSendMessage();
                          },
                          icon: Icon(Icons.send)),
                    ],
                  ),
                ))
          ],
        ),
      ),
      // bottomNavigationBar: Container(
      //   height: size.height / 10,
      //   width: size.width,
      //   alignment: Alignment.center,
      //   child: Container(
      //     height: size.height / 12,
      //     width: size.width / 1.1,
      //     child: Row(
      //       children: <Widget>[
      //         Container(
      //           height: size.height / 15,
      //           width: size.width / 1.1,
      //           child: TextField(
      //               controller: _message,
      //               decoration: InputDecoration(
      //                   border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(8),
      //               ))),
      //         ),
      //         IconButton(
      //           onPressed: () {},
      //           icon: Icon(Icons.send),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map) {
    return
        // map['type'] == "text"?
        Container(
      width: size.width,
      alignment: map['sendby'] == _auth.currentUser?.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.blue,
        ),
        child: Text(
          map['message'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
    // : Container(
    //     height: size.height / 2.5,
    //     width: size.width,
    //     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    //     alignment: map['sendby'] == _auth.currentUser!.displayName
    //         ? Alignment.centerRight
    //         : Alignment.centerLeft,
    //     child: InkWell(
    //       onTap: () => Navigator.of(context).push(
    //         MaterialPageRoute(
    //           builder: (_) => ShowImage(
    //             imageUrl: map['message'],
    //           ),
    //         ),
    //       ),
    //       child: Container(
    //         height: size.height / 2.5,
    //         width: size.width / 2,
    //         decoration: BoxDecoration(border: Border.all()),
    //         alignment: map['message'] != "" ? null : Alignment.center,
    //         child: map['message'] != ""
    //             ? Image.network(
    //                 map['message'],
    //                 fit: BoxFit.cover,
    //               )
    //             : CircularProgressIndicator(),
    //       ),
    //     ),
    //   );
  }
}
