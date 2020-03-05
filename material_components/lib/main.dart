import 'package:flutter/material.dart';
import 'package:material_components/model/product.dart';
import 'package:material_components/screens/backdrop.dart';
import 'package:material_components/screens/category_menu_page.dart';
import 'package:material_components/screens/home.dart';
import 'package:material_components/screens/login.dart';

import 'custom/cut_corners_border.dart';

void main() => runApp(MyApp());

const kShrinePink50 = const Color(0xFFFEEAE6);
const kShrinePink100 = const Color(0xFFFEDBD0);
const kShrinePink300 = const Color(0xFFFBB8AC);
const kShrinePink400 = const Color(0xFFEAA4A4);

const kShrineBrown900 = const Color(0xFF442B2D);

const kShrineErrorRed = const Color(0xFFC5032B);

const kShrineSurfaceWhite = const Color(0xFFFFFBFA);
const kShrinePurple = Color(0xFF5D1049);
const kShrineBlack = Color(0xFF000000);
const kShrineBackgroundWhite = Colors.white;

final ThemeData _kShrineTheme = _buildShrineTheme();

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
        headline: base.headline.copyWith(
          fontWeight: FontWeight.w500,
        ),
        title: base.title.copyWith(fontSize: 18.0),
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: kShrineBrown900,
        bodyColor: kShrineBrown900,
      );
}

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: kShrineBrown900,
    primaryColor: kShrinePink100,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: kShrinePink100,
      colorScheme: base.colorScheme.copyWith(
        secondary: kShrineBrown900,
      ),
    ),
    buttonBarTheme: base.buttonBarTheme.copyWith(
      buttonTextTheme: ButtonTextTheme.accent,
    ),
    scaffoldBackgroundColor: kShrineBackgroundWhite,
    cardColor: kShrineBackgroundWhite,
    textSelectionColor: kShrinePink100,
    errorColor: kShrineErrorRed,
    textTheme: _buildShrineTextTheme(base.textTheme),
    primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
    primaryIconTheme: base.iconTheme.copyWith(color: kShrineBrown900),
    inputDecorationTheme: InputDecorationTheme(
      border: CutCornersBorder(),
    ),
  );
}

class _MyAppState extends State<MyApp>{
  Category _currentCategory = Category.all;

  void _onCategoryTap(Category category){
    setState(() {
      _currentCategory = category;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _kShrineTheme,
      home: Backdrop(
        currentCategory: _currentCategory,
        frontLayer: HomePage(category: _currentCategory,),
        backLayer: CategoryMenuPage(
          currentCategory: _currentCategory,
          onCategoryTap: _onCategoryTap,
        ),
        frontTitle: Text('LNH'),
        backTitle: Text('Menu'),
      ),
      initialRoute: '/',
      onGenerateRoute: _getRoute,

    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
//    if (settings.name != '/login') {
//      return null;
//    }

    return MaterialPageRoute<void>(
        builder: (BuildContext context) => LoginPage(),
        fullscreenDialog: true,
        settings: settings);
  }
}

class MyApp extends StatefulWidget {
  @override
 _MyAppState createState() => _MyAppState();
}
