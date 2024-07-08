import 'package:flutter/material.dart';
import 'package:system_settings/system_settings.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'login_page.dart';
import 'main.dart';

class ArduPage extends StatelessWidget {
  final LoginInfo? loginInfo;
  ArduPage({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffEAEAEA),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                'images/panzee_1.png',
                width: width * 0.48,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ArduPage2(loginInfo: loginInfo))
                );
              },
              child: Text(
                '시작하기',
                style: TextStyle(
                  fontSize: 24
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(width * 0.53, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<WifiNetwork>> loadWifiList() async {
  List<WifiNetwork> htResultNetwork;
  try {
    htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
  } on PlatformException {
    htResultNetwork = <WifiNetwork>[];
  }
  return htResultNetwork;
}

List<WifiNetwork?>? _htResultNetwork;

class ArduPage2 extends StatelessWidget {
  final LoginInfo? loginInfo;
  ArduPage2({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
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
              'Wi-Fi 연결',
              style: TextStyle(
                color: Color(0xff2699FB),
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0xffFFFFFF),
            elevation: 0.0,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: width * 0.914,
              height: height * 0.2328,
              color: Color(0xff2699FB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 17,top: 30),
                    child: Text(
                      "'침팬지'를 찾아주세요",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 17,top: 27),
                    child: Opacity(
                      opacity: 0.7,
                      child: Text(
                        '제품과 가까운 곳에서 설정해주세요',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin:EdgeInsets.only(top: height * 0.4,left: 20, right: 20),
              child: ElevatedButton(
                onPressed: () async {
                  print('click');
                  _htResultNetwork = await loadWifiList();
                  print(_htResultNetwork);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArduPage3(loginInfo: loginInfo))
                  );
                },
                child: Text(
                  '다음',
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(width * 1, 50),
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
                  SystemSettings.wifi();
                },
                child: Text(
                  "Wi-Fi 설정",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ArduPage3 extends StatefulWidget {
  final LoginInfo? loginInfo;
  ArduPage3({Key? key, @required this.loginInfo}) : super(key: key);

  @override
  _ArduPage3State createState() => _ArduPage3State(loginInfo: loginInfo);
}

class _ArduPage3State extends State<ArduPage3> {
  final LoginInfo? loginInfo;
  _ArduPage3State({@required this.loginInfo});

  TextEditingController? _passwordController = TextEditingController();
  String? url2 = '';
  var dio = Dio();

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
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
              'Wi-Fi 선택',
              style: TextStyle(
                color: Color(0xff2699FB),
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0xffFFFFFF),
            elevation: 0.0,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: width * 0.914,
              height: (height * 0.2328) - 15,
              color: Color(0xff2699FB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 17,top: 20),
                    child: Text(
                      "WiFi를 선택해주세요",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 17,top: 27),
                    child: Opacity(
                      opacity: 0.7,
                      child: Text(
                        '가정에서 사용하는 WiFi를\n연결해주세요',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _htResultNetwork!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          TextButton(
                            child: Text(
                              '${_htResultNetwork![index]!.ssid}',
                              style: TextStyle(
                                fontFamily: 'NanumBold',
                                fontSize: 20,
                                color: Color(0xff2699FB),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: Size(345, 70),
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        '${_htResultNetwork![index]!.ssid}',
                                        style: TextStyle(
                                          color: Color(0xff2699FB),
                                        ),
                                      ),
                                      content: TextField(
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
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            url2 = 'http://192.168.4.1/postform/';
                                            Response response = await dio.post(
                                              url2!,
                                              data: {'ssid': '${_htResultNetwork![index]!.ssid}', 'pass': _passwordController!.text, 'usid': loginInfo!.userID, 'num' : loginInfo!.userNum},
                                              options: Options(contentType: Headers.formUrlEncodedContentType),
                                            );
                                            print(response.data.toString());
                                            await Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => ArduPage4()), (route) => false,);
                                            return;
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
                                  }
                              );
                            },
                          ),
                          Container(
                            width: width-32,
                            child: Divider(
                              color: Color(0xff2699FB),
                              thickness: 1.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
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


class ArduPage4 extends StatefulWidget {
  const ArduPage4({Key? key}) : super(key: key);

  @override
  _ArduPage4State createState() => _ArduPage4State();
}

class _ArduPage4State extends State<ArduPage4> {

  @override
  Widget build(BuildContext context) {

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffEAEAEA),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                'images/panzee_1.png',
                width: width * 0.48,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                socketIO!.connect();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()), (route) => false
                );
              },
              child: Text(
                '돌아가기',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'NanumBold',
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(width * 0.53, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
