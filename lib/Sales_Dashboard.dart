import 'dart:convert';
//import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:slimssales/allbottomnavigationbar.dart';
import 'New_Login.dart';
import './total_business.dart';
import './Center_Wise_Summary.dart';
import './report.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './ClientsList.dart';
import './allinone.dart';
import './clientprofile.dart';

import 'LocationWiseBusiness.dart';
import 'admin_dashboard.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'managerbusiness.dart';

double amount = 0;
TextEditingController _Mobile_NoController = TextEditingController();
TextEditingController _billnoController = TextEditingController();

class salesManagerDashboard extends StatefulWidget {
  String empID = "0";
  int selectedIndex;
  salesManagerDashboard(String iEmpid, this.selectedIndex) {
    empID = iEmpid;
    this.empID = iEmpid;
  }

  @override
  State<salesManagerDashboard> createState() =>
      _salesManagerDashboardState(this.empID, this.selectedIndex);
}

class _salesManagerDashboardState extends State<salesManagerDashboard> {
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();

  _CenterWiseBusinessDate(BuildContext context) async {
    final DateTimeRange? selected = await showDateRangePicker(
      context: context,
      // initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
      saveText: 'Done',
    );

    setState(() {
      globals.fromDate = selected!.start.toString().split(' ')[0];
      globals.ToDate = selected.end.toString().split(' ')[0];
      print(amount);
    });
  }

  int selectedIndex;
  var selecteFromdt = '';
  var selecteTodt = '';
  String empID = "0";
  _salesManagerDashboardState(String iEmpid, this.selectedIndex) {
    this.empID = iEmpid;
  }

  String date = "";
  // DateTimeRange? selectedDate;

  login(username, password, BuildContext context) async {
    Map data = {
      "user_name": username,
      "password": password,
      "from_dt": globals.fromDate == ""
          ? "${selectedDate.toLocal()}".split(' ')[0]
          : globals.fromDate,
      "to_dt": globals.ToDate == ""
          ? "${selectedDate.toLocal()}".split(' ')[0]
          : globals.ToDate,
      "connection": globals.Connection_Flag
      //"Server_Flag":""
    };
    print(data.toString());
    final response =
        await http.post(Uri.parse(globals.API_url + '/MobileSales/Login'),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded"
            },
            body: data,
            encoding: Encoding.getByName("utf-8"));

    setState(() {});

    if (response.statusCode == 200) {
      Map<String, dynamic> resposne = jsonDecode(response.body);

      if (resposne["message"] != "Invalid Username or Password") {
        print(resposne["Data"]);
        Map<String, dynamic> user = resposne['Data'][0];

        print(user['USER_ID']);

        String empID = user['REFERENCE_ID'].toString();
        globals.loginEmpid = user['REFERENCE_ID'].toString();

        globals.Amount_CWB = user['AMOUNTS'].toString();
        globals.MailId = user['EMAIL_ID'].toString();
        globals.EmpName = user['EMP_NAME'].toString();
        if (user['REFERENCE_TYPE_ID'].toString() == '8') {
          globals.selectedClientid = globals.loginEmpid;
          ;
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => ClientProfile(0))));
        } else {
          //  globals.sessionid = user['session_id'].toString();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    salesManagerDashboard(empID, this.selectedIndex)),
          );
        }
      } else {
        errormsg();
      }
    }
  }

