import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AsignarDoctorPage extends StatefulWidget {
  final String? DocId;
  final String? EspecialidadReq;
  const AsignarDoctorPage({Key? key, this.DocId, this.EspecialidadReq}) : super(key: key);

  @override
  State<AsignarDoctorPage> createState() => _AsignarDoctorPageState();
}

class _AsignarDoctorPageState extends State<AsignarDoctorPage> {
  String? _selectedReferenceId;
  List<Map<String, dynamic>> _references = [];
  Map<String, dynamic>? _selectedReferenceDetails;

  @override
  void initState() {
    super.initState();
    _fetchReferences();
  }

  Future<void> _fetchReferences() async {

    DocumentSnapshot espDoc = await FirebaseFirestore.instance.collection('especialidades').doc(widget.EspecialidadReq).get();

    if (!espDoc.exists) {
      throw Exception("especialidad ${widget.EspecialidadReq}no encontrado");
    }

    QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
        .collection('doctores')
        .where('EspecialidadRef', isEqualTo: espDoc.reference)
        .get();

    List<Map<String, dynamic>> references = [];

    for (var appointmentDoc in appointmentSnapshot.docs) {
      DocumentReference specialtyRef = appointmentDoc['EspecialidadRef'];
      DocumentSnapshot specialtyDoc = await specialtyRef.get();

      references.add({
        'id': appointmentDoc.id,
        'nombreDoc': appointmentDoc["Nombre"],
        'nombre': specialtyDoc['nombre'],
      });
    }

    setState(() {
      _references = references;
    });
  }

  Future<void> _getReferenceDetails(String referenceId) async {
    var reference = _references.firstWhere((ref) => ref['id'] == referenceId);
    setState(() {
      _selectedReferenceDetails = reference;
    });
  }

  Future<void> _save() async {
    if (_selectedReferenceId != null) {
      DocumentReference referenceRef = FirebaseFirestore.instance.collection('doctores').doc(_selectedReferenceId);
      DocumentReference recordRef = FirebaseFirestore.instance.collection('citas').doc(widget.DocId);

      await recordRef.update({
        'DoctorRef': referenceRef,
      });

      Navigator.pop(context);
    } else {
      print('Por favor selecciona un doctor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Referencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Asigna un doctor',
                border: OutlineInputBorder(),
              ),
              value: _selectedReferenceId,
              items: _references.map((reference) {
                return DropdownMenuItem<String>(
                  value: reference['id'],
                  child: Text(reference['nombreDoc']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedReferenceId = newValue;
                  _getReferenceDetails(newValue!);
                });
              },
            ),
            SizedBox(height: 20),
            _selectedReferenceDetails != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Especialidad del doc: ${_selectedReferenceDetails!['nombre']}'),
                // Añade más campos si es necesario
              ],
            )
                : Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text('Asignar doctor'),
            ),
          ],
        ),
      ),
    );
  }
}

