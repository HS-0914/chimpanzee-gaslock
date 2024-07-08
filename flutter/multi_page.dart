import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'login_page.dart';
import 'main_page.dart';
import 'ardu_page.dart';

class MultiPage extends StatefulWidget {
  final LoginInfo? loginInfo;
  MultiPage({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  _MultiPageState createState() => _MultiPageState(loginInfo: loginInfo);
}

class _MultiPageState extends State<MultiPage> {
  final LoginInfo? loginInfo;
  _MultiPageState({@required this.loginInfo});

  @override
  void initState() {
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
    print(items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:Size.fromHeight(60.0),
        child: Container(
          margin: EdgeInsets.only(top:34),
          child: AppBar(
            title: Text(
              '선택하기',
              style: TextStyle(
                fontFamily: 'NanumBold',
                fontSize: 22,
                color: Color(0xff2699FB),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: 30,),
            Container(
              child: Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index){
                    return Column(
                      children: [
                        ElevatedButton(
                          child: Text(
                            '${items[index]["ardu_name"]}',
                            style: TextStyle(
                              fontFamily: 'NanumBold',
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(345, 150),
                            primary: Color(0xff2699FB),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 35)
                          ),
                          onPressed: () async {
                            var netCheck = await Connectivity().checkConnectivity();
                            if (netCheck != none){
                              if(checkCon == 2) {
                                showToast2();
                              }
                              app_re = 'app_re_' + loginInfo!.userID;
                              socketIO!.subscribe(app_re, (data) async {
                                if(data == 'val_0'){
                                  loginInfo!.arduVal = data;
                                  loginInfo!.userNum = '${items[index]["acc_num"]}';
                                  loginInfo!.arduMac = '${items[index]["ardu_mac"]}';
                                  socketIO!.unSubscribe(app_re);
                                  await Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainPage0(loginInfo: loginInfo)), (route) => false,
                                  );
                                } else {
                                  loginInfo!.arduVal = data;
                                  loginInfo!.userNum = '${items[index]["acc_num"]}';
                                  loginInfo!.arduMac = '${items[index]["ardu_mac"]}';
                                  socketIO!.unSubscribe(app_re);
                                  await Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainPage1(loginInfo: loginInfo)), (route) => false,
                                  );
                                }
                              });
                              await Future.microtask(() {
                                socketIO!.sendMessage(
                                    'from_app', json.encode(
                                    {
                                      "type" : "valve",
                                      "ID" : loginInfo!.userID,
                                      "Password" : loginInfo!.userPW,
                                      "mac" : '${items[index]["ardu_mac"]}',
                                    }
                                ));
                                return;
                              });
                            } else {
                              showToast();
                            }
                          },
                        ),
                        SizedBox(height: 15,)
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MultiPage2 extends StatefulWidget {
  final LoginInfo? loginInfo;
  MultiPage2({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  _MultiPage2State createState() => _MultiPage2State(loginInfo: loginInfo);
}

class _MultiPage2State extends State<MultiPage2> {
  final LoginInfo? loginInfo;
  _MultiPage2State({@required this.loginInfo});

  @override
  void initState() {
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
    print(items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:Size.fromHeight(60.0),
        child: Container(
          margin: EdgeInsets.only(top:34),
          child: AppBar(
            leading: IconButton(
              padding: EdgeInsets.all(0),
              color: Colors.blueAccent,
              icon: Icon(
                Icons.arrow_back,
                color: Color(0xff2699FB),
              ),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            title: Text(
              '변경/추가하기',
              style: TextStyle(
                fontFamily: 'NanumBold',
                fontSize: 22,
                color: Color(0xff2699FB),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: 30,),
            Container(
              child: Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: items.length+1,
                  itemBuilder: (context, index){
                    if (index == items.indexOf(items.last) + 1){
                      return Column(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(345, 150),
                                primary: Color(0xff2699FB),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 35)
                            ),
                            icon: Icon(Icons.add, size:28),
                            label: Text(
                              '추가하기',
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: 'NanumBold',
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              var netCheck = await Connectivity().checkConnectivity();
                              if(netCheck != none){
                                if(checkCon == 2) {
                                  showToast2();
                                }
                                if(checkCon == 1){
                                  app_re = 'app_re_' + loginInfo!.userID;
                                  socketIO!.subscribe(app_re, (jsondata) {
                                    Future.microtask(() async {
                                      Map<String, dynamic> data = jsonDecode(jsondata);
                                      socketIO!.disconnect();
                                      checkCon = 2;
                                      loginInfo!.userNum = data["acc_num"];
                                      socketIO!.unSubscribe(app_re);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => ArduPage(loginInfo: loginInfo)), (route) => false,
                                      );
                                    });
                                    return;
                                  });
                                  await Future.microtask(() {
                                    socketIO!.sendMessage(
                                        'from_app', json.encode(
                                        {
                                          "type" : "new",
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
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        ElevatedButton(
                          child: Text(
                            '${items[index]["ardu_name"]}',
                            style: TextStyle(
                              fontFamily: 'NanumBold',
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(345, 150),
                              primary: Color(0xff2699FB),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 35)
                          ),
                          onPressed: () async {
                            var netCheck = await Connectivity().checkConnectivity();
                            if (netCheck != none){
                              if(checkCon == 2) {
                                showToast2();
                              }
                              if(checkCon == 1){

                                void selectArdu(data) async {
                                  if(data == 'val_0'){
                                    loginInfo!.arduVal = data;
                                    loginInfo!.arduMac = '${items[index]["ardu_mac"]}';
                                    loginInfo!.userNum = '${items[index]["acc_num"]}';
                                    firstLoad = 0;
                                    await Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => MainPage0(loginInfo: loginInfo)), (route) => false,
                                    );
                                  } else {
                                    loginInfo!.arduVal = data;
                                    loginInfo!.arduMac = '${items[index]["ardu_mac"]}';
                                    loginInfo!.userNum = '${items[index]["acc_num"]}';
                                    firstLoad = 0;
                                    await Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => MainPage1(loginInfo: loginInfo)), (route) => false,
                                    );
                                  }
                                }

                                app_re = 'app_re_' + loginInfo!.userID;
                                socketIO!.subscribe(app_re, selectArdu);
                                await Future.microtask(() {
                                  socketIO!.sendMessage(
                                      'from_app', json.encode(
                                      {
                                        "type" : "valve",
                                        "ID" : loginInfo!.userID,
                                        "Password" : loginInfo!.userPW,
                                        "mac" : "${items[index]['ardu_mac']}",
                                      }
                                  ));
                                  return;
                                });
                              }
                            } else {
                              showToast();
                            }
                          },
                        ),
                        SizedBox(height: 15,)
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiPage3 extends StatefulWidget {
  final LoginInfo? loginInfo;
  MultiPage3({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  _MultiPageState3 createState() => _MultiPageState3(loginInfo: loginInfo);
}

class _MultiPageState3 extends State<MultiPage3> {
  final LoginInfo? loginInfo;
  _MultiPageState3({@required this.loginInfo});

  @override
  void initState() {
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
    print(items);
    super.initState();
  }
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:Size.fromHeight(60.0),
        child: Container(
          margin: EdgeInsets.only(top:34),
          child: AppBar(
            leading: IconButton(
              padding: EdgeInsets.all(0),
              color: Colors.blueAccent,
              icon: Icon(
                Icons.arrow_back,
                color: Color(0xff2699FB),
              ),
              onPressed: () {
                Navigator.pop(context);
              }
            ),
            title: Text(
              '이름 변경하기',
              style: TextStyle(
                fontFamily: 'NanumBold',
                fontSize: 22,
                color: Color(0xff2699FB),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: 30,),
            Container(
              child: Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index){
                    return Column(
                      children: [
                        ElevatedButton(
                          child: Text(
                            '${items[index]["ardu_name"]}',
                            style: TextStyle(
                              fontFamily: 'NanumBold',
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(345, 150),
                              primary: Color(0xff2699FB),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 35)
                          ),
                          onPressed: () {
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
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                          borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                          borderSide: BorderSide(width: 1, color: Color(0xffBCE0FD)),
                                        ),
                                        labelText: "Name",
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
                                              var name = '';
                                              app_re = 'app_re_' + loginInfo!.userID;

                                              void changeNa(jsondata){
                                                if(jsondata == 'existName'){
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
                                                            '동일한 이름입니다',
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
                                                              socketIO!.unSubscribe(app_re, changeNa);
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
                                                } else {
                                                  items[index]["ardu_name"] = name;
                                                  setState(() {
                                                    items[index]["ardu_name"] = name;
                                                  });
                                                  socketIO!.unSubscribe(app_re, changeNa);
                                                  Navigator.of(context).pop();
                                                }
                                              }

                                              socketIO!.subscribe(app_re, changeNa);
                                              await Future.microtask(() {
                                                socketIO!.sendMessage(
                                                    'from_app', json.encode(
                                                    {
                                                      "type" : "name",
                                                      "ID" : loginInfo!.userID,
                                                      "mac" : '${items[index]["ardu_mac"]}',
                                                      "change" : _passwordController.text,
                                                    }
                                                ));
                                                return;
                                              }).then((_) {
                                                this.setState(() {});
                                                // loginInfo!.arduMac = _passwordController.text;
                                                name = _passwordController.text;
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
                        ),
                        SizedBox(height: 15,)
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}