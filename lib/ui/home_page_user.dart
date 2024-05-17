import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_fix_it/ui/homePages/diyPage.dart';
import 'package:we_fix_it/ui/homePages/historialPage.dart';
import 'package:we_fix_it/ui/homePages/toolsPage.dart';
import 'package:we_fix_it/ui/homePages/profilePage.dart';
import 'homePages/homePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 2;
  final pantallas = [
    MyHistorial(),
    MyDiy(),
    MyInicio(),
    MyTools(),
    MyLogOut(),
  ];

  List<Map<String, dynamic>> problems = [];

  @override
  void initState() {
    super.initState();
    _getProblems();
  }

  Future<void> _getProblems() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String uid = user.uid;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('userProblems')
          .where('uid', isEqualTo: uid)
          .get();
      setState(() {
        problems = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user != null ? user.uid : '';

    return Scaffold(
      backgroundColor: const Color(0xffF4F0E8),
      appBar: AppBar(
        title: uid.isEmpty
            ? const Text('Perfil')
            : FutureBuilder<String>(
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
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    );
                  }
                },
              ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
            width: double.infinity,
            child: Container(
              color: Colors.red,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: pantallas[currentIndex],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: problems.length,
                    itemBuilder: (context, index) {
                      final problem = problems[index];
                      return ListTile(
                        title: Text(problem['problem']),
                        subtitle: Text(problem['description']),
                        trailing: problem['imageLink'] != null
                            ? Image.network(problem['imageLink'], width: 50, height: 50)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.palette),
            label: "DIY",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: "Herramientas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: "Salir",
          ),
        ],
      ),
    );
  }
}
