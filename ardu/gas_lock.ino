#include <stdbool.h>
#include <string.h>

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <SocketIoClient.h>

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Servo.h>

ESP8266WebServer server(80);
SocketIoClient webSocket;

String sta_ssid = "";
String sta_pass = "";
String sta_user = "";
String sta_num  = "";
String sta_mac  = "";
String ap_ssid = "침팬지가스락";
bool softApOn = false;
long ap_time = 0;
long pre_time = 0;
long cnt = 0;
long times = 0;
long times2 = 0;
long times3 = 0;
String ardu_re = "";
String emit_msg = "";
int valve = 3;
// 영이===========
LiquidCrystal_I2C lcd(0x27, 16, 2);
Servo mysv;
int GasPin = A0;    // 센서 핀 설정
int piezo = D7;     // 부저 핀 설정
int sw1 = D6;       // 스위치(SW) 핀 설정
int sw2 = D2;       // 스위치(SW) 핀 설정
int state = LOW;      // 장치 상태
int reading1;          // SW 상태
int reading2;          // SW 상태
int previous1 = LOW;   // SW 이전 상태
int previous2 = LOW;
int leak = 0;
long time1 = 0;       // ON/OFF 토글된 마지막 시간
long time2 = 0;
long debounce = 100;
int res = 5;

// ===========================
void setup() {
  Serial.begin(115200);
  pinMode(GasPin ,INPUT);   // 아날로그 핀 A0를 입력모드로 설정
  pinMode(piezo, OUTPUT);   // 아날로그 핀 D7을 출력모드로 설정
  delay(200);
  Serial.println("set hard");
  hardSet();
}

void loop() {
  if(WiFi.isConnected()){
    if(millis()-times2 > 1000){
      times2 = millis();
      webSocket.loop();
      Sens();
      webSocket.loop();
    }
    webSocket.loop();
  }
  hardRun();
}

void connectSet() {
  WiFi.disconnect(true);
  WiFi.softAPdisconnect(true);
  WiFi.mode(WIFI_AP_STA);
  Serial.println("*** Starting Network Connection!***\n");
  if (sta_ssid.length()!= 0) {
    connect_STA();
  } else {
    Serial.println("SSID is not setted!");
  }
  //
  if (WiFi.status() != WL_CONNECTED) {
    connect_AP();
  }
  //
}
// sta client=======================================================
void connect_STA() {
  Serial.println("STA mode Run!");
  int count = 0; 
  WiFi.mode(WIFI_STA);
  Serial.println(WiFi.getMode());
  while (WiFi.status() != WL_CONNECTED) {
    count++;
    Serial.print(" Attempting to connect to Network named: ");
    Serial.println(sta_ssid);                   // print the network name (SSID);
    Serial.print(" Attempting to connect to Network password: ");
    Serial.println(sta_pass);
    // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
    WiFi.begin(sta_ssid, sta_pass);
    pre_time = millis();
    while(millis() - pre_time < 10000){
      if(WiFi.status() == WL_CONNECTED){
        Serial.println("");
        Serial.println("WiFi connected!!!!!!!!!!!!!");
        lcd.setCursor(0,0);
        lcd.print("WiFi Connected!");
        pre_time = millis();
        while(millis() - pre_time < 3000){
          Serial.print(".");
        }
        lcd.setCursor(0,0);
        lcd.print("Push Button!   ");
        break;
      } else {
        Serial.print(".");
      }
    }
    //
    if(WiFi.status() == WL_CONNECTED){
      ardu_re = "ardu_re_";
      ardu_re += WiFi.macAddress();
      Serial.println(ardu_re);
      connToNode();
      pre_time = millis();
      while(millis() - pre_time < 7000){
        webSocket.loop();
      }
      WiFi.setAutoReconnect(true);
      return;
    }
    //
    if (count >= 3){
      return;
    }
  }
}

void onToNode(const char* msg, size_t length){
  // -1: ASCII 코드 기준으로 문자열2(s2)가 클 때
  // 0: ASCII 코드 기준으로 두 문자열이 같을 때
  // 1: ASCII 코드 기준으로 문자열1(s1)이 클 때
  int a;

  // 잠금 요청 받음
  a = strcmp(msg, "close");
  printf("close a: %d\n", a);
  if(a == 0){
    Serial.printf("got message: %s\n", msg);
    //가스락 잠금
    gasLock();
  }

  // 상태 요청 받음
  a = strcmp(msg, "valve");
  printf("valve a: %d\n", a);
  if (a == 0){
    Serial.printf("got message: %s\n", msg);
    //밸브 상태 보내기,   0: 잠김, 1: 열림
    emit_valve();
    
  }
}

void emit_valve(){
  emit_msg = "{\"type\":\"val\", \"ID\":\"" + sta_user + "\", \"arduVal\":\"" + valve + "\"}";
  emitToNode(emit_msg.c_str());
}

