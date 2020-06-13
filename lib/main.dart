import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:chat_firebase_app/chat_page.dart';

void main() {
  runApp(new MainPage());
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We-Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        iconTheme: IconThemeData(
          color: Colors.lime 
        )
      ),
      home: ChatPage(),
    );
  }
}