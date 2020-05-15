import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final String keyID = 'id';
final String keyAlamat = 'alamat';
final String keyEmail = 'email';
final String keyNama = 'nama';
final String keyNoTelp = 'no_telp';
final String keyRole = 'role';
final String keyStatus = 'status';

//setter

setID(id) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: keyID, value: id.toString());
}

setAlamat(alamat) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: keyAlamat, value: alamat.toString());
}

setEmail(email) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: keyEmail, value: email.toString());
}

setNama(nama) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: keyNama, value: nama.toString());
}

setNoTelp(noTelp) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: keyNoTelp, value: noTelp.toString());
}

setRole(role) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: keyRole, value: role.toString());
}

setStatus(status) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: keyStatus, value: status.toString());
}

//getter

getID() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: keyID);
  return value ?? null;
}

getAlamat() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: keyAlamat);
  return value ?? null;
}

getEmail() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: keyEmail);
  return value ?? null;
}

getNama() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: keyNama);
  return value ?? null;
}

getNoTelp() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: keyNoTelp);
  return value ?? null;
}

getRole() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: keyRole);
  return value ?? null;
}

getStatus() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: keyStatus);
  return value ?? null;
}

//clear preference

clearStorage() async {
  final storage = new FlutterSecureStorage();
  await storage.deleteAll();
}