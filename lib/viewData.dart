import 'package:flutter/material.dart';
import 'Client.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pmdd_app/test.dart';

class ViewData extends StatefulWidget {
  final Client client;

  const ViewData({Key key, this.client}) : super(key: key);
  @override
  _ViewDataState createState() => _ViewDataState();
}

class _ViewDataState extends State<ViewData> {
  bool dataLoaded = true;
  DatabaseReference _dRef =
      FirebaseDatabase.instance.reference().child('userdata');

  @override
  Widget build(BuildContext context) {
    setState(() {});

    return dataLoaded ? _chartsScaffold() : _waitScaffold();
  }

  Widget _waitScaffold() {
    return SpinKitSquareCircle(
      color: Colors.red,
      size: 50.0,
    );
  }

  Widget _chartsScaffold() {
    Future<bool> _onBackPressed() {
      Navigator.pop(context);
    }

    return WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: Scaffold(
          body: StreamBuilder(
              stream: _dRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    !snapshot.hasError &&
                    snapshot.data.snapshot.value != null) {
                  print(
                      "snapshot data : ${snapshot.data.snapshot.value.toString()}");
                  // users = snapshot.data.snapshot.value['count'];
                  var names = ['Temperature', 'Heart rate', 'SpO2 value'];

                  List<Points> data_temp = [];
                  List<Points> data_hrate = [];
                  List<Points> data_humidity = [];
                  var snap = snapshot.data.snapshot
                      .value[widget.client.name.round().toString()];
                  print(snap);
                  var keys = snap.keys.toList();
                  print(keys);
                  var start = 0;
                  for (int j = 0; j < keys.length; j++) {
                    start = 0;
                    for (int i = 0; i < snap[keys[j]].length; i++) {
                      if (snap[keys[j]][i] != null && snap[keys[j]][i] is int) {
                        if (keys[j] == 'temp') {
                          data_temp.add(Points(start, snap[keys[j]][i]));
                          start = start + 1;
                        }
                        if (keys[j] == 'heartrate') {
                          data_hrate.add(Points(start, snap[keys[j]][i]));
                          start = start + 1;
                        }
                        if (keys[j] == 'humidity') {
                          data_humidity.add(Points(start, snap[keys[j]][i]));
                          start = start + 1;
                        }
                      }
                    }
                  }

                  return Container(
                      // margin: EdgeInsets.only(top: 50),
                      child: SingleChildScrollView(
                          child: Container(
                              margin: EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    'Data of last 14 days',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(names[0],
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                      child: SizedBox(
                                    width: 850,
                                    height: 300,
                                    child: PointsLineChart(
                                      _createSampleData(data_temp),
                                      animate: true,
                                    ),
                                  )),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Text(names[1],
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                      child: SizedBox(
                                    width: 850,
                                    height: 300,
                                    child: PointsLineChart(
                                      _createSampleData(data_hrate),
                                      animate: true,
                                    ),
                                  )),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Text(names[2],
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                      child: SizedBox(
                                    width: 850,
                                    height: 300,
                                    child: PointsLineChart(
                                      _createSampleData(data_humidity),
                                      animate: true,
                                    ),
                                  )),
                                  SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ))));
                } else {
                  return SpinKitThreeBounce(
                    color: Colors.blue,
                    size: 50.0,
                  );
                }
              }),
        ));
  }
}

List<charts.Series<Points, int>> _createSampleData(List<Points> data) {
  return [
    new charts.Series<Points, int>(
      id: 'Sales',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (Points sales, _) => sales._x,
      measureFn: (Points sales, _) => sales._y,
      data: data,
    )
  ];
}

class PointsLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  PointsLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.

  @override
  Widget build(BuildContext context) {
    return Container(
        child: charts.LineChart(seriesList,
            animate: animate,
            defaultRenderer:
                new charts.LineRendererConfig(includePoints: true)));
  }

  /// Create one series with sample hard coded data.

}

class Points {
  final int _x;
  final int _y;

  Points(this._x, this._y);
}
