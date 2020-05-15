import 'package:mitraabsensi/components/nav_drawer.dart';
import 'package:mitraabsensi/components/ok_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position _position;

  String _name;
  String _locality;
  String _subAdministrativeArea;
  String _administrativeArea;

  double _lat;
  double _lon;
  double _officeLat;
  double _officeLon;

  bool _loading = true;
  bool _successLoad;
  bool _isInCoverage = false;

  @override
  void initState() {
    super.initState();
    mount();
  }

  void mount() async {
    try {
      GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
      print('status : ${geolocationStatus.value}');
      _position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(_position.latitude, _position.longitude);
      if(placeMark != null && placeMark.isNotEmpty){
        Placemark pos = placeMark[0];

        setState(() {
          _name = pos.name;
          _locality = pos.locality;
          _subAdministrativeArea = pos.subAdministrativeArea;
          _administrativeArea = pos.administrativeArea;

          _lat = _position.latitude;
          _lon = _position.longitude;
          _officeLat = -6.304820;
          _officeLon = 106.848635;

          _successLoad = true;
          _loading = false;
        });
      }

      calculateDistance(_lat, _lon, _officeLat, _officeLon);
    } on Exception catch (e){
      print(e);
      setState(() {
        _successLoad = false;
        _loading = false;
      });
    }
  }

  void launchGMaps(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void calculateDistance(double currentLat, double currentLon, double targetLat, double targetLon) async {
    double distanceInMeters = await Geolocator().distanceBetween(currentLat, currentLon, targetLat, targetLon);
    double distanceInKiloMeters = distanceInMeters / 1000;

    if(distanceInKiloMeters > 3) {
      setState(() {
        _isInCoverage = false;
      });
    } else {
      setState(() {
        _isInCoverage = true;
      });
    }
  }

  Future<void> onRefresh() async {
    setState(() {
      _loading = true;
    });

    mount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mitra Absensi'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => onRefresh(),
          ),
        ],
      ),
      drawer: NavDrawer(),
      body: Container(
        child: _loading ?
        Center(
          child: CircularProgressIndicator(),
        ) :
        _successLoad ?
        RefreshIndicator(
          onRefresh: () => onRefresh(),
          child: ListView(
            children: <Widget>[
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  title: Text('Lokasi Anda saat ini:'),
                  subtitle: Text('$_name, $_locality, $_subAdministrativeArea, $_administrativeArea'),
                  leading: Icon(Icons.location_on),
                  onTap: () {
                    launchGMaps(_lat, _lon);
                  },
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  title: _isInCoverage ? Text('Absensi tersedia') : Text('Absensi tidak tersedia'),
                  subtitle: _isInCoverage ? Text('Anda masuk wilayah cakupan') : Text('Anda terlalu jauh dari wilayah cakupan'),
                  leading: Icon(Icons.track_changes),
                  onTap: () {
                    _isInCoverage ? Navigator.of(context).pushNamed('/absence') : okDialog(context, 'Anda harus berada di wilayah cakupan untuk absen');
                  }
                ),
              ),
            ],
          ),
        ) :
        Center(
          child: RaisedButton(
            onPressed: onRefresh,
            child: Text('Perbarui'),
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