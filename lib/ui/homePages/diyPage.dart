import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MyDiy extends StatefulWidget {
  const MyDiy({super.key});

  @override
  _MyDiyState createState() => _MyDiyState();
}

class _MyDiyState extends State<MyDiy> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? uid;

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  void _loadUid() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  void _deleteProject(String projectId) async {
    try {
      await _firestore.collection('diyProjects').doc(projectId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto eliminado exitosamente')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el proyecto: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DIY Projects",
        style: TextStyle(fontWeight: FontWeight.bold,),),
      ),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('diyProjects').where('uid', isEqualTo: uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No projects found.'));
                }

                final projects = snapshot.data!.docs;

                return /* ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ListTile(
                      leading: Image.network(project['imageLink']),
                      title: Text(project['name']),
                      subtitle: Text(project['date']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProject(project.id),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailScreen(project: project),
                        ),
                      ),
                    );
                  },
                ); */
                ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailScreen(project: project),
                        ),
                      ),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    project['imageLink'],
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project['name'],
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        project['date'],
                                        style: TextStyle(fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 24,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _deleteProject(project.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Proyecto ' + project['name'] + ' fue elminiado'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                  );
              },
            );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddProjectScreen(uid: uid)),
        ),
        child: const Icon(Icons.add,
        color: Colors.white,),
      ),
    );
  }
}

class ProjectDetailScreen extends StatelessWidget {
  final DocumentSnapshot project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        title: Text(project['name'],
        style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold),),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              color: Colors.red,
              thickness: 15,),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.network(project['imageLink'],
              height: 300,
              width: 300,)),
            const SizedBox(height: 10),
            const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                color: Color.fromARGB(255, 255, 103, 92),
                thickness: 5,),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                project['name'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                color: Color.fromARGB(255, 255, 103, 92),
                thickness: 5,),
            ),
            const SizedBox(height: 8),
            Text('Fecha del proyecto: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            Text('${project['date']}', style: TextStyle(fontSize: 16),),
            const SizedBox(height: 8),
            Text('Descripción: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            Text(project['description'], style: TextStyle(fontSize: 16),),
          ],
        ),
      ),
    );
  }
}

class AddProjectScreen extends StatefulWidget {
  final String? uid;

  const AddProjectScreen({super.key, required this.uid});

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  Uint8List? _image;
  bool _imageSelected = false;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveProject() async {
    if (_image != null &&
        nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        _dateController.text.isNotEmpty) {
      try {
        final String imageUrl = await _uploadImageToStorage('projectImages', _image!);
        await _firestore.collection('diyProjects').add({
          'uid': widget.uid,
          'name': nameController.text,
          'description': descriptionController.text,
          'date': _dateController.text,
          'imageLink': imageUrl,
        });

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el proyecto: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos y seleccione una imagen')),
      );
    }
  }

  Future<String> _uploadImageToStorage(String childName, Uint8List file) async {
    try {
      final Reference ref = _storage.ref().child(childName);
      final UploadTask uploadTask = ref.putData(file);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (error) {
      throw error;
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _image = imageBytes;
        _imageSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        title: const Text('Add DIY Project',
        style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold),),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              color: Colors.red,
              thickness: 15,),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nombre del Proyecto',
            style: TextStyle(fontSize: 17)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese el nombre del proyecto',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Descripción del Proyecto',
            style: TextStyle(fontSize: 17)),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese la descripción del proyecto',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              const Text('Fecha',
            style: TextStyle(fontSize: 17)),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Selecciona una fecha',
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
                onPressed: _selectImage,
                child: Row(
                  children: [
                    _imageSelected ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.add_a_photo),
                    const SizedBox(width: 8),
                    _imageSelected ? const Text('Imagen seleccionada') : const Text('Seleccionar Imagen'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.red),
                  ),
                  onPressed: _saveProject,
                  child: const Text('Guardar Proyecto', 
                  style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
