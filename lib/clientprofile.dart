//import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import './popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ClientsList.dart';
import 'globals.dart' as globals;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'managerbusiness.dart';
// import 'dart:html' as html;
// html.window.location.reload() {
//   // ignore: todo
//   // TODO: implement reload
//   throw UnimplementedError();
// }

List datasetval = [];
String emptyval = "";
bool isloaded = false;

class ClientProfile extends StatefulWidget {
  int selectedPage;
  ClientProfile(this.selectedPage);
  // const ClientProfile({Key? key}) : super(key: key);
  @override
  _ClientProfileState createState() => _ClientProfileState(this.selectedPage);
}

class _ClientProfileState extends State<ClientProfile> {
  int selectedPage;
  _ClientProfileState(this.selectedPage);
  String date = "";

  _selectDate(BuildContext context) async {
    final DateTimeRange? selected = await showDateRangePicker(
      context: context,
      // initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
      saveText: 'Done',
    );
    //  if (selected != null && selected != selectedDate) {
    setState(() {
      //  selectedDate = selected;
      //  globals.selectDate = selected as String;
      globals.fromDate = selected!.start.toString().split(' ')[0];
      globals.ToDate = selected.end.toString().split(' ')[0];
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             ClientProfile(int.parse(globals.tab_index.toString()))));
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    //   super.build(context);
    return DefaultTabController(
      initialIndex: selectedPage,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff123456),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: Icon(Icons.arrow_back)),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.date_range_outlined),
              onPressed: () {
                _selectDate(context);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.verified_user), text: 'Sales'),
              Tab(icon: Icon(Icons.directions_transit), text: 'Ledger'),
              Tab(icon: Icon(Icons.money_outlined), text: 'Payments'),
              Tab(icon: Icon(Icons.money_outlined), text: 'Credits'),
              Tab(icon: Icon(Icons.money_outlined), text: 'Debits'),
            ],
            isScrollable: true,
          ),
          title: Text(globals.clientName.toString()),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SalesTabPage(0),
            LedgerTabPage(1),
            PaymentsTabPage(2),
            CreditNoteTransactionsTab(3),
            DebitNoteTransactionsTab(4)
          ],
        ),
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;
}

class SalesTabPage extends StatefulWidget {
  int selectedtab;
  //globals.tab_index=selectedtab;
  SalesTabPage(this.selectedtab);

  @override
  _SalesTabPageState createState() => _SalesTabPageState(this.selectedtab);
}

class _SalesTabPageState extends State<SalesTabPage> {
  int selectedIndex;
  var selecteFromdt = '';
  var selecteTodt = '';
  _SalesTabPageState(this.selectedIndex);

  @override
  Widget build(BuildContext context) {
    globals.tab_index = this.selectedIndex.toString();
    final DateFormat formatter1 = DateFormat('dd-MMM-yyyy');
    var now = DateTime.now();

    if (globals.fromDate != "") {
      selecteFromdt = globals.fromDate;
      selecteTodt = globals.ToDate;
    } else if (selecteTodt == '') {
      selecteFromdt = formatter1.format(now);
      selecteTodt = formatter1.format(now);
    }

    Future<List<SalesTransactions>> _fetchSaleTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';
      // List listresponse = [];

      Map data = {
        "ReferalId": globals.selectedClientid,
        "session_id": "1",
        "From_Date": selecteFromdt,
        "To_Date": selecteTodt,
        "TYPE": "a",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/UnbilledTransactionClient');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        //  globals.fromDate = '';
        // globals.ToDate = '';
        Map<String, dynamic> resposne = jsonDecode(response.body);
        List jsonResponse = resposne[dsetName];

        return jsonResponse
            .map((strans) => new SalesTransactions.fromJson(strans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSales = Container(
      //height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<SalesTransactions>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              }
              var data = snapshot.data;
              return tabsListView(data, context, 'S');
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: Colors.primaries,
                  strokeWidth: 4.0,
                  //   pathBackgroundColor:ColorSwatch(Action[])
                ),
              ),
            );
          }),
    );
    Widget _buildDatesCard(data, index) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        // height: double.infinity,
        // width: 80,
        //color: Colors.white,
        child: TextButton(
          child: Text(
            data["Frequency"],
            style: const TextStyle(fontSize: 12.0),
          ),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                // side: BorderSide(color: Colors.red)
              )),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.red),
              backgroundColor: selectedIndex == index && globals.fromDate == ''
                  ? MaterialStateColor.resolveWith((states) => Colors.pink)
                  : MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              shadowColor:
                  MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              foregroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.white)),
          onPressed: () {
            print(index.toString());
            setState(() {
              // globals.selectDate = '';
              globals.fromDate = '';
              globals.ToDate = '';
              selectedIndex = index;
              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = DateTime.now();
              var yesterday = now.subtract(const Duration(days: 1));
              //   var lastweek = now.subtract(const Duration(days: 7));

              var thisweek = now.subtract(Duration(days: now.weekday - 1));
              var lastWeek1stDay =
                  thisweek.subtract(Duration(days: thisweek.weekday + 6));
              var lastWeekLastDay =
                  thisweek.subtract(Duration(days: thisweek.weekday - 0));
              var thismonth = DateTime(now.year, now.month, 1);

              var prevMonth1stday = DateTime.utc(
                  DateTime.now().year, DateTime.now().month - 1, 1);
              var prevMonthLastday = DateTime.utc(
                DateTime.now().year,
                DateTime.now().month - 0,
              ).subtract(Duration(days: 1));

              if (selectedIndex == 0) {
                // Today
                selecteFromdt = formatter.format(now);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 1) {
                // yesterday
                selecteFromdt = formatter.format(yesterday);
                selecteTodt = formatter.format(yesterday);
              } else if (selectedIndex == 2) {
                // LastWeek
                selecteFromdt = formatter.format(lastWeek1stDay);
                selecteTodt = formatter.format(lastWeekLastDay);
              } else if (selectedIndex == 3) {
                selecteFromdt = formatter.format(thisweek);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 4) {
                // Last Month
                selecteFromdt = formatter.format(prevMonth1stday);
                selecteTodt = formatter.format(prevMonthLastday);
              } else if (selectedIndex == 5) {
                selecteFromdt = formatter.format(thismonth);
                selecteTodt = formatter.format(now);
              }

              print("From Date " + selecteFromdt);
              print("To Date " + selecteTodt);
            });
          },
          onLongPress: () {
            print('Long press');
          },
        ),
      );
    }

    ListView datesListView() {
      var myData = [
        {
          "FrequencyId": "1",
          "Frequency": "Today",
        },
        {
          "FrequencyId": "2",
          "Frequency": "Yesterday",
        },
        {
          "FrequencyId": "3",
          "Frequency": "Last Week",
        },
        {
          "FrequencyId": "4",
          "Frequency": "This Week",
        },
        {
          "FrequencyId": "5",
          "Frequency": "Last Month",
        },
        {
          "FrequencyId": "6",
          "Frequency": "This Month",
        }
      ];

      return ListView.builder(
          itemCount: myData.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            // return  Text(myData[index]["Frequency"].toString());
            return _buildDatesCard(myData[index], index);
          });
    }

    Widget DateSelection() {
      return Container(child: datesListView());
    }

    return Column(
      children: [
        // _buildClientHeaderSales(context),
        SizedBox(height: 48, child: DateSelection()),
        SizedBox(
            height: 15,
            child: Text(selecteFromdt + ' To ' + selecteTodt,
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0))),
        Container(
          height: MediaQuery.of(context).size.height / 1.44,
          child: verticalListSales,
        ),
      ],
    );
  }
}

