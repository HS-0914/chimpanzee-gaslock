import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'login_page.dart';
import 'set_page.dart';

class MainPage0 extends StatefulWidget {
  final LoginInfo? loginInfo;
  MainPage0({Key? key, @required this.loginInfo}) : super(key: key);
  @override
  _MainPage0State createState() => _MainPage0State(loginInfo: loginInfo);
}

class _MainPage0State extends State<MainPage0> {

  final LoginInfo? loginInfo;
  _MainPage0State({@required this.loginInfo});

  String valve = '';
  String arduRes = '';
  String btnimg = 'images/lock.png';
  String btntxt1 = '현재 가스밸브가 안전하게\n닫혀있습니다';
  String btntxt2 = '';
  int btntxtcol1 = 0xff2699FB;
  int btntxtcol2 = 0xff7FC4FD;
  int btncheck = 0; //1이면 누를수있음, 0이면 없음

  void valveScreen(data) {
    Future.microtask(() async {
      if (data == 'val_0'){
        valve = 'close';
        setState(() {
          btnimg = 'images/lock.png';
          btntxt1 = '현재 가스밸브가 안전하게\n닫혀있습니다';
          btntxt2 = '';
          btntxtcol1 = 0xff2699FB;
          btntxtcol2 = 0xff7FC4FD;
          btncheck = 2;
        });
      }
      if (data == 'val_1'){
        valve = 'open';
        setState(() {
          btnimg = 'images/open.png';
          btntxt1 = '현재 가스밸브가 위험에\n노출되어 있습니다';
          btntxt2 = '버튼을 눌러 집을 보호하세요';
          btntxtcol1 = 0xffFB657F;
          btntxtcol2 = 0xffFCA8B6;
          btncheck = 1;
        });
      }
      if (data == 'val_1'){
        valve = 'open';
        setState(() {
          btnimg = 'images/open.png';
          btntxt1 = '현재 가스밸브가 위험에\n노출되어 있습니다';
          btntxt2 = '버튼을 눌러 집을 보호하세요';
          btntxtcol1 = 0xffFB657F;
          btntxtcol2 = 0xffFCA8B6;
          btncheck = 1;
        });
      }
      if (data == 'res_0'){
        arduRes = 'failed';
        setState(() {
          btnimg = 'images/open.png';
          btntxt1 = '현재 가스밸브가 위험에\n노출되어 있습니다';
          btntxt2 = '버튼을 눌러 집을 보호하세요';
          btntxtcol1 = 0xffFB657F;
          btntxtcol2 = 0xffFCA8B6;
          btncheck = 1;
        });
      }
      if (data == 'res_1'){
        arduRes = 'success';
        setState(() {
          btnimg = 'images/lock.png';
          btntxt1 = '현재 가스밸브가 안전하게\n닫혀있습니다';
          btntxt2 = '';
          btntxtcol1 = 0xff2699FB;
          btntxtcol2 = 0xff7FC4FD;
          btncheck = 2;
        });
      }
      if (data == 'res_2'){
        arduRes = 'canceled';
        setState(() {
          btnimg = 'images/open_close.png';
          btntxt1 = '잠금이 취소됐습니다';
          btntxt2 = '나중에 다시 시도해주세요';
          btntxtcol1 = 0xff2699FB;
          btntxtcol2 = 0xff2699FB;
          btncheck = 1;
        });
      }
      if (data == 'leak'){
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
                  '가스 누출이 감지됐습니다',
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
                    setState(() {
                      btnimg = 'images/lock_leak.png';
                      btntxt1 = '가스 누출이 감지됐습니다';
                      btntxt2 = '밸브를 확인해주세요';
                      btntxtcol1 = 0xffFB657F;
                      btntxtcol2 = 0xffFCA8B6;
                      btncheck = 2;
                    });
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
      }
    });
  }



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
    app_re = 'app_re_' + loginInfo!.userID;
    socketIO!.subscribe(app_re, valveScreen);
    socketIO!.sendMessage('from_app', jsonEncode(
        {
          "type" : "valve",
          "ID" : loginInfo!.userID,
          "Password" : loginInfo!.userPW,
          "mac" : loginInfo!.arduMac,
        }
    ));
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

