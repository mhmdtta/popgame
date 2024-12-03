import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(TapGameApp());
}

class TapGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tap Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double characterY = 0;
  double obstacleX = 1;
  bool isGameOver = false;
  int score = 0;
  int timeLeft = 30; // Game duration in seconds
  Timer? gameTimer;
  Timer? countdownTimer;

  List<Balloon> balloons = [];
  double balloonSpawnRate = 0.02;

  void startGame() {
    isGameOver = false;
    score = 0;
    characterY = 0;
    obstacleX = 1;
    timeLeft = 30;
    balloons.clear();

    countdownTimer?.cancel();
    gameTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        if (timeLeft > 0) {
          obstacleX -= 0.05;
          if (obstacleX < -1) {
            obstacleX = 1;
            score += 1;
          }
          if ((characterY - 0.1).abs() < 0.1 && obstacleX < 0.1 && obstacleX > -0.1) {
            isGameOver = true;
            gameTimer?.cancel();
          }
          // Spawn balloons
          if (obstacleX < 0.5 && obstacleX > 0.4 && balloons.length < 3) {
            balloons.add(Balloon(id: balloons.length, x: obstacleX, y: -1, size: 50));
          }
          // Update balloons
          balloons = balloons.map((balloon) {
            balloon.y += balloonSpawnRate;
            return balloon;
          }).where((balloon) => balloon.y < 1).toList();
        } else {
          isGameOver = true;
          gameTimer?.cancel();
        }
      });
    });

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft -= 1;
        } else {
          isGameOver = true;
          countdownTimer?.cancel();
        }
      });
    });
  }

  void jump() {
    if (!isGameOver) {
      setState(() {
        characterY = -0.5;
        Timer(Duration(milliseconds: 300), () {
          setState(() {
            characterY = 0;
          });
        });
      });
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: jump,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    color: Colors.blue,
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    alignment: Alignment(characterY, 1),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    alignment: Alignment(obstacleX, 1),
                    child: Container(
                      width: 50,
                      height: 100,
                      color: Colors.red,
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, -0.8),
                    child: Text(
                      'Score: $score',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, -0.9),
                    child: Text(
                      'Time Left: $timeLeft',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  for (var balloon in balloons)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 0),
                      alignment: Alignment(balloon.x, balloon.y),
                      child: Container(
                        width: balloon.size,
                        height: balloon.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: isGameOver
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Game Over!',
                      style: TextStyle(fontSize: 36, color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: startGame,
                      child: Text('Restart'),
                    ),
                  ],
                ),
              )
                  : Center(
                child: ElevatedButton(
                  onPressed: startGame,
                  child: Text('Start Game'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Balloon {
  int id;
  double x;
  double y;
  double size;

  Balloon({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
  });
}
