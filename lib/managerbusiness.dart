import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import './popup.dart';

import 'ClientsList.dart';
import 'clientprofile.dart';
import 'globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

/*--------------------Manager Business card----------------------------------- */

int achieveamtDept = 0;
int achieveamtTest = 0;
int targetAmountDept = 0;
int targetAmountTest = 0;

class managerbusiness extends StatefulWidget {
  // const managerbusiness({Key? key}) : super(key: key);
  int selectedPage;
  managerbusiness(this.selectedPage);
  @override
  _managerbusinessState createState() =>
      _managerbusinessState(this.selectedPage);
}

class _managerbusinessState extends State<managerbusiness> {
  int selectedPage;
  int selectedIndex = 1;
  _managerbusinessState(this.selectedPage);
  String date = "";
  // bool isLoaded = false;
  _selectManagerBusinessDate(BuildContext context) async {
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
      //     context, MaterialPageRoute(builder: (context) => managerbusiness(this.selectedPage)));
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    globals.tab_index = this.selectedIndex.toString();
    final topAppBar = AppBar(
        toolbarHeight: 30.0,
        backgroundColor: Color(0xff123456),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range_outlined),
            onPressed: () {
              _selectManagerBusinessDate(context);
            },
          )
        ],
        bottom: const TabBar(
          tabs: [
            Tab(
                icon: Icon(
                  Icons.groups,
                  size: 25,
                ),
                text: 'My Clients'),
            Tab(
              icon: Icon(
                Icons.medication,
                size: 25,
              ),
              text: 'Dept wise',
            ),
            Tab(
                icon: Icon(
                  Icons.thermostat,
                  size: 25,
                ),
                text: 'Test Wise'),
            Tab(
                icon: Icon(
                  Icons.person_off_sharp,
                  size: 25,
                ),
                text: 'In-Active Client'),
            Tab(
                icon: Icon(
                  Icons.no_accounts_outlined,
                  size: 25,
                ),
                text: 'No Payment Client'),
            Tab(
                icon: Icon(
                  Icons.bookmark_remove,
                  size: 25,
                ),
                text: 'No Business Client'),
          ],
          isScrollable: true,
        ),
        title: Text('Business of ' + globals.selectedManagerData.empname));

    return DefaultTabController(
      initialIndex: selectedPage,
      length: 6,
      child: Scaffold(
        appBar: topAppBar,
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ManagerClientsList(0),
            SalesDeptwise(1),
            SalesTestwise(2),
            SalesInActiveClients(3),
            SalesZeroPaymentClients(4),
            SalesZeroBusinessClients(5)
          ],
        ),
      ),
    );
  }
}

class SalesDeptwise extends StatefulWidget {
  int selectedPage;
  SalesDeptwise(this.selectedPage);
  // const SalesDeptwise({Key? key}) : super(key: key);

  @override
  _SalesDeptwiseState createState() => _SalesDeptwiseState(1);
}

class _SalesDeptwiseState extends State<SalesDeptwise> {
  int selectedPage;
  _SalesDeptwiseState(this.selectedPage);
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

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

    Future<List<ManagerBusinessDeptWise>> _fetchSaleTransaction() async {
      // totalBusiness1 = 0;

      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Employeeid": globals.selectedEmpid,
        "FromDate": selecteFromdt,
        "ToDate": selecteTodt,
        "session_id": "1",
        "Flag": "SG",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      dsetName = 'Data';
      //  if (!isLoaded) {
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/ServiceGroupCount');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonresponse = jsonDecode(response.body);
        print(jsonresponse.containsKey('Data'));
        listresponse = jsonresponse[dsetName];
        achieveamtDept = 0;
        targetAmountDept = 0;
        // setState(() {
        //   isLoaded = true;
        // });

        return listresponse
            .map((smbtrans) => ManagerBusinessDeptWise.fromJson(smbtrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
      // }
    }

    Widget verticalListSalesBusiness = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<ManagerBusinessDeptWise>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return businessTestDeptList(data, context, 'SG');
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
          onPressed: () async {
            print(index.toString());
            setState(() {
              globals.fromDate = '';
              globals.ToDate = '';
              selectedIndex = index;

              final DateFormat formatter = DateFormat('dd-MMM-yyyy');
              var now = new DateTime.now();
              var yesterday = now.subtract(Duration(days: 1));
              //  var lastweek = now.subtract(Duration(days: 7));

              var thisweek = now.subtract(Duration(days: now.weekday - 1));
              var lastWeek1stDay =
                  thisweek.subtract(Duration(days: thisweek.weekday + 6));
              var lastWeekLastDay =
                  thisweek.subtract(Duration(days: thisweek.weekday - 0));
              var thismonth = new DateTime(now.year, now.month, 1);

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

              _fetchSaleTransaction();
            });
          },
          // onLongPress: () {
          //   print('Long press');
          // },
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
          height: MediaQuery.of(context).size.height * 0.73,
          child: verticalListSalesBusiness,
        ),
        // _buildtotalbusinessDept(context)
      ],
    );
  }
}

