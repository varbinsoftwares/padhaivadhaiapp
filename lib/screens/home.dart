import 'package:flutter/material.dart';
import '../core/baseLayout.dart';
import '../core/uiwidget.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';
import 'package:flutter/foundation.dart';
import '../query/chat.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  UIWidget uiobj = UIWidget();

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  @override
  void initState() {
    super.initState();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    _requestPermissions();
    // _loadUserInfo();
    Firebase.initializeApp().then((value) {
      _loadUserInfo();
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message);
      }
    });
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    FirebaseMessaging.onMessage.listen(setNotificationCount);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  setNotificationCount(RemoteMessage message) {
    if (userprofile != null) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        Map messagedata = message.data;
        if (messagedata != null) {
          if (message.data.containsKey("channel_id")) {
            if (ModalRoute.of(context)!.settings.name.toString() == '/') {
              _showNotification(
                  notification.title.toString(), "New Chat Message");
            }
          }
        }
      }

      getAllNotification(userprofile['id']);
    }
  }

  _handleMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    _loadUserInfo();
    if (notification != null && android != null && !kIsWeb) {
      Map messagedata = message.data;
      if (messagedata != null) {
        if (message.data.containsKey("channel_id")) {
          print("current path is" +
              ModalRoute.of(context)!.settings.name.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                topic_id: messagedata["channel_id"],
              ),
            ),
          );
        }
      }
    }
  }

  void _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("profile").then((value) => _loadUserInfo());
    setState(() {
      userprofile = {};
    });
  }

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  Map userprofile = {};
  bool userloggein = false;
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");
    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        getAllNotification(userprofile['id']);
        userloggein = true;
        getFCMToken(userprofile['id']);
      } else {
        userloggein = false;
      }
    });
  }

  String notification_count = "0";

  getAllNotification(user_id) async {
    var url = "$conf_all_notifications/$user_id";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map notificationbody = jsonDecode(response.body);
      print(notificationbody);
      setState(() {
        if (notificationbody.containsKey("notification_count")) {
          notification_count = notificationbody["notification_count"];
        }
      });
    }
  }

  getFCMToken(userid) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging
        .getToken(
      vapidKey:
          "BF_w-Win7CUuCDsiqWy736PoDYiU1ZjyNoZelEEj3O_nbIMyUbxVBh5LznTAvjBMJpdMpj4g7ykKbpbBc87y4PA",
    )
        .then((token) async {
      Map jsonData = {"user_id": userid.toString(), "token_id": token};
      print(jsonData);
      var response = await http.post(
        Uri.parse(conf_fcmtoken),
        body: jsonData,
      );
      print(response.body);
    });
  }

  messageDialog(context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () => Future.value(false),
              child: AlertDialog(
                title: Text("YOUR PROFILE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontFamily: "Quartzo",
                        color: Colors.black)),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.logout),
                    label: Text("Logout"),
                    onPressed: () {
                      _handleLogout();
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
                content: SingleChildScrollView(
                  child: Container(
                      child: Column(
                    children: [
                      Divider(
                        thickness: 5,
                        color: Colors.orange,
                      ),
                      ListTile(
                        title: Text("NAME",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Quartzo",
                                color: Colors.black)),
                        subtitle: Text(userprofile['name'],
                            style:
                                TextStyle(fontSize: 15, color: Colors.black)),
                      ),
                      ListTile(
                        title: Text("MOBILE No.",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Quartzo",
                                color: Colors.black)),
                        subtitle: Text(userprofile['mobile_no'],
                            style:
                                TextStyle(fontSize: 15, color: Colors.black)),
                      ),
                      ListTile(
                        title: Text("EMAIL ID",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Quartzo",
                                color: Colors.black)),
                        subtitle: Text(userprofile['username'],
                            style:
                                TextStyle(fontSize: 15, color: Colors.black)),
                      ),
                      Divider(),
                      Text("USE THESE DETAILS TO \nLOGIN OUR WEB PANEL",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Quartzo",
                              color: Colors.black)),
                    ],
                  )),
                ),
              ));
        });
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(""),
      content: Container(
        height: 300,
        child: Column(
          children: [
            Text(
                """Ask your Queries, notes, e-books, projects guidance and other services. Visit our Content Platform -Book Bird's View for Free Content""",
                style: TextStyle(
                    fontSize: 25, fontFamily: "Quartzo", color: Colors.black)),
            Divider(
              height: 30,
            ),
            Text(
                """Please Note, We are Answering Science Subject Related queries only upto class 10th""",
                style: TextStyle(fontSize: 20, color: Colors.black)),
          ],
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  openAskQueyPage() async {
    var checkpage = await Navigator.pushNamed(context, "listquery");

    _loadUserInfo();
  }

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    final double _screenHeightButton = _screenHeight * 8 / 100;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            userloggein ? Icons.account_circle : Icons.lock,
            color: Colors.black,
            size: 50,
          ),
          onPressed: () {
            //  _handleLogout();
            userloggein
                ? messageDialog(context)
                : Navigator.pushNamed(context, "login");
          },
        ),
        title: Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 270,
                // color: Colors.grey,
              ),
              Container(
                height: 150,
                color: Color(0xFFf2a350),
              ),
              Container(
                margin: EdgeInsets.only(top: 70, left: 0, right: 0),
                height: 160,
                padding: EdgeInsets.all(0),
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/wave.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Positioned(
                right: 50,
                top: -20,
                child: Container(
                  margin: EdgeInsets.only(top: 50),
                  height: 160,
                  child: Center(
                      child: Image.asset(
                    "assets/logo.png",
                    height: 180,
                  )),
                ),
              ),
              Positioned(
                left: 10,
                top: 130,
                child: Badge(
                  // elevation: 5,
                  padding: EdgeInsets.all(5),
                  animationType: BadgeAnimationType.scale,
                  badgeContent: Text(
                    notification_count,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, "notificationlist");
                      },
                      child: Icon(
                        Icons.notifications,
                        size: 60,
                      )),
                ),
              ),
              Positioned(
                right: -5,
                top: 170,
                child: Container(
                  height: 110,
                  width: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/sharebutton.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await Share.share(
                          'Ask your Queries, notes, e-books, projects guidance and other services \nhttps://play.google.com/store/apps/details?id=com.srvapps.padhaivadhai&hl=en&gl=US');
                    },
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: 180,
                child: IconButton(
                  icon: Icon(
                    Icons.help,
                    size: 60,
                    color: Color(0xFF171560),
                  ),
                  onPressed: () {
                    showAlertDialog(context);
                  },
                ),
              ),
            ],
          ),
          Container(
            height: _screenHeight - 400,
            child: Row(
              children: [
                Expanded(
                    flex: 7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        uiobj.mainButton(
                            context,
                            [Color(0xFFffce81), Color(0xFFe57433)],
                            "Ask \nQuery",
                            "assets/icon/query_50.png",
                            _screenHeightButton, () {
                          Navigator.pushNamed(context, "askquery");
                        }),
                        uiobj.mainButton(
                            context,
                            [Color(0xFF7fd6d0), Color(0xFF3d9690)],
                            "Review \nQuery",
                            "assets/icon/magnet_50.png",
                            _screenHeightButton, () {
                          openAskQueyPage();
                        }),
                        uiobj.mainButton(
                            context,
                            [Color(0xFFea8bad), Color(0xFFa138a1)],
                            "About \nPV App",
                            "assets/icon/microscope_50.png",
                            _screenHeightButton, () {
                          _launchURL("http://padhaivadhai.com/apppage.html");
                        }),
                        uiobj.mainButton(
                            context,
                            [Color(0xFFa6afe8), Color(0xFF4d59a5)],
                            "Visit \nWebsite",
                            "assets/icon/lab_50.png",
                            _screenHeightButton, () {
                          _launchURL("https://padhaivadhai.com");
                        }),
                      ],
                    )),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        // height: 80,
                        child: Center(
                            child: Image.asset(
                          "assets/brain.png",
                          height: 80,
                        )),
                      ),
                      Container(
                          child: Column(children: [
                        InkWell(
                          child: Container(
                            margin: EdgeInsets.only(top: 50),
                            // height: 80,
                            child: Center(
                                child: Image.asset(
                              "assets/icon/youtube.png",
                              height: 80,
                              width: 80,
                            )),
                          ),
                          onTap: () {
                            _launchURL(
                                "https://www.youtube.com/channel/UCzpgfFkScBskUciMZR4Xjcg");
                          },
                        ),
                        InkWell(
                          child: Container(
                            margin: EdgeInsets.only(top: 30),
                            // height: 80,
                            child: Center(
                                child: Image.asset(
                              "assets/icon/facebook.png",
                              height: 80,
                              width: 80,
                            )),
                          ),
                          onTap: () => _launchURL(
                              "https://www.facebook.com/PadhaiVadhai"),
                        ),
                      ])),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      persistentFooterButtons: <Widget>[
        InkWell(
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/footerimage.jpg"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          onTap: () => _launchURL("https://bookbirdsview.com/"),
        )
      ],
    );
  }
}
