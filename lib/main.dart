import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xomobileapp/history.dart';
import 'utils.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'ฝึกสหกิจ';

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    theme: ThemeData(
      primaryColor: Colors.blue,
    ),
    home: MainPage(title: title),
  );
}

class MainPage extends StatefulWidget {
  final String title;


  const MainPage({
    required this.title,
  });


  @override
  _MainPageState createState() => _MainPageState();
}

class Player {
  static const none = '';
  static const X = 'X';
  static const O = 'O';
}

class _MainPageState extends State<MainPage> {
  var PlayerW= new TextEditingController();
  var Matrix= new TextEditingController();
  var Datetime= new TextEditingController();

  List<History> hisList=new List.filled(0, History.empty(),growable: true);
  List<GameHistory> gamList=new List.filled(0, GameHistory.empty(),growable: true);

  int PlayX=0;
  int PlayO=0;
  int PlayDraw=0;

  List Matrix1=[];

  int dropdownValue = 3;
  int countMatrix = 3;
  static final double size = 92;

  String lastMove = Player.none;
  late List<List<String>> matrix;

  @override
  void initState() {
    super.initState();
    setEmptyFields();
  }

  void setEmptyFields() => setState(() => matrix = List.generate(
    countMatrix,
        (_) => List.generate(countMatrix, (_) => Player.none),
  ));

  Color getBackgroundColor() {
    final thisMove = lastMove == Player.X ? Player.O : Player.X;

    return getFieldColor(thisMove).withAlpha(150);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: getBackgroundColor(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: ListView(
          padding:  EdgeInsets.fromLTRB(0, 30, 0, 30),
          children: [
            Text(
              'XO Game',
              style: TextStyle(fontSize: 70,fontFamily: 'Roboto'),
              textAlign:  TextAlign.center,
            ),
            Center(
              child: DropdownButton<int>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    countMatrix=dropdownValue;
                    setEmptyFields();
                  });
                },
                items: <int>[3,4,5,6,7,8]
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: Utils.modelBuilder(matrix, (x, value) => buildRow(x)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    showHistoryDialog();
                  },
                  child: Text('History'),
                ),
              ),
            )
          ],
        ),
      )
  );

  Widget buildRow(int x) {
    final values = matrix[x];
    print(x);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Utils.modelBuilder(
        values,
            (y, value) => buildField(x, y),
      ),
    );
  }

  Color getFieldColor(String value) {
    switch (value) {
      case Player.O:
        return Colors.blue;
      case Player.X:
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  Widget buildField(int x, int y) {
    final value = matrix[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(size, size),
          primary: color,
        ),
        child: Text(value, style: TextStyle(fontSize: 32)),
        onPressed: () => selectField(value, x, y),
      ),
    );
  }

  void selectField(String value, int x, int y) {
    DateTime now = DateTime.now();
    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;



      setState(() {
        lastMove = newValue;
        matrix[x][y] = newValue;
      });

      if (isWinner(x, y)) {
        showEndDialog('Player $newValue Won');
        if(newValue=='X'){
          PlayX++;
        }
        else{
          PlayO++;
        }
        History history = new History('$newValue', countMatrix.toString()+' * '+countMatrix.toString(), now.toString());
        hisList.add(history);
        Matrix1.add(matrix);
        print(hisList);
        print(matrix);
        print('$newValue'+countMatrix.toString()+' * '+countMatrix.toString()+now.toString());
      } else if (isEnd()) {
        showEndDialog('Undecided Game');
        PlayDraw++;
        History history = new History('Draw', countMatrix.toString()+' * '+countMatrix.toString(), now.toString());
        hisList.add(history);
        Matrix1.add(matrix);
        print(hisList);
        print(matrix);
        print('$newValue'+countMatrix.toString()+' * '+countMatrix.toString()+now.toString());
      }


    }
  }

  bool isEnd() =>
      matrix.every((values) => values.every((value) => value != Player.none));

  bool isWinner(int x, int y) {
    var col = 0, row = 0, diag = 0, rdiag = 0;
    final player = matrix[x][y];
    final n = countMatrix;

    for (int i = 0; i < n; i++) {
      if (matrix[x][i] == player) col++;
      if (matrix[i][y] == player) row++;
      if (matrix[i][i] == player) diag++;
      if (matrix[i][n - i - 1] == player) rdiag++;
    }

    return row == n || col == n || diag == n || rdiag == n;
  }

  Future showEndDialog(String title) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text('Press to Restart the Game'),
      actions: [
        ElevatedButton(
          onPressed: () {
            setEmptyFields();
            Navigator.of(context).pop();
          },
          child: Text('Restart'),
        )
      ],
    ),
  );
  Future showHistoryDialog() => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ประวัติการเล่น'),
          content: Container(
            width: double.maxFinite,
            child:
            ListView.builder(itemCount: hisList.length,
              itemBuilder: (BuildContext buildContext,int index){
                return ListTile(
                  title: Text('ครั้งที่ '+(index+1).toString()),
                  subtitle: Text('ผู้เล่นที่ชนะคือ '+hisList[index].PlayerW+'  ขนาดตารางที่เล่น  '+hisList[index].Matrix + '   เวลาที่เล่น  ' + hisList[index].Datetime),
                  leading: TextButton(
                      onPressed: (){
                        showGameHistoryDialog(index);
                      },
                      child: Text(
                            'ดูเกมการเล่น'
                  )),
                );
              },
            ),
          ),
          actions: [
            Text(
                'Player X ชนะ  $PlayX  ครั้ง     Player O ชนะ  $PlayO  ครั้ง     เสมอ  $PlayDraw  ครั้ง'
            ),
            ElevatedButton(
              onPressed: () {
                setEmptyFields();
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      }
  );

  Future showGameHistoryDialog(int i) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ประวัติการเล่น'),
          content: Center(
              child: Text(
                '---------------------'+Matrix1[i].toString().replaceAll('[', '\n').replaceAll(']', ' ').replaceAll(' ', '      ')+'\n\n---------------------'
                ,style: TextStyle(fontSize: 20),
              ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setEmptyFields();
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      }
  );
}

