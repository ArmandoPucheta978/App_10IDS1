import 'package:app_10ids1/DoctorPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class DoctoresPage extends StatefulWidget {
  const DoctoresPage({super.key});

  @override
  State<DoctoresPage> createState() => _MuseosPageState();
}

class _MuseosPageState extends State<DoctoresPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista Doctores"),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('doctores').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Ha ocurrido un error"));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Sin registros"));
            }

            List<DocumentSnapshot> docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot doc = docs[index];

                return ListTile(
                  leading: const Icon(Icons.business),
                  title: Text(doc["Nombre"]),
                  subtitle: Text(doc["Matricula"]),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          DoctorPage(docId: doc.id,
                              Nombre: doc["Nombre"],
                              Matricula: doc["Matricula"])),
                    );
                    if (result == 'saved') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                              'Doctor guardado con éxito'))
                      );
                    } else if (result == 'deleted') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Doctor eliminado con éxito'))
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorPage()),
          );
          if (result == 'saved') {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Doctor guardado con éxito'))
            );
          }
        },
      ),
    );
  }
}
