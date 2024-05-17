import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/homePages/diyPage.dart';
import 'package:we_fix_it/ui/homePages/historialPage.dart';
import 'package:we_fix_it/ui/homePages/toolsPage.dart';
import 'package:we_fix_it/ui/widgets/widgetlogin.dart'; 
import 'package:we_fix_it/ui/homePages/profilePage.dart';
import 'package:we_fix_it/ui/homePages/homePage.dart';
import 'package:we_fix_it/ui/homePages/historialPage.dart';
import 'package:we_fix_it/ui/homePages/toolsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 2;
  final pantallas =[
    MyHistorial(),
    MyDiy(),
    MyInicio(),
    MyTools(),
    MyLogOut(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F0E8),
      appBar: const MyAppBar(
        action: TextButton(
          onPressed: null,
          child: Text(
            "Perfil",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,),),),
      ),
      body: pantallas[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        unselectedItemColor: Colors.black,
        iconSize: 40,
        selectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const[
          BottomNavigationBarItem(
              icon: Icon(Icons.history),
              //backgroundColor: Colors.red,
              label: "Historial"),
          BottomNavigationBarItem(
              icon: Icon(Icons.palette),
              //backgroundColor: Colors.red,
              label: "DIY"),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              //backgroundColor: Colors.red,
              label: "Inicio"),
          BottomNavigationBarItem(
              icon: Icon(Icons.build),
              //backgroundColor: Colors.red,
              label: "Herramientas"),
          BottomNavigationBarItem(
              icon: Icon(Icons.exit_to_app),
              //backgroundColor: Colors.red,
              label: "Salir",),
        ],
      ),
    );
  }
}