import 'package:flutter/material.dart';

class UIWidget {

  
  Widget mainButton(BuildContext context, gradiantlist, buttontxt, image,
      buttonheight, callback) {
    return InkWell(
       onTap: callback,
      child: Container(
        height: buttonheight,
        // width: 300,
        margin: EdgeInsets.only(top: 7, bottom: 7,),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradiantlist),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Container(
            margin: EdgeInsets.only(left: 25, right: 5,),
          
          child: Row(
            children: [
              // SizedBox(width: 40,),
              Expanded(
                flex: 7,
                child: Text(
                  buttontxt,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 23, fontFamily: "Quartzo", color: Colors.black),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Image.asset(
                    image,
                    height: 40,
                  ))
            ],
          ),
        )));
  }

 Widget mainButtonOld(BuildContext context, gradiantlist, buttontxt, image,
      buttonheight, callback) {
    return Container(
        height: buttonheight,
        // width: 300,
        margin: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradiantlist),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: ElevatedButton(
          
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Colors.transparent,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          child: Row(
            children: [
              // SizedBox(width: 40,),
              Expanded(
                flex: 7,
                child: Text(
                  buttontxt,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 25, fontFamily: "Quartzo", color: Colors.black),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Image.asset(
                    image,
                    height: 50,
                  ))
            ],
          ),
        ));
  }

  Widget genButton(BuildContext context, gradiantlist, rowchild,
      buttonheight, buttonwidth, callback) {
    return Container(
        height: buttonheight,
        width: buttonwidth,
        margin: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradiantlist),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Colors.transparent,
            shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: rowchild,
        ));
  }

    Widget loginCheckBlock(BuildContext context) {
    return Container(
        height: 300,
        margin: EdgeInsets.all(30),
         decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
     
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Please login or register to ask an query.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontFamily: "Quartzo", color: Colors.black)),
            this.genButton(
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
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Divider(color: Colors.black,),
                  flex: 4,
                ),
                Expanded(
                  child: Container(
                    // width: 50,
                    child: Text(
                      "Or",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: "Quartzo",
                          color: Colors.black),
                    ),
                  ),
                  flex: 2,
                ),
                Expanded(
                  child: Divider(color: Colors.black,),
                  flex: 4,
                ),
              ],
            ),
            this.genButton(
                context,
                [Color(0xFFffce81), Color(0xFFe57433)],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(width: 40,),
                    Container(
                        child: Text(
                      "Registration",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Quartzo",
                          color: Colors.black),
                    )),
                    Opacity(opacity: 0.5, child: Icon(Icons.lock))
                  ],
                ),
                50.0,
                200.0, () {
              // Navigator.pushNamed(context, "registration");
              Navigator.pushNamedAndRemoveUntil(
                  context, 'registration', ModalRoute.withName('/'));
            }),
          ],
        ));
  }

}
