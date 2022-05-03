import 'package:flutter/material.dart';
import '../core/baseLayout.dart';
import '../core/uiwidget.dart';
import 'package:badges/badges.dart';
import 'package:email_validator/email_validator.dart';
import '../api.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AskQuery extends StatefulWidget {
  @override
  _AskQueryState createState() => _AskQueryState();
}

class _AskQueryState extends State<AskQuery>
    with SingleTickerProviderStateMixin {
  UIWidget uiobj = UIWidget();
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  bool userloggein = false;
  Map userprofile = {};
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");

    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        print(userprofile);
        userloggein = true;
      } else {
        userloggein = false;
      }
    });
  }

  Random random = new Random();

  final ImagePicker _picker = ImagePicker();
  String uploadfilestring = "";
  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Uint8List? _tempimagedata;

  bool uploadingstatusimage = false;
  uploadProductImage() async {
    upload_file.text = "";
    setState(() {
      uploadingstatusimage = true;
    });
    String randomNumber = generateRandomString(30);
    var request = http.MultipartRequest('POST', Uri.parse(conf_uploadfileapi));

    request.files.add(http.MultipartFile.fromBytes(
        'file', _tempimagedata as List<int>,
        filename: randomNumber + ".jpg"));
    var res = await request.send();
    print(res.statusCode);
    if (res.statusCode == 200) {
      print(res.reasonPhrase);
      setState(() {
        uploadingstatusimage = false;
        upload_file.text = randomNumber + ".jpg";
      });
    } else {
      setState(() {
        uploadingstatusimage = false;
        upload_file.text = '';
      });
    }
  }

  loadImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1000, imageQuality: 80);
    print(image?.path);
    if (image != null) {
      setState(() {
        uploadfilestring = image.path;
        image.readAsBytes().then((value) {
          _tempimagedata = value.buffer.asUint8List();
          try {
            uploadProductImage();
          } on Exception catch (e) {
            e.toString();
          }
        });

        // upload_file.text = uploadfilestring;
      });
    }
  }

  messageDialog(context, message, title, navigation) {
    print(message);

    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () => Future.value(false),
              child: AlertDialog(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                actions: [
                  ElevatedButton(
                    child: Text("Ok"),
                    onPressed: () {
                      if (navigation) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'listquery', ModalRoute.withName('home'));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
                content: SingleChildScrollView(
                  child: Text(message),
                ),
              ));
        });
  }

  askQueryPost() async {
    setState(() {
      submitquerystatus = false;
    });
    Map jsonData = {
      "topic": topic.text,
      "description": description.text,
      "upload_file": upload_file.text,
      "user_id": userprofile["id"].toString()
    };

    var response = await http.post(
      Uri.parse(conf_askqueryapi),
      body: jsonData,
    );
    print(response.body);
    if (response.statusCode == 200) {
      Map registration = jsonDecode(response.body);

      switch (registration['status']) {
        case "401":
          {
            messageDialog(
                context, registration['message'], 'Post Query Failed', false);
          }
          break;
        case "100":
          {
            messageDialog(
                context, registration['message'], 'Query Submitted', true);
          }
          break;
        default:
          {}
          break;
      }

      setState(() {
        submitquerystatus = true;
      });
    } else {
      messageDialog(context, "Unable to connect Padhai Vadhai",
          'Connection Failed', false);
      setState(() {
        submitquerystatus = true;
      });
    }
  }

  bool submitquerystatus = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController description = new TextEditingController();
  TextEditingController topic = TextEditingController();
  TextEditingController upload_file = TextEditingController();
  Widget _buildTextFields() {
    return Form(
      key: _formKey,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              height: 30,
            ),
            ListTile(
                title: Text("TOPIC/SUBJECT",
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Quartzo",
                        color: Colors.black)),
                subtitle: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: topic,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Valid Topic';
                    }
                    return null;
                  },
                )),
            Divider(
              height: 10,
            ),
            ListTile(
                title: Text("DESCRIPTION",
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Quartzo",
                        color: Colors.black)),
                subtitle: TextFormField(
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 2,
                  maxLines: 3,
                  controller: description,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Valid Desciption';
                    }
                    return null;
                  },
                )),
            Divider(
              height: 10,
            ),
            ListTile(
              leading: Container(
                  height: 50,
                  width: 70,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF171560)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side:
                                        BorderSide(color: Color(0xFF171560))))),
                    onPressed: uploadingstatusimage
                        ? null
                        : () {
                            loadImage();
                          },
                    child: uploadingstatusimage
                        ? Container(
                            child: CircularProgressIndicator(),
                          )
                        : Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 30,
                          ),
                  )),
              title: Text("UPLOAD PICTURE",
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Quartzo",
                      color: Colors.black)),
              subtitle: TextFormField(
                readOnly: true,
                keyboardType: TextInputType.text,
                controller: upload_file,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Valid Image';
                  }
                  return null;
                },
              ),
              trailing: uploadfilestring == ""
                  ? Container(
                      height: 100,
                      width: 70,
                      child: Icon(Icons.image, size: 50))
                  : Image.file(
                      new File(uploadfilestring),
                      height: 100,
                      width: 70,
                    ),
            ),
            Divider(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                    height: 70,
                    width: 170,
                    margin: EdgeInsets.only(right: 10),
                    child: uiobj.genButton(
                        context,
                        [Color(0xFFffce81), Color(0xFFe57433)],
                        submitquerystatus
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // SizedBox(width: 40,),
                                  Container(
                                      child: Text(
                                    "Ask Now",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontFamily: "Quartzo",
                                        color: Colors.black),
                                  )),
                                  Opacity(opacity: 0.5, child: Icon(Icons.lock))
                                ],
                              )
                            : Container(
                                height: 20,
                                width: 150,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                        )),
                                    Text('Submitting..',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "Quartzo",
                                            color: Colors.black))
                                  ],
                                ),
                              ),
                        50.0,
                        200.0, () {
                      if (_formKey.currentState!.validate()) {
                        submitquerystatus ? askQueryPost() : null;
                      }
                    })),
              ],
            ),
          ]),
    );
  }

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    final double _screenHeightButton = _screenHeight * 8 / 100;
    return BaseLayout(
      innerPage: SingleChildScrollView(
          child: Container(
        width: double.infinity,
        height: _screenHeight - 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              child: uiobj.mainButton(
                  context,
                  [Color(0xFFffce81), Color(0xFFe57433)],
                  "Ask \nQuery",
                  "assets/icon/query_50.png",
                  _screenHeightButton, () {
                // Navigator.pushNamed(context, "askquery");
              }),
            ),
            Container(
              child: userloggein
                  ? _buildTextFields()
                  : uiobj.loginCheckBlock(context),
              margin: EdgeInsets.all(10),
            )
          ],
        ),
      )),
    );
  }
}
