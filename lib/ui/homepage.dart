import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:we_fix_it/ui/report_page.dart'; 
import 'package:we_fix_it/ui/widgets/widgetlogin.dart'; 
import 'package:we_fix_it/ui/widgets/widgethome.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 2;
  final pantallas =[
    Center(child: Text("Historial", style: TextStyle(fontSize: 60),)),
    Center(child: Text("DIY", style: TextStyle(fontSize: 60),)),
    MyInicio(),
    Center(child: Text("Herramientas", style: TextStyle(fontSize: 60),)),
    Center(child: Text("Salir", style: TextStyle(fontSize: 60),)),
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
              label: "Salir"),
        ],
      ),
    );
  }
}
class MyInicio extends StatefulWidget {
  const MyInicio({super.key});

  @override
  State<MyInicio> createState() => _MyInicioState();
}

class _MyInicioState extends State<MyInicio> {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: <Widget> [Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(right: 50),
          child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 232, 232, 232),
                  foregroundColor: Colors.black,
                  shadowColor: Colors.black,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  minimumSize: Size(300, 40), 
                ),
                onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyReportPage(title: "Reportar Problema")),
                ),
                child: Text('¡Reportanos un problema!'),
              ),
        ),
      ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyReportPage(title: "Reportar Problema")),
              ), 
              icon: Icon(Icons.email),
              iconSize: 35,
              color: Colors.black,
              ),
          )
          ]
    )
    );
}