class LedgerTabPage extends StatefulWidget {
  // const LedgerTabPage({Key? key}) : super(key: key);
  int selectedtab;
  LedgerTabPage(this.selectedtab);
  @override
  _LedgerTabPageState createState() => _LedgerTabPageState(this.selectedtab);
}

class _LedgerTabPageState extends State<LedgerTabPage> {
  int selectedIndex;
  var selecteFromdt = '';
  var selecteTodt = '';
  _LedgerTabPageState(this.selectedIndex);
  @override
  Widget build(BuildContext context) {
    globals.tab_index = this.selectedIndex.toString();
    final DateFormat formatter1 = DateFormat('dd-MMM-yyyy');
    var now = DateTime.now();

    if (globals.fromDate != "") {
      selecteFromdt = globals.fromDate;
      selecteTodt = globals.ToDate;
    } else if (selecteTodt == '') {
      selecteFromdt = formatter1.format(now);
      selecteTodt = formatter1.format(now);
    }

    Widget _buildDatesCard(data, index) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextButton(
          child: Text(
            data["Frequency"],
            style: const TextStyle(fontSize: 12.0),
          ),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              )),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.red),
              backgroundColor: selectedIndex == index && globals.fromDate == ''
                  ? MaterialStateColor.resolveWith((states) => Colors.pink)
                  : MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              shadowColor:
                  MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              foregroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.white)),
          onPressed: () {
            print(index.toString());
            setState(() {
              // globals.selectDate = '';
              globals.fromDate = '';
              globals.ToDate = '';
              selectedIndex = index;

              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = new DateTime.now();
              var yesterday = now.subtract(Duration(days: 1));
              //  var lastweek = now.subtract(Duration(days: 7));
              var prevMonth1stday = DateTime.utc(
                  DateTime.now().year, DateTime.now().month - 1, 1);
              var prevMonthLastday = DateTime.utc(
                DateTime.now().year,
                DateTime.now().month - 0,
              ).subtract(Duration(days: 1));
              var thisweek = now.subtract(Duration(days: now.weekday - 1));
              var lastWeek1stDay =
                  thisweek.subtract(Duration(days: thisweek.weekday + 6));
              var lastWeekLastDay =
                  thisweek.subtract(Duration(days: thisweek.weekday - 0));
              var thismonth = new DateTime(now.year, now.month, 1);

              if (selectedIndex == 0) {
                // Today
                selecteFromdt = formatter.format(now);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 1) {
                // yesterday
                selecteFromdt = formatter.format(yesterday);
                selecteTodt = formatter.format(yesterday);
              } else if (selectedIndex == 2) {
                // LastWeek
                selecteFromdt = formatter.format(lastWeek1stDay);
                selecteTodt = formatter.format(lastWeekLastDay);
              } else if (selectedIndex == 3) {
                selecteFromdt = formatter.format(thisweek);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 4) {
                // Last Month
                selecteFromdt = formatter.format(prevMonth1stday);
                selecteTodt = formatter.format(prevMonthLastday);
              } else if (selectedIndex == 5) {
                selecteFromdt = formatter.format(thismonth);
                selecteTodt = formatter.format(now);
              }

              print("From Date " + selecteFromdt);
              print("To Date " + selecteTodt);
            });
          },
          onLongPress: () {
            print('Long press');
          },
        ),
      );
    }

    ListView datesListView() {
      var myData = [
        {
          "FrequencyId": "1",
          "Frequency": "Today",
        },
        {
          "FrequencyId": "2",
          "Frequency": "Yesterday",
        },
        {
          "FrequencyId": "3",
          "Frequency": "Last Week",
        },
        {
          "FrequencyId": "4",
          "Frequency": "This Week",
        },
        {
          "FrequencyId": "5",
          "Frequency": "Last Month",
        },
        {
          "FrequencyId": "6",
          "Frequency": "This Month",
        }
      ];

      return ListView.builder(
          itemCount: myData.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return _buildDatesCard(myData[index], index);
          });
    }

    Widget DateSelection() {
      return Container(child: datesListView());
    }

    Future<List<LedgerTransactions>> _fetchLedgerTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';

      Map data = {
        "Client_id": globals.selectedClientid,
        "session_id": "1",
        "From_Date": selecteFromdt,
        "To_Date": selecteTodt,
        "TYPE": "a",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };

      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/ClientLedgerDet');

      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> resposne = jsonDecode(response.body);
        List jsonResponse = resposne[dsetName];

        return jsonResponse
            .map((ltrans) => new LedgerTransactions.fromJson(ltrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListLedger = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<LedgerTransactions>>(
          future: _fetchLedgerTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              }
              var data = snapshot.data;
              return tabsListView(data, context, 'L');
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: Colors.primaries,
                  strokeWidth: 4.0,
                  //   pathBackgroundColor:ColorSwatch(Action[])
                ),
              ),
            );
          }),
    );

    return Column(
      children: [
        SizedBox(height: 48, child: DateSelection()),
        SizedBox(
            height: 15,
            child: Text(selecteFromdt + ' To ' + selecteTodt,
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: verticalListLedger,
        ),
      ],
    );
  }
}

