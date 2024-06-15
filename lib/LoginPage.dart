import 'package:app_10ids1/CitaPage.dart';
import 'package:app_10ids1/MenuAdministradorPage.dart';
import 'package:app_10ids1/MenuDoctorPage.dart';
import 'package:app_10ids1/MenuPacientePage.dart';
import 'package:app_10ids1/RegisterPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  final txtUserController = TextEditingController();
  final txtPasswordController =TextEditingController();
  Future<void> fnLogin() async {
    try{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    DocumentSnapshot? doc;

    UserCredential userCredential = await auth.signInWithEmailAndPassword(email: txtUserController.text, password: txtPasswordController.text);
    user = userCredential.user;

    if (user != null){
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('usuarios').where('correo', isEqualTo: txtUserController.text).get();
      doc = querySnapshot.docs.first;
      var docId = doc.id;
      var data = doc?.data() as Map<String, dynamic>?; // Convertir a Map<String, dynamic>
      var rol = data != null && data.containsKey('rol') ? data['rol'] : 'Paciente';
      var nombre = data != null && data.containsKey('rol') ? data['rol'] : 'Paciente';
      if (rol == "Paciente"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPacientePage(DocId:docId, Rol: rol, Nombre: nombre)));
      } else if (rol == "Doctor"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => MenuDoctorPage(DocId:docId, Rol: rol, Nombre: nombre)));
      } else if (rol == "Administrador") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MenuAdministradorPage(DocId:docId, Rol: rol, Nombre: nombre)));
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Mensaje del sistema',
          text: 'Error con el rol',
        );
      }
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Mensaje del sistema',
        text: 'Datos Incorrectos',
      );
    }
  } catch (e){
      print('error: ${e.toString()}');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Mensaje del sistema',
        text: 'Datos Incorrectos',
      );
  }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página de inicio de sesión"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/user.png',
              width: 100,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30,10,30,10),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: "Usuario"
                ),
                controller: txtUserController,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30,10,30,10),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Contraseña"

                ),
                controller: txtPasswordController,
              ),
            ),
            ElevatedButton(onPressed:() async{
              fnLogin();
            },
                child: const Text("accesar")),
            TextButton(onPressed:() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
            }, child: const Text("No tienes una cuenta? Registrarse"))
          ],
        ),
      ),

    );
  }
}