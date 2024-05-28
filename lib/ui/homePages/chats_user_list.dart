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
        body: const Center(
          child: Text('Actualmente no hay un usuario ingresado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Mensajes', style: TextStyle(fontSize: 32),)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('helpRequests')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
                    return const ListTile(
                      title: Text('Cargando...'),
                      subtitle: Text('Cargando...'),
                    );
                  }
                  var employeeData = employeeSnapshot.data!.data() as Map<String, dynamic>?;
                  var employeeName = employeeData != null ? employeeData['Name'] : 'Desconocido';
                  var profileImageUrl = employeeData != null ? employeeData['ProfileImageUrl'] : null;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('userProblems').doc(problemId).get(),
                    builder: (context, problemSnapshot) {
                      if (!problemSnapshot.hasData) {
                        return Card(
                          child: ListTile(
                            title: Text(employeeName),
                            subtitle: const Text('Cargando problema...'),
                          ),
                        );
                      }
                      var problemData = problemSnapshot.data!.data() as Map<String, dynamic>?;
                      var problemName = problemData != null ? problemData['problem'] : 'Desconocido';

                      return Card(
                        shadowColor: Colors.black,
                        color: const Color.fromARGB(255, 253, 95, 84),
                        child: ListTile(
                          leading: profileImageUrl != null && profileImageUrl.isNotEmpty
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(profileImageUrl),
                                )
                              : const Icon(Icons.person, size: 40, color: Colors.white),
                          title: Text(
                            employeeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Problema: $problemName',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
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
                        ),
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
