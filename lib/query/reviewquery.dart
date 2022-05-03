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

class ListQuery extends StatefulWidget {
  @override
  _ListQueryState createState() => _ListQueryState();
}

class _ListQueryState extends State<ListQuery>
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
    var url = "$conf_listqueryapi/$user_id";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map querydata = jsonDecode(response.body);
      setState(() {
        if (querydata["status"] == "100") {
          queireslist = querydata["query_list"];
        } else {}
        loadingquiries = true;
      });
    }
  }

  openChatPage(chat_id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          topic_id: chat_id,
        ),
      ),
    );
    _loadUserInfo();
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
            width: 200,
            child: uiobj.mainButton(
                context,
                [Color(0xFF7fd6d0), Color(0xFF3d9690)],
                "Review \nQuery",
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
                                  openChatPage(queryobj["id"]);
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
                                    // height: 100,
                                    decoration: BoxDecoration(
                                      color: colorcode,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),

                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            width: 75,
                                            height: 75,
                                            margin: EdgeInsets.all(5),
                                            child: FadeInImage(
                                              image: NetworkImage(
                                                  queryobj["image"]),
                                              placeholder:
                                                  AssetImage("assets/logo.png"),
                                              imageErrorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                    'assets/logo.png',
                                                    fit: BoxFit.fitWidth);
                                              },
                                              fit: BoxFit.fitWidth,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                            flex: 6,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(queryobj["topic"],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                  queryobj["description"],
                                                )
                                              ],
                                            )),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                              child: queryobj["unseen"] == "0"
                                                  ? SizedBox(width: 0)
                                                  : Badge(
                                                      badgeContent: Text(
                                                        queryobj["unseen"],
                                                      ),
                                                      child: Icon(
                                                        Icons.message,
                                                        // size: 20,
                                                      ),
                                                    )),
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
                          Text("Loading Queries...",
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