//Date Selection...........................................
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

            var prevMonth1stday =
                DateTime.utc(DateTime.now().year, DateTime.now().month - 1, 1);
            var prevMonthLastday = DateTime.utc(
              DateTime.now().year,
              DateTime.now().month - 0,
            ).subtract(Duration(days: 1));

            if (selectedIndex == 0) {
              // Today
              total_amouont = "";
              selecteFromdt = formatter.format(now);
              selecteTodt = formatter.format(now);
            } else if (selectedIndex == 1) {
              // yesterday
              total_amouont = "";
              selecteFromdt = formatter.format(yesterday);
              selecteTodt = formatter.format(yesterday);
            } else if (selectedIndex == 2) {
              // LastWeek
              total_amouont = "";
              selecteFromdt = formatter.format(lastWeek1stDay);
              selecteTodt = formatter.format(lastWeekLastDay);
            } else if (selectedIndex == 3) {
              total_amouont = "";
              selecteFromdt = formatter.format(thisweek);
              selecteTodt = formatter.format(now);
            } else if (selectedIndex == 4) {
              total_amouont = "";
              // Last Month
              selecteFromdt = formatter.format(prevMonth1stday);
              selecteTodt = formatter.format(prevMonthLastday);
            } else if (selectedIndex == 5) {
              total_amouont = "";
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

//Date Selection...........................................
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
    Future<List<ManagerDetails>> _fetchManagerDetails() async {
      Map data = {
        "employee_id": globals.loginEmpid, "session_id": "1",
        "from_dt": selecteFromdt == ""
            ? "${selectedDate.toLocal()}".split(' ')[0]
            : selecteFromdt,
        "to_dt": selecteTodt == ""
            ? "${selectedDate.toLocal()}".split(' ')[0]
            : selecteTodt,
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      final jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/ManagerEmpDetails');
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
            .map((managers) => ManagerDetails.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListManagerDetails = Container(
        height: MediaQuery.of(context).size.height * 0.72,
        child: FutureBuilder<List<ManagerDetails>>(
            future: _fetchManagerDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                return SizedBox(
                    child: ManagerDetailsDasboardListView(data, context));
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
            }));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Builder(
                builder: (context) => IconButton(
                  icon: Image(image: NetworkImage(globals.Logo)),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            Text('Sales Dashboard'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.date_range_outlined),
              onPressed: () {
                _CenterWiseBusinessDate(context);
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xff123456),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: const Color(0xff123456),
              ),
              child: Container(
                child: Column(
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image(image: NetworkImage(globals.Logo)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      globals.EmpName,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      globals.MailId,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginClass()),
                  );
                },
                leading: const Icon(Icons.logout_rounded),
                title: const Text("Log Out"))
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 48, child: DateSelection()),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                  height: 15,
                  child: selecteFromdt == ""
                      ? Text(
                          "${selectedDate.toLocal()}".split(' ')[0] +
                              '  To   ' +
                              "${selectedDate.toLocal()}".split(' ')[0],
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0))
                      : Text(selecteFromdt + '  To   ' + selecteTodt,
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0))),
            ),
            Container(
              child: verticalListManagerDetails,
            ),
          ],
        ),
      ),
      bottomNavigationBar: AllbottomNavigation(),
    );
  }
}

ListView ManagerDetailsDasboardListView(data, BuildContext context) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildManagerDetails(data[index], context, index);
      });
}

void clearText() {
  _Mobile_NoController.clear();
  _billnoController.clear();
}

