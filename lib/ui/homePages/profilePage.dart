import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MyLogOut extends StatefulWidget {
  const MyLogOut({super.key});

  @override
  State<MyLogOut> createState() => _MyLogOutState();
}

class _MyLogOutState extends State<MyLogOut> {
    Future<String> _getUserName(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['Name'];
      } else {
        return 'No Name Found';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error';
    }
  }
  
  Future<String> _getMail(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['Email'];
      } else {
        return 'No Mail Found';
      }
    } catch (e) {
      print('Error fetching users mail: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user != null ? user.uid : '';
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container( 
              height: 150,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 232, 232, 232),
              ),
              child: Row(
              children: [
                SizedBox(width: 20),
                Icon(Icons.person, size:  90),
                SizedBox(width: 30),
                Column(
                  children: [
                    SizedBox(height: 40),
                    FutureBuilder<String>(
                        future: _getUserName(uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Cargando...');
                          } else if (snapshot.hasError) {
                            return const Text('Error');
                          } else if (!snapshot.hasData || snapshot.data == 'No Name Found') {
                            return const Text('No Name Found');
                          } else {
                            return Text(
                              snapshot.data!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      FutureBuilder<String>(
                        future: _getMail(uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Cargando...');
                          } else if (snapshot.hasError) {
                            return const Text('Error');
                          } else if (!snapshot.hasData || snapshot.data == 'No Mail Found') {
                            return const Text('No Mail Found');
                          } else {
                            return Text(
                              snapshot.data!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                  onPressed: () async{
                    await FirebaseAuth.instance.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.black,
                        shadowColor: Colors.black,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        minimumSize: Size(250, 70), 
                      ),
                  child: const Text("Cerrar Sesión", style: TextStyle(fontSize: 24, color: Colors.white),),
                ),
          ],
        ),
      ),
    );
}
}