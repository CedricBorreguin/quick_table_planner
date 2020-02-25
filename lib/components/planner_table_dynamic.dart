import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_table_planner/model/chair.dart';
import 'package:quick_table_planner/model/table.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import 'package:quick_table_planner/components/chair_painter.dart';

class PlannerTableDynamic extends StatelessWidget {
  PlannerTableDynamic({
    @required this.tableModel,
    this.selected = false,
    this.touchCallback,
    this.editingPeople,
    this.removeChairCallback,
    this.addChairCallback,
  });

  final TableModel tableModel;
  final bool selected;
  final Function touchCallback;
  final Function removeChairCallback;
  final Function addChairCallback;
  final bool editingPeople;

  List<Widget> _initializeChairs(int chairAmount) {
    List<Widget> chairs = <Widget>[];
    double angleDelta = 360.0 / chairAmount;
    double angle = 0;
    for (Chair c in tableModel.getChairs()) {
      chairs.add(PlannerChair(
        angle: vmath.radians(angle),
        number: tableModel.getChairs().indexOf(c) + 1,
        isAssigned: c.isAssigned,
        tableSelected: selected,
        isFull: getAssignedCount() == 0,
      ));
      angle += angleDelta;
    }
    return chairs;
  }

  Widget getTableNumberButtons() {
    if (selected) {
      return Container(
        color: Colors.red,
        width: 90,
        height: 30.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: FlatButton(
                child: Text(
                  '-',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                onPressed: removeChairCallback,
              ),
            ),
            Expanded(
              child: Text(
                tableModel.getNumberOfChairs().toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: FlatButton(
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                onPressed: addChairCallback,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  int getAssignedCount() {
    int countNA = 0;
    for (Chair c in tableModel.getChairs()) {
      if (!c.isAssigned) {
        countNA++;
      }
    }
    return countNA;
  }

  Color getTableColor() {
    int countNA = getAssignedCount();

    if (countNA == 0) {
      return Color(0xFF00264E);
    } else {
      if (countNA < tableModel.getNumberOfChairs()) {
        return Color(0xFF2E639B);
      } else {
        return Color(0xFF8AB8E8);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: tableModel.getX().toDouble(),
      top: tableModel.getY().toDouble(),
      child:
          //GestureDetector(
          // onTap: touchCallback,
          // child:
          Container(
        width: 200.0,
        height: 200.0,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                color: selected ? Color(0x238AB8E8) : Color(0x00000000),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                color: getTableColor(),
                shape: BoxShape.circle,
              ),
            ),
            Stack(
              children: _initializeChairs(tableModel.getNumberOfChairs()),
            ),
            Positioned(
              top: selected ? 50.0 : null,
              child: Text(
                tableModel.getId(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            getTableNumberButtons(),
          ],
        ),
      ),
      // ),
    );
  }
}

class PlannerChair extends StatelessWidget {
  PlannerChair(
      {this.angle,
      this.number,
      this.isAssigned,
      this.tableSelected,
      this.isFull});

  final String assetName = 'assets/svgs/chair_shape.svg';

  final double angle;
  final int number;
  final bool isAssigned;
  final bool tableSelected;
  final bool isFull;

  Color getChairColor() {
    if (isFull) {
      return Color(0xFF00264E);
    } else {
      if (isAssigned) {
        return Color(0xFF2E639B);
      } else {
        if (tableSelected) {
          return Colors.white;
        } else {
          return Color(0xFF8AB8E8);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Transform.translate(
        offset: Offset(
          0.0,
          -75.0,
        ),
        child: Center(
          child: SizedBox(
            width: 30.0,
            height: 25.381,
            child: CustomPaint(
              painter: ChairPainter(
                text: number.toString(),
                color: getChairColor(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
