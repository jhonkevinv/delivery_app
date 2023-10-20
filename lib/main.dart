import 'package:flutter/material.dart';
import 'package:flutter_maps_example/modal/classes.dart';
import 'package:flutter_maps_example/modal/location_search.dart';
import 'package:flutter_maps_example/util/home_example.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:map_launcher/map_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _locationText = 'Seleccionar tu ubicación';
  String? _locationText2 = 'Seleccionar dirección';
  List<GeoPoint> pointsRoadBackup = List<GeoPoint>.generate(
      2, (counter) => GeoPoint(latitude: 0, longitude: 0));
  List listApp = [];
  @override
  void initState() {
    super.initState();
    getApps();
  }

  Future<void> getApps() async {
    final availableMaps = await MapLauncher.installedMaps;
    for (var element in availableMaps) {
      listApp.add(element.mapName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location Picker',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Builder(builder: (context) {
            return Stack(
              children: [
                Positioned.fill(
                    child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.39,
                    child: MainExample(pointsRoadBackup: pointsRoadBackup),
                  ),
                )),
                Positioned.fill(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 3.3,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0)),
                            color: Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      LocationData? locationData =
                                          await LocationSearch.show(
                                              context: context,
                                              lightAdress: false,
                                              countryCodes: ["PE"],
                                              language: "es",
                                              mode: Mode.fullscreen);
                                      if (locationData != null) {
                                        setState(() {
                                          _locationText = locationData.address;
                                          pointsRoadBackup.first = GeoPoint(
                                              latitude: locationData.latitude,
                                              longitude:
                                                  locationData.longitude);
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(left: 5, right: 20),
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          bottom: 20,
                                          top: 20),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            _locationText!,
                                            maxLines: 1,
                                            textAlign: TextAlign.start,
                                          ))
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            (pointsRoadBackup.first.latitude != 0 &&
                                pointsRoadBackup.first.longitude != 0) &&
                                (pointsRoadBackup.last.latitude != 0 &&
                                    pointsRoadBackup.last.longitude != 0)
                                ?SizedBox(
                              height: 10,
                            ):SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      LocationData? locationData =
                                          await LocationSearch.show(
                                              context: context,
                                              language: "es",
                                              countryCodes: ['PE'],
                                              lightAdress: false,
                                              mode: Mode.fullscreen);
                                      if (locationData != null) {
                                        setState(() {
                                          _locationText2 = locationData.address;
                                          pointsRoadBackup.last = GeoPoint(
                                              latitude: locationData.latitude,
                                              longitude:
                                                  locationData.longitude);
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(left: 5, right: 20),
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          bottom: 20,
                                          top: 20),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            _locationText2!,
                                            maxLines: 1,
                                            textAlign: TextAlign.start,
                                          ))
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            (pointsRoadBackup.first.latitude != 0 &&
                                pointsRoadBackup.first.longitude != 0) &&
                                (pointsRoadBackup.last.latitude != 0 &&
                                    pointsRoadBackup.last.longitude != 0)
                                ?Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    listApp.contains('Google Maps')?GestureDetector(
                                      onTap: () async {
                                        await MapLauncher.showDirections(
                                            mapType: MapType.google,
                                            origin: Coords(pointsRoadBackup.first.latitude, pointsRoadBackup.first.longitude),
                                            destination: Coords(pointsRoadBackup.last.latitude, pointsRoadBackup.last.longitude),
                                            directionsMode: DirectionsMode.driving
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            bottom: 10,
                                            top: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                          BorderRadius.circular(10.0),),
                                        child: Text(
                                          'Navegar en Google Maps',
                                          maxLines: 1,
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ):Container(),
                                    listApp.contains('Waze')?GestureDetector(
                                      onTap: () async {
                                        await MapLauncher.showDirections(
                                          mapType: MapType.waze,
                                          origin: Coords(pointsRoadBackup.first.latitude, pointsRoadBackup.first.longitude),
                                          destination: Coords(pointsRoadBackup.last.latitude, pointsRoadBackup.last.longitude),
                                          directionsMode: DirectionsMode.driving
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            bottom: 10,
                                            top: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                          BorderRadius.circular(10.0),),
                                        child: Text(
                                          'Navegar con Waze',
                                          maxLines: 1,
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ):Container(),
                                  ],
                                ),
                              ],
                            ):Container(),
                          ],
                        ),
                      )),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
