import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

import 'CenterWiseBusiness.dart';
import 'Sales_Dashboard.dart';
import 'New_Login.dart';
import 'admin_dashboard.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

var loc_total_amount = 0.0;
var totalloclength = null;
String total_amount_variable = "";
var total_amouont = "";
var checkvariable = "";

class locationWiseAmount extends StatefulWidget {
  // const locationWiseAmount({Key? key}) : super(key: key);
  int selectedtab;

  //globals.tab_index=selectedtab;
  locationWiseAmount(this.selectedtab);

  @override
  State<locationWiseAmount> createState() =>
      _locationWiseAmountState(this.selectedtab);
}

class _locationWiseAmountState extends State<locationWiseAmount> {
  DateTime pastMonth = DateTime.now().subtract(Duration(days: 30));
  DateTime nextMonth = DateTime.now().add(Duration(days: 30));
  String empID = "0";
  int selectedIndex;
  var selecteFromdt = '';
  var selecteTodt = '';

  _locationWiseAmountState(this.selectedIndex);

  int index = 0;

  _selectClientWistBusinessDate(BuildContext context) async {
    final DateTimeRange? selected = await showDateRangePicker(
      context: context,

      // initialDate: selectedDate,
      firstDate: pastMonth,
      lastDate: DateTime(DateTime.now().year + 1),
      saveText: 'Done',
    );
    //  if (selected != null && selected != selectedDate) {
    setState(() {
      total_amouont = "";
      globals.fromDate = selected!.start.toString().split(' ')[0];
      globals.ToDate = selected.end.toString().split(' ')[0];
    });
    // }
  }

  @override
  Widget abced(BuildContext contex) {
    // setState(() {
    //   total_amouont.toString();
    // });
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
                Text('Location Wise Business :',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Spacer(),
                Text(total_amouont.toString(),
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

    Widget _buildLocationWiseAmountDetails(
        var data, BuildContext context, index) {
      loc_total_amount += double.parse(data.Amount.toString());
      String totalamountvariable = "";
      return GestureDetector(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 0.0),
        child: InkWell(
            onTap: (() {
              total_amouont = "";
              globals.Loc_Name_CWB = data.Location_name.toString();
              globals.location_wise_flg_glb = data.Location_name.toString();
              globals.LOC_ID = data.loc_id.toString();
              // TotalBusiness(context);
              globals.TOTAL_CHANNEL_AMOUNT = data.TOTAL_CHANNEL_AMOUNT;
              globals.TOTAL_SRV_GRP_AMOUNT = data.TOTAL_SRV_GRP_AMOUNT;
              globals.TOTAL_CLIENT_AMOUNT = data.TOTAL_CLIENT_AMOUNT;

              globals.fromDate = "";
              globals.ToDate = "";

              showDialog(
                context: context,
                builder: (BuildContext context) => CenterWiseBusiness(),
              );
            }),
            child: Container(
                decoration: BoxDecoration(
                    gradient:
                        LinearGradient(begin: Alignment.topCenter, colors: [
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
                                child: Card(
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Color.fromARGB(255, 169, 165, 164),
                                    ),
                                  ),
                                  color:
                                      const Color.fromARGB(255, 229, 231, 231),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 3, 0, 3),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_pin,
                                          size: 22,
                                          color:
                                              Color.fromARGB(255, 24, 167, 114),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            data.Location_name.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.double_arrow)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                                    //mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            30, 0, 30, 0),
                                        child: Column(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Gross Amount'),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                  '\u{20B9} ' + data.Amount,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                        padding: const EdgeInsets.fromLTRB(
                                            30, 0, 0, 0),
                                        child: Column(
                                          children: [
                                            Text('Net Amount'),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                  '\u{20B9} ' +
                                                      data.NET_AMOUNT
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15)),
                                            )
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
                                        padding: const EdgeInsets.fromLTRB(
                                            52, 0, 52, 0),
                                        child: Column(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Orders'),
                                            CircleAvatar(
                                              radius: 18.0,
                                              child: ClipRRect(
                                                child: Text(
                                                  data.ORDERS.toString(),
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
                                        padding: const EdgeInsets.fromLTRB(
                                            40, 0, 0, 0),
                                        child: Column(
                                          children: [
                                            Text('Tests'),
                                            CircleAvatar(
                                              radius: 18.0,
                                              child: ClipRRect(
                                                child: Text(
                                                  data.SAMPLES.toString(),
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
                            ]),
                          )),
                    ),
                  ],
                ))),
      ));
    }

    ListView LocationWiseAmountListView(data, BuildContext context) {
      return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return _buildLocationWiseAmountDetails(data[index], context, index);
          });
    }

