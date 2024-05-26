import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoiam9yZ2UxMjNkYW4iLCJhIjoiY2x3ZW12MGlqMW1laTJqbmlnazdmYm1rZSJ9.AaTUOIwiNbfCexj2AKngSQ';

class MyTools extends StatefulWidget {
  const MyTools({Key? key}) : super(key: key);

  @override
  State<MyTools> createState() => _MyToolsState();
}

class _MyToolsState extends State<MyTools> {
  LatLng? myPosition;
  List<Marker> hardwareStoreMarkers = [];
  bool searching = false;
  bool showMap = false;
  String selectedTool = 'Martillo'; // Valor inicial del dropdown

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    try {
      Position position = await determinePosition();
      if (!mounted) return;
      setState(() {
        myPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Manejo de errores si es necesario
    }
  }

  Future<void> getHardwareStoresWithTool(String tool) async {
    setState(() {
      searching = true;
      hardwareStoreMarkers.clear();
    });

    FirebaseFirestore.instance
        .collection('ferreterias')
        .where(tool, isEqualTo: true)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        double lat = result['latitud'];
        double lon = result['longitud'];
        String name = result['Nombre'];
        String address = result['Direccion'];
        String link = result['link'];
        LatLng location = LatLng(lat, lon);
        setState(() {
          hardwareStoreMarkers.add(
            Marker(
              point: location,
              builder: (context) => GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Ferretería'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nombre: $name'),
                            SizedBox(height: 10),
                            Text('Dirección: $address'),
                            SizedBox(height: 10),
                            Text('Enlace: $link'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cerrar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _launchURL(link);
                            },
                            child: Text('Ir al enlace'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  child: const Icon(
                    Icons.store,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ),
          );
        });
      });

      if (mounted) {
        setState(() {
          searching = false;
          showMap = true;
        });
      }
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Buscar Ferreterías'),
        backgroundColor: Colors.red,
      ),
      body: showMap
          ? FlutterMap(
              options: MapOptions(
                center: myPosition,
                minZoom: 5,
                maxZoom: 25,
                zoom: 18,
              ),
              nonRotatedChildren: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: const {
                    'accessToken': MAPBOX_ACCESS_TOKEN,
                    'id': 'mapbox/streets-v12',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: myPosition!,
                      builder: (context) {
                        return Container(
                          child: const Icon(
                            Icons.person_pin,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        );
                      },
                    ),
                    ...hardwareStoreMarkers,
                  ],
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: selectedTool,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTool = newValue!;
                        getHardwareStoresWithTool(selectedTool);
                      });
                    },
                    items: <String>[
                      'Martillo',
                      'Cinta Métrica',
                      'Destornillador',
                      'Bruñidora',
                      'Esmeriladoras',
                      'Mazo',
                      'Barreta hexagonal',
                      'Remachadora'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  searching
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => getHardwareStoresWithTool(selectedTool),
                          child: Text('Buscar'),
                        ),
                ],
              ),
            ),
    );
  }
}
