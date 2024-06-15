import 'package:flutter/material.dart';

class MenuAdministradorPage extends StatefulWidget {
  final String? DocId;
  final String? Rol;
  final String? Nombre;
  const MenuAdministradorPage({Key? key, this.DocId, this.Rol, this.Nombre}) : super(key: key);

  @override
  State<MenuAdministradorPage> createState() => _MenuAdministradorPageState();
}

class _MenuAdministradorPageState extends State<MenuAdministradorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Administrador'),
      ),
    );
  }
}
