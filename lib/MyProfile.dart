import 'dart:async';
import 'dart:convert';

import 'package:eshop/Customer_Support.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/MyTransactions.dart';
import 'package:eshop/ReferEarn.dart';
import 'package:eshop/Setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'Faqs.dart';
import 'Helper/Constant.dart';
import 'Helper/Theme.dart';
import 'Login.dart';
import 'Manage_Address.dart';
import 'MyOrder.dart';
import 'My_Wallet.dart';
import 'Privacy_Policy.dart';
import 'Profile.dart';
import 'main.dart';

class MyProfile extends StatefulWidget {
  Function update;

  MyProfile(this.update);

  @override
  State<StatefulWidget> createState() => StateProfile();
}

class StateProfile extends State<MyProfile> with TickerProviderStateMixin {
  String profile, email;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final InAppReview _inAppReview = InAppReview.instance;
  var isDarkTheme;
  bool isDark = false;
  ThemeNotifier themeNotifier;
  List<String> langCode = ["en", "zh", "es", "hi", "ar", "ru", "ja", "de"];
  List<String> themeList = [];
  List<String> languageList = [];
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  int selectLan, curTheme;
  TextEditingController curPassC, newPassC, confPassC;
  String curPass, newPass, confPass, mobile;
  bool _showPassword = false, _showNPassword = false, _showCPassword = false;

  @override
  void initState() {
    getUserDetails();

    new Future.delayed(Duration.zero, () {
      languageList = [
        getTranslated(context, 'ENGLISH_LAN'),
        getTranslated(context, 'CHINESE_LAN'),
        getTranslated(context, 'SPANISH_LAN'),
        getTranslated(context, 'HINDI_LAN'),
        getTranslated(context, 'ARABIC_LAN'),
        getTranslated(context, 'RUSSIAN_LAN'),
        getTranslated(context, 'JAPANISE_LAN'),
        getTranslated(context, 'GERMAN_LAN')
      ];

      themeList = [
        getTranslated(context, 'SYSTEM_DEFAULT'),
        getTranslated(context, 'LIGHT_THEME'),
        getTranslated(context, 'DARK_THEME')
      ];

      _getSaved();
    });
    super.initState();
  }

  _getSaved() async {
    var get = await getPrefrence(APP_THEME);

    curTheme =
        themeList.indexOf(get ?? getTranslated(context, 'SYSTEM_DEFAULT'));

    var getlng = await getPrefrence(LAGUAGE_CODE);

    selectLan = langCode.indexOf(getlng ?? "en");

    if (mounted) setState(() {});
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID);
    CUR_USERNAME = await getPrefrence(USERNAME);
    email = await getPrefrence(EMAIL);
    profile = await getPrefrence(IMAGE);

