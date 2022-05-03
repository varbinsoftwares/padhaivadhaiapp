import 'dart:async';
import 'dart:io';
import '../core/uiwidget.dart';
import '../core/baseLayout.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat/dash_chat.dart';
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
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

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
    name: "Pankaj",
    uid: "4",
    avatar: "https://ui-avatars.com/api/?name=John+Doe",
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
            name: userprofile["name"],
            uid: userprofile["id"],
            avatar: "https://ui-avatars.com/api/?name=" + userprofile["name"],
          );
          getQueryChatData(userprofile["id"]);
        } else {}
      });
    }
  }

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  final ChatUser otherUser = ChatUser(
      name: "Padhai Vadhai",
      uid: "1",
      avatar: "https://ui-avatars.com/api/?name=Padhai+Vadhai");

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
      List querychatdata = jsonDecode(response.body);
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
            user: element["sender_id"] == userprofile["id"]
                ? senderUser
                : otherUser,
            createdAt: newDateTimeObj2,
            image: imagepath != "-" ? imagepath : null);

        messagestemp.add(cmessage);
      });

      setState(() {
        messages = messagestemp;

        systemMessage();
        Timer(Duration(milliseconds: 300), () {
          _chatViewKey.currentState!.scrollController
            ..animateTo(
              _chatViewKey
                  .currentState!.scrollController.position.maxScrollExtent,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
        });
      });
    }
  }

  var m = <ChatMessage>[];

  var i = 0;

  void systemMessage() {
    Timer(Duration(milliseconds: 300), () {
      if (i < 6) {
        setState(() {
          messages = [...messages, m[i]];
        });
        i++;
      }
      Timer(Duration(milliseconds: 300), () {
        _chatViewKey.currentState!.scrollController
          ..animateTo(
            _chatViewKey
                .currentState!.scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
      });
    });
  }

  void onSend(ChatMessage message) {
    print(message.toJson());

    setState(() {
      messages = [...messages, message];
      print(messages.length);
    });
    chatPost(message.text);

    // if (i == 0) {
    //   systemMessage();
    //   Timer(Duration(milliseconds: 600), () {
    //     systemMessage();
    //   });
    // } else {
    //   systemMessage();
    // }
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
          key: _chatViewKey,
          inverted: false,
          height: _screenHeight,
          onSend: onSend,
          sendOnEnter: true,
          textInputAction: TextInputAction.send,
          user: senderUser,
          inputDecoration:
              InputDecoration.collapsed(hintText: "Add message here..."),
          dateFormat: DateFormat('yyyy-MMM-dd'),
          timeFormat: DateFormat('HH:mm a'),
          messages: messages,
          showUserAvatar: true,
          showAvatarForEveryMessage: false,
          scrollToBottom: false,
          onPressAvatar: (ChatUser user) {
            print("OnPressAvatar: ${user.name}");
          },
          onLongPressAvatar: (ChatUser user) {
            print("OnLongPressAvatar: ${user.name}");
          },
          parsePatterns: <MatchText>[
            MatchText(
                pattern: r"^Topic:",
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 20,
                ),
                onTap: (String value) {}),
            MatchText(
                type: ParsedType.URL,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                onTap: (String value) {
                  print(value);
                  _launchURL(value);
                }),
          ],
          inputMaxLines: 2,
          messageDecorationBuilder: (ChatMessage, sender) {
            print(ChatMessage.user.uid);
            if (ChatMessage.user.uid == senderUser.uid) {
              return BoxDecoration(
                color: Color(0xff171560),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              );
            } else {
              return BoxDecoration(
                color: Color(0xfff2a350),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              );
            }
          },
          messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
          showLoadEarlierWidget: () {
            return CircularProgressIndicator();
          },
          alwaysShowSend: true,
          inputToolbarPadding: EdgeInsets.all(0),
          shouldStartMessagesFromTop: false,
          inputTextStyle: TextStyle(fontSize: 16.0),
          inputContainerStyle: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              color: Color(0xffe1f8dc)),
          onQuickReply: (Reply reply) {
            setState(() {
              messages.add(ChatMessage(
                  text: reply.value,
                  createdAt: DateTime.now(),
                  user: senderUser));

              messages = [...messages];
            });

            Timer(Duration(milliseconds: 300), () {
              _chatViewKey.currentState!.scrollController
                ..animateTo(
                  _chatViewKey
                      .currentState!.scrollController.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );

              if (i == 0) {
                systemMessage();
                Timer(Duration(milliseconds: 600), () {
                  systemMessage();
                });
              } else {
                systemMessage();
              }
            });
          },
          onLoadEarlier: () {
            print("laoding...");
          },
          shouldShowLoadEarlier: false,
          showTraillingBeforeSend: true,
          trailing: <Widget>[
            // IconButton(
            //   icon: Icon(Icons.photo),
            //   onPressed: () async {
            //     final picker = ImagePicker();
            //     PickedFile? result = await picker.getImage(
            //       source: ImageSource.gallery,
            //       imageQuality: 80,
            //       maxHeight: 400,
            //       maxWidth: 400,
            //     );

            //     if (result != null) {
            //       ChatMessage message =
            //           ChatMessage(text: "", user: user, image: "");
            //     }
            //   },
            // )
          ],
        ));
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
