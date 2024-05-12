import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/home_page_user.dart';
import 'package:we_fix_it/ui/login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); 
          }
          if (snapshot.hasData) {
            return HomePage(); 
          } else {
            return LoginOrRegisterPage(); 
          }
        },
      ),
    );
  }
}
