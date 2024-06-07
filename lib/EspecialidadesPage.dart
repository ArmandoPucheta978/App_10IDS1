import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EspecialidadesPage extends StatefulWidget {
  final String? docId;
  final String? Nombre;

  const EspecialidadesPage({Key? key, this.docId, this.Nombre}) : super(key: key);



  @override
  State<EspecialidadesPage> createState() => _EspecialidadesPageState();
}

class _EspecialidadesPageState extends State<EspecialidadesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  void initState(){
    super.initState();
    if (widget.Nombre != null) {
      _nombreController.text = widget.Nombre!;

    }
  }

  void dispose(){
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _SaveData() async {
    if (_formKey.currentState!.validate()) {
      if (widget.docId == null) {
        // Crear
        await FirebaseFirestore.instance.collection('especialidades').add({
          'nombre': _nombreController.text,
        });
      } else {
        // Actualizar
        await FirebaseFirestore.instance.collection('especialidades').doc(widget.docId).update({
          'nombre': _nombreController.text,
        });
      }
      Navigator.pop(context, 'saved');
    }
  }

  Future<void> _DeleteData() async {
    if (widget.docId != null) {
      await FirebaseFirestore.instance.collection('especialidades').doc(widget.docId).delete();
      Navigator.pop(context, 'deleted');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Especialidades'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget> [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'por favor ingrese  su nombre';
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