class SalesTestwise extends StatefulWidget {
  int selectedPage;
  SalesTestwise(this.selectedPage);
  // const SalesTestwise({Key? key}) : super(key: key);

  @override
  State<SalesTestwise> createState() => _SalesTestwiseState(2);
}

class _SalesTestwiseState extends State<SalesTestwise> {
  int selectedPage;
  _SalesTestwiseState(this.selectedPage);
  int selectedIndex = 1;
  var selecteFromdt = '';
  var selecteTodt = '';

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

    Future<List<ManagerBusinessTestWise>> _fetchSaleTransaction() async {
      // totalBusiness1 = 0;
      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Employeeid": globals.selectedEmpid,
        "FromDate": selecteFromdt,
        "ToDate": selecteTodt,
        "session_id": "1",
        "Flag": "Y",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/ServiceGroupCount');
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
        achieveamtTest = 0;
        targetAmountTest = 0;
        return listresponse
            .map((smbtrans) => ManagerBusinessTestWise.fromJson(smbtrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSalesBusiness = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<ManagerBusinessTestWise>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return businessTestDeptList(data, context, 'y');
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

              //_fetchSaleTransaction();
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
          height: MediaQuery.of(context).size.height * 0.73,
          //  width: MediaQuery.of(context).size.width * 1,
          child: verticalListSalesBusiness,
        ),
        //  _buildtotalbusinessTest(context)
      ],
    );
  }
}

class SalesInActiveClients extends StatefulWidget {
  // const SalesInActiveClients({Key? key}) : super(key: key);
  int selectedPage;
  SalesInActiveClients(this.selectedPage);

  @override
  State<SalesInActiveClients> createState() => _SalesInActiveClientsState(3);
}

class _SalesInActiveClientsState extends State<SalesInActiveClients> {
  int selectedPage;
  _SalesInActiveClientsState(this.selectedPage);
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

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
    Future<List<ManagerBusinessInActiveClients>> _fetchSaleTransaction() async {
      // totalBusiness1 = 0;
      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Emp_id": globals.selectedEmpid,
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/InAndActiveClients');
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
        achieveamtTest = 0;
        targetAmountTest = 0;
        return listresponse
            .map(
                (smbtrans) => ManagerBusinessInActiveClients.fromJson(smbtrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSalesBusiness = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<ManagerBusinessInActiveClients>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return inActNoPaymentNobusinessClientList(data, context, 'IAC');
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

              //_fetchSaleTransaction();
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
          //  width: MediaQuery.of(context).size.width * 1,
          child: verticalListSalesBusiness,
        ),
      ],
    );
  }
}

class SalesZeroPaymentClients extends StatefulWidget {
  int selectedPage;
  SalesZeroPaymentClients(this.selectedPage);
  // const SalesZeroPaymentClients({Key? key}) : super(key: key);

  @override
  State<SalesZeroPaymentClients> createState() =>
      _SalesZeroPaymentClientsState(4);
}

