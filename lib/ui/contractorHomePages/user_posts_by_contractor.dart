import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPosts extends StatefulWidget {
  const UserPosts({super.key});

  @override
  State<UserPosts> createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  List<Map<String, dynamic>> problems = [];

  @override
  void initState() {
    super.initState();
    _getProblems();
  }

  Future<void> _getProblems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('userProblems').get();
    setState(() {
      problems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Problemas Reportados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),)),
      ),
      body: ListView.builder(
        itemCount: problems.length,
        itemBuilder: (context, index) {
          final problem = problems[index];
          return PostCard(problem: problem);
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> problem;

  const PostCard({Key? key, required this.problem}) : super(key: key);

  void _sendHelpRequest(BuildContext context) {
  final String? uid = problem['uid'];
  final String? problemId = problem['docId'];
  final String? employeeUid = FirebaseAuth.instance.currentUser?.uid;

  if (uid != null && problemId != null && employeeUid != null) {
    final query = FirebaseFirestore.instance
      .collection('helpRequests')
      .where('userId', isEqualTo: uid)
      .where('employeeId', isEqualTo: employeeUid)
      .where('problemId', isEqualTo: problemId)
      .limit(1);

    query.get().then((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        FirebaseFirestore.instance.collection('helpRequests').add({
          'userId': uid,
          'employeeId': employeeUid,
          'problemId': problemId,
          'requestTime': FieldValue.serverTimestamp(),
        }).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitud de ayuda enviada')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se pudo enviar la solicitud de ayuda')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Ya existe una solicitud de ayuda para este problema')),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo verificar la solicitud de ayuda existente')),
      );
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Datos incompletos para enviar la solicitud de ayuda')),
    );
  }
}
  
    void _navigateToDetailWorkPage(BuildContext context, Map<String, dynamic> problem) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(problem: problem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetailWorkPage(context, problem),
      child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              problem['imageLink'],
                height: 300,
                width: 300,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 250,
                            child: Text(
                                problem['problem'],
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              iconSize: 26,
                              icon: const Icon(Icons.help_outline),
                              onPressed: () => _sendHelpRequest(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                        Text("Fecha límite: " +
                          problem['date'],
                          style: const TextStyle(fontSize: 18),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );

  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> problem;

  const DetailPage({super.key, required this.problem});
  Future<void> _sendHelpRequest(BuildContext context) async {
  final String? uid = problem['uid'];
  final String? problemId = problem['docId'];
  final String? employeeUid = FirebaseAuth.instance.currentUser?.uid; 

  if (uid != null && problemId != null && employeeUid != null) {
  bool isDuplicate = await checkDuplicateRequest(uid, employeeUid, problemId);
  if (!isDuplicate) {
    FirebaseFirestore.instance.collection('helpRequests').add({
      'userId': uid,
      'employeeId': employeeUid, 
      'problemId': problemId,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud de ayuda enviada')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo enviar la solicitud de ayuda')),
      );
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Ya existe una solicitud con estos datos')),
    );
  }
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Error: No se pudo enviar la solicitud de ayuda')),
  );
}

}
Future<bool> checkDuplicateRequest(String userId, String employeeId, String problemId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('helpRequests')
        .where('userId', isEqualTo: userId)
        .where('employeeId', isEqualTo: employeeId)
        .where('problemId', isEqualTo: problemId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  } catch (error) {
    print('Error al verificar duplicado: $error');
    return false;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(problem['problem']),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: problem['imageLink'] != null
                        ? Image.network(problem['imageLink'],
                        height: 300,
                        width: 300,)
                        : Container(),
                  ),
                  const SizedBox(height: 8),
                  const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(
                      color: Color.fromARGB(255, 255, 103, 92),
                      thickness: 5,),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Problema: ",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    problem['problem'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(
                      color: Color.fromARGB(255, 255, 103, 92),
                      thickness: 5,),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Fecha límite del problema : ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    problem['date'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descripción del problema: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 350,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 219, 219, 219),
                  ),
                    child: Text(
                      problem['description'] ?? 'No description available.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () => _sendHelpRequest(context),
        label:const Text("Proporcionar ayuda",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        icon:const Icon(Icons.help_outline,
        color: Colors.white,),
      ),
    );
  }
}