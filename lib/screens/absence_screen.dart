import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:mitraabsensi/components/ok_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mitraabsensi/services/shared_preference.dart';
import 'package:path_provider/path_provider.dart';

class AbsenceScreen extends StatefulWidget {
  @override
  _AbsenceScreenState createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  LocalAuthentication _auth = LocalAuthentication();

  bool _loading = true;
  bool _failedLoad = false;
  bool _canCheckBiometrics;
  bool _isAuthenticating = false;
  bool _alreadyCheckIn = false;
  bool _alreadyCheckOut = false;

  DateTime _today = DateTime.now();

  String _userId;
  String _absenceId;
  String _userRole;
  String _stringToday;
  String _checkIn;
  String _checkOut;

  BuildContext _context;

  var _db = Firestore.instance;
  var _excel = Excel.createExcel();

  @override
  void initState() {
    super.initState();
    mount();
    _checkBiometrics();
  }

  void mount() async {
    var userId = await getID();
    var userRole = await getRole();

    setState(() {
      _userId = userId;
      _userRole = userRole;
      _stringToday = DateFormat('dd-MM-yyyy').format(_today);
    });

    getData('absensi', _userId, _stringToday);
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
    });

    if(!canCheckBiometrics){
      okDialog(context, 'Perangkat Anda tidak memiliki sensor Fingerprint!');
    }
  }

  Future<void> _authenticate(typeAbsensi) async {
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

    bool upAuth = authenticated ? true : false;
    
    if(upAuth){
      if(typeAbsensi == 'check_in'){
        updateCheckIn('absensi', _absenceId, DateFormat('HH.mm').format(DateTime.now()));
      } else {
        updateCheckOut('absensi', _absenceId, DateFormat('HH.mm').format(DateTime.now()));
      }
    }
    
  }

  void _cancelAuthentication() {
    _auth.stopAuthentication();
  }

  void getData(collectionName, userId, stringToday) async {
    setState(() {
      _loading = true;
    });

    _db.collection(collectionName).where('user_id', isEqualTo: userId).where('tanggal', isEqualTo: stringToday).snapshots().listen((data) {
      if(data.documents.length != 0){
        setState(() {
          _absenceId = data.documents[0].documentID;
          _checkIn = data.documents[0].data['check_in'];
          _checkOut = data.documents[0].data['check_out'];

          _checkIn != ' - ' ? _alreadyCheckIn = true : _alreadyCheckIn = false;
          _checkOut != ' - ' ? _alreadyCheckOut = true : _alreadyCheckOut = false;

          _loading = false;
          _failedLoad = false;
        });
      } else {
        _db.collection(collectionName).document().setData({'check_in' : ' - ', 'check_out' : ' - ', 'tanggal' : '$stringToday', 'user_id' : '$userId'}).catchError((error){
          print(error);
          okDialog(context, error);

          setState(() {
            _loading = false;
            _failedLoad = true;
          });
        });
      }
    }).onError((error){
      print(error);
      okDialog(context, error);

      setState(() {
        _loading = false;
        _failedLoad = true;
      });
    });
  }

  void updateCheckIn(collectionName, absenceId, updateValue){
    setState(() {
      _loading = true;
    });

    _db.collection(collectionName).document(absenceId).updateData({'check_in' : '$updateValue'}).then((result){
      okDialog(_context, 'Absen masuk berhasil diperbaharui');

      setState(() {
        _loading = false;
      });
    }).catchError((error){
      print(error);
      okDialog(_context, error);

      setState(() {
        _loading = false;
      });
    });
  }

  void updateCheckOut(collectionName, absenceId, updateValue){
    setState(() {
      _loading = true;
    });

    _db.collection(collectionName).document(absenceId).updateData({'check_out' : '$updateValue'}).then((result){
      okDialog(_context, 'Absen keluar berhasil diperbaharui');

      setState(() {
        _loading = false;
      });
    }).catchError((error){
      print(error);
      okDialog(_context, error);

      setState(() {
        _loading = false;
      });
    });
  }

  void updateFile() async {
    _db.collection('absensi').orderBy('tanggal').snapshots().listen((data) {
      if(data.documents.length != 0){
        _excel.updateCell('Sheet1', CellIndex.indexByString("A1"), "Tanggal",
            backgroundColorHex: "#FFFFFF", horizontalAlign: HorizontalAlign.Center);

        _excel.updateCell('Sheet1', CellIndex.indexByString("B1"), "ID Karyawan",
            backgroundColorHex: "#FFFFFF", horizontalAlign: HorizontalAlign.Center);

        _excel.updateCell('Sheet1', CellIndex.indexByString("C1"), "Nama Karyawan",
            backgroundColorHex: "#FFFFFF", horizontalAlign: HorizontalAlign.Center);

        _excel.updateCell('Sheet1', CellIndex.indexByString("D1"), "Absen Masuk",
            backgroundColorHex: "#FFFFFF", horizontalAlign: HorizontalAlign.Center);

        _excel.updateCell('Sheet1', CellIndex.indexByString("E1"), "Absen Keluar",
            backgroundColorHex: "#FFFFFF", horizontalAlign: HorizontalAlign.Center);

        for(int i = 0; i < data.documents.length; ++i){
          _excel.updateCell(
              'Sheet1',
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i+1),
              "${data.documents[i].data['tanggal']}",
              wrap: TextWrapping.WrapText);

          _excel.updateCell(
              'Sheet1',
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i+1),
              "${data.documents[i].data['user_id']}",
              wrap: TextWrapping.WrapText);

          _db.collection('users').document('${data.documents[i].data['user_id']}').snapshots().listen((datauser) {
            _excel.updateCell(
                'Sheet1',
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i+1),
                "${datauser['nama']}",
                wrap: TextWrapping.WrapText);

            if(data.documents.length - i == 1) {
              createExcel();
            }
          });

          _excel.updateCell(
              'Sheet1',
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i+1),
              "${data.documents[i].data['check_in']}",
              wrap: TextWrapping.WrapText);

          _excel.updateCell(
              'Sheet1',
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i+1),
              "${data.documents[i].data['check_out']}",
              wrap: TextWrapping.WrapText);
        }
      } else {
        setState(() {
          _loading = false;
        });

        okDialog(_context, 'Dokumen tidak ditemukan');
      }
    });
  }

  void createExcel() async {
    var dir = await getExternalStorageDirectory();

    try {
      _excel.encode().then((onValue) {
        File(join('${dir.path}/exported-$_stringToday.xlsx'))
          ..createSync(recursive: true)
          ..writeAsBytesSync(onValue);

        setState(() {
          _loading = false;
        });

        okDialog(_context, 'Sukses mengeskpor dokumen, data dapat dilihat di ${dir.path}/exported-$_stringToday.xlsx');
      });
    } on Exception catch(e) {
      print(e);
      setState(() {
        _loading = false;
      });

      okDialog(_context, 'Gagal mengekspor dokumen, silahkan coba lagi');
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
    setState(() {
      _context = context;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi'),
        actions: <Widget>[
          !_loading ? _userRole == 'admin' ?
          IconButton(
            icon: Icon(Icons.import_export),
            onPressed: () {
              setState(() {
                _loading = true;
              });

              updateFile();
            },
          ) :
          Container() :
          Container(),
        ],
      ),
      body: _loading ?  Center(
        child: CircularProgressIndicator(),
      ) :
      _failedLoad ? Center(
        child: RaisedButton(
          onPressed: onRefresh,
          child: Text('Perbarui'),
        ),
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
                    '\n${DateFormat('dd MMMM yyyy').format(_today)}',
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
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  title: Text(
                    'Absen Masuk:',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(
                    '\n$_checkIn',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  leading: Icon(
                    Icons.access_time,
                    size: 30.0,
                    color: Colors.green,
                  ),
                  trailing: Icon(
                    Icons.fingerprint,
                    size: 30.0,
                  ),
                  onTap: () {
                    !_alreadyCheckIn ?
                    _isAuthenticating ?
                    _cancelAuthentication() :
                    _authenticate('check_in') :
                    okDialog(context, 'Anda sudah mengisi absen masuk');
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  title: Text(
                    'Absen Keluar:',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(
                    '\n$_checkOut',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  leading: Icon(
                    Icons.access_time,
                    size: 30.0,
                    color: Colors.red,
                  ),
                  trailing: Icon(
                    Icons.fingerprint,
                    size: 30.0,
                  ),
                  onTap: () {
                    !_alreadyCheckOut ?
                    _isAuthenticating ?
                    _cancelAuthentication() :
                    _authenticate('check_out') :
                    okDialog(context, 'Anda sudah mengisi absen keluar');
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              /*IconButton(
                icon: Icon(Icons.fingerprint),
                onPressed:
                _isAuthenticating ? _cancelAuthentication : _authenticate,
              )*/
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