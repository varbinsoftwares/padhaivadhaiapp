import 'package:flutter/material.dart';
import '../core/baseLayout.dart';
import '../core/uiwidget.dart';
import 'package:badges/badges.dart';
import 'package:email_validator/email_validator.dart';
import 'chat2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api.dart';
import 'package:http/http.dart' as http;

class NotificationList extends StatefulWidget {
  @override
  _Notification createState() => _Notification();
}

class _Notification extends State<NotificationList>
    with SingleTickerProviderStateMixin {
  UIWidget uiobj = UIWidget();
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Map userprofile = {};
  bool userloggein = false;
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");

    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        getQueryData(userprofile["id"]);
        userloggein = true;
      } else {
        userloggein = false;
      }
    });
  }

  bool loadingquiries = true;
  List queireslist = [];

  getQueryData(user_id) async {
    setState(() {
      loadingquiries = false;
    });
    var url = "$conf_all_notifications/$user_id";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map querydata = jsonDecode(response.body);
      setState(() {
    
          queireslist = querydata["notification_list"];
    
        loadingquiries = true;
      });
    }
  }

  List colorlist = [
    Color(0xffacddde),
    Color(0xffcaf1de),
    Color(0xffe1f8dc),
    Color(0xfffef8dd),
    Color(0xffffe7c7),
    Color(0xfff7d8ba),
  ];
  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    final double _screenHeightButton = _screenHeight * 8 / 100;
    return BaseLayout(
      innerPage: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            width: 250,
            child: uiobj.mainButton(
                context,
                [Color(0xFF7ccccc), Color(0xFF3d9123)],
                "All Notifictions",
                "assets/icon/magnet_50.png",
                _screenHeightButton, () {
              getQueryData(userprofile["id"]);
            }),
          ),
          userloggein
              ? loadingquiries
                  ? Container(
                      width: double.infinity,
                      height: _screenHeight - (160 + _screenHeightButton * 3),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: new List.generate(
                            queireslist.length,
                            (index) {
                              Map queryobj = queireslist[index];
                              int colorindex = index % 6;
                              var colorcode = colorlist[colorindex];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        topic_id: queryobj["channel_id"],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 10, top: 10, bottom: 10),
                                    // height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),

                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 8,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(

                                                  queryobj["topic"],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                  queryobj["message_body"],
                                                )
                                              ],
                                            )),
                                        Expanded(
                                          flex: 1,
                                          child: Icon(
                                            Icons.keyboard_arrow_right,
                                            // size: 20,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ))
                  : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 50,
                          ),
                          Text("Loading ...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "Quartzo",
                                  color: Colors.black))
                        ],
                      ),
                      height: 200,
                      width: double.infinity,
                    )
              : uiobj.loginCheckBlock(context),
        ],
      ),
    );
  }
}
