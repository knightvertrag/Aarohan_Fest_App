import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class UpDownGame extends StatefulWidget {
  var coins_left;
  var fix;
  UpDownGame(this.coins_left, this.fix);
  @override
  _UpDownGameState createState() => _UpDownGameState(coins_left, fix);
}

class _UpDownGameState extends State<UpDownGame> {
  var coins_left;
  var fix;
  _UpDownGameState(this.coins_left, this.fix);
  var value;
  var result;
  var upordown;
  bool picked = false;
  var dice1 = 1;
  var dice2 = 2;
  bool _isLoading = false;
  bool help = false;

  void submit(context, result) async {
    Scaffold.of(context).showBottomSheet((context) {
      return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          Navigator.pop(context);

          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark));
        },
        child: Container(
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("THE TOTAL SUM IS $value. YOUR BET WAS 7$upordown"),
              Text(result == "winner"
                  ? "YOU WIN 10 COINS"
                  : "YOU LOSE 10 COINS"),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle(
                                statusBarColor: Colors.white,
                                systemNavigationBarIconBrightness:
                                    Brightness.dark));
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("GO BACK"),
                    ),
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          picked = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Text("PLAY AGAIN"),
                    )
                  ]),
            ],
          ),
        ),
      );
    });

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await Dio().post(
        "https://aavishkargames.herokuapp.com/sevenup/create",
        data: {"email": "romitkarmakar@gmail.com", "status": result});
    coins_left = response.data["coins"];
    setState(() {
      _isLoading = false;
    });
    print(response.data);
    await prefs.setInt('coins', coins_left);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark));
      },
      child: Scaffold(
        body: Builder(
          builder: (context) => !help
              ? SafeArea(
                  child: Container(
                    decoration: BoxDecoration(color: Color(0xFF008F23)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 5),
                            margin: EdgeInsets.all(5),
                            child: Text(
                              "Choose to bet either 7UP or 7DOWN. If the sum of your roll matches your bet, you win 10 Eurekoins! Otherwise you lose 10. ALL THE BEST",
                              style:
                                  TextStyle(fontSize: 35, color: Colors.white),
                            ),
                          ),
                          FlatButton(
                            color: Colors.white,
                            child: Text("PROCEED"),
                            onPressed: () {
                              setState(() {
                                help = true;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/dicebg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                    child: SafeArea(
                      child: Stack(children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20.0)),
                          margin: EdgeInsets.all(4.0),
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              _coinsLeft(coins_left),
                              _diceDisplay(),
                              _start(context),
                              SizedBox(
                                height: 20,
                              ),
                              picked
                                  ? Container()
                                  : Expanded(
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Expanded(
                                              child: _upButton(),
                                            ),
                                            Expanded(
                                              child: _downButton(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        FlatButton(
                          padding: EdgeInsets.fromLTRB(0, 40.0, 0, 0),
                          onPressed: () {
                            Navigator.pop(context);
                            SystemChrome.setSystemUIOverlayStyle(
                                SystemUiOverlayStyle(
                                    statusBarColor: Colors.white,
                                    systemNavigationBarIconBrightness:
                                        Brightness.dark));
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF008F23),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _coinsLeft(var coins_left) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(20.0)),
      margin: EdgeInsets.only(left: 230),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            width: 5.0,
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Container(
              child: Text(
                '$coins_left',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Image.asset('assets/coined.png'),
          ),
        ],
      ),
    );
  }

  Widget _start(context) {
    return FlatButton(
      color: Color(0xFF008F23),
      onPressed: () {
        if (!picked) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("please pick 7 UP or 7 DOWN"),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF008F23),
            elevation: 3.0,
          ));
        } else {
          if (fix == 0) {
            const oneSec = const Duration(milliseconds: 100);
            var loop = 20;
            Timer.periodic(
                oneSec,
                (Timer t) => setState(() {
                      loop--;
                      dice1 = 1 + Random().nextInt(5);
                      dice2 = 1 + Random().nextInt(5);
                      if (loop == 0) {
                        value = dice1 + dice2;
                        print(value);
                        if ((upordown == "up" && value > 7) ||
                            (upordown == "down" && value < 7)) {
                          result = "winner";
                        } else {
                          result = "loser";
                        }
                        submit(context, result);
                        t.cancel();
                      }
                    }));
          } else if (fix == 1) {
            const oneSec = const Duration(milliseconds: 100);
            var loop = 20;
            Timer.periodic(
              oneSec,
              (Timer t) => setState(
                () {
                  loop--;
                  dice1 = 1 + Random().nextInt(5);
                  dice2 = 1 + Random().nextInt(5);
                  if (loop == 0) {
                    if (upordown == "up") {
                      dice1 = 4 + Random().nextInt(2);
                      dice2 = 4 + Random().nextInt(2);
                    } else {
                      dice1 = 1 + Random().nextInt(2);
                      dice2 = 1 + Random().nextInt(2);
                    }
                    value = dice1 + dice2;
                    print(upordown);
                    print("winner$value");
                    result = "winner";
                    t.cancel();
                    submit(context, result);
                  }
                },
              ),
            );
          } else if (fix == -1) {
            const oneSec = const Duration(milliseconds: 100);
            var loop = 20;
            Timer.periodic(
              oneSec,
              (Timer t) => setState(
                () {
                  loop--;
                  dice1 = 1 + Random().nextInt(5);
                  dice2 = 1 + Random().nextInt(5);
                  if (loop == 0) {
                    if (upordown == "up") {
                      dice1 = 1 + Random().nextInt(2);
                      dice2 = 1 + Random().nextInt(2);
                    } else {
                      dice1 = 4 + Random().nextInt(2);
                      dice2 = 4 + Random().nextInt(2);
                    }
                    value = dice1 + dice2;
                    print(upordown);
                    print("loser$value");
                    result = "loser";
                    t.cancel();
                    submit(context, result);
                  }
                },
              ),
            );
          }
        }
      },
      child: Text(
        'ROLL',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white),
      ),
    );
  }

  Widget _downButton() {
    return FlatButton(
      onPressed: () {
        setState(() {
          upordown = "up";
          picked = true;
        });
      },
      child: Column(
        children: <Widget>[
          Icon(
            Icons.arrow_upward,
            size: 41,
            color: Colors.white,
          ),
          Text(
            "7",
            style: TextStyle(
              fontSize: 41,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _upButton() {
    return FlatButton(
      onPressed: () {
        setState(() {
          upordown = "down";
          picked = true;
        });
      },
      child: Column(
        children: <Widget>[
          Icon(
            Icons.arrow_downward,
            size: 41,
            color: Colors.white,
          ),
          Text(
            "7",
            style: TextStyle(
              fontSize: 41,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _diceDisplay() {
    return Expanded(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Image.asset('assets/$dice1.png'),
            ),
            Expanded(
              child: Image.asset('assets/$dice2.png'),
            ),
          ],
        ),
      ),
    );
  }
}
