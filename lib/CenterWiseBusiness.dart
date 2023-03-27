import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'Admin_Dashboard.dart';
import 'referal_test.dart';
import 'New_Login.dart';
import './total_business.dart';
import 'Department_Service_Group_Wise_Services.dart';
import 'Sales_Dashboard.dart';
import 'ClientWiseBusiness.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'LocationWiseBusiness.dart';

import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

double amount = 1;

var _selflag = "";
var flag = "";
var datasetval = [];
TextEditingController _Mobile_NoController = TextEditingController();
TextEditingController _billnoController = TextEditingController();

class CenterWiseBusiness extends StatefulWidget {
  @override
  State<CenterWiseBusiness> createState() => _CenterWiseBusinessState();
}

class _CenterWiseBusinessState extends State<CenterWiseBusiness> {
  String empID = "0";

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
      print(amount);
      if (_selflag == "CH") {
        globals.TOTAL_CHANNEL_AMOUNT = amount.toString();
      } else if (_selflag == "CL") {
        globals.TOTAL_CLIENT_AMOUNT = amount.toString();
      } else if (_selflag == "REF") {
        globals.TOTAL_CLIENT_AMOUNT = amount.toString();
      } else if (_selflag == "TE") {
        globals.TOTAL_CLIENT_AMOUNT = amount.toString();
      } else if (_selflag == "RE") {
        globals.TOTAL_CLIENT_AMOUNT = amount.toString();
        globals.glbFlag == "RE";
      } else {
        globals.TOTAL_SRV_GRP_AMOUNT = amount.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return DefaultTabController(
      initialIndex: 0,
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff123456),
          title: Row(
            children: [
              IconButton(
                  onPressed: () {
                    _billnoController.text = "";
                    _Mobile_NoController.text = "";
                    globals.fromDate = "";
                    globals.ToDate = "";
                    total_amouont = "";
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Total_Business()),
                    );
                  },
                  icon: Icon(Icons.arrow_back)),
              Text(
                "Center Wise Business",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Spacer(),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CenterWiseBusiness()));
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ))
            ],
          ),
          actions: [
            flag == "RE"
                ? IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.report_outlined,
                      color: Colors.deepOrange,
                    ))
                : Container(),
            IconButton(
              icon: Icon(Icons.date_range_outlined),
              onPressed: () {
                // amount = 0;
                _CenterWiseBusinessDate(context);
              },
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.location_history), text: 'By Client'),
              Tab(icon: Icon(Icons.location_city_outlined), text: 'By Channel'),
              Tab(
                  icon: Transform.rotate(
                      angle: -180 * math.pi / 180,
                      child: Icon(
                        Icons.filter_alt_outlined,
                      )),
                  text: 'By Dept.'),
              Tab(icon: Icon(Icons.person_search_outlined), text: 'By Referal'),
              Tab(icon: Icon(Icons.water_drop_outlined), text: 'By Test Wise'),
              Tab(icon: Icon(Icons.report_outlined), text: 'Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ClientChannelDeptWise(0, 0),
            ClientChannelDeptWise(1, 0),
            ClientChannelDeptWise(2, 0),
            ClientChannelDeptWise(3, 0),
            ClientChannelDeptWise(4, 0),
            Report_With_Popup(),
          ],
        ),
      ),
    );
  }
}

class ClientChannelDeptWise extends StatefulWidget {
  int index;

  int selectedIndex;
  ClientChannelDeptWise(this.index, this.selectedIndex);
  @override
  State<ClientChannelDeptWise> createState() =>
      _ClientChannelDeptWiseState(this.index, this.selectedIndex);
}

