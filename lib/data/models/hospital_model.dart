import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalModel {
  final String id;
  final String name;
  final GeoPoint location;

  HospitalModel({required this.id, required this.name, required this.location});
}