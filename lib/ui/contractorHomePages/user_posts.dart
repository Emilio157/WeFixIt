import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: Text('Problemas Reportados'),
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

    if (uid != null && problemId != null) {
      FirebaseFirestore.instance.collection('helpRequests').add({
        'uid': uid,
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
    return Card(
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
      body: Padding(
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
    );
  }
}