class _ClientChannelDeptWiseState extends State<ClientChannelDeptWise> {
  ReportFuction() async {
    datasetval = [];
    Map data = {
      "Emp_id": globals.loginEmpid,
      "session_id": "1",
      "flag": "",
      "from_dt": selecteFromdt,
      "to_dt": selecteTodt,
      "location_wise_flg": flag.toString(),
      "location_id": globals.LOC_ID,
      "IP_BILL_NO": _billnoController.text,
      "IP_BARCODE_NO": _Mobile_NoController.text,
      "connection": globals.Connection_Flag
    };
    print(data.toString());

    final response = await http.post(
        Uri.parse(globals.API_url + '/MobileSales/Centerwisetrans'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));

    if (response.statusCode == 200) {
      Map<String, dynamic> resposne = jsonDecode(response.body);
      datasetval = jsonDecode(response.body)["Data"];
      Map<String, dynamic> user = resposne['Data'][0];
      String LOCATION_NAME = user['LOCATION_NAME'].toString();
      print("Work Complected");

      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => ValidateOTP()));
    }
  }

  int index;
  String empID = "0";
  int selectedIndex;
  var selecteFromdt = '';
  var selecteTodt = '';
  _ClientChannelDeptWiseState(this.index, this.selectedIndex);

  Updamount(double amt) {
    setState(() {
      amount += amt;
    });
    return amount;
  }

  @override
  ListView ClientChannelDeptListView(data, BuildContext context, String flag) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          // Updamount(double.parse(data[index].CHANNEL_AMOUNT.toString()));
          if (flag == "CL") {
            return ClientWiseAmountDetails(data[index], context, index, flag);
          } else if (flag == "CH") {
            return ChannelWiseAmountDetails(data[index], context, index, flag);
          } else if (flag == "REF") {
            return RefDoctorWiseAmountDetails(
                data[index], context, index, flag);
          } else if (flag == "TE") {
            return TestWiseAmountDetails(data[index], context, index, flag);
          } else if (flag == "RE") {
            return Container();
          } else {
            return DeptWiseAmountDetails(data[index], context, index, flag);
          }
        });
  }

  Widget report(var data, BuildContext context, index, flag) {
    _selflag = flag;

    return GestureDetector(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0.0),
      child: InkWell(
        onTap: (() {}),
        child: Card(
            elevation: 4.0,
            child: ListTile(
              // leading: Icon(Icons.verified_rounded, color: Colors.green),
              title: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Icon(Icons.person, color: Colors.grey),
                      ),

                      Container(
                        width: 150,
                        child: Text(data.PATIENT_NAME.toString(),
                            style: TextStyle(
                                color: Color(0xff123456),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0)),
                      ),
                      Spacer(),
                      Text(data.Age.toString(),
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0)),
                      // SizedBox(
                      //   width: 1,
                      // ),
                    ],
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: 150,
                        child: Row(
                          children: [
                            Text(
                                data.BILL_NO.toString() +
                                    ' | ' +
                                    data.BILL_DT.toString(),
                                style: TextStyle(
                                    color: Color.fromARGB(255, 106, 199, 248),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: 150,
                        child: Text(data.SERVICE_NAME.toString(),
                            style: TextStyle(
                                color: Color(0xff123456),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.0)),
                      ),
                      Spacer(),
                      Text(data.srv_status.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.0)),
                      SizedBox(
                        height: 35,
                        child: data.srv_status == "Completed"
                            ? IconButton(
                                onPressed: () {
                                  _launchURL(data.REPORT_CD.toString());
                                },
                                icon: Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                ))
                            : Container(),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    ));
  }

  Widget ClientWiseAmountDetails(var data, BuildContext context, index, flag) {
    amount = amount + double.parse(data.CLIENT_AMOUNT.toString());
    _selflag = flag;
    globals.glbFlag == "";
    // Updamount(double.parse(data.CLIENT_AMOUNT.toString()));
    return GestureDetector(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0.0),
      child: InkWell(
        onTap: (() {
          globals.fromDate = "";
          globals.ToDate = "";
          globals.CLIENT_NAME = data.CLIENT_NAME;
          globals.selectedClientid = data.CLIENT_ID;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ClientProfile(0)));
          print("yes you click");
          print(amount);
          setState(() {});
          // showDialog(
          //   context: context,
          //   builder: (BuildContext context) => _buildPopupDialog(),
          // );
        }),
        child: Card(
            elevation: 4.0,
            child: ListTile(
              leading: Icon(Icons.location_history,
                  color: Color.fromARGB(255, 223, 40, 27)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 130,
                    child: Text(data.CLIENT_NAME.toString(),
                        style: TextStyle(
                            color: Color(0xff123456),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0)),
                  ),
                  Spacer(),
                  Text('\u{20B9} ' + data.CLIENT_AMOUNT.toString(),
                      style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  SizedBox(
                    width: 1,
                  ),
                ],
              ),

              //         child: Padding(
              //   padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              //   child:
              //   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //      Icon(Icons.location_pin, color: Color.fromARGB(255, 223, 40, 27)),
              //         Text(data.Location_name, style: TextStyle(fontSize: 13)),
              //         Text(data.Amount, style: TextStyle(fontSize: 13))
              //       ]),
              // )
            )),
      ),
    ));
  }

  Widget ChannelWiseAmountDetails(var data, BuildContext context, index, flag) {
    // amount = amount + double.parse(data.CHANNEL_AMOUNT.toString());
    _selflag = flag;
    globals.glbFlag == "";
    return GestureDetector(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0.0),
      child: InkWell(
        onTap: (() {
          print(amount);

          totbusinessChannelWise();
          print("yes you click");

          // showDialog(
          //   context: context,
          //   builder: (BuildContext context) => _buildPopupDialog(),
          // );
        }),
        child: Column(
          children: [
            Card(
                elevation: 4.0,
                child: ListTile(
                  leading: Icon(Icons.business_outlined,
                      color: Color.fromARGB(255, 126, 226, 152)),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 130,
                        child: Text(data.CHANNEL_NAME.toString(),
                            style: TextStyle(
                                color: Color(0xff123456),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0)),
                      ),
                      Spacer(),
                      Text('\u{20B9} ' + data.CHANNEL_AMOUNT.toString(),
                          style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0)),
                      SizedBox(
                        width: 1,
                      ),
                    ],
                  ),

                  //         child: Padding(
                  //   padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  //   child:
                  //   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       //crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //      Icon(Icons.location_pin, color: Color.fromARGB(255, 223, 40, 27)),
                  //         Text(data.Location_name, style: TextStyle(fontSize: 13)),
                  //         Text(data.Amount, style: TextStyle(fontSize: 13))
                  //       ]),
                  // )
                )),
          ],
        ),
      ),
    ));
  }

  Widget DeptWiseAmountDetails(var data, BuildContext context, index, flag) {
    // amount = amount + double.parse(data.DEPT_AMOUNT.toString());
    _selflag = flag;
    globals.glbFlag == "";
    return GestureDetector(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0.0),
      child: InkWell(
        onTap: (() {
          globals.Service_Group_ID = data.SERVICE_GROUP_ID.toString();
          globals.Service_Group_Name = data.SERVICE_GROUP_NAME.toString();
          globals.Total_Count = data.TOTAL..toString();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Department_Service_Group_Wise_Services()));
        }),
        child: Card(
            elevation: 4.0,
            child: ListTile(
              leading: Transform.rotate(
                  angle: -180 * math.pi / 180,
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: Color.fromARGB(255, 27, 145, 223),
                  )),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 130,
                    child: Text(data.SERVICE_GROUP_NAME.toString(),
                        style: TextStyle(
                            color: Color(0xff123456),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0)),
                  ),
                  Spacer(),
                  Text('\u{20B9} ' + data.DEPT_AMOUNT.toString(),
                      style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  SizedBox(width: 5),
                  CircleAvatar(
                    radius: 18.0,
                    child: ClipRRect(
                      child: Text(
                        data.TOTAL.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      borderRadius: BorderRadius.circular(70.0),
                    ),
                  ),
                  SizedBox(
                    width: 1,
                  ),
                ],
              ),
            )),
      ),
    ));
  }

  Widget RefDoctorWiseAmountDetails(
      var data, BuildContext context, index, flag) {
    // amount = amount + double.parse(data.DEPT_AMOUNT.toString());
    _selflag = flag;
    globals.glbFlag == "";
    return GestureDetector(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0.0),
      child: InkWell(
        onTap: (() {
          globals.Referal_Doctor_Id = data.TEMP_REF_DOC_ID.toString();
          globals.REFERAL_DOCTOR = data.REFERAL_DOCTOR.toString();
          globals.REF_AMOUNT = data.REF_AMOUNT.toString();

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Referal_Test()));
        }),
        child: Card(
            elevation: 4.0,
            child: ListTile(
              leading: Icon(
                Icons.person_search_outlined,
                color: Color.fromARGB(255, 148, 225, 144),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 130,
                    child: Text(data.REFERAL_DOCTOR.toString(),
                        style: TextStyle(
                            color: Color(0xff123456),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0)),
                  ),
                  Spacer(),
                  Text('\u{20B9} ' + data.REF_AMOUNT.toString(),
                      style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  SizedBox(
                    width: 1,
                  ),
                ],
              ),
            )),
      ),
    ));
  }

  Widget TestWiseAmountDetails(var data, BuildContext context, index, flag) {
    // amount = amount + double.parse(data.DEPT_AMOUNT.toString());
    _selflag = flag;
    globals.glbFlag == "";
    return GestureDetector(
        child: Padding(
      padding: EdgeInsets.fromLTRB(12, 4, 12, 0.0),
      child: InkWell(
        onTap: (() {}),
        child: Card(
            elevation: 4.0,
            child: ListTile(
              leading: Icon(
                Icons.water_drop_outlined,
                color: Color.fromARGB(255, 148, 225, 144),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 180,
                    child: Text(
                        data.SERVICE_NAME.toString() +
                            "-" +
                            data.SERVICE_GROUP_ID.toString(),
                        style: TextStyle(
                            color: Color(0xff123456),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0)),
                  ),
                  Spacer(),
                  Text('\u{20B9} ' + data.TEST_AMOUNT.toString(),
                      style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  SizedBox(
                    width: 1,
                  ),
                ],
              ),
            )),
      ),
    ));
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
    String flag = "";

    double neaamount = 0;
    Future<List<ClientChannelDept_class>> _fetchManagerDetails() async {
      datasetval = [];
      amount = 0;
      if (this.index == 0) {
        flag = "CL";
      } else if (this.index == 1) {
        flag = "CH";
      } else if (this.index == 2) {
        flag = "DE";
      } else if (this.index == 3) {
        flag = "REF";
      } else if (this.index == 4) {
        flag = "TE";
      } else if (this.index == 5) {
        flag = "RE";
      }
      Map data = {
        "Emp_id": globals.loginEmpid,
        "session_id": "1",
        "flag": "",
        "from_dt": selecteFromdt,
        "to_dt": selecteTodt,
        "location_wise_flg": flag.toString(),
        "location_id": globals.LOC_ID,
        "IP_BILL_NO": _billnoController.text,
        "IP_BARCODE_NO": _Mobile_NoController.text,
        "connection": globals.Connection_Flag
      };
      final jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/Centerwisetrans');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> resposne = jsonDecode(response.body);
        // Map<String, dynamic> user = resposne['Data'][0];
        // globals.Service_Group_ID = user['SERVICE_GROUP_ID'].toString();
        List jsonResponse = resposne["Data"];
        datasetval = jsonDecode(response.body)["Data"];
        _Mobile_NoController.text = "";
        _billnoController.text = "";
        return jsonResponse
            .map((managers) => ClientChannelDept_class.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
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
              //total business amount coding start
              if (_selflag == "CH") {
                globals.TOTAL_CHANNEL_AMOUNT = amount.toString();
              } else if (_selflag == "CL") {
                globals.TOTAL_CLIENT_AMOUNT = amount.toString();
              } else {
                globals.TOTAL_SRV_GRP_AMOUNT = amount.toString();
              }
              //total business amount coding end
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
    Widget verticalListClientChannelDept = Container(
        height: MediaQuery.of(context).size.height * 0.585,
        child: FutureBuilder<List<ClientChannelDept_class>>(
            future: _fetchManagerDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData && datasetval.length > 0) {
                var data = snapshot.data;
                if (snapshot.data!.isEmpty == true) {
                  return NoContent();
                }
                return SizedBox(
                    child: ClientChannelDeptListView(data, context, flag));
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

    Widget verticalListClientChannelRep = Container(
        height: MediaQuery.of(context).size.height * 0.55,
        child: FutureBuilder<List<ClientChannelDept_class>>(
            future: _fetchManagerDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData && datasetval.length > 0) {
                var data = snapshot.data;
                if (snapshot.data!.isEmpty == true) {
                  return NoContent();
                }
                return SizedBox(
                    child: ClientChannelDeptListView(data, context, flag));
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
                        Icons.location_pin,
                        size: 25,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        globals.Loc_Name_CWB,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 48, child: DateSelection()),
          SizedBox(
              height: 25,
              child: Text(selecteFromdt + '  To   ' + selecteTodt,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0))),
          Container(
              child: flag == "RE"
                  ? verticalListClientChannelRep
                  : verticalListClientChannelDept),
          Container(
              // height: 150,
              width: MediaQuery.of(context).size.width,
              height: 48,
              color: Color(0xff123456),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
                      child: InkWell(
                        onTap: () {
                          globals.fromDate = "";
                          globals.ToDate = "";
                          globals.reference_type_id != '28' &&
                                  globals.reference_type_id != '8'
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AdminDashboard(empID, 0)))
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
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
                            MaterialPageRoute(
                                builder: (context) => LoginClass()),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),
                  ]))
        ],
      ),
    ));
  }
}