Widget _buildManagerDetails(var data, BuildContext context, index) {
  Map<String, double> todayData = {
    "Target": double.parse(data.dayWiseTargetAmt),
    "Achievement": double.parse(data.dayWiseAchieveAmt),
    // "Xamarin": 2,
    // "Ionic": 2,
  };
  Map<String, double> monthlyData = {
    "Target": double.parse(data.monthWiseTargetAmt),
    "Achievement": double.parse(data.monthWiseAchieveAmt),
    // "Xamarin": 2,
    // "Ionic": 2,
  };
  return Column(
    children: [
      Column(
        children: [
          GestureDetector(
              child: Container(
                  color: const Color.fromARGB(255, 250, 248, 248),
                  child: (index == 0)
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(15, 3, 15, 0.0),
                          child: InkWell(
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
                                          Icons.account_box,
                                          size: 25,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              globals.EmpName,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800]),
                                            ),
                                            Text(
                                              globals.Employee_Code,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        (data.mngrcnt.toString() == "1")
                                            ? IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.pie_chart,
                                                  color: Colors.deepOrange,
                                                ))
                                            : IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          32.0))),
                                                          title: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              (data.reportmgrid ==
                                                                      "0")
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                          0.0,
                                                                          3.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Card(
                                                                            elevation:
                                                                                4.0,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Column(
                                                                                  children: [
                                                                                    const Text(
                                                                                      "Today",
                                                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 11,
                                                                                    ),
                                                                                    Center(
                                                                                      child: PieChart(
                                                                                        dataMap: todayData,
                                                                                        chartLegendSpacing: 20,
                                                                                        initialAngleInDegree: 130,
                                                                                        chartRadius: MediaQuery.of(context).size.width / 3.7,
                                                                                        legendOptions: const LegendOptions(
                                                                                          legendPosition: LegendPosition.bottom,
                                                                                        ),
                                                                                        chartValuesOptions: const ChartValuesOptions(
                                                                                          showChartValuesInPercentage: true,
                                                                                          showChartValueBackground: true,
                                                                                          showChartValues: true,
                                                                                          //  showChartValuesInPercentage: true,
                                                                                          showChartValuesOutside: true,
                                                                                          decimalPlaces: 1,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Column(
                                                                                  children: [
                                                                                    const Text(
                                                                                      "Monthly",
                                                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 11,
                                                                                    ),
                                                                                    Center(
                                                                                      child: PieChart(
                                                                                        dataMap: monthlyData,
                                                                                        chartLegendSpacing: 20,
                                                                                        initialAngleInDegree: 20,
                                                                                        ringStrokeWidth: 0,
                                                                                        chartRadius: MediaQuery.of(context).size.width / 3.7,
                                                                                        legendOptions: const LegendOptions(
                                                                                          showLegendsInRow: false,
                                                                                          legendPosition: LegendPosition.bottom,
                                                                                        ),
                                                                                        chartValuesOptions: const ChartValuesOptions(
                                                                                          //     showChartValuesInPercentage: true,
                                                                                          showChartValueBackground: true,
                                                                                          showChartValues: true,
                                                                                          showChartValuesInPercentage: true,
                                                                                          showChartValuesOutside: true,
                                                                                          decimalPlaces: 1,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : (data.reportmgrid !=
                                                                              "0" &&
                                                                          index ==
                                                                              0)
                                                                      ? Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              0.0,
                                                                              3.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Column(
                                                                                    children: [
                                                                                      const Text(
                                                                                        "Today",
                                                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 11,
                                                                                      ),
                                                                                      Center(
                                                                                        child: PieChart(
                                                                                          dataMap: todayData,
                                                                                          chartLegendSpacing: 20,
                                                                                          initialAngleInDegree: 50,
                                                                                          chartRadius: MediaQuery.of(context).size.width / 3.7,
                                                                                          legendOptions: const LegendOptions(
                                                                                            legendPosition: LegendPosition.bottom,
                                                                                          ),
                                                                                          chartValuesOptions: const ChartValuesOptions(
                                                                                            showChartValuesInPercentage: true,
                                                                                            showChartValueBackground: true,
                                                                                            showChartValues: true,
                                                                                            //  showChartValuesInPercentage: true,
                                                                                            showChartValuesOutside: true,
                                                                                            decimalPlaces: 1,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  Column(
                                                                                    children: [
                                                                                      const Text(
                                                                                        "Monthly",
                                                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 15,
                                                                                      ),
                                                                                      Center(
                                                                                        child: PieChart(
                                                                                          dataMap: monthlyData,
                                                                                          chartLegendSpacing: 20,
                                                                                          initialAngleInDegree: 20,
                                                                                          ringStrokeWidth: 0,
                                                                                          chartRadius: MediaQuery.of(context).size.width / 3.7,
                                                                                          legendOptions: const LegendOptions(
                                                                                            // showLegends: true,
                                                                                            showLegendsInRow: false,
                                                                                            legendPosition: LegendPosition.bottom,
                                                                                          ),
                                                                                          chartValuesOptions: const ChartValuesOptions(
                                                                                            //     showChartValuesInPercentage: true,
                                                                                            showChartValueBackground: true,
                                                                                            showChartValues: true,
                                                                                            showChartValuesInPercentage: true,
                                                                                            showChartValuesOutside: true,
                                                                                            decimalPlaces: 1,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : const Card(),
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                },
                                                icon: const Icon(
                                                  Icons.pie_chart,
                                                  color: Colors.deepOrange,
                                                ))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                globals.selectedEmpid = data.empid.toString();
                                globals.selectedEmname =
                                    globals.EmpName.toString();
                                globals.selectedManagerData = data;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => managerbusiness(0)),
                                );
                              }),
                        )
                      : const Card())),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.41,
              child: Card(
                // color: Color.fromARGB(255, 191, 227, 239),
                // color: Color.fromARGB(147, 238, 243, 245),
                color: Colors.white,
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(
                            Icons.shopping_cart_rounded,
                            size: 15,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          "Orders",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 18.0,
                      child: ClipRRect(
                        child: Text(
                          data.ORDERS,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        borderRadius: BorderRadius.circular(70.0),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(
            width: 10,
          ),
          SizedBox(
              // width: 145,
              // height: 90,
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.41,
              child: Card(
                // color: Color.fromARGB(255, 215, 241, 160),
                // color: Color.fromARGB(147, 238, 243, 245),
                color: Colors.white,
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(
                            Icons.bloodtype_rounded,
                            color: Colors.deepOrange,
                            size: 15,
                          ),
                        ),
                        Text(
                          "Tests",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 18.0,
                      child: ClipRRect(
                        child: Text(
                          data.SAMPLES,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        borderRadius: BorderRadius.circular(70.0),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
      GestureDetector(
          child: Container(
        color: const Color.fromARGB(255, 250, 248, 248),
        child: Column(children: [
          (data.reportmgrid.toString() == "0")
              //(data.mngrcnt.toString() == "1")
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 2.0, 15.0, 2.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 4.0,
                    child: Column(
                      children: [
                        (data.mngrcnt.toString() == "0")
                            // ||
                            //         (data.mngrcnt.toString() == "1")
                            ? InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 3.0, 15.0, 3.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.groups_sharp,
                                          color: Colors.deepOrange),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('My Team',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      Spacer(),
                                      Text(data.mngrcnt.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                                onTap: () {})
                            : InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 2.0, 15.0, 2.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.groups_sharp,
                                          color: Colors.deepOrange),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text('My Team',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      Text(data.mngrcnt.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  (data.mngrcnt.toString() != '0')
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AllinOne(globals.loginEmpid)))
                                      : null;
                                }),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                        ),
                        InkWell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 2.0, 15.0, 2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.business_sharp,
                                      color: Color.fromARGB(255, 90, 136, 236)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('My Business',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text('\u{20B9} ' + data.business.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500))
                                ],
                              ),
                            ),
                            onTap: () {}),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                        ),
                        InkWell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 2.0, 15.0, 2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.payments_outlined,
                                      color:
                                          Color.fromARGB(255, 163, 230, 165)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('My Collections',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text('\u{20B9} ' + data.deposits.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500))
                                ],
                              ),
                            ),
                            onTap: () {}),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                        ),
                        InkWell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 2.0, 15.0, 2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.money_rounded,
                                      color: const Color.fromARGB(
                                          255, 20, 169, 206)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('My Dues',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text('\u{20B9} ' + data.balance.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500))
                                ],
                              ),
                            ),
                            onTap: () {}),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                        ),
                        InkWell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 2.0, 15.0, 2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.blue),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('My Clients',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text(data.My_Clients.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500))
                                ],
                              ),
                            ),
                            onTap: () {
                              globals.selectedEmpid = data.empid.toString();
                              globals.selectedEmname =
                                  globals.EmpName.toString();
                              globals.selectedEmMail =
                                  globals.MailId.toString();
                              globals.selectedManagerData = data;
                              globals.selectedManagerData = data;

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ClientsList(globals.loginEmpid)));
                            }),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                        ),
                        InkWell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 2.0, 15.0, 2.0),
                              child: Row(
                                children: [
                                  Icon(Icons.location_pin,
                                      color: Color.fromARGB(255, 228, 16, 9)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Total Business',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  Spacer(),
                                  Text(
                                      '\u{20B9} ' +
                                          data.GROSS_AMOUNT.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  Icon(Icons.double_arrow,
                                      color: Color.fromARGB(255, 62, 10, 216)),
                                ],
                              ),
                            ),
                            onTap: () {
                              globals.Radio_Lab_Flag = "";
                              globals.fromDate = "";
                              globals.ToDate = "";
                              total_amouont = "";
                              globals.Amount_CWB =
                                  data.Total_CWB_AMOUNTS.toString();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Total_Business()));
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             locationWiseAmount(0)));
                            }),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                        ),
                        InkWell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 5.0, 15.0, 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.medical_information_outlined,
                                      color:
                                          Color.fromARGB(255, 249, 165, 189)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Lab Business',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  Spacer(),
                                  Text(
                                      '\u{20B9} ' +
                                          data.GROSS_AMOUNT.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  Icon(Icons.double_arrow,
                                      color:
                                          Color.fromARGB(255, 152, 132, 214)),
                                ],
                              ),
                            ),
                            onTap: () {
                              globals.Radio_Lab_Flag = "L";
                              total_amouont = "";
                              globals.fromDate = "";
                              globals.ToDate = "";
                              // globals.Amount_CWB = data.Total_CWB_AMOUNTS.toString();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LocationWiseCollection()));
                            }),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                        ),
                        InkWell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 5.0, 15.0, 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.summarize_outlined,
                                      color:
                                          Color.fromARGB(255, 132, 214, 202)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Radiology Business',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  Spacer(),
                                  Text(
                                      '\u{20B9} ' +
                                          data.RAD_BUSINESS.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  Icon(Icons.double_arrow,
                                      color:
                                          Color.fromARGB(255, 214, 132, 132)),
                                ],
                              ),
                            ),
                            onTap: () {
                              total_amouont = "";
                              globals.fromDate = "";
                              globals.ToDate = "";
                              globals.Radio_Lab_Flag = "R";
                              // globals.Amount_CWB = data.Total_CWB_AMOUNTS.toString();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LocationWiseCollection()));
                            }),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                        ),
                        InkWell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 2.0, 15.0, 2.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.report_gmailerrorred,
                                          color:
                                              Color.fromARGB(255, 104, 9, 228)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Reports',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      Spacer(),
                                      Spacer(),
                                      Icon(Icons.double_arrow,
                                          color:
                                              Color.fromARGB(255, 9, 228, 75)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32.0))),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Mobile No. :'),
                                          TextField(
                                            controller: _Mobile_NoController,
                                            decoration: InputDecoration(
                                                hintText:
                                                    "Enter here Mobile No. "),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: Text('OR',
                                                style: TextStyle(
                                                    color: Colors.indigo)),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Bill No.:'),
                                          TextField(
                                            controller: _billnoController,
                                            decoration: InputDecoration(
                                                hintText:
                                                    "Enter here Bill No.:  "),
                                          ),
                                          Center(
                                            child: SizedBox(
                                              height: 50,
                                              width: 100,
                                              child: InkWell(
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18)),
                                                  color: Colors.green,
                                                  child: Center(
                                                      child: Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )),
                                                ),
                                                onTap: () {
                                                  if (_billnoController.text ==
                                                          "" &&
                                                      _Mobile_NoController
                                                              .text ==
                                                          "") {
                                                    // return false;

                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Enter Valid Number",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                180, 17, 17),
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  }

                                                  if (_billnoController.text !=
                                                          "" ||
                                                      _Mobile_NoController
                                                              .text !=
                                                          "") {
                                                    globals.mobile_no =
                                                        _Mobile_NoController
                                                            .text;
                                                    globals.bill_no =
                                                        _billnoController.text;
                                                    ReportData(5, 0);
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ReportData(
                                                                        0, 0)));
                                                  }
                                                  clearText();
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  });
                            }),
                      ],
                    ),
                  ),
                )
              : (data.reportmgrid != "0" && index == 0)
                  ?
                  // :
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 2.0, 15.0, 2.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4.0,
                        child: Column(
                          children: [
                            (data.mngrcnt.toString() == "0")
                                // ||
                                //         (data.mngrcnt.toString() == "1")
                                ? InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15.0, 3.0, 15.0, 3.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.groups_sharp,
                                              color: Colors.deepOrange),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text('My Team',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500)),
                                          Spacer(),
                                          Text(data.mngrcnt.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500))
                                        ],
                                      ),
                                    ),
                                    onTap: () {})
                                : InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15.0, 2.0, 15.0, 2.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.groups_sharp,
                                              color: Colors.deepOrange),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text('My Team',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500)),
                                          const Spacer(),
                                          Text(data.mngrcnt.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500))
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      (data.mngrcnt.toString() != '0')
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AllinOne(
                                                          globals.loginEmpid)))
                                          : null;
                                    }),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey[300],
                            ),
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 2.0, 15.0, 2.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.business_sharp,
                                          color: Color.fromARGB(
                                              255, 90, 136, 236)),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text('My Business',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      Text(
                                          '\u{20B9} ' +
                                              data.business.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                                onTap: () {}),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey[300],
                            ),
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 2.0, 15.0, 2.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.payments_outlined,
                                          color: Color.fromARGB(
                                              255, 163, 230, 165)),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text('My Collections',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      Text(
                                          '\u{20B9} ' +
                                              data.deposits.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                                onTap: () {}),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey[300],
                            ),
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 2.0, 15.0, 2.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.money_rounded,
                                          color: const Color.fromARGB(
                                              255, 20, 169, 206)),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text('My Dues',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      Text(
                                          '\u{20B9} ' + data.balance.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                                onTap: () {}),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey[300],
                            ),
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 2.0, 15.0, 2.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person,
                                          color: Colors.blue),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text('My Clients',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      Text(data.My_Clients.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  globals.selectedEmpid = data.empid.toString();
                                  globals.selectedEmname =
                                      globals.EmpName.toString();
                                  globals.selectedEmMail =
                                      globals.MailId.toString();
                                  globals.selectedManagerData = data;
                                  globals.selectedManagerData = data;

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ClientsList(globals.loginEmpid)));
                                }),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey[300],
                            ),
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 2.0, 15.0, 2.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.business_center,
                                          color:
                                              Color.fromARGB(255, 228, 16, 9)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Total Business',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      Spacer(),
                                      Text(
                                          '\u{20B9} ' +
                                              data.GROSS_AMOUNT.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      Icon(Icons.double_arrow,
                                          color:
                                              Color.fromARGB(255, 62, 10, 216)),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  globals.Radio_Lab_Flag = "";
                                  globals.fromDate = "";
                                  globals.ToDate = "";
                                  total_amouont = "";
                                  globals.Amount_CWB =
                                      data.Total_CWB_AMOUNTS.toString();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Total_Business()));
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             locationWiseAmount(0)));
                                }),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey[300],
                            ),
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 5.0, 15.0, 4.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.summarize_outlined,
                                          color: Color.fromARGB(
                                              255, 132, 214, 202)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Radiology Business',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      Spacer(),
                                      Text(
                                          '\u{20B9} ' +
                                              data.RAD_BUSINESS.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      Icon(Icons.double_arrow,
                                          color: Color.fromARGB(
                                              255, 214, 132, 132)),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  total_amouont = "";
                                  globals.fromDate = "";
                                  globals.ToDate = "";
                                  globals.Radio_Lab_Flag = "R";
                                  // globals.Amount_CWB = data.Total_CWB_AMOUNTS.toString();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LocationWiseCollection()));
                                }),
                            Divider(
                              thickness: 1.0,
                              color: Colors.grey[300],
                            ),
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 2.0, 15.0, 2.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.report_gmailerrorred,
                                              color: Color.fromARGB(
                                                  255, 104, 9, 228)),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text('Reports',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500)),
                                          Spacer(),
                                          Spacer(),
                                          Icon(Icons.double_arrow,
                                              color: Color.fromARGB(
                                                  255, 9, 228, 75)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0))),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Mobile No. :'),
                                              TextField(
                                                controller:
                                                    _Mobile_NoController,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "Enter here Mobile No. "),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Center(
                                                child: Text('OR',
                                                    style: TextStyle(
                                                        color: Colors.indigo)),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text('Bill No.:'),
                                              TextField(
                                                controller: _billnoController,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "Enter here Bill No.:  "),
                                              ),
                                              Center(
                                                child: SizedBox(
                                                  height: 50,
                                                  width: 100,
                                                  child: InkWell(
                                                    child: Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18)),
                                                      color: Colors.green,
                                                      child: Center(
                                                          child: Text(
                                                        'OK',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )),
                                                    ),
                                                    onTap: () {
                                                      // ClientChannelDeptWise(5, 0);

                                                      if (_billnoController
                                                                  .text ==
                                                              "" &&
                                                          _Mobile_NoController
                                                                  .text ==
                                                              "") {
                                                        // return false;

                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Enter Valid Number",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    180,
                                                                    17,
                                                                    17),
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      }

                                                      if (_billnoController
                                                                  .text !=
                                                              "" ||
                                                          _Mobile_NoController
                                                                  .text !=
                                                              "") {
                                                        globals.mobile_no =
                                                            _Mobile_NoController
                                                                .text;
                                                        globals.bill_no =
                                                            _billnoController
                                                                .text;
                                                        ReportData(5, 0);
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ReportData(
                                                                            0,
                                                                            0)));
                                                      }
                                                      clearText();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                }),
                          ],
                        ),
                      ),
                    )
                  : const Card(),
        ]),
      )),
    ],
  );
}

