import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';  
import 'package:we_fix_it/ui/widgets/widgetlogin.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key,required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // methodo de ingreso WIP
  void signUserIn() async{
    showDialog(context: context, builder: (context){
      return const Center(
        child: CircularProgressIndicator(),
      );
    },);
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
      email:emailController.text,
      password: passwordController.text, 
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch(e){
      Navigator.pop(context);
      showDialog(context: context, builder: (context){
      return const AlertDialog(
        title: Text('Credenciales incorrectas'),
      );
    });
    }
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F0E8),
      appBar: const MyAppBar(
        action: TextButton(
          onPressed: null,
           child: Text(
          "Inicio Sesión usuario",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,),),),
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          child:  Container(
            decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),)
                ]
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.gavel_rounded,
                      size: 100,
                    ),
                
                    const SizedBox(height: 50),
                
                    const Text(
                      'Inicia Sesión con tu correo y contraseña para acceder',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                
                
                    const SizedBox(height: 25),
                
                    const Align(
                      alignment: Alignment.centerLeft,
                      child:Text(
                        '       Correo electrónico',
                        style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,)
                      ),
                    ),
                    MyTextField(
                      controller: emailController,
                      hintText: 'Ingresa tu correo electrónico',
                      obscureText: false,
                    ),
                
                    const SizedBox(height: 10),
                
                    const Align(
                      alignment: Alignment.centerLeft,
                      child:Text(
                          '       Contraseña',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,)
                      ),
                    ),
                
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Ingresa tu contraseña',
                      obscureText: true,
                    ),
                
                    const SizedBox(height: 10),
                
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Olvide mi contraseña',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                
                    const SizedBox(height: 25),
                
                    MyButtonSignIn(
                      text:"INICIAR SESION",
                      onTap: signUserIn,
                    ),
                
                    const SizedBox(height: 25),
                    const Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,),
                    ),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap:widget.onTap ,
                          child: const Text(
                            'Crear cuenta',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}