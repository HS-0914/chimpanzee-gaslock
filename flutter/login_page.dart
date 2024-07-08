import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
import 'sign_up.dart';
import 'main_page.dart';
import 'ardu_page.dart';
import 'multi_page.dart';

class LoginInfo{
  String userID = '';
  String userPW = '';
  String? arduMac = '';
  String? arduVal = '';
  String? userNum = '';

  LoginInfo(this.userID, this.userPW, {this.arduMac, this.arduVal, this.userNum});
}

var items = [];
SocketIO? socketIO;
String url = 'https://chimpanzee1.loca.lt';
String app_re = 'app_re_';
int checkCon = 0;
double width = 0;
double height = 0;
int firstLoad = 1;
FToast? fToast;
var mobile = ConnectivityResult.mobile;
var wifi = ConnectivityResult.wifi;
var none = ConnectivityResult.none;
StreamSubscription<ConnectivityResult>? connectivitySubscription;


void showToast() {
  Fluttertoast.showToast(
      msg: '네트워크상태를 확인해주세요',
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.blue,
      backgroundColor: Colors.white,
      timeInSecForIosWeb: 4
  );
}
void showToast2() {
  Fluttertoast.showToast(
      msg: '다시 시도해주세요',
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.blue,
      backgroundColor: Colors.white,
      timeInSecForIosWeb: 4
  );
}

connect() {
  socketIO = SocketIOManager().createSocketIO(
    url,
    '/',
    socketStatusCallback: connectStatus,
  );
  socketIO!.init();
  socketIO!.connect();
}

connectStatus(dynamic data) {
  print("Socket status: " + data);
  if(data == 'connect'){
    checkCon = 1;
    print('good');
    print(checkCon);
  } else {
    checkCon = 2;
    print('bad');
    print(checkCon);
  }
}

reconnect() {
  if (socketIO == null) {
    socketIO!.unSubscribesAll();
    SocketIOManager().destroyAllSocket();
    connect();
  } else {
    socketIO!.connect();
  }
}


class LoginPage extends StatefulWidget {
  final LoginInfo? loginInfo;
  LoginPage({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  LoginInfo? loginInfo;
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState(){
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(result != none){
        reconnect();
      } else {
        print('net err');
      }
    });
    if (checkCon != 1) {
      connect();
    } else {
      socketIO!.connect();
    }
    super.initState();
  }

  @override
  void dispose() {
    connectivitySubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffEAEAEA),
      body:  Container(
        color: Color(0xffEAEAEA),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
              margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "로그인",
                      style: TextStyle(
                        fontFamily: 'NanumBold',
                        fontSize: 20,
                        color: Colors.blueAccent
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(3.0)),
                              borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(3.0)),
                              borderSide: BorderSide(width: 1, color: Color(0xffBCE0FD)),
                            ),
                            labelText: "ID",
                            labelStyle: TextStyle(color: Color(0xffBCE0FD)),
                          ),
                          controller: _idController,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(3.0)),
                              borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(3.0)),
                              borderSide: BorderSide(width: 1, color: Color(0xffBCE0FD)),
                            ),
                            labelText: "Password",
                            labelStyle: TextStyle(color: Color(0xffBCE0FD)),
                          ),
                          controller: _passwordController,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              width: width * 1,
              margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
              child: ElevatedButton(
                onPressed: () async{
                  var netCheck = await Connectivity().checkConnectivity();
                  if (netCheck != none){
                    if(checkCon == 2) {
                      showToast2();
                      socketIO!.connect();
                    }
                    if(checkCon == 1){
                      if ( _idController.text.isNotEmpty && _passwordController.text.isNotEmpty ){
                        app_re = 'app_re_' + _idController.text;
                        items.clear();
                        print(app_re);
                        socketIO!.subscribe(app_re, (jsondata) {
                          print(jsondata);
                          if(jsondata == 'wrong'){
                            showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  content: Container(
                                    width: 320,
                                    height: 125,
                                    padding: EdgeInsets.only(top: 65),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '존재하지 않는 계정 정보입니다',
                                      style: TextStyle(
                                        fontFamily: 'Nanum',
                                        fontSize: 20,
                                        color: Color(0xff2699FB),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        '확인',
                                        style: TextStyle(
                                          fontFamily: 'Nanum',
                                          color: Color(0xff2699FB),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            socketIO!.unSubscribe(app_re);
                          } else if (jsondata == 'first'){
                            socketIO!.unSubscribe(app_re);
                            socketIO!.disconnect();
                            checkCon = 2;
                            loginInfo!.userNum = '${items[0]["acc_num"]}';
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => ArduPage(loginInfo: loginInfo)), (route) => false,
                            );
                          } else if (jsondata == 'val_0'){
                            loginInfo!.arduVal = jsondata;
                            loginInfo!.userNum = '${items[0]["acc_num"]}';
                            loginInfo!.arduMac = '${items[0]["ardu_mac"]}';
                            socketIO!.unSubscribe(app_re);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => MainPage0(loginInfo: loginInfo)), (route) => false,
                            );
                          } else if (jsondata == 'val_1'){
                            loginInfo!.arduVal = jsondata;
                            loginInfo!.userNum = '${items[0]["acc_num"]}';
                            loginInfo!.arduMac = '${items[0]["ardu_mac"]}';
                            socketIO!.unSubscribe(app_re);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => MainPage1(loginInfo: loginInfo)), (route) => false,
                            );
                          } else {
                            if (jsondata != 'multi') {
                              Future.microtask(() async {
                                Map<String, dynamic> data = jsonDecode(jsondata);
                                items.add(data);
                              });
                            }
                            if (jsondata == 'multi'){
                              socketIO!.unSubscribe(app_re);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => MultiPage(loginInfo: loginInfo)), (route) => false,
                              );
                            }
                          }
                        });
                      }
                      if ( _idController.text.isNotEmpty && _passwordController.text.isNotEmpty ){
                        await Future.microtask(() {
                          socketIO!.sendMessage(
                              'from_app', json.encode(
                              {
                                "type" : "login",
                                "ID" : _idController.text,
                                "Password" : _passwordController.text,
                              }
                          ));
                          return;
                        }).then((_) {
                          this.setState(() {});
                          loginInfo = LoginInfo(_idController.text, _passwordController.text);
                          _idController.text = '';
                          _passwordController.text = '';
                          return;
                        });
                      }
                    }
                  } else {
                    showToast();
                  }
                },
                child: Text(
                  "로그인",
                  style: TextStyle(
                    fontFamily: 'NanumBold',
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Container(
              height: 35,
              width: width * 0.5,
              margin: EdgeInsets.only(top: 25),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  primary: Colors.blueAccent,
                  side: BorderSide(
                    color: Colors.blueAccent,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp())
                  );
                },
                child: Text(
                  "회원가입",
                  style: TextStyle(
                    fontFamily: 'NanumBold'
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

