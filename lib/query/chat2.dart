import 'dart:async';
import 'dart:io';
import '../core/uiwidget.dart';
import '../core/baseLayout.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class ChatPage extends StatefulWidget {
  final String topic_id;
  ChatPage({required this.topic_id});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    FirebaseMessaging.onMessage.listen(setNotificationChatMessage);
  }

  setNotificationChatMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      Map messagedata = message.data;
      if (messagedata != null) {
        if (message.data.containsKey("channel_id")) {
          print(message.notification?.body);
          getQueryChatData(userprofile["id"]);
        }
      }
    }
  }

  ChatUser senderUser = ChatUser(
    firstName: 'Pankaj',
    id: "4",
    profileImage: "https://ui-avatars.com/api/?name=John+Doe",
  );

  Map userprofile = {};
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");
    if (this.mounted) {
      setState(() {
        if (userprofiletemp.isNotEmpty) {
          userprofile = jsonDecode(userprofiletemp);
          senderUser = ChatUser(
            firstName: userprofile["name"],
            id: userprofile["id"].toString(),
            profileImage:
                "https://ui-avatars.com/api/?name=" + userprofile["name"],
          );
          getQueryChatData(userprofile["id"].toString());
        } else {}
      });
    }
  }

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  final ChatUser otherUser = ChatUser(
      firstName: "Padhai Vadhai",
      id: "1",
      profileImage: "https://ui-avatars.com/api/?name=Padhai+Vadhai");

  bool loadingquiries = true;
  List queireslist = [];
  List<ChatMessage> messages = [];
  getQueryChatData(user_id) async {
    String topic_id = widget.topic_id;
    setState(() {
      loadingquiries = false;
    });
    var url = "$conf_querychatlist/$topic_id/$user_id";
    print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List querychatdata2 = jsonDecode(response.body);

      var querychatdata = new List.from(querychatdata2.reversed);

      List<ChatMessage> messagestemp = [];
      querychatdata.forEach((element) {
        print(element["message_body"]);
        String mdate = element["m_date"];
        String mtime = element["m_time"];

        String imagepath = element["image"];

        var newDateTimeObj2 =
            new DateFormat("yyyy-MM-dd HH:mm:ss").parse("$mdate $mtime");

        ChatMessage cmessage = ChatMessage(
            text: element["message_body"],
            user: element["sender_id"] == userprofile["id"].toString()
                ? senderUser
                : otherUser,
            createdAt: newDateTimeObj2,
            medias: imagepath != "-"
                ? [
                    ChatMedia(
                      url: imagepath,
                      fileName: "Image",
                      type: MediaType.image,
                    )
                  ]
                : null

            // image: imagepath != "-" ? imagepath : null,
            );

        messagestemp.add(cmessage);
      });

      setState(() {
        messages = messagestemp;
      });
    }
  }

  var m = <ChatMessage>[];

  var i = 0;

  void onSend(ChatMessage message) {
    print(message);

    setState(() {
      messages = [...messages, message];
      print(messages.length);
    });
    chatPost(message.text);
  }

  chatPost(message) async {
    Map jsonData = {
      "message_body": message,
      "sender_id": userprofile["id"].toString(),
      "receiver_id": "1",
      "channel_id": widget.topic_id.toString(),
    };
    print(jsonData);

    var response = await http.post(
      Uri.parse(conf_querychatinert),
      body: jsonData,
    );
    print(response.body);
    if (response.statusCode == 200) {}
  }

  @override
  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('BACK TO QUERIES',
            style: TextStyle(
                fontSize: 25, fontFamily: "Quartzo", color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color(0xfff2a350),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      // backgroundColor: Colors.white,
      body: DashChat(
        
        currentUser: senderUser,
        onSend: (ChatMessage m) {
          setState(() {
            messages.insert(0, m);
            chatPost(m.text);
          });
        },
        messages: messages,
      ),
    );
  }
}

class ChatContianer extends StatefulWidget {
  @override
  _ChatContianerState createState() => _ChatContianerState();
}

class _ChatContianerState extends State<ChatContianer>
    with SingleTickerProviderStateMixin {
  UIWidget uiobj = UIWidget();
  @override
  void initState() {
    super.initState();
  }

  getQueryData() async {}
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
      innerPage: ChatPage(
        topic_id: "0",
      ),
      showfooter: false,
    );
  }
}
