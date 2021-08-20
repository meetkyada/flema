import 'package:country_code_picker/country_localizations.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Helper/Demo_Localization.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Helper/Theme.dart';
import 'Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializedDownload();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  ));

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then((value) {
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (BuildContext context) {
          String theme = value.getString(APP_THEME);

          if (theme == DARK)
            ISDARK = "true";
          else if (theme == LIGHT) ISDARK = "false";

          if (theme == null || theme == "" || theme == DEFAULT_SYSTEM) {
            value.setString(APP_THEME, DEFAULT_SYSTEM);
            var brightness =
                SchedulerBinding.instance.window.platformBrightness;
            ISDARK = (brightness == Brightness.dark).toString();

            return ThemeNotifier(ThemeMode.system);
          }

          return ThemeNotifier(
              theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
        },
        child: MyApp(),
      ),
    );
  });
}

Future<void> initializedDownload() async {
  await FlutterDownloader.initialize(
      debug: false // optional: set false to disable printing logs to console
      );
}


final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  setLocale(Locale locale) {
    if (mounted)
      setState(() {
        _locale = locale;
      });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      if (mounted)
        setState(() {
          this._locale = locale;
        });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
        ),
      );
    } else {
      return MaterialApp(
        //scaffoldMessengerKey: rootScaffoldMessengerKey,
        locale: _locale,
        supportedLocales: [
          Locale("en", "US"),
          Locale("zh", "CN"),
          Locale("es", "ES"),
          Locale("hi", "IN"),
          Locale("ar", "DZ"),
          Locale("ru", "RU"),
          Locale("ja", "JP"),
          Locale("de", "DE")
        ],
        localizationsDelegates: [
          CountryLocalizations.delegate,
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        title: appName,
        theme: ThemeData(
          canvasColor: colors.lightWhite,
          cardColor: colors.white,
          dialogBackgroundColor: colors.white,
          iconTheme:
              Theme.of(context).iconTheme.copyWith(color: colors.primary),
          primarySwatch: colors.primary_app,
          primaryColor: colors.lightWhite,
          fontFamily: 'opensans',
          brightness: Brightness.light,
          textTheme: TextTheme(
                  headline6: TextStyle(
                    color: colors.fontColor,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle1: TextStyle(
                      color: colors.fontColor, fontWeight: FontWeight.bold))
              .apply(bodyColor: colors.fontColor),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => Splash(),
          '/home': (context) => Home(),
        },
        darkTheme: ThemeData(
          canvasColor: colors.darkColor,
          cardColor: colors.darkColor2,
          dialogBackgroundColor: colors.darkColor2,
          primarySwatch: colors.primary_app,
          primaryColor: colors.darkColor,
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: colors.primary,
              selectionColor: colors.primary,
              selectionHandleColor: colors.secondary),
          toggleableActiveColor: colors.primary,
          fontFamily: 'opensans',
          brightness: Brightness.dark,
          accentColor: colors.secondary,
          iconTheme:
              Theme.of(context).iconTheme.copyWith(color: colors.secondary),
          textTheme: TextTheme(
                  headline6: TextStyle(
                    color: colors.fontColor,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle1: TextStyle(
                      color: colors.fontColor, fontWeight: FontWeight.bold))
              .apply(bodyColor: colors.secondary),
        ),
        themeMode: themeNotifier.getThemeMode(),
      );
    }
  }
}
