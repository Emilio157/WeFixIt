import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/report_page.dart'; 
import 'package:we_fix_it/ui/widgets/widget_login.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class MyTools extends StatelessWidget {
  const MyTools
({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    Center(child: Text("Herramientas", style: TextStyle(fontSize: 60),))
    ;
  }
}