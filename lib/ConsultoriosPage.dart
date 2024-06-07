import 'package:app_10ids1/ConsultorioPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultoriosPage extends StatefulWidget {
  const ConsultoriosPage({super.key});

  @override
  State<ConsultoriosPage> createState() => _ConsultoriosPageState();
}

class _ConsultoriosPageState extends State<ConsultoriosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista Consultorios"),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('consultorios')
              .snapshots(),
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
                  title: Text(doc["consultorio"]),

                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          ConsultorioPage(DocId: doc.id,
                              Consultorio: doc["consultorio"])),
                    );
                    if (result == 'saved') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                              'Consultorio guardado con éxito'))
                      );
                    } else if (result == 'deleted') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Consultorio eliminado con éxito'))
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
            MaterialPageRoute(builder: (context) => ConsultorioPage()),
          );
          if (result == 'saved') {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Consultorio guardado con éxito'))
            );
          }
        },
      ),
    );
  }
}
