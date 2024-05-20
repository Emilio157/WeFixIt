import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
              child: Expanded(
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
                                      Center(
                                        child: Text(
                                          problem['problem'],
                                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                  },
                ),
              ),
            )
          ],
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
