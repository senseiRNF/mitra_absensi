import 'package:flutter/material.dart';
import 'package:mitraabsensi/components/ok_dialog.dart';
import 'package:mitraabsensi/services/shared_preference.dart';

class NavDrawer extends StatefulWidget {
  final isInCoverage;

  NavDrawer({@required this.isInCoverage});

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  void logout(context) async {
    await clearStorage();
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Mitra Absensi',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg')
                )
            ),
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('Absensi'),
            onTap: () {
              if(widget.isInCoverage) {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/absence');
              } else {
                Navigator.of(context).pop();
                okDialog(context, 'Anda harus berada di wilayah cakupan untuk absen');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profil'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }
}