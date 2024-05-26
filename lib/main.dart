import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:we_fix_it/ui/auth_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage()
    );
  }
}
