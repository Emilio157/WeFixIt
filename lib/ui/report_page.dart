import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:we_fix_it/ui/widgets/add_Data.dart';
import 'package:we_fix_it/ui/widgets/widgetPickImage.dart';
import 'package:we_fix_it/ui/widgets/widgetlogin.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _image;
  final TextEditingController problemController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  TextEditingController _date = TextEditingController();
  List<String> items = ['Orientacion', 'Presencialmente'];
  String? selectedItem = 'Orientacion';

  void saveReport() async {
    String problem = problemController.text;
    String description = descriptionController.text;
    String date = _date.text;
    
    String resp = await StoreData().saveData(problem: problem, description: description, date: date, file: _image!);
  }

  @override
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
            const Text(
              'Reporte de problema',
               
            ),
            const SizedBox(height: 20),
            Text('Problema'),
            TextField(
              controller: problemController,
            ),
            const SizedBox(height: 20),
            Text('Descripción del problema'),
            TextField(
              minLines: 1,
              maxLines: 10,
              decoration: InputDecoration(border: OutlineInputBorder()),
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
              onPressed: () {
                selectImage(); 
              },
              child: Row(
                children: [
                  Icon(Icons.add_a_photo),
                  Text('Selecciona una Imagen'),
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
                    borderSide: BorderSide(width: 3, color: Colors.blue),
                  ),
                ),
              value: selectedItem,
              items: items
                .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 18)),
                ))
                .toList(),
              onChanged: (item) => setState(() => selectedItem = item),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