void connToNode(){
  ardu_re = "ardu_re_";
  ardu_re += WiFi.macAddress();
  Serial.println(ardu_re);
  webSocket.on(ardu_re.c_str(), onToNode); //ardu_re_message == ardu_re_message_test2
  webSocket.begin("chimpanzee1.loca.lt");
  emit_msg = "{\"type\":\"mac\", \"ID\":\"" + sta_user + "\", \"arduMac\":\""+ WiFi.macAddress() +"\", \"num\":\"" + sta_num +"\"}"; 
  emitToNode(emit_msg.c_str());
}

void emitToNode(const char* msg){
  //void emit(const char* event, const char * payload = NULL);
  webSocket.emit("from_ardu", msg);
}

// ================================================================
// AP server=======================================================
void connect_AP() {
  Serial.println("AP mode Run!");
  int count = 0;
  WiFi.mode(WIFI_AP);
  Serial.println(WiFi.getMode());
  while (softApOn != WiFi.softAP(ap_ssid) ) {
    count++;
    Serial.println(softApOn);
    softApOn = WiFi.softAP(ap_ssid);
    Serial.println(softApOn);
    Serial.print(" Creating access point named: ");
    Serial.println(ap_ssid);
    //
    pre_time = millis();
    while(millis() - pre_time < 100){
      Serial.print(".");
    }
    if(count >= 3){
      Serial.println("Creating access point failed!");
      return;
    }
  }
  if (softApOn){
    if (MDNS.begin("esp8266")) {
      Serial.println("MDNS responder started");
    }
    server.on("/postform/", handleForm);
    server.onNotFound(handleNotFound);
    server.begin();
    Serial.println("HTTP server started");
    if (WiFi.softAPgetStationNum() == 0) {
      ap_time = millis();
    }
    IPAddress ip = WiFi.softAPIP();
    Serial.print("Connect IP Address: ");
    Serial.println(ip);
  }
}


void handleForm() {
  if (server.method() != HTTP_POST) {
    server.send(405, "text/plain", "Method Not Allowed");
  } else {
    String message = "POST form was:\n";

    message += server.arg(0) + ": " + server.arg(1) + ": " + server.arg(2) + ": " + server.arg(3) +"\n";
    
    sta_ssid = server.arg(0);
    sta_pass = server.arg(1);
    sta_user = server.arg(2);
    sta_num  = server.arg(3);;
    Serial.println(sta_ssid);
    Serial.println(sta_pass);
    Serial.println(sta_user);
    Serial.println(sta_num);
    server.send(200, "text/plain", message);
    pre_time = millis();
    while(millis() - pre_time < 3000){
      Serial.print(".");  
    }
    
    if(WiFi.softAPgetStationNum() > 0 ){
      WiFi.softAPdisconnect(true);
      softApOn = false;
      server.close();
    }
    if(WiFi.isConnected()){
      WiFi.disconnect();
    }
    connectSet();
    // for (uint8_t i = 0; i < server.args(); i++) {
    //   message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
    // }
  }
}

void handleNotFound() {
  String message = "File Not Found\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += (server.method() == HTTP_GET) ? "GET" : "POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";
  for (uint8_t i = 0; i < server.args(); i++) {
    message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
  }
  server.send(404, "text/plain", message);
}
// ======================================================================
// 장치동작================================================================
void gasLock(){
  res = 0;
  lcd.setCursor(0,0); 
  lcd.print("Reserved!        ");
  for(int i=0; i<7; i++){          //경고음 출력
    webSocket.loop();
    tone(piezo, 784);  // 솔
    pre_time = millis();
    while(millis() - pre_time < 200){
      webSocket.loop();
      Serial.println("wait");
    }
    tone(piezo, 1046); // 6옥타브 도
    pre_time = millis();
    while(millis() - pre_time < 200){
      webSocket.loop();
      Serial.println("wait");
    }
  }
  noTone(piezo);
  
  pre_time = millis();
  while(millis() - pre_time < 10000){
    webSocket.loop();
    reading2 = digitalRead(sw2);  // SW2 상태 읽음
    if (reading2 == HIGH && previous2 == LOW && millis() - time2 > debounce) {
      lcd.setCursor(0,0); 
      lcd.print("Push Button!   ");
      lcd.setCursor(0,1);     // 2번줄
      lcd.print("CANCEL   ");
      res = 2;
      time2 = millis();
      break;
    }
    previous2 = reading2;
  }
  if (res != 2) {
    state = HIGH;
    mysv.write(180);
    lcd.setCursor(0,1);     // 2번줄
    lcd.print("CLOSE    ");
    valve = 0;
    res = 1;
    // 잠그고 앱으로 결과 보내기,    0: 실패, 1: 성공, 2: 캔슬됨
  }
  lcd.setCursor(0,0);
  lcd.print("Push Button!      ");
  emit_msg = "{\"type\":\"res\", \"ID\":\"" + sta_user + "\", \"arduRes\":\"" + res + "\"}";
  emitToNode(emit_msg.c_str());
}

