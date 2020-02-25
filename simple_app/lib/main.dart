import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/common/theme.dart';
import 'package:simple_app/models/cart.dart';
import 'package:simple_app/models/catalog.dart';
import 'package:simple_app/screens/cart.dart';
import 'package:simple_app/screens/catalog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => CatalogModel(),
        ),
        ChangeNotifierProxyProvider<CatalogModel, CartModel>(
            create: (context) => CartModel(),
            update: (context, catalog, cart) {
              cart.catalog = catalog;
              return cart;
            })
      ],
      child: MaterialApp(
        title: "Provider demo",
        theme: appTheme,
        initialRoute: '/',
        routes: {'/': (context) => MyCatalog(), '/cart': (context) => MyCart()},
      ),
    );
  }
}
