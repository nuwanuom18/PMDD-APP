import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Client.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:wave_progress_widget/wave_progress.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
/*
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(0, 50, 50, 50),
        statusBarColor: Colors.red[300]));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}*/

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int latest_message_number;
  int latest_users;
  bool reload = true;
  List<dynamic> responseList = [];
  DatabaseReference _dRef =
      FirebaseDatabase.instance.reference().child('users');

  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;
  CategoriesScroller categoriesScroller;
  List<Widget> itemsData = [];

/*
  Future getNavData() async {
    DocumentReference documentReference =
        Firestore.instance.collection('data').document('messages');
    await documentReference.get().then((datasnapshot) {
      latest_message_number = datasnapshot['messages'];
    });
    DocumentReference documentReference2 =
        Firestore.instance.collection('data').document('users');
    await documentReference2.get().then((datasnapshot) {
      latest_users = datasnapshot['users'];
    });
    //sleep(const Duration(seconds: 5));
    //print('$latest_message_number, $latest_users');
    return [latest_message_number, latest_users];
  }

  */

  void getPostsData() async {
    //print('running');
    /*
    List<Widget> listItems = [];
    int items_count = 0;
    // latest_message_number = 12;
    while (items_count != 5) {
      if (latest_message_number < 0) {
        break;
      }
      // bool is_exits = await checkExist('message $latest_message_number');
      //  print(is_exits);

      try {
        DocumentReference documentReference = Firestore.instance
            .collection('messages')
            .document('message $latest_message_number');
        await documentReference.get().then((datasnapshot) {
          if (datasnapshot.exists) {
            responseList
                .add({'id': datasnapshot['id'], 'body': datasnapshot['body']});
            latest_message_number = latest_message_number - 1;
            items_count = items_count + 1;
          } else {
            latest_message_number = latest_message_number - 1;
          }
        });
      } catch (e) {
        latest_message_number = latest_message_number - 1;
      }
    }*/
    print('awa');
    List<Widget> listItems = [];
    StreamBuilder(
        stream: _dRef.onValue,
        builder: (context, snapshot) {
          print('Samantha');
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data.snapshot.value != null) {
            print("snapshot data : ${snapshot.data.snapshot.value.toString()}");
            var _dht = Client.formJson(snapshot.data.snapshot.value['Json']);
            print(
                'Client: ${_dht.temp} / ${_dht.heartrate} / ${_dht.humidity}');
            return Center(
              child: Text('NO DATA YET'),
            );
          } else {
            return Center(
              child: Text('NO DATA YET'),
            );
          }
        });

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser user = (await _auth.signInAnonymously()).user;

    _dRef.once().then((DataSnapshot data) {
      print(data.toString());
      print(data.value);
      print(data.key);
    });

    //print(responseList);
    /*
    responseList.forEach((post) {
      listItems.add(Container(
          //height: 150,

          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.blue.withAlpha(100), blurRadius: 10.0),
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
                        post["id"],
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post["body"],
                        style:
                            const TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 10,
                      ), /*
                    Text(
                      "\$ ${post["price"]}",
                      style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )*/
                    ],
                  ),
                ),
              ],
            ),
          )));
    });
    /*
    if (latest_message_number < 0) {
      listItems.add(Text('End of the list'));
    }*/
    setState(() {
      itemsData = listItems;
    });*/
  }

  @override
  void initState() {
    print('init');
    super.initState();
/*
    getNavData().then((value) {
      setState(() {
        latest_message_number = value[0];
        latest_users = value[1];

        categoriesScroller = CategoriesScroller(
            messages: latest_message_number, users: latest_users);
        getPostsData();
      });
    });*/
    getPostsData();

    controller.addListener(() {
      double value = controller.offset / 119;
      if (controller.position.pixels == controller.position.maxScrollExtent &&
          latest_message_number >= 0) {
        print(latest_message_number);

        getPostsData();
      }
      if (controller.position.pixels == 0) {
        if (reload == true) {
          reload = false;
        } else {
          reload = true;
        }
        /*
        if (reload == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }*/
      }

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              backgroundColor: Color.fromRGBO(10, 10, 10, 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              elevation: 24,
              actionsPadding: EdgeInsets.all(30),
              title: new Text(
                'Are you sure?',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              content: Container(
                width: 100,
                height: 100,
                // color: Colors.green,
                //margin: EdgeInsets.all(50),
                child: Center(
                  child: Text(
                    'Do you want to exit?',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text(
                    "NO",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                new GestureDetector(
                  onTap: () => exit(0),
                  child: Text(
                    "YES",
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      /*
      return CupertinoAlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit?'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () => exit(0),
                child: Text("YES"),
              ),
            ],
          ) ??
          false;*/
    }

    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.30;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
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
                  itemBuilder: (context, index) {
                    if (index == itemsData.length) {
                      print(latest_message_number);
                      if (latest_message_number == null ||
                          latest_message_number >= 0) {
                        return Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 20, 40),
                          child: SpinKitSquareCircle(
                            color: Colors.red,
                            size: 50.0,
                          ),
                        );
                      } else {
                        return Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 30),
                          child: Center(
                            child: Text(
                              "no more messages",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    return itemsData[index];
                  },
                  itemCount: itemsData.length + 1,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoriesScroller extends StatelessWidget {
  final int messages, users;

  CategoriesScroller({Key key, @required this.messages, @required this.users})
      : super(key: key);

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
                        "Total\nMessages",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Messages',
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
                height: categoryHeight,
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
                          "User Number",
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