class PaymentsTabPage extends StatefulWidget {
  // const PaymentsTabPage({Key? key}) : super(key: key);
  int selectedtab;
  PaymentsTabPage(this.selectedtab);
  @override
  _PaymentsTabPageState createState() =>
      _PaymentsTabPageState(this.selectedtab);
}

class _PaymentsTabPageState extends State<PaymentsTabPage> {
  int selectedtab;
  _PaymentsTabPageState(this.selectedtab);

  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

  @override
  Widget build(BuildContext context) {
    globals.tab_index = this.selectedIndex.toString();
    final DateFormat formatter1 = DateFormat('dd-MMM-yyyy');
    var now = new DateTime.now();

    if (globals.fromDate != "") {
      selecteFromdt = globals.fromDate;
      selecteTodt = globals.ToDate;
    } else if (selecteTodt == '') {
      selecteFromdt = formatter1.format(now);
      selecteTodt = formatter1.format(now);
    }

    Widget _buildDatesCard(data, index) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        // height: double.infinity,
        // width: 80,
        //color: Colors.white,
        child: TextButton(
          child: Text(
            data["Frequency"],
            style: const TextStyle(fontSize: 12.0),
          ),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                // side: BorderSide(color: Colors.red)
              )),
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.red),
              backgroundColor: selectedIndex == index && globals.fromDate == ''
                  ? MaterialStateColor.resolveWith((states) => Colors.pink)
                  : MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              shadowColor:
                  MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              foregroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.white)),
          onPressed: () {
            print(index.toString());
            setState(() {
              // globals.selectDate = '';
              globals.fromDate = '';
              globals.ToDate = '';
              selectedIndex = index;

              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = new DateTime.now();
              var yesterday = now.subtract(Duration(days: 1));
              //   var lastweek = now.subtract(Duration(days: 7));
              var prevMonth1stday = DateTime.utc(
                  DateTime.now().year, DateTime.now().month - 1, 1);
              var prevMonthLastday = DateTime.utc(
                DateTime.now().year,
                DateTime.now().month - 0,
              ).subtract(Duration(days: 1));
              var thisweek = now.subtract(Duration(days: now.weekday - 1));
              var lastWeek1stDay =
                  thisweek.subtract(Duration(days: thisweek.weekday + 6));
              var lastWeekLastDay =
                  thisweek.subtract(Duration(days: thisweek.weekday - 0));
              var thismonth = new DateTime(now.year, now.month, 1);

              if (selectedIndex == 0) {
                // Today
                selecteFromdt = formatter.format(now);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 1) {
                // yesterday
                selecteFromdt = formatter.format(yesterday);
                selecteTodt = formatter.format(yesterday);
              } else if (selectedIndex == 2) {
                // LastWeek
                selecteFromdt = formatter.format(lastWeek1stDay);
                selecteTodt = formatter.format(lastWeekLastDay);
              } else if (selectedIndex == 3) {
                selecteFromdt = formatter.format(thisweek);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 4) {
                // Last Month
                selecteFromdt = formatter.format(prevMonth1stday);
                selecteTodt = formatter.format(prevMonthLastday);
              } else if (selectedIndex == 5) {
                selecteFromdt = formatter.format(thismonth);
                selecteTodt = formatter.format(now);
              }

              print("From Date " + selecteFromdt);
              print("To Date " + selecteTodt);

              // _fetchSaleTransaction();
            });
          },
          onLongPress: () {
            print('Long press');
          },
        ),
      );
    }

    ListView datesListView() {
      var myData = [
        {
          "FrequencyId": "1",
          "Frequency": "Today",
        },
        {
          "FrequencyId": "2",
          "Frequency": "Yesterday",
        },
        {
          "FrequencyId": "3",
          "Frequency": "Last Week",
        },
        {
          "FrequencyId": "4",
          "Frequency": "This Week",
        },
        {
          "FrequencyId": "5",
          "Frequency": "Last Month",
        },
        {
          "FrequencyId": "6",
          "Frequency": "This Month",
        }
      ];

      return ListView.builder(
          itemCount: myData.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            // return  Text(myData[index]["Frequency"].toString());
            return _buildDatesCard(myData[index], index);
          });
    }

    Widget DateSelection() {
      return Container(child: datesListView());
    }

    Future<List<PaymentTransactions>> _fetchPaymentTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';
      // Map data={};

      Map data = {
        "ReferalId": globals.selectedClientid,
        "session_id": "1",
        "From_Date": selecteFromdt,
        "To_Date": selecteTodt,
        "TYPE": "a",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };

      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/PaymentForReferal');
      print(data);
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        //List jsonResponse = json.decode(response.body);
        Map<String, dynamic> resposne = jsonDecode(response.body);
        List jsonResponse = resposne[dsetName];
        return jsonResponse
            .map((ptrans) => new PaymentTransactions.fromJson(ptrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListLedger = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      // height: MediaQuery.of(context).size.height,
      // width: MediaQuery.of(context).size.width,
      child: FutureBuilder<List<PaymentTransactions>>(
          future: _fetchPaymentTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return tabsListView(data, context, 'P');
              }
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: Colors.primaries,
                  strokeWidth: 4.0,
                  //   pathBackgroundColor:ColorSwatch(Action[])
                ),
              ),
            );
          }),
    );

    return Column(
      children: [
        SizedBox(height: 48, child: DateSelection()),
        SizedBox(
            height: 15,
            child: Text(selecteFromdt + ' To ' + selecteTodt,
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: verticalListLedger,
        ),
      ],
    );
  }
}

