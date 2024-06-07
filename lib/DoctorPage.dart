import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoctorPage extends StatefulWidget {
  final String? docId;
  final String? Nombre;
  final String? Matricula;

  const DoctorPage({Key? key, this.docId, this.Nombre, this.Matricula}) : super(key: key);

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _matriculaController = TextEditingController();

  @override
  void initState(){
    super.initState();
    if (widget.Nombre != null) {
      _nombreController.text =widget.Nombre!;
    }
    if (widget.Matricula != null) {
      _matriculaController.text =widget.Matricula!;
    }
  }

  void dispose(){
    _nombreController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  Future<void> _SaveData() async {
    if (_formKey.currentState!.validate()) {
      if (widget.docId == null) {
        // Crear
        await FirebaseFirestore.instance.collection('doctores').add({
          'matricula': _matriculaController.text,
          'nombre': _nombreController.text,
        });
      } else {
        // Actualizar
        await FirebaseFirestore.instance.collection('doctores').doc(widget.docId).update({
          'matricula': _matriculaController.text,
          'nombre': _nombreController.text,
        });
      }
      Navigator.pop(context, 'saved');
    }
  }

  Future<void> _DeleteData() async {
    if (widget.docId != null) {
      await FirebaseFirestore.instance.collection('doctores').doc(widget.docId).delete();
      Navigator.pop(context, 'deleted');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Doctores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget> [
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(labelText: 'Matricula'),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'por favor ingrese su matricula';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'por favor ingrese su nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (widget.docId != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _SaveData,
                      child: Text('Guardar'),
                    ),
                    ElevatedButton(
                      onPressed: _DeleteData,
                      child: Text('Eliminar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              if (widget.docId == null)
                ElevatedButton(
                  onPressed: _SaveData,
                  child: Text('Guardar'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
