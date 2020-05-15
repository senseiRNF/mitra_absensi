import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mitraabsensi/services/shared_preference.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _alamat;
  String _email;
  String _nama;
  String _noTelp;

  @override
  void initState() {
    super.initState();
    mount();
  }

  void mount() async {
    String alamat = await getAlamat();
    String email = await getEmail();
    String nama = await getNama();
    String noTelp = await getNoTelp();

    setState(() {
      _alamat = alamat;
      _email = email;
      _nama = nama;
      _noTelp = noTelp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Container(
        child: ListView.builder(
            itemCount: 4,
            itemBuilder: (BuildContext context, int index){
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  leading: Icon(
                    index == 0 ? Icons.account_circle :
                    index == 1 ? Icons.email :
                    index == 2 ? Icons.phone :
                    Icons.home,
                    size: 30.0,
                  ),
                  title: Text(
                    index == 0 ? '$_nama' :
                    index == 1 ? '$_email' :
                    index == 2 ? '$_noTelp' :
                    '$_alamat',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}