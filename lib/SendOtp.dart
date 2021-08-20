import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Privacy_Policy.dart';
import 'package:eshop/Verify_Otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SendOtp extends StatefulWidget {
  String title;

  SendOtp({Key key, this.title}) : super(key: key);

  @override
  _SendOtpState createState() => new _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String mobile, id, countrycode, countryName, mobileno;
  bool _isNetworkAvail = true;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
        await buttonController.reverse();
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.fontColor),
      ),
      backgroundColor: colors.lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: kToolbarHeight),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<void> getVerifyUser() async {
    try {
      var data = {MOBILE: mobile};
      Response response =
      await post(getVerifyUserApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      await buttonController.reverse();
      if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
        if (!error) {
          setSnackbar(msg);

          setPrefrence(MOBILE, mobile);
          setPrefrence(COUNTRY_CODE, countrycode);
          Future.delayed(Duration(seconds: 1)).then((_) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        VerifyOtp(
                          mobileNumber: mobile,
                          countryCode: countrycode,
                          title: getTranslated(context, 'SEND_OTP_TITLE'),
                        )));
          });
        } else {
          setSnackbar(msg);
        }
      }
      if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
        if (error) {
          setPrefrence(MOBILE, mobile);
          setPrefrence(COUNTRY_CODE, countrycode);
          Future.delayed(Duration(seconds: 1)).then((_) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        VerifyOtp(
                          mobileNumber: mobile,
                          countryCode: countrycode,
                          title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                        )));
          });
        } else {
          setSnackbar(getTranslated(context, 'FIRSTSIGNUP_MSG'));
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      await buttonController.reverse();
    }
  }

  subLogo() {
    return Expanded(
      flex: widget.title == getTranslated(context, 'SEND_OTP_TITLE') ? 4 : 5,
      child: Container(
        child: Center(
          child: new SvgPicture.asset('assets/images/homelogo.svg'),
        ),
      ),
    );
  }

  createAccTxt() {
    return Padding(
        padding: EdgeInsets.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: new Text(
            widget.title == getTranslated(context, 'SEND_OTP_TITLE')
                ? getTranslated(context, 'CREATE_ACC_LBL')
                : getTranslated(context, 'FORGOT_PASSWORDTITILE'),
            style: Theme
                .of(context)
                .textTheme
                .subtitle1
                .copyWith(color: colors.fontColor, fontWeight: FontWeight.bold),
          ),
        ));
  }

  verifyCodeTxt() {
    return Padding(
        padding:
        EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0, bottom: 20.0),
        child: Align(
          alignment: Alignment.center,
          child: new Text(
            getTranslated(context, 'SEND_VERIFY_CODE_LBL'),
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .subtitle2
                .copyWith(
              color: colors.fontColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ));
  }

  setCodeWithMono() {
    return Container(
        width: deviceWidth * 0.7,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              color: colors.lightWhite,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: setCountryCode(),
                ),
                Expanded(
                  flex: 4,
                  child: setMono(),
                )
              ],
            )));
  }

  setCountryCode() {
    double width = deviceWidth;
    double height = deviceHeight * 0.9;
    return CountryCodePicker(
        showCountryOnly: false,
        flagWidth: 20,

        boxDecoration: BoxDecoration(
          color: colors.lightWhite,
        ),
        searchDecoration: InputDecoration(
          hintText: getTranslated(context, 'COUNTRY_CODE_LBL'),
          hintStyle: TextStyle(color: colors.fontColor),
          fillColor: colors.fontColor,
        ),
        showOnlyCountryWhenClosed: false,
        initialSelection: 'IN',
        dialogSize: Size(width, height),
        alignLeft: true,
        textStyle:
        TextStyle(color: colors.fontColor, fontWeight: FontWeight.bold),
        onChanged: (CountryCode countryCode) {
          countrycode = countryCode.toString().replaceFirst("+", "");
          countryName = countryCode.name;
        },
        onInit: (code) {
          countrycode = code.toString().replaceFirst("+", "");
        });
  }

  setMono() {
    return TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: Theme
            .of(this.context)
            .textTheme
            .subtitle2
            .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) =>
            validateMob(
                val,
                getTranslated(context, 'MOB_REQUIRED'),
                getTranslated(context, 'VALID_MOB')),
        onSaved: (String value) {
          mobile = value;
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme
              .of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.lightWhite),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.lightWhite),
          ),
        ));
  }

  verifyBtn() {
    return AppBtn(
        title: widget.title == getTranslated(context, 'SEND_OTP_TITLE')
            ? getTranslated(context, 'SEND_OTP')
            : getTranslated(context, 'GET_PASSWORD'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          validateAndSubmit();
        });
  }

  termAndPolicyTxt() {
    return widget.title == getTranslated(context, 'SEND_OTP_TITLE')
        ? Padding(
      padding: EdgeInsets.only(
          bottom: 30.0, left: 25.0, right: 25.0, top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(getTranslated(context, 'CONTINUE_AGREE_LBL'),
              style: Theme
                  .of(context)
                  .textTheme
                  .caption
                  .copyWith(
                  color: colors.fontColor,
                  fontWeight: FontWeight.normal)),
          SizedBox(
            height: 3.0,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PrivacyPolicy(
                                title: getTranslated(context, 'TERM'),
                              )));
                },
                child: Text(
                  getTranslated(context, 'TERMS_SERVICE_LBL'),
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption
                      .copyWith(
                      color: colors.fontColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.normal),
                )),
            SizedBox(
              width: 5.0,
            ),
            Text(getTranslated(context, 'AND_LBL'),
                style: Theme
                    .of(context)
                    .textTheme
                    .caption
                    .copyWith(
                    color: colors.fontColor,
                    fontWeight: FontWeight.normal)),
            SizedBox(
              width: 5.0,
            ),
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PrivacyPolicy(
                                title: getTranslated(context, 'PRIVACY'),
                              )));
                },
                child: Text(
                  getTranslated(context, 'PRIVACY'),
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption
                      .copyWith(
                      color: colors.fontColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.normal),
                )),
          ]),
        ],
      ),
    )
        : Container();
  }

  backBtn() {
    return Platform.isIOS
        ? Container(
        padding: EdgeInsets.only(top: 20.0, left: 10.0),
        alignment: Alignment.topLeft,
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: InkWell(
              child: Icon(Icons.keyboard_arrow_left, color: colors.fontColor),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ))
        : Container();
  }

  @override
  void initState() {
    super.initState();
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  expandedBottomView() {
    return Expanded(
      flex: widget.title == getTranslated(context, 'SEND_OTP_TITLE') ? 6 : 5,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      createAccTxt(),
                      verifyCodeTxt(),
                      setCodeWithMono(),
                      verifyBtn(),
                      termAndPolicyTxt(),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Container(
            color: colors.lightWhite,
            padding: EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Column(
              children: <Widget>[
                backBtn(),
                subLogo(),
                expandedBottomView(),
              ],
            ))
            : noInternet(context));
  }
}