class _SalesZeroPaymentClientsState extends State<SalesZeroPaymentClients> {
  int selectedPage;
  _SalesZeroPaymentClientsState(this.selectedPage);
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

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
    Future<List<ManagerBusinessZeroPaymentClients>>
        _fetchSaleTransaction() async {
      // totalBusiness1 = 0;
      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Emp_id": globals.selectedEmpid,
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/ZeropaymentClients');
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
        achieveamtTest = 0;
        targetAmountTest = 0;
        return listresponse
            .map((smbtrans) =>
                ManagerBusinessZeroPaymentClients.fromJson(smbtrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSalesBusiness = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<ManagerBusinessZeroPaymentClients>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return inActNoPaymentNobusinessClientList(data, context, 'NPC');
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

              final DateFormat formatter = DateFormat('yyyy-MM-dd');
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

              //_fetchSaleTransaction();
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
          height: MediaQuery.of(context).size.height / 1.6,
          //  width: MediaQuery.of(context).size.width * 1,
          child: verticalListSalesBusiness,
        ),
      ],
    );
  }
}

class SalesZeroBusinessClients extends StatefulWidget {
  int selectedPage;
  SalesZeroBusinessClients(this.selectedPage);
  // const SalesZeroBusinessClients({Key? key}) : super(key: key);

  @override
  State<SalesZeroBusinessClients> createState() =>
      _SalesZeroBusinessClientsState(5);
}

class _SalesZeroBusinessClientsState extends State<SalesZeroBusinessClients> {
  int selectedPage;
  _SalesZeroBusinessClientsState(this.selectedPage);
  // const SalesZeroBusinessClients({Key? key}) : super(key: key);
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

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
    Future<List<ManagerBusinessZeroBusinessClients>>
        _fetchSaleTransaction() async {
      // totalBusiness1 = 0;
      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Emp_id": globals.selectedEmpid,
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/ZeroBusinessClients');
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
        achieveamtTest = 0;
        targetAmountTest = 0;
        return listresponse
            .map((smbtrans) =>
                ManagerBusinessZeroBusinessClients.fromJson(smbtrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListSalesBusiness = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<ManagerBusinessZeroBusinessClients>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return inActNoPaymentNobusinessClientList(data, context, 'NBC');
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

              //_fetchSaleTransaction();
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
          height: MediaQuery.of(context).size.height / 1.6,
          //  width: MediaQuery.of(context).size.width * 1,
          child: verticalListSalesBusiness,
        ),
      ],
    );
  }
}

class ManagerClientsList extends StatefulWidget {
  // const ManagerClientsList({Key? key}) : super(key: key);
  int selectedPage;
  ManagerClientsList(this.selectedPage);

  @override
  State<ManagerClientsList> createState() => _ManagerClientsListState(0);
}

class _ManagerClientsListState extends State<ManagerClientsList> {
  int selectedPage;
  _ManagerClientsListState(this.selectedPage);
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

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
    Future<List<ManagerMyClients>> _fetchSalespersons() async {
      Map data = {
        "emp_id": globals.loginEmpid, "session_id": "1",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };

      final jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/EmpReferalDetails');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> resposne = jsonDecode(response.body);
        List jsonResponse = resposne["Data"];

        return jsonResponse
            .map((managers) => ManagerMyClients.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget ManagerMyClientverticalList = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      // height: MediaQuery.of(context).size.height * 1,
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder<List<ManagerMyClients>>(
          future: _fetchSalespersons(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              return ManagerMyClientsListView(data, context);
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

              //_fetchSaleTransaction();
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
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 48, child: DateSelection()),
        // SizedBox(
        //     height: 15,
        //     child: Text(selecteFromdt + ' To ' + selecteTodt,
        //         style: const TextStyle(
        //             color: Colors.red,
        //             fontWeight: FontWeight.bold,
        //             fontSize: 12.0))),
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.35,
          //  width: MediaQuery.of(context).size.width * 1,
          child: ManagerMyClientverticalList,
        ),
        // SizedBox(
        //   width: 350,
        //   height: 50,
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(8, 0.0, 8, 0.0),
        //     child: Card(
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(9)),
        //       color: Color.fromARGB(255, 27, 165, 114),
        //       child: Padding(
        //         padding: const EdgeInsets.fromLTRB(9, 2, 9, 2),
        //         child: Row(
        //           children: [
        //             Text('Total Business :',
        //                 style: TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 14,
        //                     fontWeight: FontWeight.w500)),
        //             Spacer(),
        //             Text('\u{20B9} 0000',
        //                 style: TextStyle(
        //                     fontSize: 14,
        //                     color: Colors.white,
        //                     fontWeight: FontWeight.w500)),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // )
      ],
    );
  }
}

