import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mitraabsensi/services/shared_preference.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _email;

  @override
  void initState() {
    super.initState();
    mount();
  }

  void mount() async {
    String email = await getEmail();

    setState(() {
      _email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').where('email', isEqualTo: _email).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          DocumentSnapshot document = snapshot.data.documents[0];
          //print('id : ${snapshot.data.documents[0].documentID}');
          Map<String, dynamic> task = document.data;
          return ListView.builder(
              itemCount: 3,
              itemBuilder: (BuildContext context, int index){
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    leading: Icon(
                      index == 0 ? Icons.account_circle :
                      index == 1 ? Icons.email :
                      Icons.phone,
                      size: 30.0,
                    ),
                    title: Text(
                      index == 0 ? '${task['nama']}' :
                      index == 1 ? '${task['email']}' :
                      '${task['no_telp']}',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                );
              });
          },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}