import 'package:mitraabsensi/components/ok_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

class AbsenceScreen extends StatefulWidget {
  @override
  _AbsenceScreenState createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  LocalAuthentication _auth = LocalAuthentication();

  bool _loading = true;
  bool _canCheckBiometrics;
  bool _isAuthenticating = false;

  DateTime _today = DateTime.now();

  String _stringToday;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();

    setState(() {
      _stringToday = DateFormat('dd MMMM yyyy').format(_today);
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      _loading = false;
    });

    if(!canCheckBiometrics){
      okDialog(context, 'Perangkat Anda tidak memiliki sensor Fingerprint!');
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });
      authenticated = await _auth.authenticateWithBiometrics(
          localizedReason: 'Mohon untuk melakukan verifikasi sidik jari',
          useErrorDialogs: true,
          stickyAuth: true,
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    print(message);
  }

  void _cancelAuthentication() {
    _auth.stopAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi'),
      ),
      body: _loading ?  Center(
        child: CircularProgressIndicator(),
      ) :
      _canCheckBiometrics ? Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  title: Text(
                    'Tanggal:',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(
                    '\n$_stringToday',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  leading: Icon(
                    Icons.calendar_today,
                    size: 30.0,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              IconButton(
                icon: Icon(Icons.fingerprint),
                onPressed:
                _isAuthenticating ? _cancelAuthentication : _authenticate,
              )
            ]),
      ) :
      Container(
        child: Center(
          child: Text('Maaf, Anda tidak dapat absen melalui perangkat ini'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _cancelAuthentication();
  }
}