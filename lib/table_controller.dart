import 'package:quick_table_planner/model/table.dart';

class TableController {
  List<TableModel> tables;
  int highlightedIndex;

  TableController({this.tables});

  void focusTable(int index) {
    if (highlightedIndex == null) {
      highlightedIndex = index;
    } else {}
  }

  void unfocusTable() {
    highlightedIndex = null;
  }
}
