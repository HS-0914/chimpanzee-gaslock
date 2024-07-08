import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'login_page.dart';
import 'multi_page.dart';
import 'main.dart';

class SettingPage extends StatefulWidget {
  final LoginInfo? loginInfo;
  SettingPage({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState(loginInfo: loginInfo);
}

class _SettingPageState extends State<SettingPage> {
  final LoginInfo? loginInfo;
  _SettingPageState({@required this.loginInfo});

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

  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    var changedPW = '';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          color: Color(0xff2699FB),
          padding: EdgeInsets.only(top:10),
          child: AppBar(
            leading: IconButton(
              padding: EdgeInsets.all(0),
              color: Colors.white,
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            title: Text(
              '설 정',
              style: TextStyle(
                fontFamily: 'NanumBold',
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0xff2699FB),
            elevation: 0.0,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              child: TextButton(
                onPressed: () async {
                  var netCheck = await Connectivity().checkConnectivity();
                  if (netCheck != none){
                    if(checkCon == 2){
                      showToast2();
                      socketIO!.connect();
                    }
                    if(checkCon == 1){
                      items.clear();
                      print(items);

                      void settingMul(jsondata) {
                        if(jsondata != 'set_mul'){
                          Future.microtask(() async {
                            Map<String, dynamic> data = jsonDecode(jsondata);
                            items.add(data);
                          });
                        }
                        if (jsondata == 'set_mul'){
                          socketIO!.unSubscribe(app_re, settingMul);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MultiPage2(loginInfo: loginInfo)),
                          );
                        }
                      }

                      app_re = 'app_re_' + loginInfo!.userID;
                      socketIO!.subscribe(app_re, settingMul);
                      await Future.microtask(() {
                        socketIO!.sendMessage(
                            'from_app', json.encode(
                            {
                              "type" : "setting_mul",
                              "ID" : loginInfo!.userID,
                              "Password" : loginInfo!.userPW,
                            }
                        ));
                        return;
                      });
                    }
                  } else {
                    showToast();
                  }
                },
                child: Text(
                  '기기 변경/추가',
                  style: TextStyle(
                    fontFamily: 'NanumBold',
                    fontSize: 16,
                    color: Color(0xff2699FB),
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  minimumSize: Size((width-32), 65),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 25),
                ),
              ),
            ),

            Container(
              width: width-32,
              child: Divider(
                color: Color(0xff2699FB),
                thickness: 1.0,
              ),
            ),

            Container(
              child: TextButton(
                onPressed: () async {
                  var netCheck = await Connectivity().checkConnectivity();
                  if (netCheck != none){
                    if(checkCon == 2){
                      showToast2();
                      socketIO!.connect();
                    }
                    if(checkCon == 1){
                      items.clear();
                      print(items);

                      void settingMul(jsondata) {
                        if(jsondata != 'set_mul'){
                          Future.microtask(() async {
                            Map<String, dynamic> data = jsonDecode(jsondata);
                            items.add(data);
                          });
                        }
                        if (jsondata == 'set_mul'){
                          socketIO!.unSubscribe(app_re, settingMul);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MultiPage3(loginInfo: loginInfo)),
                          );
                        }
                      }

                      app_re = 'app_re_' + loginInfo!.userID;
                      socketIO!.subscribe(app_re, settingMul);
                      await Future.microtask(() {
                        socketIO!.sendMessage(
                            'from_app', json.encode(
                            {
                              "type" : "setting_mul",
                              "ID" : loginInfo!.userID,
                              "Password" : loginInfo!.userPW,
                            }
                        ));
                        return;
                      });
                    }
                  } else {
                    showToast();
                  }
                },
                child: Text(
                  '이름 변경',
                  style: TextStyle(
                    fontFamily: 'NanumBold',
                    fontSize: 16,
                    color: Color(0xff2699FB),
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  minimumSize: Size((width-32), 65),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 25),
                ),
              ),
            ),

            Container(
              width: width-32,
              child: Divider(
                color: Color(0xff2699FB),
                thickness: 1.0,
              ),
            ),

            Container(
              child: TextButton(
                onPressed: (){
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        content: Container(
                          width: 320,
                          height: 125,
                          padding: EdgeInsets.only(top: 60),
                          child: TextField(
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
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              var netCheck = await Connectivity().checkConnectivity();
                              if (netCheck != none){
                                if(checkCon == 2) {
                                  showToast2();
                                  socketIO!.connect();
                                }
                                if(checkCon == 1){
                                  if (_passwordController.text.isNotEmpty){
                                    void changePW(jsondata){
                                      if(jsondata == 'existPW'){
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
                                                  '동일한 비밀번호입니다',
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
                                        socketIO!.unSubscribe(app_re, changePW);
                                      } else {
                                        loginInfo!.userPW = changedPW;
                                        socketIO!.unSubscribe(app_re, changePW);
                                        Navigator.of(context).pop();
                                      }
                                    }
                                    app_re = 'app_re_' + loginInfo!.userID;
                                    socketIO!.subscribe(app_re, changePW);
                                    await Future.microtask(() {
                                      socketIO!.sendMessage(
                                          'from_app', json.encode(
                                          {
                                            "type" : "pass",
                                            "ID" : loginInfo!.userID,
                                            "Password" : _passwordController.text,
                                          }
                                      ));
                                      return;
                                    }).then((_) {
                                      this.setState(() {});
                                      changedPW = _passwordController.text;
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
                              'ok',
                              style: TextStyle(
                                fontFamily: 'Nanum',
                                fontSize: 16,
                                color: Color(0xff2699FB),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'cancel',
                              style: TextStyle(
                                fontFamily: 'Nanum',
                                fontSize: 16,
                                color: Color(0xff2699FB),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  '비밀번호 변경',
                  style: TextStyle(
                    fontFamily: 'NanumBold',
                    fontSize: 16,
                    color: Color(0xff2699FB),
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  minimumSize: Size((width-32), 65),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 25),
                ),
              ),
            ),
            Container(
              width: width-32,
              child: Divider(
                color: Color(0xff2699FB),
                thickness: 1.0,
              ),
            ),
            Container(
              child: TextButton(
                onPressed: () async {
                  app_re = 'app_re_' + loginInfo!.userID;
                  socketIO!.unSubscribe(app_re);
                  socketIO!.disconnect();
                  checkCon = 2;
                  SocketIOManager().destroySocket(socketIO);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()), (route) => false,);
                },
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontFamily: 'NanumBold',
                    fontSize: 16,
                    color: Color(0xff2699FB),
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  minimumSize: Size((width-32), 65),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