class ManagerBusinessDeptWise {
  final String groupname;
  final String amount;
  final String count;
  final String srvgrpval;
  final frmDt;
  final toDt;
  final targetamt;
  final daywiseTargtAmount;
  final daywiseAchieveAmount;

  ManagerBusinessDeptWise(
      {required this.groupname,
      required this.amount,
      required this.count,
      required this.srvgrpval,
      required this.frmDt,
      required this.toDt,
      required this.targetamt,
      required this.daywiseTargtAmount,
      required this.daywiseAchieveAmount});

  factory ManagerBusinessDeptWise.fromJson(Map<String, dynamic> json) {
    //int totalBusiness1 = 0;
    // print('Sales Transaction');
    achieveamtDept =
        int.parse(json['DAY_WISE_ACHIEVED_AMOUNT'].toString().split('.')[0]);
    targetAmountDept =
        int.parse(json['DAY_WISE_TARGET_AMOUNT'].toString().split('.')[0]);
    // print(totalBusiness1);
    // print('kanha');
    print(json);
    return ManagerBusinessDeptWise(
      groupname: json['SERVICE_GROUP'].toString(),
      amount: json['AMOUNT'].toString(),
      count: json['SRV_GRP_COUNT'].toString(),
      srvgrpval: json['SRV_GRP_VAL'].toString(),
      frmDt: json['FROM_DT'].toString(),
      toDt: json['TO_DT'].toString(),
      targetamt: json['TARGET_AMOUNT'].toString(),
      daywiseAchieveAmount: json['DAY_WISE_ACHIEVED_AMOUNT'].toString(),
      daywiseTargtAmount: json['DAY_WISE_TARGET_AMOUNT'].toString(),
    );
  }
}

class ManagerBusinessTestWise {
  final String groupname;
  final String amount;
  final String count;
  final String srvgrpval;
  final frmDt;
  final toDt;
  final targetamt;
  final daywiseTargtAmount;
  final daywiseAchieveAmount;

  ManagerBusinessTestWise(
      {required this.groupname,
      required this.amount,
      required this.count,
      required this.srvgrpval,
      required this.frmDt,
      required this.toDt,
      required this.targetamt,
      required this.daywiseTargtAmount,
      required this.daywiseAchieveAmount});

  factory ManagerBusinessTestWise.fromJson(Map<String, dynamic> json) {
    //int totalBusiness1 = 0;
    // print('Sales Transaction');
    achieveamtTest =
        int.parse(json['DAY_WISE_ACHIEVED_AMOUNT'].toString().split('.')[0]);
    targetAmountTest =
        int.parse(json['DAY_WISE_TARGET_AMOUNT'].toString().split('.')[0]);
    // print(totalBusiness1);
    // print('kanha');
    print(json);
    return ManagerBusinessTestWise(
      groupname: json['SERVICE_GROUP'].toString(),
      amount: json['AMOUNT'].toString(),
      count: json['SRV_GRP_COUNT'].toString(),
      srvgrpval: json['SRV_GRP_VAL'].toString(),
      frmDt: json['FROM_DT'].toString(),
      toDt: json['TO_DT'].toString(),
      targetamt: json['TARGET_AMOUNT'].toString(),
      daywiseAchieveAmount: json['DAY_WISE_ACHIEVED_AMOUNT'].toString(),
      daywiseTargtAmount: json['DAY_WISE_TARGET_AMOUNT'].toString(),
    );
  }
}

class ManagerBusinessInActiveClients {
  final company_id;
  final company_code;
  final company_name;

  ManagerBusinessInActiveClients({
    required this.company_id,
    required this.company_code,
    required this.company_name,
  });

  factory ManagerBusinessInActiveClients.fromJson(Map<String, dynamic> json) {
    print(json);
    return ManagerBusinessInActiveClients(
      company_id: json['COMPANY_ID'].toString(),
      company_code: json['COMANY_CD'].toString(),
      company_name: json['COMPANY_NAME'].toString(),
    );
  }
}

