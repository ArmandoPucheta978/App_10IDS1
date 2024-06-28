import 'package:app_10ids1/AsignarDoctorPage.dart';
import 'package:app_10ids1/CitaPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CitasPage extends StatefulWidget {
  final String? DocId;
  final String? Rol;
  final String? Nombre;
  const CitasPage({Key? key, this.DocId , this.Rol, this.Nombre,}) : super(key: key);

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  Future<List<Map<String, dynamic>>> _getAppointmentsWithDetails() async {
    // Consulta la colección de usuarios para obtener el documento del usuario
    QuerySnapshot usuarios = await FirebaseFirestore.instance.collection('usuarios').get();

    // Consulta la colección de citas para obtener las citas del usuario
    QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
        .collection('citas')
        .get();

    List<Map<String, dynamic>> appointmentDetails = [];

    for (var appointmentDoc in appointmentSnapshot.docs) {
      // Obtener referencia a la especialidad
      DocumentReference specialtyRef = appointmentDoc['EspecialidadRef'];

      // Obtener detalles de la especialidad
      DocumentSnapshot specialtyDoc = await specialtyRef.get();

      appointmentDetails.add({
        'appointment': appointmentDoc.data(),
        'specialty': specialtyDoc.data(),
      });
    }

    return appointmentDetails;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todas las Citas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('citas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var appointmentDocs = snapshot.data!.docs;

          if (appointmentDocs.isEmpty) {
            return Center(child: Text('No hay citas.'));
          }

          var filteredAppointments = appointmentDocs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return !data.containsKey('DoctorRef');
          }).toList();

          if (filteredAppointments.isEmpty) {
            return Center(child: Text('Todas las citas estan asignadas.'));
          }

          return ListView.builder(
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              var appointment = filteredAppointments[index];
              return FutureBuilder<Map<String, dynamic>>(
                future: _getAppointmentDetails(appointment),
                builder: (context, detailsSnapshot) {
                  if (!detailsSnapshot.hasData) {
                    return ListTile(
                      title: Text('Cargando...'),
                    );
                  }

                  var doc = detailsSnapshot.data!;
                  return ListTile(
                    title: Text('Usuario: ${doc['userName']}'),
                    subtitle: Text('Especialidad: ${doc['specialtyName']}\nFecha: ${doc['formattedDate']}'),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            AsignarDoctorPage(DocId: appointment.id,
                                              EspecialidadReq: doc['specialtyId'],)),
                      );
                      if (result == 'saved') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Doctor asignado con éxito'))
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getAppointmentDetails(DocumentSnapshot appointment) async {
    var data = appointment.data() as Map<String, dynamic>;
    var userRef = appointment['UsuarioRef'] as DocumentReference;
    var specialtyRef = appointment['EspecialidadRef'] as DocumentReference;

    var userDoc = await userRef.get();
    var specialtyDoc = await specialtyRef.get();

    Timestamp timestamp = appointment['Fecha'];
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    return {
      'userName': userDoc['nombre'],
      'specialtyId': specialtyDoc.id,
      'specialtyName': specialtyDoc['nombre'],
      'formattedDate': formattedDate,
    };
  }
}
