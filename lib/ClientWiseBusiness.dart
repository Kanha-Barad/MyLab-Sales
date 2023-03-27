//import 'dart:ffi';
import 'dart:ui';
// import 'package:clients_app/Business.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'ClientDashBoard.dart';
import 'New_Login.dart';
import 'Sales_Dashboard.dart';
import 'CenterWiseBusiness.dart';
// import 'SalesDashboard.dart';
import 'admin_dashboard.dart';
import 'allbottomnavigationbar.dart';
import 'globals.dart' as globals;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

// import 'dart:html' as html;
// html.window.location.reload() {
//   // ignore: todo
//   // TODO: implement reload
//   throw UnimplementedError();
// }
List persons = [];
List original = [];
List datasetval = [];
TextEditingController txtQuery = new TextEditingController();
String emptyval = "";
bool isloaded = false;

class ClientProfile extends StatefulWidget {
  // const ClientProfile({Key? key}) : super(key: key);
  int selectedPage;

  ClientProfile(this.selectedPage);
  @override
  _ClientProfileState createState() => _ClientProfileState(this.selectedPage);
}

class _ClientProfileState extends State<ClientProfile> {
  int selectedPage;
  DateTime pastMonth = DateTime.now().subtract(Duration(days: 30));
  _ClientProfileState(this.selectedPage);
  String date = "";
  // DateTimeRange? selectedDate;

  _selectDate(BuildContext context) async {
    final DateTimeRange? selected = await showDateRangePicker(
      context: context,
      // initialDate: selectedDate,
      firstDate: pastMonth,
      lastDate: DateTime(DateTime.now().year + 1),
      saveText: 'Done',
    );
    //  if (selected != null && selected != selectedDate) {
    setState(() {
      //  selectedDate = selected;
      //  globals.selectDate = selected as String;
      globals.fromDate = selected!.start.toString().split(' ')[0];
      globals.ToDate = selected.end.toString().split(' ')[0];
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => ClientProfile(this.selectedPage)));
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    //   super.build(context);
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xff123456),
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
              Tab(icon: Icon(Icons.report_outlined), text: 'Reports'),
              Tab(icon: Icon(Icons.verified_user), text: 'Sales'),
              Tab(icon: Icon(Icons.directions_transit), text: 'Ledger'),
              Tab(icon: Icon(Icons.money_outlined), text: 'Payments'),
              Tab(icon: Icon(Icons.money_outlined), text: 'Credits'),
              Tab(icon: Icon(Icons.money_outlined), text: 'Debits'),
            ],
            isScrollable: true,
          ),
          title: Row(
            children: [
              IconButton(
                  onPressed: () {
                    globals.fromDate = "";
                    globals.ToDate = "";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CenterWiseBusiness()),
                    );
                  },
                  icon: Icon(Icons.arrow_back)),
              Text(
                "Client Wise Business",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ReportTabPage(0),
            SalesTabPage(1),
            LedgerTabPage(2),
            PaymentsTabPage(3),
            CreditNoteTransactionsTab(4),
            DebitNoteTransactionsTab(5)
          ],
        ),
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;
}

class ReportTabPage extends StatefulWidget {
  // const ReportTabPage({Key? key}) : super(key: key);
  int selectedtab;
  ReportTabPage(this.selectedtab);
  @override
  _ReportTabPageState createState() => _ReportTabPageState(this.selectedtab);
}

