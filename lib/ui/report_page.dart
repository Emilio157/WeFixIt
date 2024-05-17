import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_fix_it/ui/widgets/widgetPickImage.dart';
import 'package:we_fix_it/ui/widgets/widgetlogin.dart';

class MyReportPage extends StatefulWidget {
  const MyReportPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyReportPage> createState() => _MyReportPageState();
}

class _MyReportPageState extends State<MyReportPage> {
  Uint8List? _image;
  bool _imageSelected = false;
  final TextEditingController problemController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TextEditingController _date = TextEditingController();
  List<String> items = ['Orientacion', 'Presencialmente'];
  String? selectedItem = 'Orientacion';

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  Future<void> saveReport() async {
    try {
      final String? uid = await getUserUid();
      if (uid == null) {
        throw Exception('No se pudo recuperar el UID del usuario.');
      }

      if (_image != null && problemController.text.isNotEmpty && descriptionController.text.isNotEmpty && _date.text.isNotEmpty) {
        // Subir imagen a Firebase Storage
        final String imageUrl = await uploadImageToStorage('problemImage', _image!);

        // Guardar datos en Firebase Firestore
        await _firestore.collection('userProblems').add({
          'uid': uid,
          'problem': problemController.text,
          'description': descriptionController.text,
          'imageLink': imageUrl,
          'date': _date.text,
        });

        // Limpiar campos después de enviar el reporte
        setState(() {
          _image = null;
          _imageSelected = false;
          problemController.clear();
          descriptionController.clear();
          _date.clear();
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reporte enviado con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor complete todos los campos y seleccione una imagen')),
        );
      }
    } catch (error) {
      print('Error al enviar el reporte: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error al enviar el reporte')),
      );
    }
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    try {
      final Reference ref = _storage.ref().child(childName);
      final UploadTask uploadTask = ref.putData(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print("Error al subir la imagen: $error");
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        action: TextButton(
          onPressed: null,
          child: Text(
            "Usuario",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: [
                SizedBox(width: 10),
                Text(
                  'Reporte de problema',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Problema'),
            TextField(
              controller: problemController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Ingrese el problema',
              ),
            ),
            const SizedBox(height: 20),
            Text('Descripción del problema'),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Ingrese la descripción del problema',
              ),
              minLines: 1,
              maxLines: 10,
              controller: descriptionController,
            ),
            const SizedBox(height: 20),
            Text('Fecha Límite'),
            TextField(
              controller: _date,
              decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today_rounded),
                labelText: "Selecciona una fecha límite",
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _date.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                Uint8List? image = await pickImage(ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _image = image;
                    _imageSelected = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  _imageSelected
                      ? Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.add_a_photo),
                  const SizedBox(width: 10),
                  _imageSelected ? Text('Imagen adjuntada') : Text('Seleccionar Imagen'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text('Método de contacto'),
            SizedBox(
              width: 320,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(width: 2),
                  ),
                ),
                value: selectedItem,
                items: items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: const TextStyle(fontSize: 18)),
                      ),
                    )
                    .toList(),
                onChanged: (item) => setState(() => selectedItem = item),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                saveReport();
              },
              child: Text('Enviar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}
