// npm install express http mysql socket.io@2.3.0
// npm install -g localtunnel
// lt -s chimpanzee -p 3000
// lt 보안 오류
// 1. windows PowerShell 프로그램을 관리자 권한으로 실행합니다.
// 2. Get-ExecutionPolicy 명령어를 작성하면 본인의 권한? 상태가 보여집니다.
// 3. 권한이 RemoteSigned 가 아니라면 Set-ExecutionPolicy RemoteSigned 를 입력
// 4. Get-ExecutionPolicy 명령어로 다시 한번 확인 하면 RemoteSigned로 변경 확인.
// socket.io======================================================
var app  = require('express')();
var http = require('http').Server(app);
var io   = require('socket.io')(http);

// mysql==========================================================
// ALTER USER '[MYSQL 아이디]'@'[MYSQL 주소]' IDENTIFIED WITH mysql_native_password BY '[MYSQL 비밀번호]';
// ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '1q2w3e4r!';
// -- windows + r => services.msc mysql80 start
var mysql      = require('mysql');
var sqlConnection = mysql.createConnection({
    host     : 'localhost',
    user     : 'root',
    password : '1q2w3e4r!',
    database : 'appdb'
});
var localtunnel = require('localtunnel');

var queryString;//보기 편하려고
var typeInfo;//보기 편하려고
var to_app = "";   // 앱으로 보낼 메시지의 키
var to_ardu = "";  // 아두로 보낼 메시지의 키

http.listen(3000, function(){
    console.log('listening on *:3000');
});