class ClientChannelDept_class {
  final CLIENT_NAME;
  final CLIENT_AMOUNT;
  final CHANNEL_NAME;
  final CHANNEL_AMOUNT;
  final SERVICE_GROUP_NAME;
  final DEPT_AMOUNT;
  final TOTAL_CHANNEL_AMOUNT;
  final TOTAL_SRV_GRP_AMOUNT;
  final TOTAL_CLIENT_AMOUNT;
  final REF_AMOUNT;
  final TEMP_REF_DOC_ID;
  final REFERAL_DOCTOR;
  final CLIENT_ID;
  final TEST_AMOUNT;
  final SERVICE_GROUP_ID;
  // final SERVICE_NAME;
  final srv_status;
  final SERVICE_ID;
  final BILL_NO;
  final BILL_DT;
  final UMR_NO;
  final PATIENT_NAME;
  final Age;
  final SERVICE_NAME;
  final TOTAL;
  final REPORT_CD;

  ClientChannelDept_class({
    required this.CLIENT_NAME,
    required this.CLIENT_AMOUNT,
    required this.CHANNEL_NAME,
    required this.CHANNEL_AMOUNT,
    required this.SERVICE_GROUP_NAME,
    required this.DEPT_AMOUNT,
    required this.TOTAL_CHANNEL_AMOUNT,
    required this.TOTAL_SRV_GRP_AMOUNT,
    required this.TOTAL_CLIENT_AMOUNT,
    required this.REF_AMOUNT,
    required this.TEMP_REF_DOC_ID,
    required this.REFERAL_DOCTOR,
    required this.CLIENT_ID,
    required this.TEST_AMOUNT,
    required this.SERVICE_GROUP_ID,
    // required this.SERVICE_NAME,
    required this.srv_status,
    required this.SERVICE_ID,
    required this.BILL_NO,
    required this.BILL_DT,
    required this.UMR_NO,
    required this.PATIENT_NAME,
    required this.Age,
    required this.SERVICE_NAME,
    required this.TOTAL,
    required this.REPORT_CD,
  });

