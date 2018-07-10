import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:mobileoffice/events.dart';
import '../Calendarro.dart';
import 'package:mobileoffice/ui/CircleView.dart';
import 'package:mobileoffice/WebService.dart';
import 'package:mobileoffice/ReservationsController.dart';
import 'package:mobileoffice/Models/MonthReservations.dart';
import 'package:http/http.dart' as http;

class DayTileView extends StatefulWidget {
  DateTime date;
  CalendarroState calendarro;
  DayTileView({this.date, this.calendarro});

  @override
  State<DayTileView> createState() {
    return new DayTileState(date: date);
  }
}

class DayTileState extends State<DayTileView> {
  DateTime date;
  CalendarroState calendarro;

  DayTileState({
    this.date,
    this.calendarro
  });

  @override
  Widget build(BuildContext context) {
    bool isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    var textColor = isWeekend ? Colors.grey : Colors.black;

    var today = DateTime.now();
    bool isToday = today.day == date.day &&
        today.month == date.month &&
        today.year == date.year;

    calendarro = Calendarro.of(context);
    bool isSelected = calendarro.selectedDate.day == date.day;

    BoxDecoration boxDecoration;
    if (isSelected) {
      boxDecoration =
          new BoxDecoration(color: Colors.white, shape: BoxShape.circle);
    } else if (isToday) {
      boxDecoration = new BoxDecoration(
          border: new Border.all(
            color: Colors.white,
            width: 1.0,
          ),
          shape: BoxShape.circle);
    }

    var stackChildren = <Widget>[];
    stackChildren.add(new Center(
        child: new Text(
      "${date.day}",
      textAlign: TextAlign.center,
      style: new TextStyle(color: textColor),
    )));

    if (!isWeekend) {
      var reservationsController = ReservationsController.get();
      var fullyReserved = reservationsController.isDayFullyReserved(date.day);
      var reservationsForDay = reservationsController.getReservationsForDay(date.day);
      var reservedByMe = reservationsForDay != null && reservationsForDay.isNotEmpty;
      stackChildren.add(buildSignaturesRow(fullyReserved, reservedByMe));
    }

    return new Expanded(
        child: new GestureDetector(
      child: new Container(
          height: 40.0,
          decoration: boxDecoration,
          child: new Stack(children: stackChildren)),
      onTap: handleTap,
    ));
  }

  Container buildSignaturesRow(bool occupied, bool reservedByMe) {
    var rowChildren = <Widget>[];

    if (occupied) {
      rowChildren.add(new CircleView(color: Colors.red, radius: 2.0));
    }

    if (reservedByMe) {
      if (rowChildren.isNotEmpty) {
        rowChildren.add(new Container(width: 1.0, height: 2.0));
      }
      rowChildren.add(new CircleView(color: Colors.blue, radius: 2.0));
    }
    return new Container(
      child: new Row(
        children: rowChildren,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      alignment: Alignment.topCenter,
      padding: new EdgeInsets.only(
        top: 40 * .70,
      ),
    );
  }

  void handleTap() {
    calendarro.setSelectedDate(date);
    calendarro.setCurrentDate(date);

    eventBus.fire(DayClickedEvent(date: date));

//    var webService = WebService();
//    webService.getParkingMonth().then((MonthReservations monthReservations) {
//      print(monthReservations.users);
//    });

    ReservationsController().updateReservations().then((monthReservations) {
      monthReservations.toString();
    });

    WebService().fetchPost().then((http.Response response) {
      response.body;
    });

  }
}
