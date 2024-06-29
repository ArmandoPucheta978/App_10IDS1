import 'package:app_10ids1/AsignarMedPage.dart';
import 'package:app_10ids1/DoctorPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuDoctorPage extends StatefulWidget {
  final String? DocId;
  final String? Rol;
  final String? Nombre;
  const MenuDoctorPage({Key? key,this.DocId, this.Rol, this.Nombre}) : super(key: key);

  @override
  State<MenuDoctorPage> createState() => _MenuDoctorPageState();
}

class _MenuDoctorPageState extends State<MenuDoctorPage> {
  Future<List<Map<String, dynamic>>> _getAppointmentsWithDetails() async {
    // Consulta la colección de usuarios para obtener el documento del doctor
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(widget.DocId).get();

    if (!userDoc.exists) {
      throw Exception("Usuario no encontrado");
    }

    // Consulta la colección de citas para obtener las citas asignadas del doctor
    QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
        .collection('citas')
        .where('DoctorRef', isEqualTo: userDoc['DoctorRef'])
        .orderBy('Fecha', descending: true)
        .get();

    List<Map<String, dynamic>> appointmentDetails = [];

    for (var appointmentDoc in appointmentSnapshot.docs) {
      // Obtener referencia al usuario
      DocumentReference userRef = appointmentDoc['UsuarioRef'];

      // Obtener detalles del usuario
      DocumentSnapshot userSnapshot = await userRef.get();
      var data = appointmentDoc.data() as Map<String, dynamic>;

      appointmentDetails.add({
        'id': appointmentDoc.id,
        'appointment': data,
        'user': userSnapshot.data(),
        //'MedicamentoRef': data.containsKey('MedicamentoRef') ? data['MedicamentoRef'] : null,
      });

      print('Appointment: ${data}');
      print('User: ${userSnapshot.data()}');
    }

    print('Total Appointments: ${appointmentDetails.length}');
    return appointmentDetails;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('citas para: ${widget.Nombre}'),
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
          print('APF: ${appointments}');
          var filteredAppointments = appointments.where((appointment) {

            return !appointment.containsKey('MedicamentoRef');
          }).toList();

          if (filteredAppointments.isEmpty) {
            return Center(child: Text('Todas las citas están asignadas.'));
          }

          return ListView.builder(
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              var appointment = filteredAppointments[index];
              var citaId = filteredAppointments[index]['id'];
              var user = filteredAppointments[index]['user'];
              var med;
              if (appointment == null || user == null || citaId == null) {
                return ListTile(
                  title: Text('Cita no disponible'),
                );
              }
              if (appointment['appointment']['MedicamentoRef'] == null){
                med = "Sin medicamento recetado";
              } else {
                med = "Medicina recetada";
              };
              Timestamp timestamp = appointment['appointment']['Fecha'];
              DateTime dateTime = timestamp.toDate();
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

              return ListTile(
                title: Text('Fecha: $formattedDate\nPaciente: ${user['nombre']}'),
                subtitle: Text(med),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        AsignarMedPage(DocId: citaId))
                  );
                  if (result == 'saved') {
                    setState(() {
                    _getAppointmentsWithDetails();
                    });
                    _getAppointmentsWithDetails();
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
      ),
    );
  }
}
