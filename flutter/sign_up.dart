import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:convert';
import 'login_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          leading: IconButton(
            color: Colors.blueAccent,
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color(0xffEAEAEA),
          elevation: 0.0,
        ),
      ),
      backgroundColor: Color(0xffEAEAEA),
      body:  Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "회원가입",
                      style: TextStyle(
                        fontFamily: 'NanumBold',
                        fontSize: 20,
                        color: Colors.blueAccent,
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
                    if(checkCon == 1) {
                      app_re = 'app_re_' + _idController.text;
                      socketIO!.subscribe(app_re, (msg) {
                        print(msg);
                        if(msg == 'success') {
                          print('msg is success');
                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                content: Container(
                                  width: 320,
                                  height: 125,
                                  padding: EdgeInsets.only(top: 70),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '가입이 완료됐습니다',
                                    textAlign: TextAlign.center,
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
                        }
                        if(msg == 'exist'){
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
                                    '이미 등록된 계정입니다',
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
                        }
                      });
                      if ( _idController.text.isNotEmpty && _passwordController.text.isNotEmpty ){
                        await Future.microtask(() {
                          socketIO!.sendMessage(
                              'from_app', json.encode(
                              {
                                "type" : "sign_up",
                                "ID" : _idController.text,
                                "Password" : _passwordController.text,
                              }
                          ));
                          return;
                        }).then((_) {
                          this.setState(() {});
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
                  "회원가입",
                  style: TextStyle(
                    fontFamily: 'NanamBold',
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}