class ManagerBusinessZeroPaymentClients {
  final company_id;
  final company_code;
  final company_name;
  final payment_amt;
  final employee_name;

  ManagerBusinessZeroPaymentClients({
    required this.company_id,
    required this.company_code,
    required this.company_name,
    required this.payment_amt,
    required this.employee_name,
  });

  factory ManagerBusinessZeroPaymentClients.fromJson(
      Map<String, dynamic> json) {
    print(json);
    return ManagerBusinessZeroPaymentClients(
        company_id: json['COMPANY_ID'].toString(),
        company_code: json['COMANY_CD'].toString(),
        company_name: json['COMPANY_NAME'].toString(),
        payment_amt: json['PAYMENT_AMT'].toString(),
        employee_name: json['EMPLOYEE_NAME'].toString());
  }
}

class ManagerBusinessZeroBusinessClients {
  final company_id;
  final company_code;
  final company_name;

  ManagerBusinessZeroBusinessClients({
    required this.company_id,
    required this.company_code,
    required this.company_name,
  });

  factory ManagerBusinessZeroBusinessClients.fromJson(
      Map<String, dynamic> json) {
    print(json);
    return ManagerBusinessZeroBusinessClients(
      company_id: json['COMPANY_ID'].toString(),
      company_code: json['COMANY_CD'].toString(),
      company_name: json['COMPANY_NAME'].toString(),
    );
  }
}

class ManagerMyClients {
  final Company_Name;
  final Business;
  final Deposit;
  final Balance;
  final last_Payment_Dt;
  final last_Payment_Amt;

  ManagerMyClients({
    required this.Company_Name,
    required this.Business,
    required this.Deposit,
    required this.Balance,
    required this.last_Payment_Dt,
    required this.last_Payment_Amt,
  });

  factory ManagerMyClients.fromJson(Map<String, dynamic> json) {
    if (json['LAST_PAYMENT_DT'] == '' || json['LAST_PAYMENT_DT'] == null) {
      json['LAST_PAYMENT_DT'] = 'No Payment done.';
    }
    if (json['LAST_PAY_AMT'] == '' || json['LAST_PAY_AMT'] == null) {
      json['LAST_PAY_AMT'] = '0.00';
    }

    return ManagerMyClients(
      Company_Name: json['COMPANY_NAME'].toString(),
      Deposit: json['DEPOSITS'].toString(),
      Business: json['BUSINESS'].toString(),
      Balance: json['BALANCE'].toString(),
      last_Payment_Dt: json['LAST_PAYMENT_DT'].toString(),
      last_Payment_Amt: json['LAST_PAY_AMT'].toString(),
    );
  }
}

Widget businessTestDeptList(data, BuildContext context, String tabType) {
  int i = 0;
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildBusinessDeptTestCard(
          data[index],
          context,
          tabType,
        );
      });
}

Widget _buildBusinessDeptTestCard(data, BuildContext context, String flg) {
  var inoutflg = '';
  var head = '';
  var subheading = '';
  var subtitle = '';
  var tranamt = '';
  var supportingText = 'Advance amount 5000 collected for rolling advance';

  if (flg == 'SG') {
    head = data.groupname;
    supportingText = '';
    subtitle = '';
    //head =  data.clientname;
    subheading = data.count;
    subtitle = '\u{20B9}' + data.amount;
  } else if (flg == 'y') {
    head = data.groupname;
    supportingText = '';
    subtitle = '';
    //head =  data.clientname;
    subheading = data.count;
    subtitle = '\u{20B9}' + data.amount;
  }
  return GestureDetector(
    onTap: () {
      globals.selectedPatientData = data;
      (flg == "SG" || flg == "y")
          ? Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => salesMngrBills(
                      flg,
                      data.srvgrpval.toString(),
                      data.frmDt.toString(),
                      data.toDt.toString())))
          : _showPicker1(context, data.billno.toString());
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
                    width: 190.0,
                    child: Text(head,
                        style: TextStyle(
                            color: Color(0xff123456),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0)),
                  ),
                  // SizedBox(
                  //   width: 5,
                  // ),
                  SizedBox(
                    //  width: 35,
                    child: Text(tranamt,
                        style: TextStyle(
                            color: Color(0xff123456),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0)),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    //      width: 30,
                    child: Text(subheading,
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: (flg == 'MB')
                            ? const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0)
                            : const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0)),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle,
                      style: (flg == 'MB')
                          ? const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0)
                          : const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0)),
                ],
              ),
              trailing: //(data.ttype=='Sales') ?
                  (inoutflg == 'I')
                      ? const Icon(Icons.arrow_back_rounded,
                          size: 20, color: Colors.green)
                      : const Icon(Icons.arrow_forward_rounded,
                          size: 20, color: Colors.red)),
          // (flg != 'MB')
          //     ? Text(supportingText,
          //         style: TextStyle(
          //             color: Colors.black45,
          //             fontWeight: FontWeight.bold,
          //             fontStyle: FontStyle.italic,
          //             fontSize: 12),
          //         softWrap: true)
          //     : Text('')
        ],
      ),
    ),
  );
}

