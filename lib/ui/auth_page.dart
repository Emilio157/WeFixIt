import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 // Importa la página del contratista
import 'package:we_fix_it/ui/home_page_user.dart'; // Importa la página del usuario
import 'package:we_fix_it/ui/login_or_register_page.dart';
import 'package:we_fix_it/ui/home_page_contractor.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  Future<bool> isUserContractor(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(uid).get();
    return userDoc['Contractor'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            String uid = snapshot.data!.uid;
            return FutureBuilder<bool>(
              future: isUserContractor(uid),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (asyncSnapshot.hasData) {
                  bool isContractor = asyncSnapshot.data!;
                  return isContractor ? HomePageContractor() : HomePage();
                } else {
                  return LoginOrRegisterPage();
                }
              },
            );
          } else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