class _ReportTabPageState extends State<ReportTabPage> {
  int selectedtab;
  _ReportTabPageState(this.selectedtab);
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';
  String empID = "0";
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
    var Datavalues = null;
    // globals.fromDate = '';
    // globals.ToDate = '';
    Future<List<ReportTransactions>> _fetchReportTransactions() async {
      Datavalues = null;
      var jobsListAPIUrl = null;
      var dsetName = '';
      // List listresponse = [];

      Map data = {
        "Clientid": globals.selectedClientid,
        "from_dt": selecteFromdt,
        "to_dt": selecteTodt,
        "session_id": "1",
        "connection": globals.Connection_Flag
        // "TYPE": "a"
        //"Server_Flag":""
      };
      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/ClientApprovedbills');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        globals.fromDate = '';
        globals.ToDate = '';
        Map<String, dynamic> resposne = jsonDecode(response.body);
        Datavalues = jsonDecode(response.body)["Data"];
        List jsonResponse = resposne[dsetName];
        persons = jsonResponse;
        original = jsonResponse;
        return jsonResponse
            .map((strans) => new ReportTransactions.fromJson(strans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSales = Container(
      //height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<ReportTransactions>>(
          future: _fetchReportTransactions(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              }
              var data = snapshot.data;
              return tabsListView(data, context, 'R');
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
              overlayColor: (globals.fromDate != '')
                  ? MaterialStateColor.resolveWith((states) => Colors.blueGrey)
                  : MaterialStateColor.resolveWith((states) => Colors.red),
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
              //  globals.selectDate = '';
              selectedIndex = index;
              globals.fromDate = '';
              globals.ToDate = '';

              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = DateTime.now();
              var yesterday = now.subtract(const Duration(days: 1));
              //   var lastweek = now.subtract(const Duration(days: 7));

              var thisweek = now.subtract(Duration(days: now.weekday - 1));
              var lastWeek1stDay =
                  thisweek.subtract(Duration(days: thisweek.weekday + 6));
              var lastWeekLastDay =
                  thisweek.subtract(Duration(days: now.weekday - 0));
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

//..................................
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

    Widget MyBottomNavigation = Container(
        // height: 150,
        width: MediaQuery.of(context).size.width,
        height: 48,
        color: Color(0xff123456),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 5, 0, 0),
            child: InkWell(
              onTap: () {
                globals.fromDate = "";
                globals.ToDate = "";
                globals.reference_type_id != '28' &&
                        globals.reference_type_id != '8'
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminDashboard(empID, 0)))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                salesManagerDashboard(empID, 0)));
              },
              child: Column(children: [
                Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  "Home",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                )
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => UsersProfile()),
                // );
              },
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Profile",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 20, 0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginClass()),
                );
              },
              child: Column(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Log Out",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ]));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0.0, 8, 0.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons.person_outline,
                          size: 25,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          globals.CLIENT_NAME,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 48, child: DateSelection()),
            SizedBox(
                height: 15,
                child: Text(selecteFromdt + ' To ' + selecteTodt,
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0))),
            Container(
              height: MediaQuery.of(context).size.height * 0.61,
              child: verticalListSales,
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigation,
    );
  }
}

class SalesTabPage extends StatefulWidget {
  int selectedtab;

  SalesTabPage(this.selectedtab);
  // const SalesTabPage({Key? key}) : super(key: key);
  @override
  _SalesTabPageState createState() => _SalesTabPageState(this.selectedtab);
}

class _SalesTabPageState extends State<SalesTabPage> {
  int selectedtab;
  _SalesTabPageState(this.selectedtab);
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';
  String empID = "0";
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
        globals.fromDate = '';
        globals.ToDate = '';
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
              globals.fromDate = '';
              globals.ToDate = '';
              selectedIndex = index;
              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = DateTime.now();
              var yesterday = now.subtract(const Duration(days: 1));
              // var lastweek = now.subtract(const Duration(days: 7));

              var thisweek = now.subtract(Duration(days: now.weekday - 1));
              var lastWeek1stDay =
                  thisweek.subtract(Duration(days: thisweek.weekday + 6));
              var lastWeekLastDay =
                  thisweek.subtract(Duration(days: now.weekday - 0));
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

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 48, child: DateSelection()),
          SizedBox(
              height: 15,
              child: Text(selecteFromdt + ' To ' + selecteTodt,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0))),
          Container(
            height: MediaQuery.of(context).size.height / 1.56,
            child: verticalListSales,
          ),
        ],
      ),
      bottomNavigationBar: AllbottomNavigation(),
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
  int selectedtab;
  _LedgerTabPageState(this.selectedtab);
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';
  String empID = "0";
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
                  thisweek.subtract(Duration(days: now.weekday - 0));
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
        globals.fromDate = '';
        globals.ToDate = '';
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

    return Scaffold(
      body: Column(
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
            height: MediaQuery.of(context).size.height * 0.64,
            child: verticalListLedger,
          ),
        ],
      ),
      bottomNavigationBar: AllbottomNavigation(),
    );
  }
}

