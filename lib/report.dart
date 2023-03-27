import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'Sales_Dashboard.dart';
import 'ClientWiseBusiness.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'LocationWiseBusiness.dart';
import 'New_Login.dart';
import 'admin_dashboard.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

double amount = 1;
TextEditingController _Mobile_NoController = TextEditingController();
TextEditingController _billnoController = TextEditingController();

class ReportData extends StatefulWidget {
  int index;

  int selectedIndex;
  ReportData(this.index, this.selectedIndex);
  @override
  State<ReportData> createState() =>
      _ReportDataState(this.index, this.selectedIndex);
}

class _ReportDataState extends State<ReportData> {
  DateTime selectedDate = DateTime.now();

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

  int index;

  String empID = "0";
  int selectedIndex;
  var selecteFromdt = '';
  var selecteTodt = '';
  _ReportDataState(this.index, this.selectedIndex);

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
          return report(data[index], context, index, flag);
        });
  }

  Widget report(var data, BuildContext context, index, flag) {
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
                        height: 30,
                        child: data.srv_status == "Completed"
                            ? IconButton(
                                onPressed: () {
                                  _launchURL(data.REPORT_CD.toString());
                                },
                                icon: Icon(Icons.picture_as_pdf,
                                    size: 15, color: Colors.red))
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
      amount = 0;

      Map data = {
        "Emp_id": globals.loginEmpid,
        "session_id": "1",
        "flag": "",
        "from_dt": "${selectedDate.toLocal()}".split(' ')[0],
        "to_dt": "${selectedDate.toLocal()}".split(' ')[0],
        "location_wise_flg": "RE",
        "location_id": globals.LOC_ID,
        "IP_BILL_NO": globals.bill_no,
        "IP_BARCODE_NO": globals.mobile_no,
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

//Date Selection...........................................
    Widget verticalListClientChannelDept = Container(
        height: MediaQuery.of(context).size.height * 0.59,
        child: FutureBuilder<List<ClientChannelDept_class>>(
            future: _fetchManagerDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
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
        height: MediaQuery.of(context).size.height * 0.75,
        child: FutureBuilder<List<ClientChannelDept_class>>(
            future: _fetchManagerDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (snapshot.data!.isEmpty == true) {
                  return NoContent();
                }
                return SizedBox(
                    child: ClientChannelDeptListView(data, context, flag));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return const Center(
                  child: const CircularProgressIndicator(
                strokeWidth: 4.0,
              ));
            }));
    Widget MybototomNavigation = Container(
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
                globals.bill_no = "";
                globals.mobile_no = "";
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
                  globals.bill_no = "";
                  globals.mobile_no = "";
                  globals.fromDate = "";
                  globals.ToDate = "";
                  total_amouont = "";
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              salesManagerDashboard(empID, 0)));
                },
                icon: Icon(Icons.arrow_back)),
            Text(
              "Reports",
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
                _selectDate(context);
              },
            ),
          ],
        ),
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
                          Icons.location_pin,
                          size: 25,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "All Location",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800]),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(child: verticalListClientChannelRep),
          ],
        ),
      ),
      bottomNavigationBar: MybototomNavigation,
    );
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
  // SfPdfViewer.network(
  //     "http://103.145.36.189/his/PUBLIC/HIMSREPORTVIEWER.ASPX?UNIUQ_ID=" +
  //         REPORT_CD +
  //         "");

  var url = globals.Report_URL + REPORT_CD + "";
  if (await launch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

/*--------------------------------------------url Launcher----------------------------------------*/

Messagetoaster() {}
