import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CitaPage extends StatefulWidget {
  final String? DocId;
  final String? EspecialidadRef;
  final String? UsuarioRef;
  final Timestamp? Fecha;
  const CitaPage({Key? key,this.DocId, this.EspecialidadRef, this.UsuarioRef, this.Fecha}): super(key: key);

  @override
  State<CitaPage> createState() => _CitaPageState();
}

class _CitaPageState extends State<CitaPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _Especialidades = [];
  String? _EspecialidadId;
  final _FechaController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  Timestamp selectedTimestamp = Timestamp.now();

  Future<void> _fetchSpecialties() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('especialidades').get();

    setState(() {
      _Especialidades = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nombre': doc['nombre'],
        };
      }).toList();
    });
  }

  void initState() {
    super.initState();
    _fetchSpecialties();
    if (widget.UsuarioRef != null && widget.Fecha != null && widget.EspecialidadRef != null) {
      Timestamp selectedDate = widget.Fecha!;
    } else {
      Timestamp selectedDate = Timestamp.now();
    }
  }

  void dispose() {
    _FechaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTimestamp = Timestamp.now();
      });
    }
  }

  Future<void> _SaveData() async {
    if (_formKey.currentState!.validate()) {
      if (widget.DocId == null) {
        // Crear
        DocumentReference userRef = FirebaseFirestore.instance.collection('usuarios').doc(widget.UsuarioRef);
        DocumentReference specialtyRef = FirebaseFirestore.instance.collection('especialidades').doc(_EspecialidadId);
        await FirebaseFirestore.instance.collection('citas').add({
          'EspecialidadRef': specialtyRef,
          'UsuarioRef': userRef,
          'Fecha': selectedTimestamp,
        });
      } else {
        // Actualizar
        await FirebaseFirestore.instance.collection('citas')
            .doc(widget.DocId)
            .update({
          'EspecialidadRef': _EspecialidadId,
          'UsuarioRef': widget.UsuarioRef,
          'Fecha': selectedTimestamp,
        });
      }
      Navigator.pop(context, 'saved');
    }
  }

  Future<void> _DeleteData() async {
    if (widget.DocId != null) {
      await FirebaseFirestore.instance.collection('citas')
          .doc(widget.DocId)
          .delete();
      Navigator.pop(context, 'deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario para citas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Selecciona una especialidad',
                  border: OutlineInputBorder(),
                ),
                value: _EspecialidadId,
                items: _Especialidades.map((specialty) {
                  return DropdownMenuItem<String>(
                    value: specialty['id'],
                    child: Text(specialty['nombre']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _EspecialidadId = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
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

