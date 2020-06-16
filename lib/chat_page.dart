import 'package:flutter/material.dart';
import 'package:chat_firebase_app/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:chat_firebase_app/chat_message.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser _currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        this._currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (this._currentUser != null) return this._currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await this.googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await this._getUser();

    if (user == null) {
      this._scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
                'Não foi possível efetuar login. Tente novamente mais tarde.'),
            backgroundColor: Colors.red,
          ));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now()
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      setState(() {
        this.isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;

      setState(() {
        this.isLoading = false;
      });
    }

    if (text != null) {
      data["body"] = text;
    }
    Firestore.instance.collection('messages').add(data);
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    this._scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Você saiu com sucesso.'),
          backgroundColor: Colors.green,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(this._currentUser != null
            ? "Olá, ${this._currentUser.displayName}"
            : "We-Chat"),
        elevation: 0,
        actions: <Widget>[
          this._currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app), onPressed: this.logout)
              : Container(),
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('messages')
                    .orderBy('time')
                    .snapshots(),
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
                            return ChatMessage(documents[index].data, documents[index].data['uid'] == this._currentUser?.uid);
                          });
                  }
                })),
        this.isLoading ? LinearProgressIndicator() : Container(),
        TextComposer(this._sendMessage)
      ]),
    );
  }
}