class CreditNoteTransactionsTab extends StatefulWidget {
  //const CreditNoteTransactionsTab({Key? key}) : super(key: key);

  int selectedtab;
  CreditNoteTransactionsTab(this.selectedtab);
  @override
  _CreditNoteTransactionsTabState createState() =>
      _CreditNoteTransactionsTabState(this.selectedtab);
}

class _CreditNoteTransactionsTabState extends State<CreditNoteTransactionsTab> {
  int selectedtab;
  _CreditNoteTransactionsTabState(this.selectedtab);

  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

  @override
  Widget build(BuildContext context) {
    globals.tab_index = this.selectedIndex.toString();
    final DateFormat formatter1 = DateFormat('dd-MMM-yyyy');
    var now = new DateTime.now();

    if (globals.fromDate != "") {
      selecteFromdt = globals.fromDate;
      selecteTodt = globals.ToDate;
    } else if (selecteTodt == '') {
      selecteFromdt = formatter1.format(now);
      selecteTodt = formatter1.format(now);
    }

    Future<List<CreditNoteTransactions>> _fetchSaleTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Referalid": globals.selectedClientid,
        "session_id": "1",
        "FromDate": selecteFromdt,
        "ToDate": selecteTodt,
        "TYPE": "a",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };

      dsetName = 'Data';
      jobsListAPIUrl = Uri.parse(globals.API_url + '/MobileSales/CreditNote');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        print('before fetch list method');
        Map<String, dynamic> jsonresponse = jsonDecode(response.body);
        print(jsonresponse.containsKey('Data'));
        listresponse = jsonresponse[dsetName];
        return listresponse
            .map((cntrnans) => new CreditNoteTransactions.fromJson(cntrnans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSales = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      //height: 50.0,
      // height: 450.0,
      // height: MediaQuery.of(context).size.height,
      // width: MediaQuery.of(context).size.width,
      child: FutureBuilder<List<CreditNoteTransactions>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return tabsListView(data, context, 'CN');
              }
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: Colors.primaries,
                  strokeWidth: 4.0,
                  //   pathBackgroundColor:ColorSwatch(Action[])
                ),
              ),
            );
          }),
    );

    Widget _buildDatesCard(data, index) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        // height: double.infinity,
        // width: 80,
        //color: Colors.white,
        child: TextButton(
          child: Text(
            data["Frequency"],
            style: const TextStyle(fontSize: 12.0),
          ),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                // side: BorderSide(color: Colors.red)
              )),
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.red),
              backgroundColor: selectedIndex == index && globals.fromDate == ''
                  ? MaterialStateColor.resolveWith((states) => Colors.pink)
                  : MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              shadowColor:
                  MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              foregroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.white)),
          onPressed: () {
            print(index.toString());
            setState(() {
              // globals.selectDate = '';
              globals.fromDate = '';
              globals.ToDate = '';
              selectedIndex = index;

              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = new DateTime.now();
              var yesterday = now.subtract(Duration(days: 1));
              // var lastweek = now.subtract(Duration(days: 7));
              var prevMonth1stday = DateTime.utc(
                  DateTime.now().year, DateTime.now().month - 1, 1);
              var prevMonthLastday = DateTime.utc(
                DateTime.now().year,
                DateTime.now().month - 0,
              ).subtract(Duration(days: 1));
              var thisweek = now.subtract(Duration(days: now.weekday - 1));
              var lastWeek1stDay =
                  thisweek.subtract(Duration(days: thisweek.weekday + 6));
              var lastWeekLastDay =
                  thisweek.subtract(Duration(days: thisweek.weekday - 0));
              var thismonth = new DateTime(now.year, now.month, 1);

              if (selectedIndex == 0) {
                // Today
                selecteFromdt = formatter.format(now);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 1) {
                // yesterday
                selecteFromdt = formatter.format(yesterday);
                selecteTodt = formatter.format(yesterday);
              } else if (selectedIndex == 2) {
                // LastWeek
                selecteFromdt = formatter.format(lastWeek1stDay);
                selecteTodt = formatter.format(lastWeekLastDay);
              } else if (selectedIndex == 3) {
                selecteFromdt = formatter.format(thisweek);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 4) {
                // Last Month
                selecteFromdt = formatter.format(prevMonth1stday);
                selecteTodt = formatter.format(prevMonthLastday);
              } else if (selectedIndex == 5) {
                selecteFromdt = formatter.format(thismonth);
                selecteTodt = formatter.format(now);
              }

              print("From Date " + selecteFromdt);
              print("To Date " + selecteTodt);
            });
          },
          onLongPress: () {
            print('Long press');
          },
        ),
      );
    }

    ListView datesListView() {
      var myData = [
        {
          "FrequencyId": "1",
          "Frequency": "Today",
        },
        {
          "FrequencyId": "2",
          "Frequency": "Yesterday",
        },
        {
          "FrequencyId": "3",
          "Frequency": "Last Week",
        },
        {
          "FrequencyId": "4",
          "Frequency": "This Week",
        },
        {
          "FrequencyId": "5",
          "Frequency": "Last Month",
        },
        {
          "FrequencyId": "6",
          "Frequency": "This Month",
        }
      ];

      return ListView.builder(
          itemCount: myData.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            // return  Text(myData[index]["Frequency"].toString());
            return _buildDatesCard(myData[index], index);
          });
    }

    Widget DateSelection() {
      return Container(child: datesListView());
    }

    return Column(
      children: [
        SizedBox(height: 48, child: DateSelection()),
        SizedBox(
            height: 15,
            child: Text(selecteFromdt + ' To ' + selecteTodt,
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: verticalListSales,
        ),
      ],
    );
  }
}

