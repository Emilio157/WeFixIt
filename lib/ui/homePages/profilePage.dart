import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyLogOut extends StatefulWidget {
  const MyLogOut({super.key});

  @override
  State<MyLogOut> createState() => _MyLogOutState();
}

class _MyLogOutState extends State<MyLogOut> {
  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(
        child: Container( 
          height: 200,
          width: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromARGB(255, 232, 232, 232),
          ),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Text("¿Esta seguro que desea cerrar sesión?", style: TextStyle(fontSize: 18),),

              const SizedBox(height: 25),

              ElevatedButton(
              onPressed: () async{
                await FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 254, 182, 15),
                    foregroundColor: Colors.black,
                    shadowColor: Colors.black,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    minimumSize: Size(250, 70), 
                  ),
              child: const Text("Cerrar Sesión", style: TextStyle(fontSize: 24),),
            ),
            ]          
          ),
        ),
      ),
    );
}