ListView ManagerMyClientsListView(data, BuildContext context) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildManagerMyClientsCard(data[index], context);
      });
}

Widget _buildManagerMyClientsCard(data, BuildContext context) {
  return GestureDetector(
      child: Padding(
    padding: const EdgeInsets.fromLTRB(10, 3, 10, 0.0),
    child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        // color: Color.fromARGB(255, 229, 243, 240),
        elevation: 6.0,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 8.0),
                  child: Text(
                    data.Company_Name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2.0, 12.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\u{20B9} ' + data.Business,
                      style: TextStyle(fontSize: 14, color: Colors.green)),
                  Text('\u{20B9} ' + data.Deposit,
                      style: TextStyle(fontSize: 14, color: Colors.indigo)),
                  Text('\u{20B9} ' + data.Balance,
                      style: TextStyle(fontSize: 14, color: Colors.red))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2.0, 12.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data.last_Payment_Dt,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey)),
                  Text('\u{20B9} ' + data.last_Payment_Amt,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey))
                ],
              ),
            )
          ],
        )),
  ));
}

Widget inActNoPaymentNobusinessClientList(
    data, BuildContext context, String tabType) {
  int i = 0;
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _inActNoPaymentNobusinessClientCard(
          data[index],
          context,
          tabType,
        );
      });
}

Widget _inActNoPaymentNobusinessClientCard(
    data, BuildContext context, String flg) {
  var head = '';
  var subheading = '';
  var subtitle = '';
  if (flg == 'IAC') {
    head = data.company_name;
    subheading = data.company_code.trim();
  } else if (flg == 'NPC') {
    head = data.company_name;
    subheading = data.company_code.trim();
    subtitle = data.employee_name;
  } else if (flg == 'NBC') {
    head = data.company_name;
    subheading = data.company_code.trim();
  }

  return GestureDetector(
    child: Column(
      children: [
        Card(
            elevation: 4.0,
            child: Column(children: [
              ListTile(
                  leading: Icon(Icons.verified_rounded, color: Colors.green),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(head,
                            style: TextStyle(
                                color: Color(0xff123456),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0)),
                        Text(subheading,
                            style: TextStyle(
                                color: Color.fromARGB(255, 245, 84, 21),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0))
                      ]),
                  subtitle: (flg == 'NPC')
                      ? Row(
                          children: [
                            Text(subtitle,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 41, 129, 218),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0))
                          ],
                        )
                      : Text('')),
            ])),
      ],
    ),
  );
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

