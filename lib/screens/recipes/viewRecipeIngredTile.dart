import 'package:flutter/material.dart';

class ViewRecipeIngredTile extends StatelessWidget {
  final String name;
  final String quantity;
  final String unit;
  ViewRecipeIngredTile({this.name, this.quantity, this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(0.0),
        child: Wrap(
          children: <Widget>[
            Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.top,
                border: TableBorder.symmetric(
                    inside: BorderSide(width: 3, color: Colors.blue[200]),
                    outside: BorderSide(width: 3, color: Colors.blue[200])),
                defaultColumnWidth: FixedColumnWidth(150),
                children: [
                  TableRow(children: [
                    TableCell(
                        child: Center(
                            child: Text(name,
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 18,
                                    height: 1.8)))),
                    TableCell(
                        child: Center(
                            child: Text(quantity + '  ' + unit,
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 18,
                                    height: 1.8)))),
                  ])
                ])
          ],
          alignment: WrapAlignment.center,
        ));
  }
}
