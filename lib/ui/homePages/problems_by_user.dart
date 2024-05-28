import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/report_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyInicio extends StatefulWidget {
  const MyInicio({Key? key});

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
        problems = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['docId'] = doc.id;
          return data;
        }).toList();
      });
    }
  }

  Future<void> _deleteProblem(String docId, String uid) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid == uid) {
      try {
        await FirebaseFirestore.instance.collection('userProblems').doc(docId).delete();
        await _getProblems();
      } catch (e) {
        print("Error deleting problem: $e");
      }
    } else {
      print("No se tiene acceso para eliminar este problema");
    }
  }

 Future<void> _showContractors(BuildContext context) async {
  try {
    QuerySnapshot contractorsSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .where('Contractor', isEqualTo: true)
        .get();
    
    List<Map<String, dynamic>> contractors = contractorsSnapshot.docs.map((doc) {
      return {
        'uid': doc.id,
        'name': doc['Name'], 
      };
    }).toList();

    // Show dialog to display contractors
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contratistas'),
        content: SingleChildScrollView(
          child: Column(
            children: contractors.map((contractor) {
              return ListTile(
                title: Text(contractor['name']),
                onTap: () {
                  _showProblems(context, contractor);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  } catch (e) {
    print('Error getting contractors: $e');
  }
}

Future<void> _showProblems(BuildContext context, Map<String, dynamic> contractor) async {
  try {
    QuerySnapshot problemsSnapshot = await FirebaseFirestore.instance
        .collection('userProblems')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    
    List<Map<String, dynamic>> problems = problemsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id;
      return data;
    }).toList();

    // Show dialog to display problems
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Problemas'),
        content: SingleChildScrollView(
          child: Column(
            children: problems.map((problem) {
              return ListTile(
                title: Text(problem['problem']),
                onTap: () {
                  _sendHelpRequest(context, contractor, problem);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  } catch (e) {
    print('Error getting problems: $e');
  }
}

  void _sendHelpRequest(BuildContext context, Map<String, dynamic> contractor, Map<String, dynamic> problem) {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final String? problemId = problem['docId'];
  final String? employeeUid = contractor['uid'];

  if (uid != null && problemId != null && employeeUid != null) {
    FirebaseFirestore.instance.collection('helpRequests')
      .where('userId', isEqualTo: uid)
      .where('employeeId', isEqualTo: employeeUid)
      .where('problemId', isEqualTo: problemId)
      .get()
      .then((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          FirebaseFirestore.instance.collection('helpRequests').add({
            'userId': uid,
            'employeeId': employeeUid,
            'problemId': problemId,
          }).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Solicitud de ayuda enviada')),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: No se pudo enviar la solicitud de ayuda')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ya has enviado una solicitud de ayuda para este problema con este contratista.')),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se pudo verificar la existencia de solicitudes previas')),
        );
      });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: No se pudo enviar la solicitud de ayuda')),
    );
  }
}


  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: <Widget>[
        Column(
          children: [
            SizedBox(height: 8),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    minimumSize: Size(300, 40),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyReportPage(title: "Reportar Problema")),
                  ),
                  child: Text(
                    '¡Crea un reporte de problema!',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyReportPage(title: "Reportar Problema")),
            ),
            icon: Icon(Icons.email),
            iconSize: 35,
            color: Colors.red,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: problems.length,
            itemBuilder: (context, index) {
              final problem = problems[index];
              return GestureDetector(
                onTap: () => _navigateToDetailPage(context, problem),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: problem['imageLink'] != null ? Image.network(
                          problem['imageLink'],
                          height: 300,
                          width: 300,
                        ) : Container(height: 300, width: 300, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    problem['problem'],
                                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Fecha límite: " + problem['date'],
                                  style: TextStyle(fontSize: 18),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _showContractors(context);
                            },
                            icon: Icon(Icons.help_outline),
                            color: Colors.blue,
                          ),

                          IconButton(
                            onPressed: () => _deleteProblem(problem['docId'], problem['uid']),
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        await  _showContractors(context);
;
      },
      label: Text('Solicitar ayuda'),
      icon: Icon(Icons.help),
      backgroundColor: Colors.red,
    ),
  );

  void _navigateToDetailPage(BuildContext context, Map<String, dynamic> problem) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(problem: problem)),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> problem;

  const DetailPage({Key? key, required this.problem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(problem['problem']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              problem['imageLink'] != null
                  ? Image.network(problem['imageLink'])
                  : Container(),
              SizedBox(height: 16),
              Text(
                problem['problem'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Fecha límite: " + problem['date'],
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                problem['description'] ?? 'No description available.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
