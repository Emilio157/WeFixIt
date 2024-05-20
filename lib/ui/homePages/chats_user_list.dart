import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_fix_it/ui/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chats'),
        ),
        body: Center(
          child: Text('No user is currently logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('helpRequests')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var helpRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: helpRequests.length,
            itemBuilder: (context, index) {
              var request = helpRequests[index];
              var employeeId = request['employeeId'];
              var problemId = request['problemId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Usuarios').doc(employeeId).get(),
                builder: (context, employeeSnapshot) {
                  if (!employeeSnapshot.hasData) {
                    return ListTile(
                      title: Text('Cargando...'),
                      subtitle: Text('Cargando...'),
                    );
                  }
                  var employeeData = employeeSnapshot.data!.data() as Map<String, dynamic>?;
                  var employeeName = employeeData != null ? employeeData['Name'] : 'Desconocido';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('userProblems').doc(problemId).get(),
                    builder: (context, problemSnapshot) {
                      if (!problemSnapshot.hasData) {
                        return ListTile(
                          title: Text(employeeName),
                          subtitle: Text('Cargando problema...'),
                        );
                      }
                      var problemData = problemSnapshot.data!.data() as Map<String, dynamic>?;
                      var problemName = problemData != null ? problemData['problem'] : 'Desconocido';

                      return ListTile(
                        title: Text(employeeName),
                        subtitle: Text('Problema: $problemName'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatUserScreen(
                                receiverId: employeeId,
                                problemId: problemId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
