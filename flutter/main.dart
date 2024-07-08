import 'package:client_app_3/main_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'set_page.dart';
import 'ardu_page.dart';
// --no-sound-null-safety
// windows + R => services.msc => mysql80
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     home: LoginPage(),
     debugShowCheckedModeBanner: false,
     // home: ArduPage4()
    );
  }
}

//Execution failed for task 'a:app:compressDebugAssets' ==> flutter clean gogo
//_unSubscribes, ${인덱스}, setpage