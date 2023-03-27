import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import './globals.dart' as globals;
import 'package:http/http.dart' as http;

String client_id = "";

class ClientBusiness extends StatefulWidget {
  ClientBusiness(clientid) {
    client_id = '';
    client_id = clientid;
  }

  @override
  State<ClientBusiness> createState() => _ClientBusinessState();
}

class _ClientBusinessState extends State<ClientBusiness> {
  String date = "";
  _selectBusinessDate(BuildContext context) async {
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClientBusiness(globals.ClientBusinessId)));
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = AppBar(
        toolbarHeight: 29.0,
        backgroundColor: Color(0xff123456),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range_outlined),
            onPressed: () {
              _selectBusinessDate(context);
            },
          ),
        ],
        bottom: const TabBar(
          tabs: [
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
          ],
          //  isScrollable: true,
        ),
        title: Text('Business of ' + globals.clientName,
            style: TextStyle(fontSize: 16)));

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: topAppBar,
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              ClientTestWise(),
              ClientDeptWise(),
            ],
          ),
        ));
  }
}

class ClientTestWise extends StatefulWidget {
  const ClientTestWise({Key? key}) : super(key: key);

  @override
  State<ClientTestWise> createState() => _ClientTestWiseState();
}

class _ClientTestWiseState extends State<ClientTestWise> {
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

  @override
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

    Future<List<BusinessTestWise>> _fetchSaleTransaction() async {
      // totalBusiness1 = 0;

      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Employeeid": '0',
        "FromDate": selecteFromdt,
        "ToDate": selecteTodt,
        "session_id": "1",
        "Flag": "SG",
        "client_id": globals.ClientBusinessId,
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

        // setState(() {
        //   isLoaded = true;
        // });

        return listresponse
            .map((smbtrans) => BusinessTestWise.fromJson(smbtrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
      // }
    }

    Widget TestWiseClientBusiness = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<BusinessTestWise>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return ClientBusinessListView(data, context, 'SG');
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
          child: TestWiseClientBusiness,
        ),
        // _buildtotalbusinessDept(context)
      ],
    );
  }
}

class ClientDeptWise extends StatefulWidget {
  const ClientDeptWise({Key? key}) : super(key: key);

  @override
  State<ClientDeptWise> createState() => _ClientDeptWiseState();
}

class _ClientDeptWiseState extends State<ClientDeptWise> {
  int selectedIndex = 0;
  var selecteFromdt = '';
  var selecteTodt = '';

  @override
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

    Future<List<BusinessDeptWise>> _fetchSaleTransaction() async {
      // totalBusiness1 = 0;

      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "Employeeid": '0',
        "FromDate": selecteFromdt,
        "ToDate": selecteTodt,
        "session_id": "1",
        "Flag": "y",
        "client_id": globals.ClientBusinessId,
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

        // setState(() {
        //   isLoaded = true;
        // });

        return listresponse
            .map((smbtrans) => BusinessDeptWise.fromJson(smbtrans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
      // }
    }

    Widget DeptWiseClientBusiness = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: FutureBuilder<List<BusinessDeptWise>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              } else {
                return ClientBusinessListView(data, context, 'y');
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
              //   var lastweek = now.subtract(Duration(days: 7));

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
          child: DeptWiseClientBusiness,
        ),
        // _buildtotalbusinessDept(context)
      ],
    );
  }
}

class BusinessTestWise {
  final SrvGrp;
  final Amount;
  final SrvGrpCnt;
  final SrvGrpVal;
  final FrmDt;
  final ToDt;
  BusinessTestWise(
      {required this.SrvGrp,
      required this.Amount,
      required this.SrvGrpCnt,
      required this.SrvGrpVal,
      required this.FrmDt,
      required this.ToDt});
  factory BusinessTestWise.fromJson(Map<String, dynamic> json) {
    return BusinessTestWise(
        SrvGrp: json['SERVICE_GROUP'].toString(),
        Amount: json['AMOUNT'].toString(),
        SrvGrpCnt: json['SRV_GRP_COUNT'].toString(),
        SrvGrpVal: json['SRV_GRP_VAL'].toString(),
        FrmDt: json['FROM_DT'].toString(),
        ToDt: json['TO_DT'].toString());
  }
}

class BusinessDeptWise {
  final SrvGrp;
  final Amount;
  final SrvGrpCnt;
  final SrvGrpVal;
  final FrmDt;
  final ToDt;
  BusinessDeptWise(
      {required this.SrvGrp,
      required this.Amount,
      required this.SrvGrpCnt,
      required this.SrvGrpVal,
      required this.FrmDt,
      required this.ToDt});
  factory BusinessDeptWise.fromJson(Map<String, dynamic> json) {
    return BusinessDeptWise(
        SrvGrp: json['SERVICE_GROUP'].toString(),
        Amount: json['AMOUNT'].toString(),
        SrvGrpCnt: json['SRV_GRP_COUNT'].toString(),
        SrvGrpVal: json['SRV_GRP_VAL'].toString(),
        FrmDt: json['FROM_DT'].toString(),
        ToDt: json['TO_DT'].toString());
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

Widget ClientBusinessListView(data, BuildContext context, String tabType) {
  int i = 0;
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildSalesCardClientBusiness(data[index], context, tabType, '');
      });
}

Widget _buildSalesCardClientBusiness(
    data, BuildContext context, String flg, String trantype) {
  var inoutflg = '';
  var head = '';
  var subheading = '';
  var subtitle = '';
  var tranamt = '';
  var supportingText = 'Advance amount 5000 collected for rolling advance';

  if (flg == 'SG') {
    head = data.SrvGrp;
    supportingText = '';
    subtitle = '';
    //head =  data.clientname;
    subheading = data.SrvGrpCnt;
    subtitle = '\u{20B9}' + data.Amount;
  } else if (flg == 'y') {
    head = data.SrvGrp;
    supportingText = '';
    subtitle = '';
    //head =  data.clientname;
    subheading = data.SrvGrpCnt;
    subtitle = '\u{20B9}' + data.Amount;
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
                      data.SrvGrpVal.toString(),
                      data.FrmDt.toString(),
                      data.ToDt.toString())))
          : Card();
      //  _showPicker1(context, data.billno.toString()
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
                  // SizedBox(
                  //   //  width: 35,
                  //   child: Text(tranamt,
                  //       style: TextStyle(
                  //           color: Color(0xff123456),
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 12.0)),
                  // ),
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
                //  crossAxisAlignment: CrossAxisAlignment.start,
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

// void _showPicker1(BuildContext context, billno) {
//   var res = showModalBottomSheet(
//     context: context,
//     builder: (_) => Container(
//       //  width: ,
//       height: MediaQuery.of(context).size.height * 0.4,
//       //  color: Color(0xff123456),
//       child: SelectionPickerBottom(billno.toString()),
//     ),
//   );
//   print(res);
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
        "employee_id": globals.selectedClientid,
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
          backgroundColor: Color(0xff123456), title: Text('Business of ')),
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
                        child: Text(globals.selectedPatientData.SrvGrp,
                            style: TextStyle(
                                color: Color(0xff123456),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0)),
                      ),
                      SizedBox(
                        // width: 30,
                        child: Text(globals.selectedPatientData.SrvGrpCnt,
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
                      Text('\u{20B9}' + globals.selectedPatientData.Amount,
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

// /* Business Bottom Pop-up */
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