void hardSet(){
  lcd.init();
  lcd.backlight();
  pinMode(sw1, INPUT_PULLUP); // SW 를 설정, 아두이노 풀업저항 사용
  pinMode(sw2, INPUT_PULLUP);
  mysv.attach(D5);           //서보모터 5번핀 세팅
  mysv.write(180);             //180도 초기화
  valve = 0;
  lcd.setCursor(0,0);
  lcd.print("Push Button!      ");
  lcd.setCursor(0,1);
  lcd.print("PUSH!!     ");
}

void hardRun(){
  reading1 = digitalRead(sw1);  // SW 상태 읽음
  reading2 = digitalRead(sw2);  // SW2 상태 읽음
  
  //SW 가 눌려졌고 스위치 토글 눌림 경과시간이 Debounce 시간보다 크면 실행
  if (reading1 == HIGH && previous1 == LOW && millis() - time1 > debounce) {
    if (state == HIGH) { // HIGH 면 LOW 로 바꿔준다.
      state = LOW;
      mysv.write(0);
      lcd.setCursor(0,1);     // 2번줄
      lcd.print("OPEN  ");
      valve = 1;
      if(WiFi.isConnected()){
        emit_valve();
      }
      SND_O();
//      Sens();  
    } else { // LOW 면 HIGH 로 바꿔준다.
      state = HIGH;
      mysv.write(180);
      lcd.setCursor(0,1);     // 2번줄
      lcd.print("CLOSE ");
      valve = 0;
      if(WiFi.isConnected()){
        emit_valve();
      }
      SND_C();
//      Sens();  
    }
    time1 = millis();
  }
  previous1 = reading1;
  if(reading2 == HIGH && cnt == 0){
    cnt = millis();
  }
  if (cnt > 0 && reading2 == LOW){
    times = millis()-cnt;
    cnt = 0;
  }
  if(times > 5000){
    lcd.setCursor(0,0);
    lcd.print("AP Mode ON      ");
    Serial.println("btn2 5000");
    times = 0;
    connectSet();
    while(WiFi.isConnected() != true){
      if ( WiFi.softAPgetStationNum() == 0 ) {
        if (millis() - ap_time > 300000) {
          Serial.println("AP Mode down");
          WiFi.softAPdisconnect(true);
          break;
        }
      }
      server.handleClient();
    }
  }
  if(WiFi.isConnected() != true){
    Sens();  
  }
}

void Sens(){
  if(analogRead(GasPin) > 150){
    webSocket.loop();
    emit_msg = "{\"type\":\"gas\", \"ID\":\"" + sta_user + "\"}";
    emitToNode(emit_msg.c_str());
    state = HIGH;
    mysv.write(180);
    lcd.setCursor(0,0); 
    lcd.print("GasLeak DETECTED");
    lcd.setCursor(0,1);     // 2번줄
    lcd.print("CLOSE ");
    valve = 0;
    
    for(int i=0; i<7; i++){          //경고음 출력
      webSocket.loop();
      tone(piezo, 784);  // 솔
      pre_time = millis();
      while(millis() - pre_time < 200){
        webSocket.loop();
        Serial.println("wait");
      }
      tone(piezo, 1046); // 6옥타브 도
      pre_time = millis();
      while(millis() - pre_time < 200){
        webSocket.loop();
        Serial.println("wait");
      }
    }
    noTone(piezo);
    times3 = millis();
    while(true){            // 가스 누수동안 계속 돌아감 (근데 계속 안돌아감 / 왜인지는 몰?루)
      
      webSocket.loop();
      if(millis()-times3 > 1000){
        times3 = millis();
        webSocket.loop();
        if(analogRead(GasPin) < 150){
           webSocket.loop();
           if(WiFi.isConnected()){
            emit_valve();
            Serial.print("emit_valve!!!!!!!!!");
          }
          lcd.setCursor(0,0);
          lcd.print("PROBLEM SOLVED!   ");
          pre_time = millis();
          while(millis() - pre_time < 3000){
            Serial.print(".");
            webSocket.loop();
          }
          lcd.setCursor(0,0); 
          lcd.print("Push Button!     ");     
          break;            // 누수감지가 되지 않으면 반복문 종료
        } else {
          Serial.println("GasLeak");
        }
        webSocket.loop();
      }
    }
    Serial.println("GasLeak break");
  }
}

void SND_O(){
  tone(piezo, 523); // 5옥타브 도
  pre_time = millis();
  while(millis() - pre_time < 100){
    Serial.print(".");
  }
  tone(piezo, 659); // 미
  pre_time = millis();
  while(millis() - pre_time < 100){
    Serial.print(".");
  }
  tone(piezo, 784); // 솔
  pre_time = millis();
  while(millis() - pre_time < 150){
    Serial.print(".");
  }
  noTone(piezo);
}

void SND_C(){
  tone(piezo, 784); // 솔
  pre_time = millis();
  while(millis() - pre_time < 200){
    Serial.print(".");
  }
  tone(piezo, 523); // 5옥타브 도
  pre_time = millis();
  while(millis() - pre_time < 200){
    Serial.print(".");
  }
  noTone(piezo);
}
