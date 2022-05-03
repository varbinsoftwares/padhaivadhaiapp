import 'package:flutter/material.dart';
import '../core/baseLayout.dart';
import '../core/uiwidget.dart';
import 'package:badges/badges.dart';
import 'package:email_validator/email_validator.dart';
import '../api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration>
    with SingleTickerProviderStateMixin {
  UIWidget uiobj = UIWidget();
  @override
  void initState() {
    super.initState();
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
                        context, 'home', ModalRoute.withName('/'));
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

  _registration() async {
    setState(() {
      checklogin = false;
    });
    Map jsonData = {
      "name": fullname.text,
      "mobile_no": mobile_no.text,
      "username": email.text,
      "password": password.text
    };
    print(conf_registrationapi);

    var response = await http.post(
      Uri.parse(conf_registrationapi),
      body: jsonData,
    );
    print(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      Map registration = jsonDecode(response.body);
      print(registration);

      switch (registration['status']) {
        case "401":
          {
            messageDialog(context, "Email or mobile no. already registered",
                'Registration Failed', false);
          }
          break;
        case "100":
          {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var profiledata = jsonEncode(registration['userdata']);
            print(profiledata);
            prefs.setString("profile", profiledata).then((value){
              print(value);
               messageDialog(context, "Thanks for regitration, Please login",
                'Registration Success', true);
            });
           
          }
          break;
        default:
          {}
          break;
      }

      // if (registration["status"] == "200") {
      //   print("all done");
      //   messageDialog(context, registration["msg"].toString(),
      //       'Registration Success', true);
      // } else {
      //   messageDialog(context, registration["msg"].toString(),
      //       'Registration Failed', false);
      // }
      setState(() {
        checklogin = true;
      });
    } else {
      messageDialog(context, "Unable to connect Padhai Vadhai",
          'Registration Failed', false);
      setState(() {
        checklogin = true;
      });
    }
  }

  bool checklogin = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController mobile_no = new TextEditingController();
  TextEditingController fullname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  Widget _buildTextFields() {
    return Form(
      key: _formKey,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(30.0),
              //   border: Border.all(color: Colors.red, width: 5),
              //   color: Colors.white,
              // ),
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: fullname,
                style: TextStyle(fontSize: 15),
                decoration:
                    new InputDecoration(hintText: "Your Full Name", border: null
                        // labelText: "Your Mobile No.",
                        ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Valid Name';
                  }
                  return null;
                },
              ),
            ),
            Divider(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(30.0),
              //   border: Border.all(color: Colors.red, width: 5),
              //   color: Colors.white,
              // ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: mobile_no,
                style: TextStyle(fontSize: 15),
                decoration: new InputDecoration(
                    hintText: "Your Mobile No.*", border: null
                    // labelText: "Your Mobile No.",
                    ),
                validator: (value) {
                  if (value!.length != 10) {
                    return 'Please Enter 10 Digit Mobile No.';
                  }
                  return null;
                },
              ),
            ),
            Divider(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(30.0),
              //   border: Border.all(color: Colors.red, width: 5),
              //   color: Colors.white,
              // ),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: email,
                style: TextStyle(fontSize: 15),
                decoration:
                    new InputDecoration(hintText: "Email*", border: null),
                validator: (value) {
                  if (!EmailValidator.validate(value!)) {
                    return 'Please Enter valid email.';
                  }
                  return null;
                },
              ),
            ),
            Divider(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(30.0),
              //   border: Border.all(color: Colors.red, width: 5),
              //   color: Colors.white,
              // ),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: password,
                obscureText: true,
                style: TextStyle(fontSize: 15),
                decoration:
                    new InputDecoration(hintText: "Password*", border: null),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Valid Password';
                  }
                  return null;
                },
              ),
            ),
            Divider(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: 50,
                    width: 200,
                    child: uiobj.genButton(
                        context,
                        [Color(0xFFffce81), Color(0xFFe57433)],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(width: 40,),
                            Container(
                              child: checklogin
                                  ? Text(
                                      "Registration",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: "Quartzo",
                                          color: Colors.black),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Checking..',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: "Quartzo",
                                                color: Colors.black))
                                      ],
                                    ),
                            ),
                            Opacity(opacity: 0.5, child: Icon(Icons.lock))
                          ],
                        ),
                        50.0,
                        200.0,
                        checklogin
                            ? () {
                                print("workingt");
                                if (_formKey.currentState!.validate()) {
                                  _registration();
                                }
                              }
                            : null)),
              ],
            ),
            Container(
              width: double.infinity,
              // color: Colors.grey,
              padding: EdgeInsets.only(right: 5, top: 10, bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),

                // color: Colors.white,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Text("If you already have an account?",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 15)),
                    Container(
                        height: 50,
                        width: 160,
                        child: uiobj.genButton(
                            context,
                            [Color(0xFF7fd6d0), Color(0xFF3d9690)],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // SizedBox(width: 40,),
                                Container(
                                    child: Text(
                                  "Login Now",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Quartzo",
                                      color: Colors.black),
                                )),
                                Opacity(opacity: 0.5, child: Icon(Icons.login))
                              ],
                            ),
                            50.0,
                            200.0, () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, 'login', ModalRoute.withName('/'));
                          //  Navigator.pushNamed(context, "login");
                        })),
                  ]),
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
        height: _screenHeight - 150,
        child: Container(width: 300, child: _buildTextFields()),
      )),
    );
  }
}
