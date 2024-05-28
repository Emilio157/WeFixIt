import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:quickalert/quickalert.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({Key? key, required this.onTap});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final nameController = TextEditingController(); 
  bool selectedValue = false; 

  void signUserUp() async {
    try {
      if (passwordController.text == confirmpasswordController.text) {
        bool isContractor = selectedValue;
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        String userId = userCredential.user!.uid;
        Map<String, dynamic> userData = {
          'Email': emailController.text,
          'Name': nameController.text,
          'Contractor': isContractor,
          'UserId': userId,
        };
        try {
          await FirebaseFirestore.instance.collection('Usuarios').doc(userId).set(userData);
        } catch (error) {
          print("Error al guardar datos en firebase: $error");
        }
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('Contraseñas no coinciden'),
              backgroundColor: Colors.white,
              surfaceTintColor: Color.fromARGB(255, 235, 115, 106),
            );
          },
        );
      }
    } on FirebaseAuthException {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error al crear cuenta',
        text: 'Datos ingresados no validos',
      );
    }
  }


  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Ingresa tu correo electrónico",
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
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          height: 60,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.black87,
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
              ),
            ),
          ),
        ),
      ],
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
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          height: 60,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(
              color: Colors.black87,
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
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          height: 60,
          child: TextField(
            controller: confirmpasswordController,
            obscureText: true,
            style: const TextStyle(
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(
                Icons.lock,
                color: Color.fromARGB(255, 160, 160, 160),
              ),
              hintText: "Vuelve a ingresar la contraseña",
              hintStyle: TextStyle(
                color: Colors.black38,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Nombre",
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
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          height: 60,
          child: TextField(
            controller: nameController,
            style: const TextStyle(
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(
                Icons.person,
                color: Color.fromARGB(255, 160, 160, 160),
              ),
              hintText: "Nombre",
              hintStyle: TextStyle(
                color: Colors.black38,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Eres un contractor",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: DropdownButtonFormField<bool>(
            value: selectedValue,
            onChanged: (bool? newValue) {
              setState(() {
                selectedValue = newValue!;
              });
            },
            items: const [
              DropdownMenuItem(
                value: true,
                child: Text("Si"),
              ),
              DropdownMenuItem(
                value: false,
                child: Text("No"),
              ),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSignInBtn() {
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
        onPressed: signUserUp,
        child: const Text(
          "Crear Cuenta",
          style: TextStyle(
            color: Color(0xFFFF0000),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildLogInBtn() {
    return GestureDetector(
      onTap: widget.onTap,
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "¿Ya tienes cuenta? ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: "Ingresa a tu cuenta",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Crear Cuenta",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildName(),
                      const SizedBox(height: 10),
                      buildEmail(),
                      const SizedBox(height: 10),
                      buildPassword(),
                      const SizedBox(height: 10),
                      buildType(),
                      const SizedBox(height: 10),
                      buildSignInBtn(),
                      const SizedBox(height: 10),
                      buildLogInBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
