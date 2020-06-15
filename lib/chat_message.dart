import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          !this.mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(this.data['senderPhotoUrl'])),
                )
              : Container(),
          Expanded(
              child: Column(
                  crossAxisAlignment: this.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                data['imgUrl'] != null
                    ? Image.network(
                        data['imgUrl'],
                        width: 250,
                      )
                    : Text(data['body'], textAlign: this.mine ? TextAlign.end : TextAlign.start, style: TextStyle(fontSize: 16)),
                Text(data['senderName'],
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))
              ])),
          this.mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(this.data['senderPhotoUrl'])),
                )
              : Container(),
        ],
      ),
    );
  }
}
