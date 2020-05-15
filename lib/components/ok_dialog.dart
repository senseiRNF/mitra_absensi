import 'package:flutter/material.dart';

okDialog (context, message) {
  return showDialog(
    context: context,
    builder: (context){
      return AlertDialog(
        title: Text('Attention'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}