    if (mounted) setState(() {});
  }

  _getHeader() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 10.0, top: 10),
        child: Container(
          padding: EdgeInsetsDirectional.only(
            start: 10.0,
          ),
          child: Row(
            children: [
              Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CUR_USERNAME == "" || CUR_USERNAME == null
                            ? getTranslated(context, 'GUEST')
                            : CUR_USERNAME,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color:colors.fontColor),
                      ),
                      email != null
                          ? Text(
                              email,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color:colors.fontColor),
                            )
                          : Container(),
                      CUR_BALANCE != null &&
                              CUR_BALANCE != "" &&
                              CUR_BALANCE != "0" &&
                              CUR_BALANCE.isNotEmpty
                          ? Text(
                              CUR_CURRENCY +
                                  " " +
                                  "${double.parse(CUR_BALANCE).toStringAsFixed(2)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color:colors.fontColor))
                          : Container(),
                      CUR_USERNAME == "" || CUR_USERNAME == null
                          ? Padding(
                              padding: const EdgeInsetsDirectional.only(top: 7),
                              child: InkWell(
                                child: Text(
                                    getTranslated(
                                        context, 'LOGIN_REGISTER_LBL'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                          color: colors.primary,
                                          decoration: TextDecoration.underline,
                                        )),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Login(),
                                      ));
                                },
                              ))
                          : Padding(
                              padding: const EdgeInsetsDirectional.only(
                                top: 7,
                              ),
                              child: InkWell(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        getTranslated(
                                            context, 'EDIT_PROFILE_LBL'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(color:colors.fontColor)),
                                    Icon(
                                      Icons.arrow_right_outlined,
                                      color:colors.fontColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Profile(),
                                      ));

                                  getUserDetails();
                                },
                              ))
                    ],
                  )),
              Spacer(),
              Container(
                margin: EdgeInsetsDirectional.only(end: 20),
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.0, color: colors.white)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: profile != null
                      ? new FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: NetworkImage(profile),
                          height: 64.0,
                          width: 64.0,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(64),
                          placeholder: placeHolder(64),
                        )
                      : imagePlaceHolder(62),
                ),
              ),
            ],
          ),
        ));
  }

  List<Widget> getLngList() {
    return languageList
        .asMap()
        .map(
          (index, element) => MapEntry(
              index,
              InkWell(
                onTap: () {
                  if (mounted)
                    setState(() {
                      selectLan = index;
                      _changeLan(langCode[index]);
                    });
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 25.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectLan == index
                                    ? colors.grad2Color
                                    : colors.white,
                                border: Border.all(color: colors.grad2Color)),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: selectLan == index
                                  ? Icon(
                                      Icons.check,
                                      size: 17.0,
                                      color: colors.white,
                                    )
                                  : Icon(
                                      Icons.check_box_outline_blank,
                                      size: 15.0,
                                      color: colors.white,
                                    ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: 15.0,
                              ),
                              child: Text(
                                languageList[index],
                                style: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(color: colors.lightBlack),
                              ))
                        ],
                      ),
                      index == languageList.length - 1
                          ? Container(
                              margin: EdgeInsetsDirectional.only(
                                bottom: 10,
                              ),
                            )
                          : Divider(
                              color: colors.lightBlack,
                            ),
                    ],
                  ),
                ),
              )),
        )
        .values
        .toList();
  }

  void _changeLan(String language) async {
    Locale _locale = await setLocale(language);

    MyApp.setLocale(context, _locale);
  }

  _showDialog() async {
    await dialogAnimate(context,
           StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'CHANGE_PASS_LBL'),
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: colors.fontColor),
                            )),
                        Divider(color: colors.lightBlack),
                        Form(
                            key: _formkey,
                            child: new Column(
                              children: <Widget>[
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: (val) => validatePass(
                                          val,
                                          getTranslated(
                                              context, 'PWD_REQUIRED'),
                                          getTranslated(context, 'PWD_LENGTH')),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                          hintText: getTranslated(
                                              context, 'CUR_PASS_LBL'),
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                  color: colors.lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: colors.lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showPassword,
                                      controller: curPassC,
                                      onChanged: (v) => setState(() {
                                        curPass = v;
                                      }),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: (val) => validatePass(
                                          val,
                                          getTranslated(
                                              context, 'PWD_REQUIRED'),
                                          getTranslated(context, 'PWD_LENGTH')),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: new InputDecoration(
                                          hintText: getTranslated(
                                              context, 'NEW_PASS_LBL'),
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                  color: colors.lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showNPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: colors.lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showNPassword =
                                                    !_showNPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showNPassword,
                                      controller: newPassC,
                                      onChanged: (v) => setState(() {
                                        newPass = v;
                                      }),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value.length == 0)
                                          return getTranslated(
                                              context, 'CON_PASS_REQUIRED_MSG');
                                        if (value != newPass) {
                                          return getTranslated(context,
                                              'CON_PASS_NOT_MATCH_MSG');
                                        } else {
                                          return null;
                                        }
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: new InputDecoration(
                                          hintText: getTranslated(
                                              context, 'CONFIRMPASSHINT_LBL'),
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                  color: colors.lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showCPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: colors.lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showCPassword =
                                                    !_showCPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showCPassword,
                                      controller: confPassC,
                                      onChanged: (v) => setState(() {
                                        confPass = v;
                                      }),
                                    )),
                              ],
                            ))
                      ])),
              actions: <Widget>[
                new TextButton(
                    child: Text(
                      getTranslated(context, 'CANCEL'),
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                              color: colors.lightBlack,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                new TextButton(
                    child: Text(
                      getTranslated(context, 'SAVE_LBL'),
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                              color: colors.fontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final form = _formkey.currentState;
                      if (form.validate()) {
                        form.save();
                        if (mounted)
                          setState(() {
                            Navigator.pop(context);
                          });
                        setUpdateUser();
                      }
                    })
              ],
            );
          }));
        
  }

  Future<void> setUpdateUser() async {
    var data = {USER_ID: CUR_USERID, OLDPASS: curPass, NEWPASS: newPass};

    Response response =
        await post(getUpdateUserApi, body: data, headers: headers)
            .timeout(Duration(seconds: timeOut));
    if (response.statusCode == 200) {
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        setSnackbar(getTranslated(context, 'USER_UPDATE_MSG'));
      } else {
        setSnackbar(msg);
      }
    }
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

  _getDrawerFirst() {
    return Card(
      margin: EdgeInsetsDirectional.only(start: 10.0, end: 10.0),
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          _getDrawerItem(getTranslated(context, 'MY_ORDERS_LBL'),
              'assets/images/pro_myorder.svg'),
          _getDivider(),
          _getDrawerItem(getTranslated(context, 'MANAGE_ADD_LBL'),
              'assets/images/pro_address.svg'),
          _getDivider(),
          CUR_USERID == "" || CUR_USERID == null
              ? Container()
              : _getDrawerItem(getTranslated(context, 'MYWALLET'),
                  'assets/images/pro_wh.svg'),
          CUR_USERID == "" || CUR_USERID == null ? Container() : _getDivider(),
          CUR_USERID == "" || CUR_USERID == null
              ? Container()
              : _getDrawerItem(getTranslated(context, 'MYTRANSACTION'),
                  'assets/images/pro_th.svg'),
          CUR_USERID == "" || CUR_USERID == null ? Container() : _getDivider(),
          _getDrawerItem(getTranslated(context, 'CHANGE_THEME_LBL'),
              'assets/images/pro_theme.svg'),
          _getDivider(),
          _getDrawerItem(getTranslated(context, 'CHANGE_LANGUAGE_LBL'),
              'assets/images/pro_language.svg'),
          CUR_USERID == "" || CUR_USERID == null ? Container() : _getDivider(),
          CUR_USERID == "" || CUR_USERID == null
              ? Container()
              : _getDrawerItem(getTranslated(context, 'CHANGE_PASS_LBL'),
                  'assets/images/pro_pass.svg'),
        ],
      ),
    );
  }

  _getDivider() {
    return Divider(
      height: 1,
      color: colors.black,
    );
  }

  _getDrawerSecond() {
    return Card(
      margin: EdgeInsetsDirectional.only(
          start: 10.0, end: 10.0, top: 15.0, bottom: 15.0),
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          _getDivider(),
          CUR_USERID == "" || CUR_USERID == null
              ? Container()
              : _getDrawerItem(getTranslated(context, 'REFEREARN'),
                  'assets/images/pro_referral.svg'),
          CUR_USERID == "" || CUR_USERID == null ? Container() : _getDivider(),
          _getDrawerItem(getTranslated(context, 'CUSTOMER_SUPPORT'),
              'assets/images/pro_customersupport.svg'),
          _getDivider(),
          _getDrawerItem(getTranslated(context, 'ABOUT_LBL'),
              'assets/images/pro_aboutus.svg'),
          _getDivider(),
          _getDrawerItem(getTranslated(context, 'CONTACT_LBL'),
              'assets/images/pro_customersupport.svg'),
          _getDivider(),
          _getDrawerItem(
              getTranslated(context, 'FAQS'), 'assets/images/pro_faq.svg'),
          _getDivider(),
          _getDrawerItem(
              getTranslated(context, 'PRIVACY'), 'assets/images/pro_pp.svg'),
          _getDivider(),
          _getDrawerItem(
              getTranslated(context, 'TERM'), 'assets/images/pro_tc.svg'),
          _getDivider(),
          _getDrawerItem(getTranslated(context, 'RATE_US'),
              'assets/images/pro_rateus.svg'),
          _getDivider(),
          _getDrawerItem(getTranslated(context, 'SHARE_APP'),
              'assets/images/pro_share.svg'),
          CUR_USERID == "" || CUR_USERID == null ? Container() : _getDivider(),
          CUR_USERID == "" || CUR_USERID == null
              ? Container()
              : _getDrawerItem(getTranslated(context, 'LOGOUT'),
                  'assets/images/pro_logout.svg'),
        ],
      ),
    );
  }

  _getDrawerItem(String title, String img) {
    return ListTile(
      dense: true,
      leading: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: new BorderRadius.all(const Radius.circular(5.0)),
              color: colors.lightWhite),
          child: SvgPicture.asset(
            img,
          )),
      title: Text(
        title,
        style: TextStyle(color:colors.fontColor, fontSize: 15),
      ),
      onTap: () {
        if (title == getTranslated(context, 'MY_ORDERS_LBL')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyOrder(),
              ));

          //sendAndRetrieveMessage();
        } else if (title == getTranslated(context, 'MYTRANSACTION')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionHistory(),
              ));
        } else if (title == getTranslated(context, 'MYWALLET')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyWallet(),
              ));
        } else if (title == getTranslated(context, 'SETTING')) {
          CUR_USERID == null
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Setting(),
                  ));
        } else if (title == getTranslated(context, 'MANAGE_ADD_LBL')) {
          CUR_USERID == null
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageAddress(
                      home: true,
                    ),
                  ));
        } else if (title == getTranslated(context, 'REFEREARN')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReferEarn(),
              ));
        } else if (title == getTranslated(context, 'CONTACT_LBL')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacyPolicy(
                  title: getTranslated(context, 'CONTACT_LBL'),
                ),
              ));
        } else if (title == getTranslated(context, 'CUSTOMER_SUPPORT')) {
          CUR_USERID == null
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ))
              : Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CustomerSupport()));
        } else if (title == getTranslated(context, 'TERM')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacyPolicy(
                  title: getTranslated(context, 'TERM'),
                ),
              ));
        } else if (title == getTranslated(context, 'PRIVACY')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacyPolicy(
                  title: getTranslated(context, 'PRIVACY'),
                ),
              ));
        } else if (title == getTranslated(context, 'RATE_US')) {
          _openStoreListing();
        } else if (title == getTranslated(context, 'SHARE_APP')) {
          var str =
              "$appName\n\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n\n ${getTranslated(context, 'IOSLBL')}\n$iosLink$iosPackage";

          Share.share(str);
        } else if (title == getTranslated(context, 'ABOUT_LBL')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacyPolicy(
                  title: getTranslated(context, 'ABOUT_LBL'),
                ),
              ));
        } else if (title == getTranslated(context, 'FAQS')) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Faqs(
                  title: getTranslated(context, 'FAQS'),
                ),
              ));
        } else if (title == getTranslated(context, 'CHANGE_THEME_LBL')) {
          themeDialog();
        } else if (title == getTranslated(context, 'LOGOUT')) {
          logOutDailog();
        } else if (title == getTranslated(context, 'CHANGE_PASS_LBL')) {
          _showDialog();
        } else if (title == getTranslated(context, 'CHANGE_LANGUAGE_LBL')) {
          languageDialog();
        }
      },
    );
  }

  languageDialog() async {
    await dialogAnimate(context,
           StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                      child: Text(
                        getTranslated(context, 'CHOOSE_LANGUAGE_LBL'),
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: colors.fontColor),
                      )),
                  Divider(color: colors.lightBlack),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: getLngList()),
                    ),
                  ),
                ],
              ),
            );
          }));
        
  }

  themeDialog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      isDarkTheme = Theme.of(context).brightness == Brightness.dark;
      themeNotifier = Provider.of<ThemeNotifier>(context);
      return AlertDialog(
        contentPadding: const EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                child: Text(
                  getTranslated(context, 'CHOOSE_THEME_LBL'),
                  style: Theme.of(this.context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: colors.fontColor),
                )),
            Divider(color: colors.lightBlack),
            Flexible(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: themeListView(),
              ),
            )),
          ],
        ),
      );
    }));
  }

  List<Widget> themeListView() {
    return themeList
        .asMap()
        .map(
          (index, element) => MapEntry(
              index,
              InkWell(
                onTap: () {
                  _updateState(index);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 25.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: curTheme == index
                                    ? colors.grad2Color
                                    : colors.white,
                                border: Border.all(color: colors.grad2Color)),
                            child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: curTheme == index
                                    ? Icon(
                                        Icons.check,
                                        size: 17.0,
                                        color: colors.white,
                                      )
                                    : Icon(
                                        Icons.check_box_outline_blank,
                                        size: 15.0,
                                        color: colors.white,
                                      )),
                          ),
                          Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: 15.0,
                              ),
                              child: Text(
                                themeList[index],
                                style: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(color: colors.lightBlack),
                              ))
                        ],
                      ),
                      index == themeList.length - 1
                          ? Container(
                              margin: EdgeInsetsDirectional.only(
                                bottom: 10,
                              ),
                            )
                          : Divider(
                              color: colors.lightBlack,
                            )
                    ],
                  ),
                ),
              )),
        )
        .values
        .toList();
  }

  _updateState(int position) {
    curTheme = position;
    onThemeChanged(themeList[position]);
  }

  void onThemeChanged(
    String value,
  ) async {
    if (value == getTranslated(context, 'SYSTEM_DEFAULT')) {
      themeNotifier.setThemeMode(ThemeMode.system);
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      if (mounted)
        setState(() {
          isDark = brightness == Brightness.dark;
          if (isDark)
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
          else
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        });
    } else if (value == getTranslated(context, 'LIGHT_THEME')) {
      themeNotifier.setThemeMode(ThemeMode.light);
      if (mounted)
        setState(() {
          isDark = false;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        });
    } else if (value == getTranslated(context, 'DARK_THEME')) {
      themeNotifier.setThemeMode(ThemeMode.dark);
      if (mounted)
        setState(() {
          isDark = true;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        });
    }
    ISDARK = isDark.toString();

    setPrefrence(APP_THEME, value);
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: appStoreId,
        microsoftStoreId: 'microsoftStoreId',
      );

  logOutDailog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          content: Text(
            getTranslated(context, 'LOGOUTTXT'),
            style: Theme.of(this.context)
                .textTheme
                .subtitle1
                .copyWith(color: colors.fontColor),
          ),
          actions: <Widget>[
            new TextButton(
                child: Text(
                  getTranslated(context, 'NO'),
                  style: Theme.of(this.context).textTheme.subtitle2.copyWith(
                      color: colors.lightBlack, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }),
            new TextButton(
                child: Text(
                  getTranslated(context, 'YES'),
                  style: Theme.of(this.context).textTheme.subtitle2.copyWith(
                      color: colors.fontColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  clearUserSession();
                  favList.clear();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home', (Route<dynamic> route) => false);
                })
          ],
        );
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_getHeader(), _getDrawerFirst(), _getDrawerSecond()],
            ),
          ),
        ));
  }
}
