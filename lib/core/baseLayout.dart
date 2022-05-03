import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:badges/badges.dart';
import 'uiwidget.dart';
import 'package:url_launcher/url_launcher.dart';


class BaseLayout extends StatelessWidget {
  final Widget innerPage;
   final bool showfooter;
  BaseLayout({ required  this.innerPage,  this.showfooter=true});

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  @override
  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 40, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Column(children: [
        Stack(
          children: [
            Container(
              height: 50,
              color: Color(0xFFf2a350),
            ),
            Container(
              margin: EdgeInsets.only(top: 0, left: 0, right: 0),
              height: 150,
              padding: EdgeInsets.all(0),
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/wave.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              height: 150,
              child: Center(
                  child: Image.asset(
                "assets/logo.png",
                height: 150,
              )),
            ),
            Positioned(
              right: -5,
              top: 90,
              child: Container(
                margin: EdgeInsets.only(top: 0, left: 0, right: 0),
                height: 80,
                padding: EdgeInsets.only(left: 10, bottom: 10),
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
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(height: _screenHeight - (this.showfooter ? 250:0), child: this.innerPage),
        )
      ]),
      persistentFooterButtons: this.showfooter ? <Widget>[
        InkWell(child:Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage("assets/footerimage.jpg"),
              fit: BoxFit.fill,
            ),
          ),
        ),onTap: ()=>_launchURL("https://bookbirdsview.com/"),)
      ] : null,
    );
  }
}