class PaymentsTabPage extends StatefulWidget {
  int selectedtab;
  PaymentsTabPage(this.selectedtab);
  // const PaymentsTabPage({Key? key}) : super(key: key);

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
  String empID = "0";
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
              globals.fromDate = '';
              globals.ToDate = '';
              selectedIndex = index;

              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = new DateTime.now();
              var yesterday = now.subtract(Duration(days: 1));
              //    var lastweek = now.subtract(Duration(days: 7));
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
                  thisweek.subtract(Duration(days: now.weekday - 0));
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
        globals.fromDate = '';
        globals.ToDate = '';
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

    return Scaffold(
      body: Column(
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
            height: MediaQuery.of(context).size.height * 0.64,
            child: verticalListLedger,
          ),
        ],
      ),
      bottomNavigationBar: AllbottomNavigation(),
    );
  }
}

class CreditNoteTransactionsTab extends StatefulWidget {
  int selectedtab;
  CreditNoteTransactionsTab(this.selectedtab);
  // const CreditNoteTransactionsTab({Key? key}) : super(key: key);
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
  String empID = "0";
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
        globals.fromDate = '';
        globals.ToDate = '';
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
                  thisweek.subtract(Duration(days: now.weekday - 0));
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

    return Scaffold(
      body: Column(
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
            height: MediaQuery.of(context).size.height * 0.64,
            child: verticalListSales,
          ),
        ],
      ),
      bottomNavigationBar: AllbottomNavigation(),
    );
  }
}

class DebitNoteTransactionsTab extends StatefulWidget {
  // const DebitNoteTransactionsTab({Key? key}) : super(key: key);
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
  String empID = "0";
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
        globals.fromDate = '';
        globals.ToDate = '';
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
                  thisweek.subtract(Duration(days: now.weekday - 0));
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

    return Scaffold(
      body: Column(
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
            height: MediaQuery.of(context).size.height * 0.64,
            child: verticalListSales,
          ),
        ],
      ),
      bottomNavigationBar: AllbottomNavigation(),
    );
  }
}

class ReportTransactions {
  final String serid;
  final String sername;
  final String disname;
  final String billname;
  final String billdate;
  final String serstatus;
  final String billamount;
  final age;
  final report;
  final String sentdate;
  final String approdate;
  final String ser_status_name;
  final String sampledate;
  final String batchdate;
  final String deptdate;
  final String resultdate;
  final String verifydate;

  ReportTransactions({
    required this.serid,
    required this.sername,
    required this.disname,
    required this.billname,
    required this.billdate,
    required this.serstatus,
    required this.billamount,
    required this.age,
    required this.report,
    required this.sentdate,
    required this.approdate,
    required this.ser_status_name,
    required this.sampledate,
    required this.batchdate,
    required this.deptdate,
    required this.resultdate,
    required this.verifydate,
  });

