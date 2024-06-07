import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConsultorioPage extends StatefulWidget {
  final String? DocId;
  final String? Consultorio;

  const ConsultorioPage({Key? key, this.DocId, this.Consultorio}) : super(key: key);

  @override
  State<ConsultorioPage> createState() => _ConsultorioPageState();
}

class _ConsultorioPageState extends State<ConsultorioPage> {
  @override

    final _formKey = GlobalKey<FormState>();
    final  _consultorioController = TextEditingController();

    void initState(){
      super.initState();
      if (widget.Consultorio != null) {
        _consultorioController.text =widget.Consultorio!;
      }
    }

    void dispose(){
      _consultorioController.dispose();
      super.dispose();
    }

    Future<void> _SaveData() async {
      if (_formKey.currentState!.validate()) {
        if (widget.DocId == null) {
          // Crear
          await FirebaseFirestore.instance.collection('consultorios').add({
            'consultorio': _consultorioController.text,
          });
        } else {
          // Actualizar
          await FirebaseFirestore.instance.collection('consultorios').doc(widget.DocId).update({
            'consultorio': _consultorioController.text,
          });
        }
        Navigator.pop(context, 'saved');
      }
    }

    Future<void> _DeleteData() async {
      if (widget.DocId != null) {
        await FirebaseFirestore.instance.collection('consultorios').doc(widget.DocId).delete();
        Navigator.pop(context, 'deleted');
      }
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Formulario de consultorio'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget> [
                TextFormField(
                  controller: _consultorioController,
                  decoration: InputDecoration(labelText: 'Consultorio'),
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'por favor ingrese el consultorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                if (widget.DocId != null)
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
                if (widget.DocId == null)
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