// _buildtotalbusinessDept(BuildContext context) {
//   return Row(
//     children: [
//       SizedBox(
//         width: MediaQuery.of(context).size.width * 0.50,
//         // height: MediaQuery.of(context).size.height * 0.06,
//         child: TextButton.icon(
//           onPressed: () {},
//           icon: Container(
//             height: 30,
//             width: 50,
//             child: Image.asset(
//               'assets/images/achievement.png',
//             ),
//           ),
//           label: Text(
//             '\u{20B9} ' + achieveamtDept.toString(),
//             style: TextStyle(fontSize: 18),
//           ),
//           style: TextButton.styleFrom(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(0.0)),
//             primary: Color.fromARGB(255, 17, 13, 13),
//             backgroundColor: Color.fromARGB(255, 119, 230, 109),
//           ),
//         ),
//       ),
//       SizedBox(
//         width: MediaQuery.of(context).size.width * 0.50,
//         child: TextButton.icon(
//           onPressed: () {},
//           icon: Container(
//             height: 30,
//             width: 50,
//             child: Image.asset(
//               'assets/images/target.png',
//             ),
//           ),
//           label: Text(
//             '\u{20B9}' + targetAmountDept.toString(),
//             style: TextStyle(fontSize: 18),
//           ),
//           style: TextButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(0.0)),
//               primary: Color.fromARGB(255, 10, 10, 10),
//               backgroundColor: Color.fromARGB(255, 241, 69, 69)),
//         ),
//       )
//     ],
//   );
// }

// _buildtotalbusinessTest(BuildContext context) {
//   return Row(
//     children: [
//       SizedBox(
//         width: MediaQuery.of(context).size.width * 0.50,
//         // height: MediaQuery.of(context).size.height * 0.06,
//         child: TextButton.icon(
//           onPressed: () {},
//           icon: Container(
//             height: 30,
//             width: 50,
//             child: Image.asset(
//               'assets/images/achievement.png',
//             ),
//           ),
//           label: Text(
//             '\u{20B9} ' + achieveamtDept.toString(),
//             style: TextStyle(fontSize: 18),
//           ),
//           style: TextButton.styleFrom(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(0.0)),
//             primary: Color.fromARGB(255, 17, 13, 13),
//             backgroundColor: Color.fromARGB(255, 119, 230, 109),
//           ),
//         ),
//       ),
//       SizedBox(
//         width: MediaQuery.of(context).size.width * 0.50,
//         child: TextButton.icon(
//           onPressed: () {},
//           icon: Container(
//             height: 30,
//             width: 50,
//             child: Image.asset(
//               'assets/images/target.png',
//             ),
//           ),
//           label: Text(
//             '\u{20B9}' + targetAmountDept.toString(),
//             style: TextStyle(fontSize: 18),
//           ),
//           style: TextButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(0.0)),
//               primary: Color.fromARGB(255, 10, 10, 10),
//               backgroundColor: Color.fromARGB(255, 241, 69, 69)),
//         ),
//       )
//     ],
//   );
// }

/*--------------------Manager Business card----------------------------------- */

String flg = '';
String srvdept = '';
String frmdt = '';
String todt = '';

class salesMngrBills extends StatefulWidget {
  salesMngrBills(flag, pid, frmdte, todte) {
    flg = '';
    srvdept = '';
    flg = flag;
    srvdept = pid;
    frmdt = frmdte;
    todt = todte;
  }

  @override
  State<salesMngrBills> createState() => _salesMngrBillsState();
}

class _salesMngrBillsState extends State<salesMngrBills> {
  @override
  Widget build(BuildContext context) {
    Future<List<businessManager>> _fetchSaleTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';
      // List listresponse = [];

      Map data = {
        "employee_id": globals.selectedEmpid,
        "from_date": frmdt,
        "to_date": todt,
        "session_id": "1",
        "flag": flg,
        "service_group_id": srvdept,
        "service_id": "",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      dsetName = 'Data';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/ServiceGroupWiseBills');
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
            .map((strans) => new businessManager.fromJson(strans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    double height = MediaQuery.of(context).size.height * 0.7;

    Widget verticalListSalesBusiness = Container(
      //  height: MediaQuery.of(context).size.height * 0.7,
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<businessManager>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return BusinessListView(data);
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
          backgroundColor: Color(0xff123456),
          title: Text('Business of ' + globals.selectedManagerData.empname)),
      body: Column(children: [
        Card(
            elevation: 4.0,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.verified_rounded, color: Colors.green),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 180,
                        child: Text(globals.selectedPatientData.groupname,
                            style: TextStyle(
                                color: Color(0xff123456),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0)),
                      ),
                      SizedBox(
                        // width: 30,
                        child: Text(globals.selectedPatientData.count,
                            textAlign: TextAlign.justify,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: (flg == 'MB')
                                ? const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0)
                                : const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0)),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\u{20B9}' + globals.selectedPatientData.amount,
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
                )
              ],
            )),
        Container(height: height, child: verticalListSalesBusiness)
      ]),
    );
  }
}