  factory ReportTransactions.fromJson(Map<String, dynamic> json) {
    print('Sales Transaction');
    print(json);
    return ReportTransactions(
      serid: json['SERVICE_ID'].toString(),
      sername: json['SERVICE_NAME'].toString(),
      disname: json['DISPLAY_NAME'].toString(),
      billname: json['BILL_NO'].toString(),
      billdate: json['BILL_DT'].toString(),
      serstatus: json['SERVICE_STATUS'].toString(),
      billamount: json['BILL_AMOUNT'].toString(),
      age: json['AGE'].toString(),
      report: json['REPORT_CD'].toString(),
      sentdate: json['SENT_DT'].toString(),
      approdate: json['APPROVED_DT'].toString(),
      sampledate: json['SAMPLE_COLLECT_DT'].toString(),
      batchdate: json['BATCH_RECERIVED_DT'].toString(),
      deptdate: json['DEPT_RECERIVED_DT'].toString(),
      resultdate: json['RESULT_DT'].toString(),
      verifydate: json['VERIFY_DT'].toString(),
      ser_status_name: json['SERVICE_STATUS_NAME'].toString(),
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
  int _currentStep = 2;
  var inoutflg = '';
  var subheading = '';
  var subtitle = '';
  var tranamt = '';
  var supportingText = '';

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
  } else if (flg == 'R') {
    head = data.disname;
    subheading = data.age;
    subtitle = data.billname + " | " + data.billdate;
    supportingText = data.sername;
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
      (flg == "R")
          ? showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                contentPadding: EdgeInsets.only(
                  // top: 20.0,
                  left: 20.0,
                  right: 20.0,
                  //  bottom: 20.0
                ),
                title: Container(
                  height: 70,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Services',
                            style: TextStyle(
                              color: Color.fromARGB(255, 19, 102, 170),
                              fontSize: 25,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.cancel_outlined,
                                  color: Colors.red))
                        ],
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 2,
                      ),
                    ],
                  ),
                ),
                content: Container(
                  height: 300,
                  width: 200,
                  child: Theme(
                    data: ThemeData(
                        accentColor: Colors.green,
                        primarySwatch: Colors.green,
                        colorScheme: ColorScheme.light(primary: Colors.green)),
                    child: Stepper(
                      margin: EdgeInsets.all(0),
                      type: StepperType.vertical,
                      physics: const ScrollPhysics(),
                      // currentStep: _currentStep,
                      // onStepTapped: (step) => _stepTapped(step),
                      // onStepContinue: _stepContinue,
                      // onStepCancel: _stepCancel,
                      steps: [
                        // The first step: Name
                        Step(
                            title: Column(
                              children: [
                                Text('Registered'),
                                data.billdate != "null"
                                    ? Text(data.billdate)
                                    : Text(''),
                              ],
                            ),
                            content: Text(""),
                            isActive: data.billdate != "null",
                            state: data.billdate != "null"
                                ? StepState.complete
                                : StepState.editing
                            //state: StepState.error,
                            ),

                        Step(
                            title: Column(
                              children: [
                                Text('Pending'),
                                data.verifydate != "null"
                                    ? Text(data.verifydate)
                                    : Text(''),
                              ],
                            ),
                            content: Text(""),
                            isActive: data.verifydate != "null",
                            state: data.verifydate != "null"
                                ? StepState.complete
                                : StepState.editing),

                        Step(
                            title: Column(
                              children: [
                                Text('Approved'),
                                data.approdate != "null"
                                    ? Text(data.approdate)
                                    : Text(''),
                              ],
                            ),
                            content: Text(""),
                            isActive: data.approdate != "null",
                            state: data.approdate != "null"
                                ? StepState.complete
                                : StepState.editing),
                      ],
                      controlsBuilder: (context, _) {
                        return Row(
                          children: <Widget>[],
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
          : Card();
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
                    width: 110.0,
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
                    width: 5,
                  ),
                  SizedBox(
                    child: Text(subheading,
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
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
                              fontSize: 17.0)
                          : const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0)),
                ],
              ),
            ),
            (flg != 'R')
                ? (flg != 'MB')
                    ? Text(supportingText,
                        style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                            //  fontStyle: FontStyle.italic,
                            fontSize: 12),
                        softWrap: true)
                    : Text('')
                : (flg != 'MB')
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: 70.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 120,
                              child: Text(supportingText,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      //   fontStyle: FontStyle.italic,
                                      fontSize: 12),
                                  softWrap: true),
                            ),
                            Text(
                              data.ser_status_name,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            (data.ser_status_name == "Dispatch" ||
                                    data.ser_status_name == "Completed")
                                ? SizedBox(
                                    height: 30,
                                    child: IconButton(
                                        onPressed: () {
                                          _launchURL(data.report.toString());
                                        },
                                        icon: Icon(Icons.picture_as_pdf,
                                            size: 18,
                                            color: Color.fromARGB(
                                                255, 213, 21, 21))),
                                  )
                                : Container(),
                            // RaisedButton(
                            //   color: Colors.white,
                            //   elevation: 0,
                            //   child: Icon(Icons.print, color: Colors.black),
                            //   textColor: Colors.red,
                            //   onPressed: () {
                            //     _launchURL(data.report.toString());
                            //   },
                            // ),
                          ],
                        ),
                      )
                    : Text(''),
          ],
        )),
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
              (data.srvstats1 == "Completed" || data.srvstats1 == "Dispatch")
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
  if (await launch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

/*--------------------------------------------url Launcher----------------------------------------*/