class DebitNoteTransactionsTab extends StatefulWidget {
  //const DebitNoteTransactionsTab({Key? key}) : super(key: key);
  int selectedtab;
  DebitNoteTransactionsTab(this.selectedtab);
  @override
  _DebitNoteTransactionsTabState createState() =>
      _DebitNoteTransactionsTabState(this.selectedtab);
}

class _DebitNoteTransactionsTabState extends State<DebitNoteTransactionsTab> {
  int selectedtab;
  _DebitNoteTransactionsTabState(this.selectedtab);

  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

  @override
  Widget build(BuildContext context) {
    globals.tab_index = this.selectedIndex.toString();
    final DateFormat formatter1 = DateFormat('dd-MMM-yyyy');
    var now = new DateTime.now();

    if (globals.fromDate != "") {
      selecteFromdt = globals.fromDate;
      selecteTodt = globals.ToDate;
    } else if (selecteTodt == '') {
      selecteFromdt = formatter1.format(now);
      selecteTodt = formatter1.format(now);
    }

    Future<List<DebitNoteTransactions>> _fetchSaleTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Referalid": globals.selectedClientid,
        "session_id": "1",
        "FromDate": selecteFromdt,
        "ToDate": selecteTodt,
        "TYPE": "a",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };

      dsetName = 'Data';
      jobsListAPIUrl = Uri.parse(globals.API_url + '/MobileSales/DebitNote');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        print('before fetch list method');
        Map<String, dynamic> jsonresponse = jsonDecode(response.body);
        print(jsonresponse.containsKey('Data'));
        listresponse = jsonresponse[dsetName];
        return listresponse
            .map((dbttrans) => new DebitNoteTransactions.fromJson(dbttrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSales = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      //height: 50.0,
      // height: 450.0,
      // height: MediaQuery.of(context).size.height,
      // width: MediaQuery.of(context).size.width,
      child: FutureBuilder<List<DebitNoteTransactions>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return tabsListView(data, context, 'DN');
              }
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: Colors.primaries,
                  strokeWidth: 4.0,
                  //   pathBackgroundColor:ColorSwatch(Action[])
                ),
              ),
            );
          }),
    );

    Widget _buildDatesCard(data, index) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        // height: double.infinity,
        // width: 80,
        //color: Colors.white,
        child: TextButton(
          child: Text(
            data["Frequency"],
            style: const TextStyle(fontSize: 12.0),
          ),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                // side: BorderSide(color: Colors.red)
              )),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.red),
              backgroundColor: selectedIndex == index && globals.fromDate == ''
                  ? MaterialStateColor.resolveWith((states) => Colors.pink)
                  : MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              shadowColor:
                  MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              foregroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.white)),
          onPressed: () {
            print(index.toString());
            setState(() {
              globals.selectDate = '';
              selectedIndex = index;

              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = new DateTime.now();
              var yesterday = now.subtract(Duration(days: 1));
              //  var lastweek = now.subtract(Duration(days: 7));
              var prevMonth1stday = DateTime.utc(
                  DateTime.now().year, DateTime.now().month - 1, 1);
              var prevMonthLastday = DateTime.utc(
                DateTime.now().year,
                DateTime.now().month - 0,
              ).subtract(Duration(days: 1));
              var thisweek = now.subtract(Duration(days: now.weekday - 1));
              var lastWeek1stDay =
                  thisweek.subtract(Duration(days: thisweek.weekday + 6));
              var lastWeekLastDay =
                  thisweek.subtract(Duration(days: thisweek.weekday - 0));
              var thismonth = new DateTime(now.year, now.month, 1);

              if (selectedIndex == 0) {
                // Today
                selecteFromdt = formatter.format(now);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 1) {
                // yesterday
                selecteFromdt = formatter.format(yesterday);
                selecteTodt = formatter.format(yesterday);
              } else if (selectedIndex == 2) {
                // LastWeek
                selecteFromdt = formatter.format(lastWeek1stDay);
                selecteTodt = formatter.format(lastWeekLastDay);
              } else if (selectedIndex == 3) {
                selecteFromdt = formatter.format(thisweek);
                selecteTodt = formatter.format(now);
              } else if (selectedIndex == 4) {
                // Last Month
                selecteFromdt = formatter.format(prevMonth1stday);
                selecteTodt = formatter.format(prevMonthLastday);
              } else if (selectedIndex == 5) {
                selecteFromdt = formatter.format(thismonth);
                selecteTodt = formatter.format(now);
              }

              print("From Date " + selecteFromdt);
              print("To Date " + selecteTodt);

              _fetchSaleTransaction();
            });
          },
          onLongPress: () {
            print('Long press');
          },
        ),
      );
    }

    ListView datesListView() {
      var myData = [
        {
          "FrequencyId": "1",
          "Frequency": "Today",
        },
        {
          "FrequencyId": "2",
          "Frequency": "Yesterday",
        },
        {
          "FrequencyId": "3",
          "Frequency": "Last Week",
        },
        {
          "FrequencyId": "4",
          "Frequency": "This Week",
        },
        {
          "FrequencyId": "5",
          "Frequency": "Last Month",
        },
        {
          "FrequencyId": "6",
          "Frequency": "This Month",
        }
      ];

      return ListView.builder(
          itemCount: myData.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            // return  Text(myData[index]["Frequency"].toString());
            return _buildDatesCard(myData[index], index);
          });
    }

    Widget DateSelection() {
      return Container(child: datesListView());
    }

    return Column(
      children: [
        SizedBox(height: 48, child: DateSelection()),
        SizedBox(
            height: 15,
            child: Text(selecteFromdt + ' To ' + selecteTodt,
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: verticalListSales,
        ),
      ],
    );
  }
}

