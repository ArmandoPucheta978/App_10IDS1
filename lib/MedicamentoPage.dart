import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicamentoPage extends StatefulWidget {
  final String? DocId;
  final String? Codigo;
  final String? Medicamento;
  final String? Existencias;
  final Timestamp? Fecha_cad;
  const MedicamentoPage({Key? key, this.DocId,this.Codigo, this.Medicamento, this.Existencias, this.Fecha_cad}) : super(key: key);

  @override
  State<MedicamentoPage> createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _medicamentoController = TextEditingController();
  final _existenciaController = TextEditingController();
  final _fecha_cadController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  Timestamp selectedTimestamp = Timestamp.now();

  void initState(){
    super.initState();
    if (widget.Medicamento != null) {
      _codigoController.text = widget.Codigo!;
      _medicamentoController.text = widget.Medicamento!;
      _existenciaController.text = widget.Existencias!;
      Timestamp selectedDate = widget.Fecha_cad!;
    } else {
      Timestamp selectedDate = Timestamp.now();
    }
  }

  void dispose(){
    _medicamentoController.dispose();
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
        await FirebaseFirestore.instance.collection('medicamentos').add({
          'codigo': _codigoController.text,
          'nombre': _medicamentoController.text,
          'existencia': _existenciaController.text,
          'fecha_cad': selectedTimestamp,
        });
      } else {
        // Actualizar
        await FirebaseFirestore.instance.collection('medicamentos').doc(widget.DocId).update({
          'codigo': _codigoController.text,
          'nombre': _medicamentoController.text,
          'existencia': _existenciaController.text,
          'fecha_cad': selectedTimestamp,
        });
      }
      Navigator.pop(context, 'saved');
    }
  }

  Future<void> _DeleteData() async {
    if (widget.DocId != null) {
      await FirebaseFirestore.instance.collection('medicamentos').doc(widget.DocId).delete();
      Navigator.pop(context, 'deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Medicamentos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              TextFormField(
                controller: _codigoController,
                decoration: InputDecoration(labelText: 'Codigo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'por favor ingrese el codigo';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _medicamentoController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'por favor ingrese el medicamento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _existenciaController,
                decoration: InputDecoration(labelText: 'Existencias'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'por favor ingrese las existencias';
                  }
                  return null;
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
