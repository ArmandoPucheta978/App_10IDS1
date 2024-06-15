import 'package:app_10ids1/DoctorPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuDoctorPage extends StatefulWidget {
  final String? DocId;
  final String? Rol;
  final String? Nombre;
  const MenuDoctorPage({Key? key,this.DocId, this.Rol, this.Nombre}) : super(key: key);

  @override
  State<MenuDoctorPage> createState() => _MenuDoctorPageState();
}

class _MenuDoctorPageState extends State<MenuDoctorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Citas Asignadas"),
      ),

    );
  }
}
