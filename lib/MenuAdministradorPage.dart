import 'package:app_10ids1/CitasPage.dart';
import 'package:app_10ids1/ConsultoriosPage.dart';
import 'package:app_10ids1/DoctoresPage.dart';
import 'package:app_10ids1/MedicamentosPage.dart';
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
        title: const Text("Menu del Administrador"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ElevatedButton(onPressed:() async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctoresPage()));},
                  child: const Text("Lista Doctores")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed:() async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicamentosPage()));
              },
                  child: const Text("Lista Medicamentos")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed:() async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultoriosPage()));
              },
                  child: const Text("Formulario Consultorios")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed:() async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CitasPage()));
              },
                  child: const Text("Lista Citas Pendientes")),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
