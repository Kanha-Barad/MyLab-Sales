import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'Admin_Dashboard.dart';
import 'New_Login.dart';
import './summary_by_report.dart';
import 'CenterWiseBusiness.dart';
import 'Report_by_Cardialogy.dart';
import 'globals.dart' as globals;

import 'Sales_Dashboard.dart';
import 'service_group_wise_services.dart';

var datasetval = [];

class Total_Business extends StatefulWidget {
  Total_Business({Key? key}) : super(key: key);

  @override
  State<Total_Business> createState() => _Total_BusinessState();
}

String empID = "0";

class _Total_BusinessState extends State<Total_Business> {
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';
  DateTime selectedDate = DateTime.now();

  @override

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
            print(selectedIndex);
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
  _CenterWiseBusinessDate(BuildContext context) async {
    final DateTimeRange? selected = await showDateRangePicker(
      context: context,
      // initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
      saveText: 'Done',
    );
    // if (selected != null && selected != selectedDate) {
    setState(() {
      globals.fromDate = selected!.start.toString().split(' ')[0];
      globals.ToDate = selected.end.toString().split(' ')[0];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Widget build(BuildContext context) {
    final DateFormat formatter1 = DateFormat('dd-MMM-yyyy');
    var now = DateTime.now();
    if (globals.fromDate != "") {
      selecteFromdt = globals.fromDate;
      selecteTodt = globals.ToDate;
    } else if (selecteTodt == '') {
      selecteFromdt = formatter1.format(now);
      selecteTodt = formatter1.format(now);
    }
    Future<List<Total_Business_Model_Class>> _fetchSaleTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];
      datasetval = [];
      Map data = {
        "IP_USER_ID": globals.USER_ID,
        // "IP_FROM_DT": "${selectedDate.toLocal()}".split(' ')[0],
        // "IP_TO_DT": "${selectedDate.toLocal()}".split(' ')[0],
        "IP_FROM_DT": selecteFromdt == ""
            ? "${selectedDate.toLocal()}".split(' ')[0]
            : selecteFromdt,
        "IP_TO_DT": selecteTodt == ""
            ? "${selectedDate.toLocal()}".split(' ')[0]
            : selecteTodt,
        "connection": globals.Connection_Flag
      };

      dsetName = 'result';
      jobsListAPIUrl = Uri.parse(
          globals.API_url + '/MobileSales/Location_Wise_Total_Business');
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
        datasetval = jsonDecode(response.body)["Data"];
        return jsonResponse
            .map((managers) => Total_Business_Model_Class.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget Total_Business_Vertical_Widget = Container(
      // margin: EdgeInsets.symmetric(vertical: 2.0),
      height: MediaQuery.of(context).size.height * 0.65,
      child: FutureBuilder<List<Total_Business_Model_Class>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData && datasetval.length > 0) {
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              }
              var data = snapshot.data;
              return Total_Business_ListView(data, context);
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
    Widget Total_Business_only_Widget = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      height: 40.0,
      child: FutureBuilder<List<Total_Business_Model_Class>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              }
              var data = snapshot.data;
              return Total_Business_Only_ListView(data, context);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Container();
          }),
    );

