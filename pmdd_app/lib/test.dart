import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Client.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:wave_progress_widget/wave_progress.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'viewData.dart';

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int tabIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _dRef =
      FirebaseDatabase.instance.reference().child('users');

  bool _signIn;
  String heatIndexText;
  Timer _timer;
  bool closeTopContainer = false;
  double topContainer = 0;
  ScrollController controller = ScrollController();
  _CategoriesScroller categoriesScroller;
  int users;
  List clients;
  List filtered_clients;
  int l1 = 0;
  int l2 = 0;
  static String sortby;

  Future loadData() async {
    int _users = (await FirebaseDatabase.instance
            .reference()
            .child("users/count")
            .once())
        .value;

    List _clients = [];
    print(_users.toString() + 'gfghfgh');
    for (int i = 1; i <= _users; i++) {
      _clients.add(Client.formJson(
          (await FirebaseDatabase.instance.reference().child("users").once())
              .value[i.toString()]));
    }
    return [_users, _clients];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _signIn = false;
    heatIndexText = 'Show heat index soon';
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_signIn) {
        setState(() {});
      }
    });

    loadData().then((value) {
      setState(() {
        categoriesScroller = _CategoriesScroller(users: value[0]);
        users = value[0];
        clients = value[1];
      });
    });
    print(users);
    filtered_clients = [];
    controller.addListener(() {
      double value = controller.offset / 119;
      if (controller.position.pixels == controller.position.maxScrollExtent) {}

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _signIn ? mainScaffold() : signInScaffold();
  }

  Widget mainScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text('PMDD APPLLICATION'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (int index) {
            setState(() {
              tabIndex = index;
            });
          },
          tabs: [
            Tab(
              icon: Icon(
                MaterialCommunityIcons.book_open,
              ),
            ),
            Tab(
              icon: Icon(MaterialCommunityIcons.search_web),
            )
          ],
        ),
      ),
      body: StreamBuilder(
          stream: _dRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                !snapshot.hasError &&
                snapshot.data.snapshot.value != null) {
              print(
                  "snapshot data : ${snapshot.data.snapshot.value.toString()}");
              // users = snapshot.data.snapshot.value['count'];
              print(users);

              users = snapshot.data.snapshot.value.length - 1;
              var list = new List(users);
              for (int i = 1; i <= users; i++) {
                print('$i');
                list[i - 1] =
                    Client.formJson(snapshot.data.snapshot.value[i.toString()]);
              }
              filtered_clients = list + [];
              var _dht = Client.formJson(snapshot.data.snapshot.value['1']);
              print(
                  'Client: ${_dht.temp} / ${_dht.heartrate} / ${_dht.humidity}');

              var l = {};
              var _values = [];
              if (sortby != null) {
                for (int i = 0; i < list.length; i++) {
                  if (sortby == 'temperature') {
                    l[list[i].temp] = list[i];
                    _values.add(list[i].temp);
                  } else if (sortby == 'heartrate') {
                    l[list[i].heartrate] = list[i];
                    _values.add(list[i].heartrate);
                  } else if (sortby == 'humidity') {
                    l[list[i].humidity] = list[i];
                    _values.add(list[i].humidity);
                  }
                }

                _values.sort();
                _values = _values.reversed.toList();
                for (int i = 0; i < _values.length; i++) {
                  list[i] = l[_values[i]];
                }
              }
              return IndexedStack(
                index: tabIndex,
                children: [_temperatureLayout(list), _humidityLayout(list)],
              );
            } else {
              return SpinKitSquareCircle(
                color: Colors.red,
                size: 50.0,
              );
            }
          }),
    );
  }

  Widget _temperatureLayout(List list) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.30;
    return SafeArea(
      child: Scaffold(
        //backgroundColor: Colors.white,
        body: Container(
          height: size.height,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: closeTopContainer ? 0 : 1,
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: size.width,
                    alignment: Alignment.topCenter,
                    height: closeTopContainer ? 0 : categoryHeight,
                    child: categoriesScroller),
              ),
              Expanded(
                  child: ListView.builder(
                controller: controller,
                physics: BouncingScrollPhysics(),
                itemCount: users,
                itemBuilder: (context, index) {
                  return Container(
                      //height: 150,

                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      //margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blue.withAlpha(100),
                                blurRadius: 10.0),
                          ]),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Device ID : " +
                                        list[index].name.toInt().toString(),
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Temperature : " +
                                              list[index].temp.toString(),
                                          style: const TextStyle(
                                              fontSize: 17, color: Colors.grey),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            child: FAProgressBar(
                                              progressColor: Colors.green,
                                              direction: Axis.horizontal,
                                              verticalDirection:
                                                  VerticalDirection.up,
                                              size: 20,
                                              currentValue:
                                                  list[index].temp.round(),
                                              changeColorValue: 99,
                                              changeProgressColor: Colors.red,
                                              maxValue: 150,
                                              displayText: '°F ',
                                              borderRadius: 16,
                                              animatedDuration:
                                                  Duration(milliseconds: 500),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Heart Rate : " +
                                              list[index].heartrate.toString(),
                                          style: const TextStyle(
                                              fontSize: 17, color: Colors.grey),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            child: FAProgressBar(
                                              progressColor: Colors.orange,
                                              direction: Axis.horizontal,
                                              verticalDirection:
                                                  VerticalDirection.up,
                                              size: 20,
                                              currentValue:
                                                  list[index].heartrate.round(),
                                              changeColorValue: 100,
                                              changeProgressColor: Colors.red,
                                              maxValue: 150,
                                              displayText: 'bpm ',
                                              borderRadius: 16,
                                              animatedDuration:
                                                  Duration(milliseconds: 500),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Humidity : " +
                                              list[index].humidity.toString(),
                                          style: const TextStyle(
                                              fontSize: 17, color: Colors.grey),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            child: FAProgressBar(
                                              progressColor: Colors.blue,
                                              direction: Axis.horizontal,
                                              verticalDirection:
                                                  VerticalDirection.up,
                                              size: 20,
                                              currentValue:
                                                  list[index].humidity.round(),
                                              changeColorValue: 75,
                                              changeProgressColor: Colors.red,
                                              maxValue: 100,
                                              displayText: '%',
                                              borderRadius: 16,
                                              animatedDuration:
                                                  Duration(milliseconds: 500),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  /*
                                  Text(
                                    "Device ID : " +
                                        list[index].name.toInt().toString(),
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Temperature : " +
                                        list[index].temp.toString(),
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.grey),
                                  ),
                                  Text(
                                    "Humidity : " +
                                        list[index].humidity.toString(),
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.grey),
                                  ),
                                  Text(
                                    "Heart Rate : " +
                                        list[index].heartrate.toString(),
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.grey),
                                  ),*/
                                  SizedBox(
                                    height: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              )),
            ],
          ),
        ),
      ),
    );
    /*
    return Center(
        child: Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'TEMPERATURE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: FAProgressBar(
              progressColor: Colors.green,
              direction: Axis.vertical,
              verticalDirection: VerticalDirection.up,
              size: 100,
              currentValue: _dht.temp.round(),
              changeColorValue: 100,
              changeProgressColor: Colors.red,
              maxValue: 150,
              displayText: '°F',
              borderRadius: 16,
              animatedDuration: Duration(milliseconds: 500),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 40),
          child: Text(
            '${_dht.temp.toStringAsFixed(2)} °F',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
        )
      ],
    ));*/
  }

  Widget _humidityLayout(List list) {
    print(clients.length.toString() + 'jjjj');

    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              hintText: 'Enter device id'),
          onChanged: (string) {
            print('dd' + string + 'gg');

            if (l2 > string.length) {
              clients = filtered_clients + [];
            }
            setState(() {
              for (int i = 0; i < clients.length; i++) {
                if (!clients[i].name.round().toString().contains(string) &&
                    string != null &&
                    string != '') {
                  clients.remove(clients[i]);
                }
              }
            });
            print(filtered_clients);
            l2 = string.length;
          },
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: clients.length,
            itemBuilder: (BuildContext context, int index) {
              Client x;
              for (int i = 0; i < filtered_clients.length; i++) {
                if (clients[index].name == filtered_clients[i].name) {
                  x = filtered_clients[i];
                }
              }
              return Card(
                  child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          // filtered_clients[clients.indexOf(clients[index])]
                          'Device ID : ' + x.name.round().toString(),
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        RaisedButton(
                          color: Colors.red,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.red)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewData(
                                        client: x,
                                      )),
                            );
                          },
                          child: Text(
                            "view data",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      // filtered_clients[clients.indexOf(clients[index])]
                      'Temperature : ' + x.temp.toString(),
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      // filtered_clients[clients.indexOf(clients[index])]
                      'Heart rate : ' + x.heartrate.toString(),
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      // filtered_clients[clients.indexOf(clients[index])]
                      'Humidity : ' + x.humidity.toString(),
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                    ),
                  ],
                ),
              ));
            },
          ),
        )
      ],
    );
  }

  _setMarqueeText(Client _dht) {
    heatIndexText = "Heat Index : ${_dht.heartrate.toStringAsFixed(2)} °F";
  }

  Widget signInScaffold() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PMDD FLUTTER APP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 50,
            ),
            RaisedButton(
              color: Colors.red,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.red)),
              onPressed: () async {
                _signInAnonymously();
              },
              child: Text(
                "sign in",
                style: TextStyle(fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _signInAnonymously() async {
    final FirebaseUser user = (await _auth.signInAnonymously()).user;
    print("User is anonymous : ${user.isAnonymous}");
    print("user id: ${user.uid}");
    setState(() {
      if (user != null) {
        _signIn = true;
      } else {}
    });
  }
}

class _CategoriesScroller extends StatefulWidget {
  final int users;
  _CategoriesScroller({Key key, @required this.users}) : super(key: key);
  @override
  CategoriesScroller createState() => CategoriesScroller();
}

class CategoriesScroller extends State<_CategoriesScroller>
    with SingleTickerProviderStateMixin {
  int colored;
  bool changeButtonColor(int num) {
    print(colored);
    print(num);
    print('//////////////////////////////////');
    if (colored == null) {
      colored = num;
      return true;
    } else {
      if (colored == num) {
        return false;
      } else {
        colored = num;
        return true;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    colored = -1;
  }

  @override
  Widget build(BuildContext context) {
    print('scroll bar');
    final double categoryHeight =
        MediaQuery.of(context).size.height * 0.30 - 50;
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
          child: Row(
            children: <Widget>[
              Container(
                width: 150,
                margin: EdgeInsets.only(right: 20),
                height: categoryHeight,
                decoration: BoxDecoration(
                    color: Colors.orange.shade400,
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Total\nUsers",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.users.toString(),
                        //getmessages(),
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 150,
                margin: EdgeInsets.only(right: 20),
                height: categoryHeight + 40,
                decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Sort by",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        RaisedButton(
                          color: colored != 0 ? Colors.red : Colors.red[900],
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.red)),
                          onPressed: () {
                            _TestAppState.sortby = "temperature";
                            changeButtonColor(0);
                            setState(() {});
                          },
                          child: Text(
                            "temperature",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        RaisedButton(
                          color: colored != 1 ? Colors.red : Colors.red[900],
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.red)),
                          onPressed: () {
                            _TestAppState.sortby = "heartrate";
                            colored = 1;
                            setState(() {});
                          },
                          child: Text(
                            "heartrate",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        RaisedButton(
                          color: colored != 2 ? Colors.red : Colors.red[900],
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.red)),
                          onPressed: () {
                            _TestAppState.sortby = "humidity";
                            colored = 2;
                            setState(() {});
                          },
                          child: Text(
                            "humidity",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 150,
                margin: EdgeInsets.only(right: 20),
                height: categoryHeight,
                decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.shade400,
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Another\nNote",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "sample",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