class SalesTransactions {
  final String umrno;
  final String billno;
  final String pname;
  final String billdt;
  final String billamt;
  final String cmpdueamt;
  final String billingloc;
  final age;
  final gender;

  SalesTransactions({
    required this.umrno,
    required this.billno,
    required this.pname,
    required this.billdt,
    required this.billamt,
    required this.cmpdueamt,
    required this.billingloc,
    required this.age,
    required this.gender,
  });

  factory SalesTransactions.fromJson(Map<String, dynamic> json) {
    print('Sales Transaction');
    print(json);
    return SalesTransactions(
        umrno: json['UMR_NO'].toString(),
        billno: json['BILL_NO'].toString(),
        pname: json['PATIENT_NAME'].toString(),
        billdt: json['BILL_DT'].toString(),
        billamt: json['BILL_AMOUNT'].toString(),
        billingloc: json['FB_LOC_NAME'].toString(),
        cmpdueamt: json['CMP_DUE_AMT'].toString(),
        age: json['AGE'].toString(),
        gender: json['GENDER'].toString());
  }
}

class PaymentTransactions {
  final String clientcd;
  final String clientname;
  final String paymentdt;
  final String paymentamt;
  final String ptype;
  final String pmode;

  PaymentTransactions({
    required this.clientcd,
    required this.clientname,
    required this.paymentdt,
    required this.paymentamt,
    required this.ptype,
    required this.pmode,
  });

  factory PaymentTransactions.fromJson(Map<String, dynamic> json) {
    return PaymentTransactions(
      clientcd: json['REFRL_CD'].toString(),
      clientname: json['REFERAL_NAME'].toString(),
      paymentdt: json['CREATE_DT'].toString(),
      paymentamt: json['AMOUNT'].toString(),
      ptype: json['TYPE'].toString(),
      pmode: json['PAYMENT_MODE_ID'].toString(),
    );
  }
}

class LedgerTransactions {
  final String tranno;
  final String trandt;
  final String creditamt;
  final String debitamt;
  final String ttype;
  final String remarks;
  final String closingbal;

  LedgerTransactions({
    required this.tranno,
    required this.trandt,
    required this.creditamt,
    required this.debitamt,
    required this.ttype,
    required this.remarks,
    required this.closingbal,
  });

  factory LedgerTransactions.fromJson(Map<String, dynamic> json) {
    return LedgerTransactions(
        tranno: json['TRANSACTION_NO'].toString(),
        trandt: json['TRANSACTION_DATE'].toString(),
        creditamt: json['CREDIT_AMOUNT'].toString(),
        debitamt: json['DEBIT_AMOUNT'].toString(),
        ttype: json['TYPE'].toString(),
        remarks: json['REMARKS'].toString(),
        closingbal: json['CLOSING_BALANCE'].toString());
  }
}

class CreditNoteTransactions {
  final String clientcd;
  final String clientname;
  final String ttype;
  final String pmode;
  final String tdate;
  final String tamt;

  CreditNoteTransactions(
      {required this.clientcd,
      required this.clientname,
      required this.ttype,
      required this.pmode,
      required this.tdate,
      required this.tamt});

  factory CreditNoteTransactions.fromJson(Map<String, dynamic> json) {
    print('Sales Transaction');
    print(json);
    return CreditNoteTransactions(
      clientcd: json['REFRL_CD'].toString(),
      clientname: json['REFERAL_NAME'].toString(),
      ttype: json['TYPE'].toString(),
      pmode: json['PAYMENT_MODE_ID'].toString(),
      tdate: json['CREATE_DT'].toString(),
      tamt: json['AMOUNT'].toString(),
    );
  }
}

class DebitNoteTransactions {
  final String clientcd;
  final String clientname;
  final String ttype;
  final String pmode;
  final String tdate;
  final String tamt;

