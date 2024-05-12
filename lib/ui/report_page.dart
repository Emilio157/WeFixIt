import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:we_fix_it/ui/widgets/widgetPickImage.dart';
import 'package:we_fix_it/ui/widgets/widgetlogin.dart';

class MyReportPage extends StatefulWidget {
  const MyReportPage({super.key, required this.title});
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

  // void saveReport() async {
  //   String problem = problemController.text;
  //   String description = descriptionController.text;
  //   String date = _date.text;
    
  //   String resp = await StoreData().saveData(problem: problem, description: description, date: date, file: _image!);
  // }

  void selectImage() async{
    Uint8List img = await pickImage(ImageSource.gallery);
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
            fontSize: 20,),),),
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
                // Adjust border, hint text, etc. as needed
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
                // Adjust border, hint text, etc. as needed
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Ingrese el problema',
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
                labelText: "Selecciona una fecha límite"
              ),
              onTap: () async{
                DateTime? pickeddate = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000), 
                  lastDate: DateTime(2101)
                );
                if(pickeddate != null){
                  setState(() {
                    _date.text = DateFormat('yyyy-MM-dd').format(pickeddate);
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
            Text('Metodo de contacto'),
            SizedBox(
              width: 320,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(width: 2), // Adjust border width and color
                  ),
                ),
                value: selectedItem,
                items: items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, style: const TextStyle(fontSize: 18)),
                        ))
                    .toList(),
                onChanged: (item) => setState(() => selectedItem = item),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                //saveReport
              },
              child: Text('Enviar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}