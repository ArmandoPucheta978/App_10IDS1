import 'package:app_10ids1/MedicamentoPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicamentosPage extends StatefulWidget {
  const MedicamentosPage({super.key});

  @override
  State<MedicamentosPage> createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista Medicamentos"),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('medicamentos').snapshots(),
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
                  subtitle: Text('Existencias: ${doc["existencia"]}'),

                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          MedicamentoPage(DocId: doc.id,
                              Medicamento: doc["nombre"],
                              Codigo: doc["codigo"],
                              Existencias: doc["existencia"],
                              Fecha_cad: doc["fecha_cad"],)),
                    );
                    if (result == 'saved') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                              'Medicamento guardado con éxito'))
                      );
                    } else if (result == 'deleted') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Medicamento eliminado con éxito'))
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
            MaterialPageRoute(builder: (context) => MedicamentoPage()),
          );
          if (result == 'saved') {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Medicamento guardado con éxito'))
            );
          }
        },
      ),
    );
  }
}

