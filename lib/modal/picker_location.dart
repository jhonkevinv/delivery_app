import 'package:flutter/material.dart';
import 'package:flutter_osm_interface/flutter_osm_interface.dart';
import 'package:flutter_osm_plugin/src/common/osm_option.dart';

import 'package:flutter_osm_plugin/src/controller/map_controller.dart';
import 'package:flutter_osm_plugin/src/osm_flutter.dart';

/// showSimplePickerLocation : picker to select specific position
///
/// [context] : (BuildContext) dialog context parent
///
/// [titleWidget] : (Widget) widget title  of the dialog
///
/// [title] : (String) text title widget of the dialog
///
/// [titleStyle] : (TextStyle) style text title widget of the dialog
///
/// [textConfirmPicker] : (String) text confirm button widget of the dialog
///
/// [textCancelPicker] : (String) text cancel button widget of the dialog
///
/// [radius] : (double) rounded radius of the dialog
///
/// [isDismissible] : (bool) to indicate if tapping out side of dialog will dismiss the dialog
///
/// [initCurrentUserPosition] : (GeoPoint) to indicate initialize position in the map
///
/// [initPosition] : (bool) to initialize the map  in user location
Future<GeoPoint?> showSimplePickerLocation2({
  required BuildContext context,
  Widget? titleWidget,
  String? title,
  TextStyle? titleStyle,
  String? textConfirmPicker,
  String? textCancelPicker,
  EdgeInsets contentPadding = EdgeInsets.zero,
  double radius = 0.0,
  GeoPoint? initPosition,
  ZoomOption zoomOption = const ZoomOption(),
  bool isDismissible = true,
  UserTrackingOption? initCurrentUserPosition,
}) async {
  bool loading = true;
  assert(title == null || titleWidget == null);
  assert(((initCurrentUserPosition != null) && initPosition == null) ||
      ((initCurrentUserPosition == null) && initPosition != null));
  final MapController controller = MapController(
    initMapWithUserPosition: initCurrentUserPosition,
    initPosition: initPosition,
  );
  GeoPoint? point = await showDialog(
    context: context,
    builder: (ctx) {
      return WillPopScope(
        onWillPop: () async {
          return isDismissible;
        },
        child: SizedBox(
            height: MediaQuery.of(context).size.height / 2.4,
            width: MediaQuery.of(context).size.height / 2,
            child: StatefulBuilder(builder: (context, mysetState) {
              return AlertDialog(
                insetPadding: EdgeInsets.zero,
                titlePadding:
                    EdgeInsets.only(right: 10, left: 10, bottom: 20, top: 20),
                title: title != null
                    ? Column(
                        children: [
                          Text(
                            title,
                            style: titleStyle,
                          )
                        ],
                      )
                    : titleWidget,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(radius),
                  ),
                ),
                contentPadding: contentPadding,
                content: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: OSMFlutter(
                    controller: controller,
                    osmOption: OSMOption(
                      zoomOption: zoomOption,
                      markerOption: MarkerOption(advancedPickerMarker: MarkerIcon(icon: Icon(Icons.my_location, size: 80, color: Colors.deepOrange),)),
                      isPicker: true,
                      showZoomController: true,
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
                        loading = false;
                        mysetState(() {});
                      }
                    },
                  ),
                ),
                actions: [
                  loading == false
                      ? TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            textCancelPicker ??
                                MaterialLocalizations.of(context)
                                    .cancelButtonLabel,
                          ),
                        )
                      : Container(),
                  loading == false
                      ? ElevatedButton(
                          onPressed: () async {
                            final p = await controller
                                .getCurrentPositionAdvancedPositionPicker();
                            await controller.cancelAdvancedPositionPicker();
                            Navigator.pop(ctx, p);
                          },
                          child: Text(
                            textConfirmPicker ??
                                MaterialLocalizations.of(context).okButtonLabel,
                          ),
                        )
                      : Container(),
                ],
              );
            })),
      );
    },
  );

  return point;
}
