import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mitraabsensi/components/ok_dialog.dart';
import 'package:mitraabsensi/services/shared_preference.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool _splashPlay = true;
  bool _loading = false;
  bool _obscureText = true;

  var _db = Firestore.instance;

  @override
  void initState() {
    super.initState();
    mount();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void mount() async {
    Timer(
      Duration(seconds: 3), () {
        checkAuth();
      }
    );
  }

  void checkAuth() async {
    String id = await getID();

    if(id != null){
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        _splashPlay = false;
      });
    }
  }
  
  Future<dynamic> postData(collectionName, email, pass) async {
    setState(() {
      _loading = true;
    });

    try {
      _db.collection(collectionName).where('email', isEqualTo: email).where('password', isEqualTo: pass).snapshots().listen((data) {
        if(data.documents.length != 0){
          setState(() {
            _loading = false;
          });

          setID(data.documents[0].documentID);
          setAlamat(data.documents[0].data['alamat']);
          setEmail(data.documents[0].data['email']);
          setNama(data.documents[0].data['nama']);
          setNoTelp(data.documents[0].data['no_telp']);
          setRole(data.documents[0].data['role']);
          setStatus(data.documents[0].data['status']);

          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          setState(() {
            _loading = false;
          });

          okDialog(context, 'Gagal masuk, silahkan coba lagi');
        }
      });
    } on Exception catch(e) {
      setState(() {
        _loading = false;
      });

      okDialog(context, 'Gagal masuk, silahkan coba lagi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _splashPlay ?
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 250.0,
                  width: 250.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/logo.jpeg'),
                      )
                  ),
                ),
                SizedBox(height: 50.0,),
                CircularProgressIndicator(),
              ],
            )
          ],
        ),
      ) : _loading ?
      Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ) :
      Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 250.0,
                width: 250.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/logo.jpeg'),
                    )
                ),
              ),
              SizedBox(height: 50.0,),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 25.0,),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          suffixIcon: InkWell(
                            onTap: () {
                              _toggle();
                            },
                            child: _obscureText ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: RaisedButton(
                        onPressed: () {
                          postData('users', emailController.text, passwordController.text);
                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0,),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 15.0,),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}