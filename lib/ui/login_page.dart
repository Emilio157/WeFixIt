import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickalert/quickalert.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;
  const LoginScreen({super.key,required this.onTap});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

  void signUserIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error al iniciar sesión',
        text: 'Credenciales Incorrectas',
      );
    }
  }

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Correo electrónico",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const[
               BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0,2)
              )
            ]
          ),
          height: 60,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.black87
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(
                Icons.email,
                color: Color.fromARGB(255, 160, 160, 160),
              ),
              hintText: "usuario@ejemplo.com",
              hintStyle: TextStyle(
                color: Colors.black38,
              )
            )
          )
        )
      ]
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Contraseña",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const[
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0,2)
              )
            ]
          ),
          height: 60,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(
              color: Colors.black87
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(
                Icons.lock,
                color: Color.fromARGB(255, 160, 160, 160),
              ),
              hintText: "Contraseña",
              hintStyle: TextStyle(
                color: Colors.black38,
              )
            )
          )
        )
      ]
    );
  }

  Widget buildLoginBtn(){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 5,
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          signUserIn(context); 
        },
        child: const Text(
          "Iniciar Sesión",
          style: TextStyle(
            color: Color(0xFFFF0000),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildSignUpBtn() {
    return GestureDetector(
      onTap: widget.onTap ,
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "¿No tienes cuenta? ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500
              ),
            ),
            TextSpan(
              text: "Crear cuenta",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
                )
            )
          ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x33FF0000),
                      Color(0x77FF0000),
                      Color(0xBBFF0000),
                      Color(0xFFFF0000),
                    ]
                  )
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 120
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "WeFixIt", 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      const SizedBox(height: 50),
                      buildEmail(),
                      const SizedBox(height: 20),
                      buildPassword(),
                      buildLoginBtn(),
                      buildSignUpBtn(),
                    ]
                  ),
                ),
              )
            ]
          )
        ),
      )
    );
  }
}