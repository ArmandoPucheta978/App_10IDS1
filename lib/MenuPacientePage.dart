import 'package:app_10ids1/CitaPage.dart';
import 'package:app_10ids1/EspecialidadesPage.dart';
import 'package:app_10ids1/MenuPacientePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class MenuPacientePage extends StatefulWidget {
  final String? DocId;
  final String? Rol;
  final String? Nombre;
  MenuPacientePage({Key? key, this.DocId , this.Rol, this.Nombre,}) : super(key: key);

  @override
  State<MenuPacientePage> createState() => _MenuPacientePageState();
}

class _MenuPacientePageState extends State<MenuPacientePage> {
  Future<List<Map<String, dynamic>>> _getAppointmentsWithDetails() async {
    // Consulta la colección de usuarios para obtener el documento del usuario
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(widget.DocId).get();

    if (!userDoc.exists) {
      throw Exception("Usuario no encontrado");
    }

    // Consulta la colección de citas para obtener las citas del usuario
    QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
        .collection('citas')
        .where('UsuarioRef', isEqualTo: userDoc.reference)
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
        title: Text('Mis Citas'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAppointmentsWithDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tienes citas.'));
          }

          var appointments = snapshot.data!;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index]['appointment'];
              var specialty = appointments[index]['specialty'];

              if (appointment == null || specialty == null) {
                return ListTile(
                  title: Text('Cita no disponible'),
                );
              }

              Timestamp timestamp = appointment['Fecha'];
              DateTime dateTime = timestamp.toDate();
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

              return ListTile(
                title: Text('Fecha: $formattedDate\nEspecialidad: ${specialty['nombre']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CitaPage(UsuarioRef: widget.DocId,)),
          );
          if (result == 'saved') {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cita guardada con éxito'))
            );
                setState(() {});
          }
        },
      ),
    );
  }
}