  DebitNoteTransactions(
      {required this.clientcd,
      required this.clientname,
      required this.ttype,
      required this.pmode,
      required this.tdate,
      required this.tamt});

  factory DebitNoteTransactions.fromJson(Map<String, dynamic> json) {
    print('Sales Transaction');
    print(json);
    return DebitNoteTransactions(
      clientcd: json['REFRL_CD'].toString(),
      clientname: json['REFERAL_NAME'].toString(),
      ttype: json['TYPE'].toString(),
      pmode: json['PAYMENT_MODE_ID'].toString(),
      tdate: json['CREATE_DT'].toString(),
      tamt: json['AMOUNT'].toString(),
    );
  }
}

class NoContent extends StatelessWidget {
  const NoContent();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.verified_rounded,
              color: Colors.red,
              size: 50,
            ),
            const Text('No Data Found'),
          ],
        ),
      ),
    );
  }
}

Widget tabsListView(data, BuildContext context, String tabType) {
  int i = 0;
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildSalesCard(data[index], context, tabType, '');
      });
}

Widget _buildSalesCard(
    data, BuildContext context, String flg, String trantype) {
  // datasetval = data;
  var inoutflg = '';
  var subheading = '';
  var subtitle = '';
  var tranamt = '';
  var supportingText = 'Advance amount 5000 collected for rolling advance';
  var head = '';
  if (flg == 'S') {
    supportingText = 'Bill No ' +
        data.billno +
        ', patient ' +
        data.pname +
        ' of Amount ' +
        data.billamt +
        ' has been added.';
    head = data.pname;
    subheading = '\u{20B9}' + data.billamt;
    subtitle = data.billno + " | " + data.billdt;
  } else if (flg == 'P') {
    head = '';
    subtitle =
        'Advance amount ' + data.paymentamt + ' collected for rolling advance.';
    head = data.clientname;
    subheading = '\u{20B9}' + data.paymentamt;
    subtitle = data.pmode + " | " + data.paymentdt;
  } else if (flg == 'CN') {
    head = '';
    supportingText = 'Credit Note of ' + data.tamt + ' Added.';
    subtitle = 'Credit Note of ' + data.tamt + ' Added.';
    head = data.clientname;
    subheading = '\u{20B9}' + data.tamt;
    subtitle = data.pmode + " | " + data.tdate;
    inoutflg = 'I';
  } else if (flg == 'DN') {
    head = '';
    inoutflg = 'O';
    supportingText = 'Debit Note of ' + data.tamt + ' Added.';
    subtitle = ' Note of ' + data.tamt + ' Added.';
    head = data.clientname;
    subheading = '\u{20B9}' + data.tamt;
    subtitle = data.pmode + " | " + data.tdate;
  } else if (flg == 'L') {
    trantype = data.ttype;
    head = data.ttype;
    tranamt = data.debitamt.toString();
    if (trantype == 'Opening Balance') {
      tranamt = '\u{20B9}' + data.debitamt.toString();
    } else if (trantype == 'Sales') {
      tranamt = '\u{20B9}' + data.debitamt.toString();
      inoutflg = 'I';
    } else if (trantype == 'Credit Payments') {
      head = 'Payment';
      tranamt = '\u{20B9}' + data.creditamt.toString();
      inoutflg = 'O';
    } else if (trantype == 'Credit Note') {
      //  head = '\u{20B9}' + data.creditamt;
      tranamt = '\u{20B9}' + data.creditamt.toString();
      inoutflg = 'I';
    } else if (trantype == 'Debit Note') {
      //  head = 'Debit';
      tranamt = '\u{20B9}' + data.debitamt.toString();
      inoutflg = 'O';
    }
    subtitle = data.tranno + " | " + data.trandt;
    supportingText = data.remarks;
    subheading = '\u{20B9}' + data.closingbal;
  }
  return GestureDetector(
    onTap: () {
      globals.selectedPatientData = data;
      (flg == "S") ? _showPicker1(context, data.billno.toString()) : Card();
    },
    child: Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
                leading: Icon(Icons.verified_rounded, color: Colors.green),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 93.0,
                      child: Text(head,
                          style: TextStyle(
                              color: Color(0xff123456),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0)),
                    ),
                    SizedBox(
                      child: Text(tranamt,
                          style: TextStyle(
                              color: Color(0xff123456),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0)),
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    SizedBox(
                      child: Text(subheading,
                          textAlign: TextAlign.justify,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: (flg == 'MB')
                              ? const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0)
                              : const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0)),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subtitle,
                        style: (flg == 'MB')
                            ? const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0)
                            : const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0)),
                  ],
                ),
                trailing: //(data.ttype=='Sales') ?
                    (inoutflg == 'I')
                        ? const Icon(Icons.arrow_back_rounded,
                            size: 17, color: Colors.green)
                        : const Icon(Icons.arrow_forward_rounded,
                            size: 17, color: Colors.red)),
            (flg != 'MB')
                ? Text(supportingText,
                    style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 12),
                    softWrap: true)
                : Text('')
          ],
        )),
  );
}

