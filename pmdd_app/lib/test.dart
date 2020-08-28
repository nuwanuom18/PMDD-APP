import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Client.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int tabIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _dRef =
      FirebaseDatabase.instance.reference().child('RandomVal2');
  bool _signIn;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _signIn = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
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
              icon: Icon(Icons.ac_unit),
            ),
            Tab(
              icon: Icon(Icons.accessibility_new),
            )
          ],
        ),
      ),
      body: StreamBuilder(
          stream: _dRef.onValue,
          builder: (context, snapshot) {
            print('Samantha');
            if (snapshot.hasData &&
                !snapshot.hasError &&
                snapshot.data.snapshot.value != null) {
              print(
                  "snapshot data : ${snapshot.data.snapshot.value.toString()}");
              var _dht = Client.formJson(snapshot.data.snapshot.value['Json']);
              print(
                  'Client: ${_dht.temp} / ${_dht.heartrate} / ${_dht.humidity}');
              return IndexedStack(
                index: tabIndex,
                children: [_temperatureLayout(_dht), _humidityLayout(_dht)],
              );
            } else {
              return Center(
                child: Text('NO DATA YET'),
              );
            }
          }),
    );
  }

  Widget _temperatureLayout(Client _dht) {
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
              displayText: 'F',
              borderRadius: 16,
              animatedDuration: Duration(milliseconds: 500),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 40),
          child: Text(
            '${_dht.temp.round().toStringAsFixed(2)} F',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
        )
      ],
    ));
  }

  Widget _humidityLayout(Client _dht) {
    return Center(
      child: Text('Humidity'),
    );
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