    Future<List<LocWiseAmt>> _fetchManagerDetails() async {
      loc_total_amount = 0.0;
      Map data = {
        "Emp_id": globals.loginEmpid,
        "from_dt": globals.fromDate == "" ? selecteFromdt : globals.fromDate,
        "to_dt": globals.ToDate == "" ? selecteTodt : globals.ToDate,

        "session_id": "1",
        "flag": '',
        "connection": globals.Connection_Flag
        //"Server_Flag":""
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
        totalloclength = jsonDecode(response.body);
        List jsonResponse = resposne["Data"];

        //this code written for total location amount

        List data = [];
        data = totalloclength["Data"];

        Map<String, dynamic> sum =
            totalloclength["Data"].reduce((value, element) {
          // setState(() {});

          return {
            // sum the population here
            "AMOUNT": value["AMOUNT"] + element["AMOUNT"],
            // sum the area here
          };
        });

        print(sum);
        if (total_amouont == "" || total_amouont == null) {
          setState(() {
            total_amouont = sum["AMOUNT"].toString();
          });
        }

        //this code written for total location amount
        return jsonResponse
            .map((managers) => LocWiseAmt.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    abc() {
      return;
    }

    Widget verticalListLocationWiseAmount = Container(
        height: MediaQuery.of(context).size.height * 0.65,
        child: FutureBuilder<List<LocWiseAmt>>(
            future: (total_amouont == "" || total_amouont == null)
                ? _fetchManagerDetails()
                : abc(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (snapshot.data!.isEmpty == true) {
                  return NoContent();
                }
                return SizedBox(
                    child: LocationWiseAmountListView(data, context));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return SizedBox(
                height: 100,width: 100,
                child: Center(
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballClipRotateMultiple,
                    colors: Colors.primaries,
                    strokeWidth: 4.0,
                    //   pathBackgroundColor:ColorSwatch(Action[])
                  ),),
              );
            }));

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
              totbusinessDeptWise();
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
Widget MyBoTTomNaVigTION = Container(
  // height: 150,
    width: MediaQuery.of(context).size.width,
    height: 48,
    color: Color(0xff123456),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                  style: TextStyle(
                      color: Colors.white, fontSize: 12),
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
                    style: TextStyle(
                        color: Colors.white, fontSize: 12),
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
                    style: TextStyle(
                        color: Colors.white, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ]));
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(
                  onPressed: () {
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
                  icon: Icon(Icons.arrow_back)),
              Text(
                "Location Wise Business",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff123456),
          actions: [
            IconButton(
              icon: Icon(Icons.date_range_outlined),
              onPressed: () {
                _selectClientWistBusinessDate(context);
              },
            ),
          ],
        ),
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
                            Icons.account_box,
                            size: 25,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                globals.EmpName,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800]),
                              ),
                              globals.reference_type_id != '28' &&
                                      globals.reference_type_id != '8'
                                  ? Text(
                                      " Empoyee",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600]),
                                    )
                                  : Text(
                                      globals.Employee_Code,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600]),
                                    ),
                            ],
                          ),
                          const Spacer(),
                          globals.reference_type_id != '28' &&
                                  globals.reference_type_id != '8'
                              ? IconButton(
                                  onPressed: () {
                                    // globals.selectedEmpid = data.empid.toString();
                                    // globals.selectedEmname =
                                    //     globals.EmpName.toString();
                                    // globals.selectedManagerData = data;
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             ClientsList(globals.loginEmpid)));
                                  },
                                  icon: const Icon(
                                      Icons.admin_panel_settings_outlined,
                                      color: Colors.grey))
                              : IconButton(
                                  onPressed: () {
                                    // globals.selectedEmpid = data.empid.toString();
                                    // globals.selectedEmname =
                                    //     globals.EmpName.toString();
                                    // globals.selectedManagerData = data;
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             ClientsList(globals.loginEmpid)));
                                  },
                                  icon: const Icon(
                                    Icons.groups_sharp,
                                    color: Colors.grey,
                                  ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 48, child: DateSelection()),
              SizedBox(
                  height: 17,
                  child: Text(selecteFromdt + '  To   ' + selecteTodt,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 70, 29, 217),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0))),
              Container(child: verticalListLocationWiseAmount),
              // abced(context),

            ],
          ),
        ),bottomNavigationBar: MyBoTTomNaVigTION,);
  }
}

class LocWiseAmt {
  final Location_name;
  final Amount;
  final loc_id;
  final TOTAL_CHANNEL_AMOUNT;
  final TOTAL_SRV_GRP_AMOUNT;
  final TOTAL_CLIENT_AMOUNT;
  final SAMPLES;
  final ORDERS;
  final NET_AMOUNT;
  LocWiseAmt(
      {required this.Location_name,
      required this.Amount,
      required this.loc_id,
      required this.TOTAL_CHANNEL_AMOUNT,
      required this.TOTAL_SRV_GRP_AMOUNT,
      required this.TOTAL_CLIENT_AMOUNT,
      required this.SAMPLES,
      required this.ORDERS,
      required this.NET_AMOUNT});

  factory LocWiseAmt.fromJson(Map<String, dynamic> json) {
    return LocWiseAmt(
      Location_name: json['LOCATION_NAME'].toString(),
      Amount: json['AMOUNT'].toString(),
      loc_id: json['LOCATION_ID'].toString(),
      TOTAL_CHANNEL_AMOUNT: json['TOTAL_CHANNEL_AMOUNT'].toString(),
      TOTAL_SRV_GRP_AMOUNT: json['TOTAL_SRV_GRP_AMOUNT'].toString(),
      TOTAL_CLIENT_AMOUNT: json['TOTAL_CLIENT_AMOUNT'].toString(),
      SAMPLES: json['SAMPLES'].toString(),
      ORDERS: json['ORDERS'].toString(),
      NET_AMOUNT: json['NET_AMOUNT'].toString(),
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
