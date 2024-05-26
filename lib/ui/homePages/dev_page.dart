import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHardwareStoreScreen extends StatefulWidget {
  const AddHardwareStoreScreen({Key? key}) : super(key: key);

  @override
  _AddHardwareStoreScreenState createState() => _AddHardwareStoreScreenState();
}

class _AddHardwareStoreScreenState extends State<AddHardwareStoreScreen> {
  String name = '';
  String direccion = '';
  String link = '';
  double latitud = 0.0;
  double longitud = 0.0;
  Map<String, bool> tools = {
    'Martillo': false,
    'Cinta_Métrica': false,
    'Destornillador': false,
    'Bruñidora': false,
    'Esmeriladoras': false,
    'Mazo': false,
    'Barreta_hexagonal': false,
    'Remachadora': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onChanged: (value) => name = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Dirección'),
                onChanged: (value) => direccion = value,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Enlace'),
                onChanged: (value) => link = value,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Latitud'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => latitud = double.tryParse(value) ?? 0.0,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Longitud'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => longitud = double.tryParse(value) ?? 0.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Herramientas Disponibles:'),
              SizedBox(height: 10),
              Container(
                height: 120, // Adjust the height as needed
                child: ListView(
                  shrinkWrap: true,
                  children: tools.entries.map((entry) => CheckboxListTile(
                    title: Row(
                      children: [
                        Text(entry.key),
                        Spacer(),
                        if (entry.value) Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        tools[entry.key] = value!;
                      });
                    },
                  )).toList(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (name.isNotEmpty && direccion.isNotEmpty && link.isNotEmpty) {
                    FirebaseFirestore.instance.collection('ferreterias').add({
                      'Nombre': name,
                      'Direccion': direccion,
                      'link': link,
                      'latitud': latitud,
                      'longitud': longitud,
                      ...tools,
                    }).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ferretería agregada')));
                      setState(() {
                        name = '';
                        direccion = '';
                        link = '';
                        latitud = 0.0;
                        longitud = 0.0;
                        tools.forEach((key, value) {
                          tools[key] = false;
                        });
                      });
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor, ingresa todos los campos')));
                  }
                },
                child: Text('Agregar Ferretería'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