    // if (firstLoad == 0){
    //   socketIO!.sendMessage('from_app', jsonEncode(
    //       {
    //         "type" : "valve",
    //         "ID" : loginInfo!.userID,
    //         "Password" : loginInfo!.userPW,
    //         "mac" : loginInfo!.arduMac,
    //       }
    //   ));
    //   firstLoad = 1;
    //   setState(() {
    //     firstLoad = 1;
    //   });
    // }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:Size.fromHeight(60.0),
        child: Container(
          margin: EdgeInsets.only(top:34),
          child: AppBar(
            title: Image.asset(
              'images/Appbar.png',
              fit: BoxFit.fitHeight,
            ),
            backgroundColor: Color(0xffEAEAEA),
            elevation: 0.0,
          ),
        ),
      ),
      backgroundColor: Color(0xffEAEAEA),
      body:  Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 0.1,
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    child: IconButton(
                      icon: Image.asset(
                        btnimg,
                      ),
                      iconSize: width * 0.5,
                      onPressed: () async {
                        if (btncheck == 1){
                          var netCheck = await Connectivity().checkConnectivity();
                          if (netCheck != none){
                            if(checkCon == 2) {
                              showToast2();
                              socketIO!.connect();
                            }
                            if(checkCon == 1){
                              await Future.microtask(() {
                                socketIO!.sendMessage(
                                    'from_app', json.encode(
                                    {
                                      "type" : "close",
                                      "ID" : loginInfo!.userID,
                                      "mac" : loginInfo!.arduMac,
                                    }
                                ));
                                return;
                              }).then((_) {
                                setState(() {
                                  btnimg = 'images/open_close.png';
                                  btntxt1 = '가스밸브 잠그는중...';
                                  btntxt2 = '잠시 기다려주세요';
                                  btntxtcol1 = 0xff2699FB;
                                  btntxtcol2 = 0xff2699FB;
                                  btncheck = 2;
                                });
                                return;
                              });
                            }
                          } else {
                            showToast();
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 55.4),
                  Text(
                    btntxt1,
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(btntxtcol1),
                        letterSpacing: 1
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    btntxt2,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(btntxtcol2),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingPage(loginInfo: loginInfo)),
                  );
                },
                icon: Image.asset(
                  'images/menu.png',
                  width: 33,
                  height: 33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage1 extends StatefulWidget {
  final LoginInfo? loginInfo;
  MainPage1({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  _MainPage1State createState() => _MainPage1State(loginInfo: loginInfo);
}

class _MainPage1State extends State<MainPage1> {
  final LoginInfo? loginInfo;
  _MainPage1State({@required this.loginInfo});
  String btnimg = 'images/open.png';
  String btntxt1 = '현재 가스밸브가 위험에\n노출되어 있습니다';
  String btntxt2 = '버튼을 눌러 집을 보호하세요';
  String valve = '';
  String arduRes = '';
  int btntxtcol1 = 0xffFB657F;
  int btntxtcol2 = 0xffFCA8B6;
  int btncheck = 1; //1이면 누를수있음, 0이면 없음

  void valveScreen(data){
    Future.microtask(() async {
      if (data == 'val_0'){
        valve = 'close';
        setState(() {
          btnimg = 'images/lock.png';
          btntxt1 = '현재 가스밸브가 안전하게\n닫혀있습니다';
          btntxt2 = '';
          btntxtcol1 = 0xff2699FB;
          btntxtcol2 = 0xff7FC4FD;
          btncheck = 2;
        });
      }
      if (data == 'val_1'){
        valve = 'open';
        setState(() {
          btnimg = 'images/open.png';
          btntxt1 = '현재 가스밸브가 위험에\n노출되어 있습니다';
          btntxt2 = '버튼을 눌러 집을 보호하세요';
          btntxtcol1 = 0xffFB657F;
          btntxtcol2 = 0xffFCA8B6;
          btncheck = 1;
        });
      }
      if (data == 'res_0'){
        arduRes = 'failed';
        setState(() {
          btnimg = 'images/open.png';
          btntxt1 = '현재 가스밸브가 위험에\n노출되어 있습니다';
          btntxt2 = '버튼을 눌러 집을 보호하세요';
          btntxtcol1 = 0xffFB657F;
          btntxtcol2 = 0xffFCA8B6;
          btncheck = 1;
        });
      }
      if (data == 'res_1'){
        arduRes = 'success';
        setState(() {
          btnimg = 'images/lock.png';
          btntxt1 = '현재 가스밸브가 안전하게\n닫혀있습니다';
          btntxt2 = '';
          btntxtcol1 = 0xff2699FB;
          btntxtcol2 = 0xff7FC4FD;
          btncheck = 2;
        });
      }
      if (data == 'res_2'){
        arduRes = 'canceled';
        setState(() {
          btnimg = 'images/open_close.png';
          btntxt1 = '잠금이 취소됐습니다';
          btntxt2 = '나중에 다시 시도해주세요';
          btntxtcol1 = 0xff2699FB;
          btntxtcol2 = 0xff2699FB;
          btncheck = 1;
        });
      }
      if (data == 'leak'){
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
                  '가스 누출이 감지됐습니다',
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
                    setState(() {
                      btnimg = 'images/lock_leak.png';
                      btntxt1 = '가스 누출이 감지됐습니다';
                      btntxt2 = '밸브를 확인해주세요';
                      btntxtcol1 = 0xffFB657F;
                      btntxtcol2 = 0xffFCA8B6;
                      btncheck = 2;
                    });
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
      }
    });
  }

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
    app_re = 'app_re_' + loginInfo!.userID;
    socketIO!.subscribe(app_re, valveScreen);
    socketIO!.sendMessage('from_app', jsonEncode(
        {
          "type" : "valve",
          "ID" : loginInfo!.userID,
          "Password" : loginInfo!.userPW,
          "mac" : loginInfo!.arduMac,
        }
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    // if (firstLoad == 0){
    //   socketIO!.sendMessage('from_app', jsonEncode(
    //       {
    //         "type" : "valve",
    //         "ID" : loginInfo!.userID,
    //         "Password" : loginInfo!.userPW,
    //         "mac" : loginInfo!.arduMac,
    //       }
    //   ));
    //   firstLoad = 1;
    //   setState(() {
    //     firstLoad = 1;
    //   });
    // }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:Size.fromHeight(60.0),
        child: Container(
          margin: EdgeInsets.only(top:34),
          child: AppBar(
            title: Image.asset(
              'images/Appbar.png',
              fit: BoxFit.fitHeight,
            ),
            backgroundColor: Color(0xffEAEAEA),
            elevation: 0.0,
          ),
        ),
      ),
      backgroundColor: Color(0xffEAEAEA),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 0.1,
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    child: IconButton(
                        icon: Image.asset(
                          btnimg,
                        ),
                        iconSize: width * 0.5,
                        onPressed: () async {
                          if (btncheck == 1){
                            var netCheck = await Connectivity().checkConnectivity();
                            if (netCheck != none){
                              if(checkCon == 2) {
                                showToast2();
                                socketIO!.connect();
                              }
                              if(checkCon == 1){
                                await Future.microtask(() {
                                  socketIO!.sendMessage(
                                      'from_app', json.encode(
                                      {
                                        "type" : "close",
                                        "ID" : loginInfo!.userID,
                                        "mac" : loginInfo!.arduMac,
                                      }
                                  ));
                                  return;
                                }).then((_) {
                                  setState(() {
                                    btnimg = 'images/open_close.png';
                                    btntxt1 = '가스밸브 잠그는중...';
                                    btntxt2 = '잠시 기다려주세요';
                                    btntxtcol1 = 0xff2699FB;
                                    btntxtcol2 = 0xff2699FB;
                                    btncheck = 2;
                                  });
                                  return;
                                });
                              }
                            } else {
                              showToast();
                            }
                          }
                        }
                    ),
                  ),
                  SizedBox(height: 55.4),
                  Text(
                    btntxt1,
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(btntxtcol1),
                        letterSpacing: 1
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    btntxt2,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(btntxtcol2),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingPage(loginInfo: loginInfo)),
                  );
                },
                icon: Image.asset(
                  'images/menu.png',
                  width: 33,
                  height: 33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
