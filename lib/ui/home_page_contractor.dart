import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_fix_it/ui/contractorHomePages/chats_by_contractor.dart';
import 'package:we_fix_it/ui/contractorHomePages/user_posts_by_contractor.dart';
import 'package:we_fix_it/ui/profile_page.dart';

class HomePageContractor extends StatefulWidget {
  const HomePageContractor({super.key});

  @override
  State<HomePageContractor> createState() => _HomePageContractorState();
}

class _HomePageContractorState extends State<HomePageContractor> {
  int currentIndex = 1;  
  final pantallas = [
    EmployeeChatListScreen(),
    const UserPosts(),
    const MyLogOut(),
  ];

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
      extendBody: true,
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
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        color: Colors.red,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.red,
        height: MediaQuery.of(context).size.height * 0.11,
        items: const [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.chat,
              color: Colors.white,
              size: 40,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.home,
              color: Colors.white,
              size: 40,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
