//import 'dart:ffi';
import 'dart:ui';
// import 'package:clients_app/Business.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'New_Login.dart';
import 'Sales_Dashboard.dart';
import 'CenterWiseBusiness.dart';
import 'LocationWiseBusiness.dart';
// import 'SalesDashboard.dart';
import 'admin_dashboard.dart';
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
List data = [];

class LocationWiseReport extends StatefulWidget {
  // const ClientProfile({Key? key}) : super(key: key);
  int selectedPage;

  LocationWiseReport(this.selectedPage);
  @override
  _LocationWiseReportState createState() =>
      _LocationWiseReportState(this.selectedPage);
}

class _LocationWiseReportState extends State<LocationWiseReport> {
  var client_selectedItem;
  var department_selectedItem;
  int selectedPage;
  DateTime pastMonth = DateTime.now().subtract(Duration(days: 30));
  _LocationWiseReportState(this.selectedPage);
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
    late Map<String, dynamic> map;
    late Map<String, dynamic> params;

    getSWData() async {
      // if ((nameController.text == "" || nameController.text == null)) {
      //   return "fail";
      // }

      params = {"IP_SESSION_ID": "1", "connection": "2"};

      final response = await http.post(
          Uri.parse(
              "https://mobileappjw.softmed.in/PatinetMobileApp/Location_list"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: params,
          encoding: Encoding.getByName("utf-8"));

      print('im here');
      print(response.body);
      map = json.decode(response.body);
      print(response.body);
      // if (response.statusCode == 200) {
      //   functionCalls = "true";
      // } else {
      //   functionCalls == "false";
      // }
      setState(() {
        data = map["Data"] as List;
        // print(data);
      });

      return "Sucess";
    }

    final client_Dropdwon = SizedBox(
        width: 120,
        height: 30,
        child: Card(
          elevation: 2.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isDense: true,
                isExpanded: true,
                value: client_selectedItem,
                hint: Text('Select'),
                onChanged: (value) {
                  setState(() {
                    client_selectedItem = value;
                    globals.SelectedlocationId = client_selectedItem;
                  });
                },
                items: data.map((ldata) {
                  return DropdownMenuItem(
                    child: Text(
                      ldata['LOCATION_NAME'].toString(),
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    value: ldata['LOC_ID'].toString(),
                  );
                }).toList(),
                // style: TextStyle(color: Colors.black, fontSize: 20,fontFamily: "Montserrat"),
              ),
            ),
          ),
        ));

    final department_Dropdwon = SizedBox(
        width: 120,
        height: 30,
        child: Card(
          elevation: 2.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isDense: true,
                isExpanded: true,
                value: department_selectedItem,
                hint: Text('Select'),
                onChanged: (value) {
                  setState(() {
                    department_selectedItem = value;
                    globals.SelectedlocationId = department_selectedItem;
                  });
                },
                items: data.map((ldata) {
                  return DropdownMenuItem(
                    child: Text(
                      ldata['LOCATION_NAME'].toString(),
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    value: ldata['LOC_ID'].toString(),
                  );
                }).toList(),
                // style: TextStyle(color: Colors.black, fontSize: 20,fontFamily: "Montserrat"),
              ),
            ),
          ),
        ));

    if (data == "" || data.length == 0) {
      getSWData();
    }
    //   super.build(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff123456),
        title: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      globals.fromDate = "";
                      globals.ToDate = "";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => locationWiseAmount(0)),
                      );
                    },
                    icon: Icon(Icons.arrow_back)),
                Text(
                  "Location Wise Report",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.date_range_outlined),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 162,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        child: Text(
                          "Client:",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      client_Dropdwon,
                    ],
                  ),
                ),
                Container(
                  width: 162,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        child: Text(
                          "Dept.: ",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      department_Dropdwon
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 162,
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            child: Text(
                              "Bill No:",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 100,
                            //  padding: EdgeInsets.symmetric(vertical: 2),
                            child: TextField(
                              //   focusNode: myFocusNode,
                              keyboardType: TextInputType.number,
                              // inputFormatters: <TextInputFormatter>[
                              //   FilteringTextInputFormatter.digitsOnly
                              // ],
                              // obscureText: true,
                              // controller: NameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusColor: Colors.white,
                                fillColor: Colors.white,
                                filled: true,
                                //hintText: 'Enter Your Name',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 162,
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            child: Text(
                              "B Code:",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 100,
                            //  padding: EdgeInsets.symmetric(vertical: 2),
                            child: TextField(
                              //   focusNode: myFocusNode,
                              keyboardType: TextInputType.number,
                              // inputFormatters: <TextInputFormatter>[
                              //   FilteringTextInputFormatter.digitsOnly
                              // ],
                              // obscureText: true,
                              // controller: NameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusColor: Colors.white,
                                fillColor: Colors.white,
                                filled: true,
                                //hintText: 'Enter Your Name',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 238, 244, 54),
                              Colors.blue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                            child: Text("Search",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0))),
                      ),
                    ),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => ClientProfile(0)),
                      // );
                      print("tapped on container");
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: Report(0),
    );
  }
}

class Report extends StatefulWidget {
  int selectedtab;
  Report(this.selectedtab);
  @override
  _ReportState createState() => _ReportState(this.selectedtab);
}

class _ReportState extends State<Report> {
  int selectedtab;
  _ReportState(this.selectedtab);
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
//..................................
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
//..................................
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

    Widget BottomNavigation = Container(
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
              height: MediaQuery.of(context).size.height * 0.6,
              child: verticalListSales,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation,
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
  return Text("This is Body Part");
}