  factory ClientChannelDept_class.fromJson(Map<String, dynamic> json) {
    return ClientChannelDept_class(
      CHANNEL_NAME: json['CHANNEL_NAME'].toString(),
      SERVICE_GROUP_NAME: json['SERVICE_GROUP_NAME'].toString(),
      DEPT_AMOUNT: json['DEPT_AMOUNT'].toString(),
      CHANNEL_AMOUNT: json['CHANNEL_AMOUNT'].toString(),
      CLIENT_AMOUNT: json['CLIENT_AMOUNT'].toString(),
      CLIENT_NAME: json['CLIENT_NAME'].toString(),
      TOTAL_CHANNEL_AMOUNT: json['TOTAL_CHANNEL_AMOUNT'].toString(),
      TOTAL_SRV_GRP_AMOUNT: json['TOTAL_SRV_GRP_AMOUNT'].toString(),
      TOTAL_CLIENT_AMOUNT: json['TOTAL_CLIENT_AMOUNT'].toString(),
      REF_AMOUNT: json['REF_AMOUNT'].toString(),
      TEMP_REF_DOC_ID: json['TEMP_REF_DOC_ID'].toString(),
      REFERAL_DOCTOR: json['REFERAL_DOCTOR'].toString(),
      CLIENT_ID: json['CLIENT_ID'].toString(),
      TEST_AMOUNT: json['TEST_AMOUNT'].toString(),
      SERVICE_GROUP_ID: json['SERVICE_GROUP_ID'].toString(),
      // SERVICE_NAME: json['SERVICE_NAME'].toString(),
      srv_status: json['srv_status'].toString(),
      SERVICE_ID: json['SERVICE_ID'].toString(),
      BILL_NO: json['BILL_NO'].toString(),
      BILL_DT: json['BILL_DT'].toString(),
      UMR_NO: json['UMR_NO'].toString(),
      PATIENT_NAME: json['PATIENT_NAME'].toString(),
      Age: json['Age'].toString(),
      SERVICE_NAME: json['SERVICE_NAME'].toString(),
      TOTAL: json['TOTAL'].toString(),
      REPORT_CD: json['REPORT_CD'].toString(),
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

totbusinessClientWise() {
  return SizedBox(
    width: 350,
    height: 50,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 0.0, 8, 0.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        color: Color.fromARGB(255, 27, 165, 114),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 2, 9, 2),
          child: Row(
            children: [
              Text('Total Business :',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              Spacer(),

              //setState({}),
              Text(globals.TOTAL_CLIENT_AMOUNT,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    ),
  );
}

totbusinessChannelWise() {
  return SizedBox(
    width: 350,
    height: 50,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 0.0, 8, 0.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        color: Color.fromARGB(255, 27, 165, 114),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 2, 9, 2),
          child: Row(
            children: [
              Text('Total Business :',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              Spacer(),

              //setState({}),
              Text(amount.toString(),
                  // Text("amount.toString()",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    ),
  );
}

totbusinessDeptWise() {
  return SizedBox(
    width: 350,
    height: 50,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 0.0, 8, 0.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        color: Color.fromARGB(255, 27, 165, 114),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 2, 9, 2),
          child: Row(
            children: [
              Text('Total Business :',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              Spacer(),

              //setState({}),
              Text(amount.toString(),
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    ),
  );
}

/*--------------------------------------------url Launcher----------------------------------------*/

_launchURL(REPORT_CD) async {
  var url = globals.Report_URL + REPORT_CD;
  if (await launch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

/*--------------------------------------------url Launcher----------------------------------------*/

Messagetoaster() {}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: new Row(
      children: [
        SizedBox(
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
        ),
        Container(margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

//......................................Report Class is

class Report_With_Popup extends StatefulWidget {
  const Report_With_Popup({Key? key}) : super(key: key);

  @override
  State<Report_With_Popup> createState() => _Report_With_PopupState();
}

class _Report_With_PopupState extends State<Report_With_Popup> {
  @override
  Widget build(BuildContext context) {
    showDataAlert() {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mobile No.:'),
                  TextField(
                    controller: _Mobile_NoController,
                    decoration:
                        InputDecoration(hintText: "Enter here Mobile No. "),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text('OR', style: TextStyle(color: Colors.indigo)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Bill No.:'),
                  TextField(
                    controller: _billnoController,
                    decoration:
                        InputDecoration(hintText: "Enter here Bill No.:  "),
                  ),
                ],
              ),
              actions: <Widget>[
                Center(
                    child: SizedBox(
                  height: 50,
                  width: 100,
                  child: InkWell(
                    child: Card(
                      // shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      // color: Colors.green,

                      child: Center(
                          child: Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                    onTap: () {
                      print("you enter ok");

                      if (_billnoController.text == "" &&
                          _Mobile_NoController.text == "") {
                        // return false;

                        Fluttertoast.showToast(
                            msg: "Enter Valid Number",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color.fromARGB(255, 180, 17, 17),
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }

                      if (_billnoController.text != "" ||
                          _Mobile_NoController.text != "") {
                        globals.mobile_no = _Mobile_NoController.text;
                        globals.bill_no = _billnoController.text;
                        Navigator.pop(context);

                        setState(() {
                          Report_With_Popup();
                        });
                      }
                      clearText();
                    },
                  ),
                ))
              ],
            );
          });
    }

    _billnoController.text != "" || _Mobile_NoController.text != ""
        ? Container()
        : WidgetsBinding.instance.addPostFrameCallback((_) => showDataAlert());

    Future<List<ClientChannelDept_class>> _fetchSaleTransaction() async {
      amount = 0;

      Map data = {
        "Emp_id": globals.loginEmpid,
        "session_id": "1",
        "flag": "",
        "from_dt": "23-sep-2022",
        "to_dt": "23-sep-2022",
        "location_wise_flg": "RE",
        "location_id": globals.LOC_ID,
        "IP_BILL_NO": _billnoController.text,
        "IP_BARCODE_NO": _Mobile_NoController.text,
        "connection": globals.Connection_Flag
      };

      final jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/Centerwisetrans');
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
            .map((managers) => ClientChannelDept_class.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Future<List<ClientChannelDept_class>> _fetchSaleTransaction1() async {
      int amount = 0;

      return [];
    }

    Widget ReportVerticalList = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      height: 540.0,
      child: FutureBuilder<List<ClientChannelDept_class>>(
          future:
              (_billnoController.text != "" || _Mobile_NoController.text != "")
                  ? _fetchSaleTransaction()
                  : _fetchSaleTransaction1(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty == true) {
                return Container();
              }
              var data = snapshot.data;
              return ReportListView(data, context);
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
    Widget mybottomnavigation = Container(
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
            Container(child: ReportVerticalList),
          ],
        ),
      ),
      bottomNavigationBar: mybottomnavigation,
    );
  }
}

ListView ReportListView(data, BuildContext context) {
  if (data != null) {
    return ListView.builder(
        itemCount: data.length,
        //itemCount: 1,
        itemBuilder: (context, index) {
          //return _tile(data[index].position, data[index].company, Icons.work);
          return report(data[index], context, index);
        });
  }
  return ListView();
}

Widget report(var data, BuildContext context, index) {
  _selflag = flag;

  return GestureDetector(
      child: Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0.0),
    child: InkWell(
      onTap: (() {}),
      child: Card(
          elevation: 4.0,
          child: ListTile(
            // leading: Icon(Icons.verified_rounded, color: Colors.green),
            title: Column(
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Icon(Icons.person, color: Colors.grey),
                    ),

                    Container(
                      width: 150,
                      child: Text(data.PATIENT_NAME.toString(),
                          style: TextStyle(
                              color: Color(0xff123456),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0)),
                    ),
                    Spacer(),
                    Text(data.Age.toString(),
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0)),
                    // SizedBox(
                    //   width: 1,
                    // ),
                  ],
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Container(
                      width: 150,
                      child: Row(
                        children: [
                          Text(
                              data.BILL_NO.toString() +
                                  ' | ' +
                                  data.BILL_DT.toString(),
                              style: TextStyle(
                                  color: Color.fromARGB(255, 106, 199, 248),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0)),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Container(
                      width: 150,
                      child: Text(data.SERVICE_NAME.toString(),
                          style: TextStyle(
                              color: Color(0xff123456),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.0)),
                    ),
                    Spacer(),
                    Text(data.srv_status.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.0)),
                    SizedBox(
                      height: 35,
                      child: data.srv_status == "Completed"
                          ? IconButton(
                              onPressed: () {
                                _launchURL(data.REPORT_CD.toString());
                              },
                              icon: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ))
                          : Container(),
                    ),
                  ],
                ),
              ],
            ),
          )),
    ),
  ));
}

class NoContent3 extends StatelessWidget {
  const NoContent3();

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