class businessManager {
  final billNo;
  final netamt;
  final billId;
  final displyName;
  final billDt;
  final aGe;
  final genDer;
  final srvid;

  businessManager(
      {required this.billNo,
      required this.netamt,
      required this.billId,
      required this.displyName,
      required this.billDt,
      required this.aGe,
      required this.genDer,
      required this.srvid});

  factory businessManager.fromJson(Map<String, dynamic> json) {
    return businessManager(
        billNo: json['BILL_NO'].toString(),
        netamt: json['NET_AMOUNT'].toString(),
        billId: json['BILL_ID'].toString(),
        displyName: json['DISPLAY_NAME'].toString(),
        billDt: json['BILL_DT'].toString(),
        aGe: json['AGE'].toString(),
        genDer: json['GENDER_NAME'].toString(),
        srvid: json['SRV_ID'].toString());
  }
}

Widget BusinessListView(data) {
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
        _showPicker(
            context, data.billNo.toString(), data.srvid.toString(), flg);
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.account_circle_rounded),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        child: Text(
                      data.displyName,
                      style: TextStyle(
                          color: Color(0xff123456),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0),
                    )),
                    Text('\u{20B9}' + data.netamt,
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.0)),
                  ]),
              subtitle: SizedBox(
                  child: Row(
                children: [
                  Text(data.billNo + '  |  ' + data.billDt,
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0))
                ],
              )),
            )
          ],
        ),
      ));
}

/* Business Bottom Pop-up */
var Bill_noval = "";
var service_id = "";
var Flag = "";

class businessBtmPopup extends StatefulWidget {
  businessBtmPopup(billNo, serviceid, flag) {
    Bill_noval = "";

    service_id = "";
    Flag = "";

    Bill_noval = billNo.toString();
    service_id = serviceid;
    Flag = flag;
  }

  @override
  State<businessBtmPopup> createState() => _businessBtmPopupState();
}

class _businessBtmPopupState extends State<businessBtmPopup> {
  @override
  Widget build(BuildContext context) {
    Future<List<patientDetails>> _fetchSaleTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';
      // List listresponse = [];

      Map data = {
        "bill_id": Bill_noval,
        "service_group_id": service_id,
        "flag": Flag,
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
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

    Widget verticalListSalesBusiness = SizedBox(
      height: MediaQuery.of(context).size.height * 1,
      //margin: EdgeInsets.symmetric(vertical: 2.0),
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
              child: Text(globals.selectedPatientData.displyName.toString(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Spacer(),
            Text(
              globals.selectedPatientData.aGe.split(',')[0].toString() +
                  '/' +
                  globals.selectedPatientData.genDer.toString(),
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
        return _buildPatientInfoCard(data[index], context, index);
      });
}

Widget _buildPatientInfoCard(data, BuildContext context, int index) {
  return GestureDetector(
      onTap: () {
        globals.selectedPatientData = data;
      },
      child: Card(
        elevation: 4.0,
        color: MaterialStateColor.resolveWith(
            (states) => Color.fromARGB(255, 245, 248, 248)),
        child: Column(children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 150,
                child: Text(
                  data.srvname,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
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
      reportCd: json['REPORT_CD'].toString(),
    );
  }
}

void _showPicker(BuildContext context, billNo, serviceid, flag) {
  var res = showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      //  width: ,
      height: MediaQuery.of(context).size.height * 0.4,
      //  color: Color(0xff123456),
      child: businessBtmPopup(billNo.toString(), serviceid, flag),
    ),
  );
  print(res);
}

// /* Business Bottom Pop-up */

/*    Launch url for Print Button      */
_launchURL(rportcde) async {
  var url = globals.Report_URL + rportcde + "";

  if (await launch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
} /*    Launch url for Print Button      */
