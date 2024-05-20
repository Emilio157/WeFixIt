import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPosts extends StatefulWidget {
  const UserPosts({Key? key}) : super(key: key);

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
        title: Center(child: Text('Problemas Reportados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),)),
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
    FirebaseFirestore.instance.collection('helpRequests').add({
      'userId': uid,
      'employeeId': employeeUid, 
      'problemId': problemId,
      'requestTime': FieldValue.serverTimestamp(),
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
      SnackBar(content: Text('Error: No se pudo enviar la solicitud de ayuda')),
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
            child: Image.network(
              problem['imageLink'],
                height: 300,
                width: 300,
              ),
            ),
            SizedBox(height: 10),
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
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              iconSize: 26,
                              icon: Icon(Icons.help_outline),
                              onPressed: () => _sendHelpRequest(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                        Text("Fecha límite: " +
                          problem['date'],
                          style: TextStyle(fontSize: 18),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: 8),
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

  const DetailPage({Key? key, required this.problem}) : super(key: key);
  void _sendHelpRequest(BuildContext context) {
  final String? uid = problem['uid'];
  final String? problemId = problem['docId'];
  final String? employeeUid = FirebaseAuth.instance.currentUser?.uid; 

  if (uid != null && problemId != null && employeeUid != null) {
    FirebaseFirestore.instance.collection('helpRequests').add({
      'userId': uid,
      'employeeId': employeeUid, 
      'problemId': problemId,
      'requestTime': FieldValue.serverTimestamp(),
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
      SnackBar(content: Text('Error: No se pudo enviar la solicitud de ayuda')),
    );
  }
}

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
              const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  color: Color.fromARGB(255, 255, 103, 92),
                  thickness: 5,),
              ),
              Row(
                children: [
                  const Text(
                    "Contactar para proporcionar ayuda: ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    iconSize: 26,
                    icon: Icon(Icons.help_outline),
                    onPressed: () => _sendHelpRequest(context),
                  ),
                ],
              ),
              const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  color: Color.fromARGB(255, 255, 103, 92),
                  thickness: 5,),
              ),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Descripción del problema: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: 350,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 219, 219, 219),
              ),
                child: Text(
                  problem['description'] ?? 'No description available.',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






//Lista antigua de visualizacion
/* Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        title: Text(
          problem['problem'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Fecha límite: " + problem['date'],
          style: TextStyle(fontSize: 14),
        ),
        leading: problem['imageLink'] != null
            ? Image.network(problem['imageLink'], width: 70, height: 70, fit: BoxFit.cover)
            : null,
        trailing: IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () => _sendHelpRequest(context),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(problem: problem),
            ),
          );
        },
      ),
    ); */