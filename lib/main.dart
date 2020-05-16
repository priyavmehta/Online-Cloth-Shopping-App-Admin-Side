import 'package:flutter/material.dart';
import 'package:priyav_mart_admin/provider/products_provider.dart';
import 'package:priyav_mart_admin/screens/admin.dart';
import 'package:provider/provider.dart';
void main(){
  runApp(
    MultiProvider(
      providers: [
      ChangeNotifierProvider.value(value: ProductProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Admin(),
      ),
    )
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    );
  }
}

