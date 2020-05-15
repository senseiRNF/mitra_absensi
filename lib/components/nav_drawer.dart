import 'package:flutter/material.dart';
import 'package:mitraabsensi/services/shared_preference.dart';

class NavDrawer extends StatelessWidget {

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
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/absence');
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
            leading: Icon(Icons.settings),
            title: Text('Pengaturan'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/setting');
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Bantuan'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/help');
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