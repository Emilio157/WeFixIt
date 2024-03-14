import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/LoginPage.dart';
import 'package:we_fix_it/ui/report_page.dart';
import 'package:we_fix_it/ui/homepage.dart';
import 'package:we_fix_it/ui/login_or_register_page.dart';

class AuthPage extends StatelessWidget{
    const AuthPage({super.key});
    @override
    Widget build(BuildContext context){
        return Scaffold(
          body:StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot){
              //existe usuario
              if(snapshot.hasData){
                return HomePage(); 
              }
              //no existe el usuario
              else{
                return LoginOrRegisterPage();
              }
            },
          ) ,
        );

    }
}