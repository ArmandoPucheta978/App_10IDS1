import 'package:app_10ids1/CitaPage.dart';
import 'package:app_10ids1/LoginPage.dart';
import 'package:app_10ids1/MenuPacientePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();

}

class _RegisterPageState extends State<RegisterPage> {
  final txtNameController = TextEditingController();
  final txtUserController = TextEditingController();
  final txtPasswordController =TextEditingController();
  //bool BtnVisible(true);
  Future<void> fnLogin() async {
    try{
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: txtUserController.text, password: txtPasswordController.text);
      await FirebaseFirestore.instance.collection('usuarios').add({
        'nombre' : txtNameController.text,
        'correo': txtUserController.text,
        'rol': "Paciente",
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Registrado con éxito',
        text: 'Ya puedes Iniciar sesión.',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: 'Mensaje del sistema',
          text: 'La contraseña es muy débil.',
        );
      } else if (e.code == 'email-already-in-use') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Mensaje del sistema',
          text: 'El correo electrónico ya está en uso.',
        );
      } else if (e.code == 'invalid-email') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Mensaje del sistema',
          text: 'El correo electrónico no es válido.',
        );
      }
    } catch (e) {
      print(e);
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página de Registro"),
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
                decoration: InputDecoration(
                    labelText: "Nombre"
                ),
                controller: txtNameController,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30,10,30,10),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: "Correo Electrónico"
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            }, child: const Text("Ya tienes una cuenta? Iniciar Sesión")
            ),
          ],
        ),
      ),
    );
  }
}