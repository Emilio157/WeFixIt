import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/report_page.dart'; 

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
                child: Text('¡Reportanos un problema!', style: TextStyle(fontSize: 20),),
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
