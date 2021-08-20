import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share/share.dart';

import 'Helper/Color.dart';
import 'Helper/SimBtn.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';

class ReferEarn extends StatefulWidget {
  @override
  _ReferEarnState createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: getAppBar(getTranslated(context, 'REFEREARN'), context),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/refer.svg",
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Text(
                    getTranslated(context, 'REFEREARN'),
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: colors.fontColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getTranslated(context, 'REFER_TEXT'),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Text(
                    getTranslated(context, 'YOUR_CODE'),
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: colors.fontColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: new BoxDecoration(
                          border: Border.all(
                              width: 1, style: BorderStyle.solid,
                            color: colors.secondary,),
                        borderRadius: BorderRadius.circular(4),

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          REFER_CODE,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: colors.fontColor),
                        ),
                      )),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                          color: colors.lightWhite,
                          borderRadius:
                              new BorderRadius.all(const Radius.circular(4.0))),
                      child: Text(getTranslated(context, 'TAP_TO_COPY'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.button.copyWith(
                                color: colors.fontColor,
                              ))),
                  onPressed: () {
                    Clipboard.setData(new ClipboardData(text: REFER_CODE));
                    setSnackbar('Refercode Copied to clipboard');
                  },
                ),
                SimBtn(
                  size: 0.8,
                  title: getTranslated(context, "SHARE_APP"),
                  onBtnSelected: () {

                    var str =
                        "$appName\nRefer Code:$REFER_CODE\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n\n${getTranslated(context, 'IOSLBL')}\n$iosLink$iosPackage";
                   Share.share(str);

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
