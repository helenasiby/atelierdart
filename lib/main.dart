import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mainproject/add_product_page.dart';
import 'package:mainproject/admindashboard.dart';
import 'package:mainproject/buyerpage.dart';
import 'package:mainproject/cartpage.dart';
import 'package:mainproject/deleteusers.dart';
import 'package:mainproject/firebase_options.dart';
import 'package:mainproject/forgotpassword.dart';
import 'package:mainproject/imagepick.dart';
import 'package:mainproject/login.dart';
import 'package:mainproject/loginmain.dart';
import 'package:mainproject/manageuserspage.dart';
import 'package:mainproject/productlist.dart';
import 'package:mainproject/profilescreen.dart';
import 'package:mainproject/registeration.dart';
import 'package:mainproject/sellerfrontend.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // Disable the DEBUG banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:Loginmain()
    );
  }
}

