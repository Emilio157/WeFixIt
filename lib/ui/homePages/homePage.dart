import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/report_page.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class MyInicio extends StatefulWidget {
  const MyInicio({super.key});

  @override
  State<MyInicio> createState() => _MyInicioState();
}

class _MyInicioState extends State<MyInicio> {
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
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: <Widget> [Column(
        children: [
          Align(
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
        ],
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
      ),
      Padding(  
        padding: const EdgeInsets.only(top: 60),
        child: Expanded(
              child: ListView.builder(
                itemCount: problems.length,
                itemBuilder: (context, index) {
                  final problem = problems[index];
                  return ListTile(
                    title: Text(problem['problem'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    subtitle: Text("Fecha límite: " + problem['date'],
                    style: TextStyle(fontSize: 14,),),
                    leading: problem['imageLink'] != null
                        ? Image.network(problem['imageLink'], width: 70, height: 70)
                        : null,
                  );
                },
            ),
            ),
      )
      ],             
    )
  );
}