class ManagerDetails {
  final empid;
  final empname;
  final reportmgrid;
  final reportmgrname;
  final deposits;
  final business;
  final balance;
  final InActive;
  final Active;
  final My_Clients;
  final mobileno;
  final emailid;
  final mngrcnt;
  final monthWiseAchieveAmt;
  final monthWiseTargetAmt;
  final dayWiseAchieveAmt;
  final dayWiseTargetAmt;
  final Total_CWB_AMOUNTS;
  final GROSS_AMOUNT;
  final NET_AMOUNT;
  final ORDERS;
  final SAMPLES;
  final LAB_BUSINESS;
  final RAD_BUSINESS;

  ManagerDetails({
    required this.empid,
    required this.empname,
    required this.reportmgrid,
    required this.reportmgrname,
    required this.deposits,
    required this.business,
    required this.balance,
    required this.InActive,
    required this.Active,
    required this.My_Clients,
    required this.mobileno,
    required this.emailid,
    required this.mngrcnt,
    required this.monthWiseAchieveAmt,
    required this.monthWiseTargetAmt,
    required this.dayWiseAchieveAmt,
    required this.dayWiseTargetAmt,
    required this.Total_CWB_AMOUNTS,
    required this.GROSS_AMOUNT,
    required this.NET_AMOUNT,
    required this.ORDERS,
    required this.SAMPLES,
    required this.LAB_BUSINESS,
    required this.RAD_BUSINESS,
  });
  factory ManagerDetails.fromJson(Map<String, dynamic> json) {
    if (json['EMPLOYEE_NAME'].toString() == "null") {
      json['EMPLOYEE_NAME'] = "";
    }
    if (json['MNGR_CNT'].toString() == "null") {
      json['MNGR_CNT'] = "0";
    }
    if (json['BUSINESS'].toString() == "null") {
      json['BUSINESS'] = "0";
    }
    if (json['DEPOSITS'].toString() == "null") {
      json['DEPOSITS'] = "0";
    }
    if (json['BALANCE'].toString() == "null") {
      json['BALANCE'] = "0";
    }
    if (json['TOTAL'].toString() == "null") {
      json['TOTAL'] = "0";
    }

    if (json['EMAIL_ID'] == "") {
      json['EMAIL_ID'] = 'Not Specified.';
    }
    // globals.daypay = json['DAY_WISE_ACHIEVED'].toString();
    // globals.daybusin = json['DAY_WISE_TARGET'].toString();

    return ManagerDetails(
      empid: json['EMPLOYEE_ID'].toString(),
      empname: json['EMPLOYEE_NAME'].toString(),
      reportmgrid: json['REPORTING_MNGR_ID'].toString(),
      reportmgrname: json['REPORTING_MNGR_NAME'].toString(),
      deposits: json['DEPOSITS'].toString(),
      business: json['BUSINESS'].toString(),
      balance: json['BALANCE'].toString(),
      InActive: json['IN_ACTIVE'].toString(),
      Active: json['ACTIVE'].toString(),
      My_Clients: json['TOTAL'].toString(),
      mobileno: json['MOBILE_PHONE'].toString(),
      emailid: json['EMAIL_ID'].toString(),
      mngrcnt: json['MNGR_CNT'].toString(),
      monthWiseTargetAmt: json['ACHIEVED_AMOUNT'].toString(),
      monthWiseAchieveAmt: json['TARGET_AMOUNT'].toString(),
      dayWiseTargetAmt: json['DAY_WISE_TARGET'].toString(),
      dayWiseAchieveAmt: json['DAY_WISE_ACHIEVED'].toString(),
      Total_CWB_AMOUNTS: json['AMOUNTS'].toString(),
      GROSS_AMOUNT: json['GROSS_AMOUNT'].toString(),
      NET_AMOUNT: json['NET_AMOUNT'].toString(),
      ORDERS: json['ORDERS'].toString(),
      SAMPLES: json['SAMPLES'].toString(),
      LAB_BUSINESS: json['LAB_BUSINESS'].toString(),
      RAD_BUSINESS: json['RAD_BUSINESS'].toString(),
    );
  }
}
