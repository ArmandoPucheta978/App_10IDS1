import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AsignarMedPage extends StatefulWidget {
  final String? DocId;
  const AsignarMedPage({Key? key, this.DocId}): super(key: key);

  @override
  State<AsignarMedPage> createState() => _AsignarMedPageState();
}

class _AsignarMedPageState extends State<AsignarMedPage> {
  String? _selectedMedicamento;
  List<Map<String, dynamic>> _medicamentos = [];
  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> _getMedicamentos() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('medicamentos').get();

    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'nombre': doc['nombre'],
      };
    }).toList();
  }

  Future<void> _save() async {
    if (_selectedMedicamento != null) {
      DocumentReference referenceRef = FirebaseFirestore.instance.collection('medicamentos').doc(_selectedMedicamento);
      DocumentReference recordRef = FirebaseFirestore.instance.collection('citas').doc(widget.DocId);

      await recordRef.update({
        'MedicamentoRef': referenceRef,
      });

      Navigator.pop(context, 'saved');
    } else {
      print('Por favor selecciona un doctor');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recetar medicamentos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getMedicamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay medicamentos disponibles.'));
          }


          _medicamentos = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Medicamento',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMedicamento,
                    items: _medicamentos.map((medicina) {
                      return DropdownMenuItem<String>(
                        value: medicina['id'],
                        child: Text(medicina['nombre']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMedicamento = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text('Guardar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}