    Widget BottomNAVIgation = Container(
        // height: 150,
        width: MediaQuery.of(context).size.width,
        height: 48,
        color: Color(0xff123456),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
            child: InkWell(
              onTap: () {
                globals.Service_Group_Name = "";
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
              onTap: () {},
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff123456),
        title: Row(
          children: [
            IconButton(
                onPressed: () {
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
                icon: Icon(Icons.arrow_back_ios_new)),
            Text(
              "Total Business",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Spacer(),
            Text("${selectedDate.toLocal()}".split(' ')[0],
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            IconButton(
              icon: Icon(Icons.date_range_outlined),
              onPressed: () {
                // _selectDate(context);

                _CenterWiseBusinessDate(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 48, child: DateSelection()),
          SizedBox(
              height: 25,
              child: Text(selecteFromdt + '  To   ' + selecteTodt,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0))),
          Container(child: Total_Business_Vertical_Widget),
        ],
      ),
      bottomSheet: Total_Business_only_Widget,
      bottomNavigationBar: BottomNAVIgation,
    );
  }
}

//........................................End Class
class NoContent extends StatelessWidget {
  const NoContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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

class Total_Business_Model_Class {
  final SERVICE_GROUP_NAME;
  final SERVICE_GROUP_ID;
  final SERVICE_GROUP_CNT;
  final GROSS;
  final NET_AMOUNT;
  final LOCATION_NAME;
  final SUM_GRP_NAMES;
  final SUM_GRP_IDS;
  final GRP_GROSS;
  final GRP_NETLAB_GROSS;
  final CARDIALOGY_NAMES;
  final CARDIALOGY_COUNTS;
  final TOTAL_CARDIA_CNTS;
  final TOTAL_CARDIA_NAMES;
  final LAB_NET;
  final ORDERS_CNT;
  final TESTS_CNT;
  final TOTAL_ORDERS;
  final TOTAL_TESTS;
  final LOC_ID;
  final CARDIALOGY_IDS;
  final LAB_GROSS;

  Total_Business_Model_Class({
    required this.SERVICE_GROUP_NAME,
    required this.SERVICE_GROUP_ID,
    required this.SERVICE_GROUP_CNT,
    required this.GROSS,
    required this.NET_AMOUNT,
    required this.LOCATION_NAME,
    required this.SUM_GRP_NAMES,
    required this.SUM_GRP_IDS,
    required this.GRP_GROSS,
    required this.GRP_NETLAB_GROSS,
    required this.CARDIALOGY_NAMES,
    required this.CARDIALOGY_COUNTS,
    required this.TOTAL_CARDIA_CNTS,
    required this.TOTAL_CARDIA_NAMES,
    required this.LAB_NET,
    required this.ORDERS_CNT,
    required this.TESTS_CNT,
    required this.TOTAL_ORDERS,
    required this.TOTAL_TESTS,
    required this.LOC_ID,
    required this.CARDIALOGY_IDS,
    required this.LAB_GROSS,
  });

  factory Total_Business_Model_Class.fromJson(Map<String, dynamic> json) {
    return Total_Business_Model_Class(
      SERVICE_GROUP_NAME: json['SERVICE_GROUP_NAME'],
      SERVICE_GROUP_ID: json['SERVICE_GROUP_ID'],
      SERVICE_GROUP_CNT: json['SERVICE_GROUP_CNT'],
      GROSS: json['GROSS'],
      NET_AMOUNT: json['NET_AMOUNT'],
      LOCATION_NAME: json['LOCATION_NAME'],
      SUM_GRP_NAMES: json['SUM_GRP_NAMES'],
      SUM_GRP_IDS: json['SUM_GRP_IDS'],
      GRP_GROSS: json['GRP_GROSS'],
      GRP_NETLAB_GROSS: json['GRP_NETLAB_GROSS'],
      CARDIALOGY_NAMES: json['CARDIALOGY_NAMES'],
      CARDIALOGY_COUNTS: json['CARDIALOGY_COUNTS'],
      TOTAL_CARDIA_CNTS: json['TOTAL_CARDIA_CNTS'],
      TOTAL_CARDIA_NAMES: json['TOTAL_CARDIA_NAMES'],
      LAB_NET: json['LAB_NET'],
      ORDERS_CNT: json['ORDERS_CNT'],
      TESTS_CNT: json['TESTS_CNT'],
      TOTAL_ORDERS: json['TOTAL_ORDERS'],
      TOTAL_TESTS: json['TOTAL_TESTS'],
      LOC_ID: json['LOC_ID'],
      CARDIALOGY_IDS: json['CARDIALOGY_IDS'],
      LAB_GROSS: json['LAB_GROSS'],
    );
  }
}

ListView Total_Business_Only_ListView(data, BuildContext context) {
  if (data != null) {
    return ListView.builder(
        itemCount: data.length,
        //itemCount: 1,
        itemBuilder: (context, index) {
          //return _tile(data[index].position, data[index].company, Icons.work);
          return Total_Business_Only_Widget(data[index], context);
        });
  }
  return ListView();
}

Widget Total_Business_Only_Widget(var data, BuildContext context) {
  return Container(
      // height: 150,
      width: MediaQuery.of(context).size.width,
      height: 48,
      color: Color.fromARGB(255, 176, 204, 232),
      // color: Color(0xff123456),
      // color: Color.fromARGB(255, 142, 206, 146),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 65, 15),
        child: Row(
          children: [
            Icon(Icons.business_center, color: Colors.black),
            SizedBox(
              width: 10,
            ),
            Text('Total Business',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500)),
            Spacer(),
            Text('\u{20B9} ' + data.GRP_GROSS.toString(),
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500))
          ],
        ),
      ));
}

ListView Total_Business_ListView(data, BuildContext context) {
  if (data != null) {
    return ListView.builder(
        itemCount: data.length,
        //itemCount: 1,
        itemBuilder: (context, index) {
          //return _tile(data[index].position, data[index].company, Icons.work);
          return Total_Business_Widget(data[index], context);
        });
  }
  return ListView();
}

Widget Total_Business_Widget(var data, BuildContext context) {
  return SingleChildScrollView(
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Color.fromARGB(255, 229, 228, 233),
            Color.fromARGB(255, 229, 229, 231),
            Color.fromARGB(255, 246, 246, 247)
          ])),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 3, 10, 1),
                child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: Color.fromARGB(143, 112, 233, 174),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
                          child: InkWell(
                            onTap: (() {
                              globals.Loc_Name_CWB =
                                  data.LOCATION_NAME.toString();

                              globals.LOC_ID = data.LOC_ID.toString();

                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => CenterWiseBusiness()));

                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    CenterWiseBusiness(),
                              );
                            }),
                            child: Card(
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Color.fromARGB(255, 169, 165, 164),
                                ),
                              ),
                              color: const Color.fromARGB(255, 229, 231, 231),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 3, 0, 3),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      size: 22,
                                      color: Color.fromARGB(255, 24, 167, 114),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        data.LOCATION_NAME.toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.double_arrow,
                                        color: Color.fromARGB(255, 9, 228, 75)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                  child: Column(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Gross Amount'),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: (data.GROSS != "null" &&
                                                data.GROSS != null)
                                            ? Text(
                                                '\u{20B9} ' +
                                                    (data.GROSS +
                                                            data.LAB_GROSS)
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15))
                                            : Text('\u{20B9} ' + "0",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15)),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: VerticalDivider(
                                      // indent: 20,
                                      // endIndent: 30,
                                      // thickness: 3,
                                      color: Colors.black),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      Text('Net Amount'),
                                      Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: (data.NET_AMOUNT != "null" &&
                                                  data.NET_AMOUNT != null)
                                              ? Text(
                                                  '\u{20B9} ' +
                                                      (data.NET_AMOUNT +
                                                              data.LAB_NET)
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15))
                                              : Text('\u{20B9} ' + "0",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15)))
                                    ],
                                  ),
                                )
                              ]),
                        ),
                        Divider(
                            indent: 20,
                            endIndent: 20,
                            //  thickness: 3,
                            color: Colors.black),
                        IntrinsicHeight(
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(62, 0, 62, 0),
                                  child: Column(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Orders'),
                                      CircleAvatar(
                                        backgroundColor: Colors.green,
                                        radius: 18.0,
                                        child: ClipRRect(
                                          child: (data.ORDERS_CNT != "null" &&
                                                  data.ORDERS_CNT != null)
                                              ? Text(
                                                  data.ORDERS_CNT.toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                )
                                              : Text(
                                                  data.ORDERS_CNT.toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(70.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: VerticalDivider(
                                      // indent: 20,
                                      // endIndent: 30,
                                      // thickness: 3,
                                      color: Colors.black),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      Text('Tests'),
                                      CircleAvatar(
                                        backgroundColor: Colors.green,
                                        radius: 18.0,
                                        child: ClipRRect(
                                          child: (data.TESTS_CNT != "null" &&
                                                  data.TESTS_CNT != null)
                                              ? Text(
                                                  data.TESTS_CNT.toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                )
                                              : Text(
                                                  "0",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(70.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        ),
                        Divider(
                            indent: 20,
                            endIndent: 20,
                            //  thickness: 3,
                            color: Colors.black),
                        //.............................................................................................
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  (data.SERVICE_GROUP_NAME != "null" &&
                                          data.SERVICE_GROUP_NAME != null)
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var i in data
                                                .SERVICE_GROUP_NAME
                                                .split(','))
                                              Container(
                                                  height: 40,
                                                  width: 180,
                                                  child: InkWell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            i.toString(),
                                                          ))))
                                          ],
                                        )
                                      : Container(),
                                  Spacer(),
                                  (data.SERVICE_GROUP_ID != "null" &&
                                          data.SERVICE_GROUP_ID != null)
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            for (var i in data.SERVICE_GROUP_CNT
                                                .split(','))
                                              Container(
                                                height: 40,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                  radius: 15.0,
                                                  child: ClipRRect(
                                                    child: Text(
                                                      i.toString(),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            70.0),
                                                  ),
                                                ),
                                              )
                                          ],
                                        )
                                      : Container(),
                                  (data.SERVICE_GROUP_ID != "null" &&
                                          data.SERVICE_GROUP_ID != null)
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var i in data.SERVICE_GROUP_ID
                                                .split(','))
                                              Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: InkWell(
                                                      onTap: () {
                                                        globals.Glb_service_group_id =
                                                            i.toString();
                                                        globals.LOC_ID = data
                                                            .LOC_ID
                                                            .toString();

                                                        print("you clicked");
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Service_Group_Wise_Services()));
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Spacer(),
                                                            Icon(
                                                              Icons
                                                                  .double_arrow,
                                                              color:
                                                                  Colors.black,
                                                            )
                                                          ],
                                                        ),
                                                      ))),
                                          ],
                                        )
                                      : Container()
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                            indent: 20,
                            endIndent: 20,
                            //  thickness: 3,
                            color: Colors.black),
                        //.............................................................................................
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  (data.CARDIALOGY_NAMES != "null" &&
                                          data.CARDIALOGY_NAMES != null)
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var i in data.CARDIALOGY_NAMES
                                                .split(','))
                                              Container(
                                                  height: 45,
                                                  width: 180,
                                                  child: InkWell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            i.toString(),
                                                          ))))
                                          ],
                                        )
                                      : Container(),
                                  Spacer(),
                                  (data.CARDIALOGY_COUNTS != "null" &&
                                          data.CARDIALOGY_COUNTS != null)
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            for (var i in data.CARDIALOGY_COUNTS
                                                .split(','))
                                              Container(
                                                height: 45,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                  radius: 15.0,
                                                  child: ClipRRect(
                                                    child: Text(
                                                      i.toString(),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            70.0),
                                                  ),
                                                ),
                                              )

                                            //Text(data.SERVICE_GROUP_NAME.toString()),
                                            // Spacer(),
                                            // Text(data.TOTAL.toString())
                                          ],
                                        )
                                      : Container(),
                                  (data.CARDIALOGY_COUNTS != "null" &&
                                          data.CARDIALOGY_COUNTS != null)
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var i in data.CARDIALOGY_IDS
                                                .split(','))
                                              Container(
                                                  height: 45,
                                                  width: 40,
                                                  child: InkWell(
                                                      onTap: () {
                                                        globals.SERVICE_ID_by_Cardialogy =
                                                            i.toString();

                                                        // for (var j in data
                                                        //     .CARDIALOGY_NAMES
                                                        //     .split(','))
                                                        //   globals.SERVICE_NAME_SERVICES =
                                                        //       data.CARDIALOGY_NAMES =
                                                        //           j.toString();
                                                        globals.SERVICE_NAME_SERVICES =
                                                            data.CARDIALOGY_NAMES
                                                                .toString();

                                                        // for (var k in data
                                                        //     .CARDIALOGY_NAMES
                                                        //     .split(','))
                                                        //   globals.Count_Services =
                                                        //       data.CARDIALOGY_COUNTS =
                                                        //           k.toString();

                                                        globals.Count_Services =
                                                            data.CARDIALOGY_COUNTS
                                                                .toString();
                                                        globals.LOC_ID = data
                                                            .LOC_ID
                                                            .toString();

                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    Report_by_Cardialogy(
                                                                        0, 0)));
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Spacer(),
                                                            Icon(
                                                              Icons
                                                                  .double_arrow,
                                                              color:
                                                                  Colors.black,
                                                            )
                                                          ],
                                                        ),
                                                      ))),
                                          ],
                                        )
                                      : Container()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                    )),
              ),
            ],
          )));
}
