import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MainExample extends StatefulWidget {
  MainExample({Key? key, this.pointsRoadBackup}) : super(key: key);
  List<GeoPoint>? pointsRoadBackup;

  @override
  _MainExampleState createState() => _MainExampleState();
}

class _MainExampleState extends State<MainExample>
    with TickerProviderStateMixin {
  late MapController controller;
  late GlobalKey<ScaffoldState> scaffoldKey;
  ValueNotifier<bool> showFab = ValueNotifier(true);
  ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> beginDrawRoad = ValueNotifier(false);
  List<GeoPoint> pointsRoad = [];
  Timer? timer;
  int x = 0;
  String textDistancia = '';
  String textTime = '';
  bool validation = false;
  String? pointsRoadsBack = '[GeoPoint{latitude: 0.0 , longitude: 0.0}, GeoPoint{latitude: 0.0 , longitude: 0.0}]';
  @override
  void initState() {
    super.initState();
    controller = MapController.withPosition(
      initPosition: GeoPoint(
        latitude: -12.063417,
        longitude: -77.146783,
      ),
    );
    scaffoldKey = GlobalKey<ScaffoldState>();
    RoadRute();
  }

  void data() async {
    if (beginDrawRoad.value) {
      await controller.removeMarkers(pointsRoad);
      pointsRoad.clear();
      controller.clearAllRoads();
      textDistancia = '';
      setState(() {});
      for (var i = 0; i < widget.pointsRoadBackup!.length; i++) {
        pointsRoad.add(widget.pointsRoadBackup![i]);
        await controller.addMarker(
          widget.pointsRoadBackup![i],
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.my_location_outlined,
              color: Colors.deepOrange,
              size: 28,
            ),
          ),
        );
      }
      if (pointsRoad.length >= 2 && showFab.value) {
        roadActionBt(context);
      }
    } else {
      lastGeoPoint.value = controller.listenerMapSingleTapping.value;
    }
  }

  @override
  void dispose() {
    if (timer != null && timer!.isActive) {
      timer?.cancel();
    }
    controller.dispose();
    super.dispose();
  }

  RoadRute() {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (validation == false) {
          if ((widget.pointsRoadBackup?.first.latitude != 0 &&
                  widget.pointsRoadBackup?.first.longitude != 0) &&
              (widget.pointsRoadBackup?.last.latitude != 0 &&
                  widget.pointsRoadBackup?.last.longitude != 0)) {
            beginDrawRoad.value = true;
            data();
            pointsRoadsBack = widget.pointsRoadBackup.toString();
            validation = true;
            setState(() {});
          }
        }
        if ((pointsRoadsBack != widget.pointsRoadBackup.toString())) {
          validation = false;
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      floatingActionButton: (widget.pointsRoadBackup?.first.latitude != 0 &&
                  widget.pointsRoadBackup?.first.longitude != 0) &&
              (widget.pointsRoadBackup?.last.latitude != 0 &&
                  widget.pointsRoadBackup?.last.longitude != 0)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                textDistancia != ''
                    ? Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        width: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              textDistancia,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                            Text(
                              textTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            )
                          ],
                        ),
                      )
                    : Container()
              ],
            )
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: OSMFlutter(
        controller: controller,
        osmOption: OSMOption(
          enableRotationByGesture: true,
          zoomOption: ZoomOption(
            initZoom: 8,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          roadConfiguration:
              RoadOption(roadColor: Colors.blueAccent, roadWidth: 10),
          showContributorBadgeForOSM: false,
          showDefaultInfoWindow: false,
        ),
        mapIsLoading: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text("Cargando mapa.."),
            ],
          ),
        ),
        onMapIsReady: (isReady) {
          if (isReady) {
            print("map is ready");
          }
        },
        onLocationChanged: (myLocation) {
          print('user location :$myLocation');
        },
      ),
    );
  }

  void roadActionBt(BuildContext ctx) async {
    try {
      showFab.value = false;
      ValueNotifier<RoadType> notifierRoadType = ValueNotifier(RoadType.car);
      showFab.value = true;
      beginDrawRoad.value = false;
      RoadInfo roadInformation = await controller.drawRoad(
        pointsRoad.first,
        pointsRoad.last,
        roadType: notifierRoadType.value,
        intersectPoint: pointsRoad.getRange(1, pointsRoad.length - 1).toList(),
      );
      textDistancia =
          'Distancia: ${roadInformation.distance?.toStringAsFixed(2)} Km.';
      textTime =
          "Tiempo: ${Duration(seconds: roadInformation.duration!.toInt()).inMinutes} Min.";
      setState(() {});
      debugPrint(
          "app duration:${Duration(seconds: roadInformation.duration!.toInt()).inMinutes}");
      debugPrint("app distance:${roadInformation.distance}Km");
      debugPrint("app road:" + roadInformation.toString());
      try {
        final console = roadInformation.instructions
            .map((e) => e.toString())
            .reduce(
              (value, element) => "$value -> \n $element",
            )
            .toString();
        debugPrint(
          console,
          wrapWidth: console.length,
        );
      } catch (e) {
        print(e);
      }
    } on RoadException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${e.errorMessage()}",
          ),
        ),
      );
    }
  }
}