Widget _buildClientHeaderSales(BuildContext context) {
  return GestureDetector(
    onTap: () {
      // print( globals.selectedClientData);
    },
    child: Container(
      //width: 175,
      child: Card(
        elevation: 5.0,
        margin: EdgeInsets.all(2.5),
        child: Column(
          children: [
            SizedBox(
              height: 90,
              child: ListTile(
                //minVerticalPadding:5,
                // leading: (index%2==0) ? const Icon(Icons.lock_open, color: Colors.green) : const Icon(Icons.lock, color: Colors.red) ,
                // trailing: Icon(Icons.arrow_forward,color: Colors.green,),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //  SizedBox(width: 10),
                    Text(
                      globals.selectedClientData.clientname,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 100),
                    // (globals.selectedClientData.locked == 'Y')
                    //     ? const Icon(
                    //         Icons.lock_rounded,
                    //         color: Colors.red,
                    //         size: 20,
                    //       )
                    //     : const Icon(Icons.lock_open_rounded,
                    //         size: 18, color: Colors.green),
                  ],
                ),

                subtitle:
                    //  SizedBox(
                    //   // height: 80,
                    //   // width: 5,
                    //   child:
                    Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.verified_rounded,
                              size: 13, color: Colors.green),
                          label: Text(
                            globals.selectedClientData.business.toString(),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.green),
                          ),
                          onPressed: () {},
                        ),
                        TextButton.icon(
                          icon: Icon(
                            Icons.camera,
                            size: 12,
                            color: Colors.blue,
                          ),
                          label: Text(
                            globals.selectedClientData.deposits.toString(),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue),
                          ),
                          onPressed: () {},
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.camera, size: 12, color: Colors.red),
                          label: Text(
                            globals.selectedClientData.balance.toString(),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.red),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Payment on',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        Text(
                          globals.selectedClientData.lastpaiddt.toString(),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        Text(
                          'Paid Amt ',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        Text(
                          globals.selectedClientData.lastpaidamt.toString(),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ],
                    )
                  ],
                  //),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/*-------------------------------------popupservices------------------------------------*/

var Bill_noval = "";

class SelectionPickerBottom extends StatefulWidget {
  SelectionPickerBottom(billno) {
    Bill_noval = "";
    Bill_noval = billno.toString();
  }

//Bill_noval=billno.toString();
  @override
  _SelectionPickerBottomState createState() => _SelectionPickerBottomState();
}

class _SelectionPickerBottomState extends State<SelectionPickerBottom> {
  @override
  Widget build(BuildContext context) {
    Future<List<patientDetails>> _fetchSaleTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';

      Map data = {"bill_id": Bill_noval, "connection": globals.Connection_Flag};
      dsetName = 'Data';
      jobsListAPIUrl = Uri.parse(globals.API_url + '/MobileSales/BillServices');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> resposne = jsonDecode(response.body);
        List jsonResponse = resposne[dsetName];

        return jsonResponse
            .map((strans) => new patientDetails.fromJson(strans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSalesBusiness = Container(
      height: MediaQuery.of(context).size.height * 0.4,
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<patientDetails>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return popupListView(data);
              }
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: Colors.primaries,
                  strokeWidth: 4.0,
                  //   pathBackgroundColor:ColorSwatch(Action[])
                ),
              ),
            );
          }),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: 200,
              child: Text(globals.selectedPatientData.pname.toString(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Spacer(),
            Text(
              globals.selectedPatientData.age.split(',')[0].toString() +
                  '/' +
                  globals.selectedPatientData.gender.toString(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Color(0xff123456),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: verticalListSalesBusiness,
      ),
    );
  }
}

Widget popupListView(data) {
  int i = 0;
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildBusinessCard(data[index], context, index);
      });
}

Widget _buildBusinessCard(data, BuildContext context, index) {
  return GestureDetector(
      onTap: () {
        globals.selectedPatientData = data;
      },
      child: Card(
        elevation: 4.0,
        color: MaterialStateColor.resolveWith(
            (states) => Color.fromARGB(255, 248, 248, 248)),
        child: Column(children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 150,
                child: Text(data.srvname,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
              ),
              Spacer(),
              Text(
                data.srvstats1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              (data.srvstats1 == "Approved" || data.srvstats1 == "Dispatch")
                  ? IconButton(
                      onPressed: () {
                        _launchURL(data.reportCd.toString());
                      },
                      icon: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ))
                  : IconButton(onPressed: () {}, icon: Icon(null))
            ],
          ),
        ]),
      ));
}

void _showPicker1(BuildContext context, billno) {
  var res = showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      //  width: ,
      height: MediaQuery.of(context).size.height * 0.4,
      //  color: Color(0xff123456),
      child: SelectionPickerBottom(billno.toString()),
    ),
  );
  print(res);
}

class patientDetails {
  final srvname;
  final srvstats1;
  final billNo;
  final displyName;
  final mobNo1;
  final age;
  final gendr;
  final reportCd;

  patientDetails(
      {required this.srvname,
      required this.srvstats1,
      required this.billNo,
      required this.displyName,
      required this.mobNo1,
      required this.age,
      required this.gendr,
      required this.reportCd});

  factory patientDetails.fromJson(Map<String, dynamic> json) {
    return patientDetails(
        srvname: json['SERVICE_NAME'].toString(),
        srvstats1: json['SERVICE_STATUS1'].toString(),
        billNo: json['BILL_NO'].toString(),
        displyName: json['DISPLAY_NAME'].toString(),
        mobNo1: json['MOBILE_NO1'].toString(),
        age: json['AGE'].toString(),
        gendr: json['GENDER'].toString(),
        reportCd: json['REPORT_CD'].toString());
  }
}

/*---------------------------------------------popupservices---------------------------------*/

/*--------------------------------------------url Launcher----------------------------------------*/

_launchURL(rportcde) async {
  var url = globals.Report_URL + rportcde + "";
  //  http://103.145.36.189/his_testing/PUBLIC/HIMSREPORTVIEWER.ASPX?UNIUQ_ID=
  if (await launch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
} /*--------------------------------------------url Launcher----------------------------------------*/
