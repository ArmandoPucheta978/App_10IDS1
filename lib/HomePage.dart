import 'package:app_10ids1/EspecialidadesPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista especialidades"),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('especialidades').snapshots(),
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
                  title: Text(doc["nombre"]),
                  //subtitle: Text(doc["nombre medico"]),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EspecialidadesPage(docId: doc.id, Nombre: doc["nombre"])),
                    );
                    if (result == 'saved') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Especialidad guardada con éxito'))
                      );
                    } else if (result == 'deleted') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Especialidad eliminada con éxito'))
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
            MaterialPageRoute(builder: (context) => EspecialidadesPage()),
          );
          if (result == 'saved') {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Especialidad guardada con éxito'))
            );
          }
        },
      ),
    );
  }
}
