import 'chair.dart';

class TableModel {
  List<Chair> chairs;
  int numberOfChairs;
  int x;
  int y;
  String id;

  TableModel({this.chairs, this.numberOfChairs, this.x, this.y, this.id});

  String getId() {
    return this.id;
  }

  int getNumberOfChairs() {
    return this.numberOfChairs;
  }

  int getX() {
    return this.x;
  }

  int getY() {
    return this.y;
  }

  void modifyNumberOfChairs(int delta) {
    this.numberOfChairs = this.numberOfChairs + delta;
  }

  List<Chair> getChairs() {
    return this.chairs;
  }
}
