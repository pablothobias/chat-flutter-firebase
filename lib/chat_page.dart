import 'package:chat_firebase_app/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  void _sendMessage({String text, File imgFile}) async {
    Map<String, dynamic> data = {};

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["body"] = url;
    }

    if (text != null) {
      data["body"] = text;
    }
    Firestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("We-Chat"),
        elevation: 0,
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                      break;
                    default:
                      List<DocumentSnapshot> documents =
                          snapshot.data.documents.reversed.toList();
                      return ListView.builder(
                          itemCount: documents.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return ListTile(title: Text(documents[index].data['body']));
                          });
                  }
                })),
        TextComposer(this._sendMessage)
      ]),
    );
  }
}
