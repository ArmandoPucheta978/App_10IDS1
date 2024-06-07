import 'package:app_10ids1/ConsultoriosPage.dart';
import 'package:app_10ids1/DoctoresPage.dart';
import 'package:app_10ids1/HomePage.dart';
import 'package:app_10ids1/MedicamentosPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
//import 'package:http/http.dart' as http;
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  final txtUserController = TextEditingController();
  final txtPasswordController =TextEditingController();
  //bool BtnVisible(true);
  Future<void> fnLogin() async {
    try{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    UserCredential userCredential = await auth.signInWithEmailAndPassword(email: txtUserController.text, password: txtPasswordController.text);
    user = userCredential.user;

    if (user != null){
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicamentosPage()));
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
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
        title: const Text("Login Page"),
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
          ],
        ),
      ),
    );
  }
}