import 'dart:convert';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quick_table_planner/model/chair.dart';
import 'package:screenshot/screenshot.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'package:quick_table_planner/components/planner_table_dynamic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_table_planner/model/table.dart';
import 'package:quick_table_planner/components/background_painter.dart';

enum OperationModes { main, search, assign, modify }

class TablesMatrix extends StatefulWidget {
  @override
  _TablesMatrixState createState() => _TablesMatrixState();
}

class _TablesMatrixState extends State<TablesMatrix> {
  List<TableModel> _tables = [];
  List<Widget> _tableWidgets = [];
  OperationModes _currentMode = OperationModes.main;
  int _selectedIndex;
  Firestore _db = Firestore.instance;

  bool _modified = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    addTables();
  }

  void addTables() async {
    QuerySnapshot query = await _db.collection('tables').getDocuments();

    for (DocumentSnapshot doc in query.documents) {
      List<Chair> chairs = [];
      List<dynamic> chairsList = doc['chairs'];
      if (chairsList.isNotEmpty) {
        //print(doc['chairs']);
        int count = 0;
        for (dynamic t in chairsList) {
          chairs.add(Chair(
            id: count.toString(),
            attendeeId: t.toString(),
            isAssigned: t.toString() == 'id0' ? false : true,
          ));
          //print(chairs[count].attendeeId);
          //print(chairs[count].isAssigned);
          count++;
        }
      }
      _tables.add(TableModel(
        chairs: chairs,
        numberOfChairs: int.parse(doc['number_of_chairs'].toString()),
        x: int.parse(doc['x']),
        y: int.parse(doc['y']),
        id: doc.documentID.replaceFirst('id', ''),
      ));
    }
    getTableWidgets();

    /*
    for (int j = 0; j < 6; j++) {
      for (int i = 109 + (j * 12); i < 109 + (12 * (j + 1)); i++) {
        int x = i - 109 - (j * 12);
        print(i);
        db.collection('tables').document('id$i').setData({
          'x': j.isOdd
              ? x < 6 ? 5300 - (x * 300) : 5300 - (x * 300) - 1800
              : x < 6 ? (x * 300) + x_base : (x * 300) + x_base + 1800,
          'y': y_base - ((j - 1) * 200) - ((j - 1) * 100),
          'chairs': {},
          'number_of_chairs': 10
        });
      }
    }
    */
  }

  void removeChair(TableModel table) {
    int index = _tables.indexOf(table);
    setState(() {
      _tables[index].modifyNumberOfChairs(-1);
      _tableWidgets[index] = PlannerTableDynamic(
        tableModel: _tables[index],
        selected: true,
        touchCallback: () {
          touchTable(_tables[index]);
        },
        editingPeople: false,
        addChairCallback: () {
          addChair(_tables[index]);
        },
        removeChairCallback: () {
          removeChair(_tables[index]);
        },
      );
      _modified = true;
    });
  }

  void addChair(TableModel table) {
    int index = _tables.indexOf(table);
    setState(() {
      _tables[index].modifyNumberOfChairs(1);
      _tableWidgets[index] = PlannerTableDynamic(
        tableModel: _tables[index],
        selected: true,
        touchCallback: () {
          touchTable(_tables[index]);
        },
        editingPeople: false,
        addChairCallback: () {
          addChair(_tables[index]);
        },
        removeChairCallback: () {
          removeChair(_tables[index]);
        },
      );
      _modified = true;
    });
  }

  void modifyDB(TableModel t) async {
    setState(() {
      _loading = false;
    });

    Map<dynamic, dynamic> chairs = {};

    for (Chair c in t.getChairs()) {
      if (c.isAssigned) {
        chairs['id${c.id}'] = c.attendeeId;
      }
    }

    try {
      await _db.collection('tables').document('id${t.getId()}').setData({
        'x': '${t.getX()}',
        'y': '${t.getY()}',
        'chairs': chairs,
      });
    } catch (e) {
      setState(() {
        _modified = false;
        _loading = false;
      });
    }

    setState(() {
      _modified = false;
      _loading = false;
    });
  }

  void touchTable(TableModel table) {
    int index = _tables.indexOf(table);
    print('Table: $index');
    print(_currentMode);
    switch (_currentMode) {
      case OperationModes.main:
        setState(() {
          _currentMode = OperationModes.modify;
          _selectedIndex = index;
          print(table.getId());
          _tableWidgets[index] = PlannerTableDynamic(
            tableModel: table,
            selected: true,
            touchCallback: () {
              touchTable(table);
            },
            editingPeople: false,
            addChairCallback: () {
              addChair(table);
            },
            removeChairCallback: () {
              removeChair(table);
            },
          );
        });
        break;
      case OperationModes.modify:
        var x = _selectedIndex;
        setState(() {
          _tableWidgets[x] = PlannerTableDynamic(
            tableModel: _tables[x],
            selected: false,
            touchCallback: () {
              touchTable(_tables[x]);
            },
            editingPeople: false,
            addChairCallback: () {
              addChair(_tables[x]);
            },
            removeChairCallback: () {
              removeChair(_tables[x]);
            },
          );
          _tableWidgets[index] = PlannerTableDynamic(
            tableModel: table,
            selected: true,
            touchCallback: () {
              touchTable(table);
            },
            editingPeople: false,
            addChairCallback: () {
              addChair(table);
            },
            removeChairCallback: () {
              removeChair(table);
            },
          );
          _selectedIndex = index;
        });
        break;
      case OperationModes.assign:
        break;
      case OperationModes.search:
        break;
    }
  }

  void touchOutside() {
    print('Outside');
    print(_currentMode);
    switch (_currentMode) {
      case OperationModes.main:
        break;
      case OperationModes.modify:
        var x = _selectedIndex;

        setState(() {
          _currentMode = OperationModes.main;

          _tableWidgets[_selectedIndex] = PlannerTableDynamic(
            tableModel: _tables[_selectedIndex],
            selected: false,
            touchCallback: () {
              touchTable(_tables[x]);
            },
            editingPeople: false,
            addChairCallback: () {
              addChair(_tables[x]);
            },
            removeChairCallback: () {
              removeChair(_tables[x]);
            },
          );

          _selectedIndex = null;
        });

        break;
      case OperationModes.assign:
        break;
      case OperationModes.search:
        break;
    }
  }

  void getTableWidgets() {
    List<Widget> tableWidgets = [];

    int counter = 0;
    for (TableModel t in _tables) {
      //if (counter < 20) {
      tableWidgets.add(
        PlannerTableDynamic(
          tableModel: t,
          selected: false,
          touchCallback: () {
            touchTable(t);
          },
          editingPeople: false,
          addChairCallback: () {
            addChair(t);
          },
          removeChairCallback: () {
            removeChair(t);
          },
        ),
      );
      //}
      counter++;
    }

    tableWidgets.add(
      Positioned(
        top: 3800,
        left: 0,
        child: Container(
          width: 5700.0,
          height: 400.0,
          color: Color(0xFF00264e),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 875,
                child: Container(
                  height: 130,
                  width: 1100,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'Acceso',
                      style: TextStyle(
                        fontSize: 60.0,
                        color: Color(0xFF00264e),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 3725,
                child: Container(
                  height: 130,
                  width: 1100,
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'Acceso',
                      style: TextStyle(
                        fontSize: 60.0,
                        color: Color(0xFF00264e),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/imgs/Logo_GRAD_FIUADY.png',
                  width: 700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    tableWidgets.add(
      Positioned(
        left: 1125,
        child: Container(
          height: 130,
          width: 600,
          color: Color(0xFF00264e),
          child: Center(
            child: Icon(
              Icons.wc,
              color: Colors.white,
              size: 100.0,
            ),
          ),
        ),
      ),
    );

    tableWidgets.add(
      Positioned(
        left: 3975,
        child: Container(
          height: 130,
          width: 600,
          color: Color(0xFF00264e),
          child: Center(
            child: Icon(
              Icons.wc,
              color: Colors.white,
              size: 100.0,
            ),
          ),
        ),
      ),
    );

    setState(() {
      _tableWidgets = tableWidgets;
    });
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory.path;
  }

  void _incrementCounter() async {
    screenshotController.capture().then((Io.File image) async {
      try {
        final path = await _localPath;
        final myImagePath = '$path/TablePlaner';
        final myImgDir = await Io.Directory(myImagePath).create();
        var file = Io.File('$myImagePath/capture_tables.png');
        file.writeAsBytesSync(image.readAsBytesSync());
        print(myImgDir);
      } catch (e) {
        print(e);
      }
      final result = await ImageGallerySaver.saveImage(image.readAsBytesSync());
      print(result);
    }).catchError((onError) {
      print(onError);
    });
  }

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Zoom(
        initZoom: 0.0,
        opacityScrollBars: 0.0,
        width: 5700,
        height: 4200,
        zoomSensibility: 3,
        child: Screenshot(
          controller: screenshotController,
          child: CustomPaint(
            painter: BackgroundPainter(),
            child:
                //GestureDetector(
                //behavior: HitTestBehavior.translucent,
                //onTap: touchOutside,
                //child:
                Stack(
              children: _tableWidgets,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Color(0xFF00264E),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
