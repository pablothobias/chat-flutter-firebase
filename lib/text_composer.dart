import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);
  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  void _reset() {
    setState(() {
      this._controller.text = '';
      this._isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () async {
                final File imgFile =
                    await ImagePicker.pickImage(source: ImageSource.camera);
                if (imgFile == null) return;
                widget.sendMessage(imgFile: imgFile);
              }),
          Expanded(
              child: TextField(
            controller: this._controller,
            decoration: InputDecoration.collapsed(hintText: "Send new message"),
            onChanged: (text) {
              setState(() {
                this._isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: (text) {
              widget.sendMessage(text: text);
              this._reset();
            },
          )),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: this._isComposing
                  ? () {
                      widget.sendMessage(text: this._controller.text);
                      this._reset();
                    }
                  : null)
        ],
      ),
    );
  }
}