io.on('connection', function(socket){
    console.log('연결');
    socket.on('from_app', function(msg){
        typeInfo = msg['type'];
        to_ardu = "ardu_re_" + msg['mac'];
        to_app = "app_re_" + msg['ID'];
        console.log('id = ', msg['ID']);
        console.log('pass = ', msg['Password']);

        //회원가입
        if(typeInfo === "sign_up"){
            console.log('=============회원가입=============');
            queryString = "SELECT * FROM appdb.account where id = '" + msg['ID'] + "';";
            sqlConnection.query(queryString, function(error, results, fields){
                if (error) {console.log('error!!!', error);}
                if(results.length == 0){
                    console.log(results.length);
                    queryString = "INSERT INTO `appdb`.`account` (`id`, `password`) VALUES ('" + msg['ID'] + "', '" + msg['Password'] + "');";
                    sqlConnection.query(queryString, function(error, results, fields){
                        if (error) {console.log('error!!!', error);}
                        console.log('회원가입 ID: ' + msg['ID'] + ' Pass: ' + msg['Password']);
                    });
                    io.emit(to_app, 'success');
                } else {
                    io.emit(to_app, 'exist');
                }
            });
        }

        //로그인
        if(typeInfo === "login"){
            console.log('=============로그인=============');
            queryString = "SELECT * FROM appdb.account where id = '" + msg['ID'] + "' and `password` =  '" + msg['Password'] + "';";
            sqlConnection.query(queryString, function(error, results, fields){
                if (error) {console.log('error!!!', error);}
                if(results.length == 0){
                    io.emit(to_app, 'wrong');
                } else if (results.length == 1) {
                    if(results[0].ardu_mac == null){
                        io.emit(to_app, results[0]);
                        io.emit(to_app, 'first');
                    } else {
                        io.emit(to_app, results[0]);
                        to_ardu = "ardu_re_" + results[0].ardu_mac // 아두로 이동
                        io.emit(to_ardu, 'valve') // 아두로 이동
                    }
                } else {
                    for (let i = 0; i < results.length; i++) {
                        io.emit(to_app, results[i]);    
                    }
                    io.emit(to_app, 'multi');
                }
            });
        }

        //밸브 상태 요청
        if(typeInfo === "valve"){
            console.log('=========밸브상태요청=========');
            io.emit(to_ardu, 'valve')
        }

        //밸브 잠금 요청
        if(typeInfo === "close"){
            console.log('=========밸브잠금요청=========');
            io.emit(to_ardu, 'close')
        }

        //기기 변경/추가
        if (typeInfo === 'setting_mul') {
            console.log('=========기기변경/추가=========');
            queryString = "SELECT * FROM appdb.account where id = '" + msg['ID'] + "' and `password` =  '" + msg['Password'] + "';";
            sqlConnection.query(queryString, function(error, results, fields){
                if (error) {console.log('error!!!', error);}
                for (let i = 0; i < results.length; i++) {
                    io.emit(to_app, results[i]);    
                }
                io.emit(to_app, 'set_mul');
            });
        }

        //추가
        if (typeInfo === 'new') {
            //INSERT INTO `appdb`.`account` (`id`, `password`) VALUES ('test1', 'test1');
            console.log('=========추가=========');
            queryString = "INSERT INTO `appdb`.`account` (`id`, `password`) VALUES ('" + msg['ID'] + "', '" + msg['Password'] + "');";
            sqlConnection.query(queryString, function(error, results, fields){
                if (error) {console.log('error!!!', error);}
                queryString = "SELECT * FROM appdb.account where (`id` = '" + msg['ID'] + "' and `ardu_mac` is null);";
                sqlConnection.query(queryString, function(error, results, fields){
                    if (error) {
                        console.log('error!!!', error);
                    } else {
                        io.emit(to_app, results[0]);
                    }
                });
            });
        }

        //이름변경
        if (typeInfo === 'name') {
            console.log('=========기기이름변경=========');
            queryString = "SELECT * FROM appdb.account where id = '" + msg['ID'] + "' and `ardu_mac` =  '" + msg['mac'] + "';";
            sqlConnection.query(queryString, function(error, results, fields){
                if (error) {console.log('error!!!', error);}
                if (results[0].ardu_name == msg['change']) {
                    io.emit(to_app, 'existName');
                } else {
                    queryString = "UPDATE `appdb`.`account` SET `ardu_name` = '" + msg['change']  + "' WHERE (`id` = '" + msg['ID'] + "' and `ardu_mac` = '" + msg['mac'] + "');";
                    sqlConnection.query(queryString, function(error, results, fields){
                        if (error) {
                            console.log('error!!!', error);
                        } else {
                            io.emit(to_app, 'changed');
                        }
                    });
                }
            });
            
        }

        //비밀번호 변경
        if(typeInfo === "pass"){
            console.log('=========비밀번호변경=========');
            queryString = "SELECT * FROM appdb.account where (id = '" + msg['ID'] + "' and `password` =  '" + msg['Password'] + "');";
            sqlConnection.query(queryString, function(error, results, fields){
                if (error) {console.log('error!!!', error);}
                if (results.length > 0) {
                    io.emit(to_app, 'existPW');
                } else {
                    queryString = "UPDATE `appdb`.`account` SET `password` = '" + msg['Password']  + "' WHERE (`id` = '" + msg['ID'] + "');";
                    sqlConnection.query(queryString, function(error, results, fields){
                        if (error) {
                            console.log('error!!!', error);
                        } else {
                            io.emit(to_app, 'successPW');
                        }
                    });
                }
            });
        }
    });

    socket.on('from_ardu', function (msg){
        typeInfo = msg['type'];
        to_ardu = "ardu_re_" + msg['arduMac'];
        to_app = "app_re_" + msg['ID'];

        // 서버에 mac등록
        if(typeInfo === 'mac'){
            console.log('==========서버에 mac등록==========');
            queryString = "UPDATE `appdb`.`account` SET `ardu_mac` = '" + msg['arduMac'] + "', `ardu_name` = '" + msg['arduMac'] + "' WHERE (`id` = '" + msg['ID'] + "' and `acc_num` = '" + msg['num'] + "');";
            sqlConnection.query(queryString, function(error, results, fields){
                if (error) {console.log('error!!!', error);}
            });
        }

        // 밸브 상태 응답,   0: 잠김, 1: 열림
        if (typeInfo === 'val'){
            console.log('==========밸브 상태 응답==========');
            queryString = "val_" + msg['arduVal'];
            io.emit(to_app, queryString);
        }

        // 잠금 요청 응답,   0: 실패, 1: 성공, 2: 캔슬됨
        if(typeInfo === 'res'){
            console.log('==========잠금 응답==========');
            queryString = "res_" + msg['arduRes'];
            io.emit(to_app, queryString);
        }

        // 가스 누출
        if(typeInfo === 'gas'){
            console.log('==========가스 누출==========');
            io.emit(to_app, 'leak');        
        }
    });
});


//오류가 나도 서버 꺼지지 않음
process.on('uncaughtException', (err) =>{
    console.error('예기치 못한 에러', err);
    // 서버를 복구하는 코드는 권장사항이 아님.
    // uncaughtException 가 콜백이 실행되는 것을 보장하지 않기 때문.
});


// sqlConnection.end();

localtunnel(3000, { subdomain: 'chimpanzee1' }, function(err, tunnel) {
    console.log('url is ' + tunnel.url);
});