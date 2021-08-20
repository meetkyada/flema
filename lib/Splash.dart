import 'dart:async';
import 'package:eshop/Intro_Slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'package:flutter_svg/flutter_svg.dart';


//splash screen of app
class Splash extends StatefulWidget {
    @override
    _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


    @override
    void initState() {
        super.initState();
        startTime();
    }

    @override
    Widget build(BuildContext context) {
        deviceHeight = MediaQuery.of(context).size.height;
        deviceWidth = MediaQuery.of(context).size.width;

        SystemChrome.setEnabledSystemUIOverlays([]);
        return Scaffold(
            key: _scaffoldKey,
            body: Stack(
                children: <Widget>[
                    Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: back(),
                        child: Center(
                            child: SvgPicture.asset(
                                'assets/images/splashlogo.svg',
                            ),
                        ),
                    ),
                    Image.asset(
                       'assets/images/doodle.png',
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                    ),
                ],
            ),
        );
    }

    startTime() async {
        var _duration = Duration(seconds: 2);
        return Timer(_duration, navigationPage);
    }

    Future<void> navigationPage() async {
        bool isFirstTime = await getPrefrenceBool(ISFIRSTTIME);
        if (isFirstTime) {
            Navigator.pushReplacementNamed(context, "/home");
        } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => IntroSlider(),
                ));
        }
    }


    setSnackbar(String msg) {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
            content: new Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.black),
            ),
            backgroundColor: colors.white,
            elevation: 1.0,
        ));
    }

    @override
    void dispose() {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        super.dispose();
    }

}