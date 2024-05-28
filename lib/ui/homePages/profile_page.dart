import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:io';

class MyLogOut extends StatefulWidget {
  const MyLogOut({super.key});

  @override
  State<MyLogOut> createState() => _MyLogOutState();
}

class _MyLogOutState extends State<MyLogOut> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

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

  Future<String> _getProfileImageUrl(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['ProfileImageUrl'];
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching profile image url: $e');
      return '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _imageFile != null) {
      try {
        String fileName = user.uid;
        Reference storageRef = FirebaseStorage.instance.ref().child('/$fileName.jpg');
        UploadTask uploadTask = storageRef.putFile(_imageFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('Usuarios').doc(user.uid).update({'ProfileImageUrl': downloadUrl});
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user != null ? user.uid : '';
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 150,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 232, 232, 232),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: FutureBuilder<String>(
                      future: _getProfileImageUrl(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.person, size: 90);
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Icon(Icons.person, size: 90);
                        } else {
                          return CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
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
                      const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  title: '¿Está segur@ que quiere cerrar sesión?',
                  confirmBtnText: 'Sí',
                  onConfirmBtnTap: _signOut,
                  cancelBtnText: 'No',
                  confirmBtnColor: Colors.red,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
                shadowColor: Colors.black,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(250, 70),
              ),
              child: const Text(
                "Cerrar Sesión",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Aplicación desarrollada por el Equipo 1: ",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const Text("Jorge Daniel Pérez Zapata",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const Text("Jesús Emilio Alvarado Castellanos",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const Text("Samuel Gerardo Amaya García",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const Text("Mariana Cecilia Vaquera Cuellar",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const Text("Julio Derek Briones Torres",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const Text("Andrick Gael Garcia Villarreal",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
