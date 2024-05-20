import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_fix_it/ui/chat_screen.dart';

class EmployeeChatListScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chats del Empleado'),
        ),
        body: Center(
          child: Text('No user is currently logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats del Empleado'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('helpRequests')
            .where('employeeId', isEqualTo: user!.uid)
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
              var userId = request['userId'];
              var problemId = request['problemId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Usuarios').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Cargando...'),
                      subtitle: Text('Cargando...'),
                    );
                  }
                  var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  var userName = userData != null ? userData['Name'] : 'Desconocido';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('userProblems').doc(problemId).get(),
                    builder: (context, problemSnapshot) {
                      if (!problemSnapshot.hasData) {
                        return ListTile(
                          title: Text(userName),
                          subtitle: Text('Cargando problema...'),
                        );
                      }
                      var problemData = problemSnapshot.data!.data() as Map<String, dynamic>?;
                      var problemName = problemData != null ? problemData['problem'] : 'Desconocido';

                      return ListTile(
                        title: Text(userName),
                        subtitle: Text('Problema: $problemName'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatUserScreen(
                                receiverId: userId,
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

