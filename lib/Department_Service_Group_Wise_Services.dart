import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import './CenterWiseBusiness.dart';
import 'Center_Wise_Summary.dart';
import 'New_Login.dart';
import 'SERVICE_WISE_PATIENTS_REPORT.dart';
import 'Sales_Dashboard.dart';
import 'ClientWiseBusiness.dart';
import 'LocationWiseBusiness.dart';

import 'admin_dashboard.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class Department_Service_Group_Wise_Services extends StatefulWidget {
  @override
  State<Department_Service_Group_Wise_Services> createState() =>
      _Department_Service_Group_Wise_ServicesState();
}

class _Department_Service_Group_Wise_ServicesState
    extends State<Department_Service_Group_Wise_Services> {
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

  String empID = "0";

  var selecteFromdt = '';
  var selecteTodt = '';

  @override
  ListView ClientChannelDeptListView(data, BuildContext context) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return report(data[index], context);
        });
  }

  ListView ServiceGroupNameListView(data, BuildContext context) {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return ServiceGroupNameCard(data[index], context);
        });
  }

  Widget ServiceGroupNameCard(var data, BuildContext context) {
    return Padding(
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
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.medical_services_outlined,
                    color: Colors.green,
                    size: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    globals.Service_Group_Name,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800]),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    // backgroundColor: Colors.green,
                    radius: 15.0,
                    child: ClipRRect(
                      child: Text(
                        globals.Total_Count.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      borderRadius: BorderRadius.circular(70.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget report(var data, BuildContext context) {
    return GestureDetector(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0.0),
      child: InkWell(
        onTap: (() {
          globals.Service_ID = data.SERVICE_ID.toString();
          globals.SERVICE_NAME = data.SERVICE_NAME.toString();
          globals.Counts = data.CNT.toString();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SERVICE_WISE_PATIENTS_REPORT(0, 0)));
        }),
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
                        child: Icon(Icons.medication_liquid_sharp,
                            color: Colors.pink),
                      ),

                      Container(
                        width: 150,
                        child: Text(data.SERVICE_NAME,
                            style: TextStyle(
                                color: Color(0xff123456),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0)),
                      ),
                      Spacer(),

                      CircleAvatar(
                        radius: 18.0,
                        child: ClipRRect(
                          child: Text(
                            data.CNT.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          borderRadius: BorderRadius.circular(70.0),
                        ),
                      ),

                      // SizedBox(
                      //   width: 1,
                      // ),
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
    Future<List<Service_Group_Wise_Services_Model>>
        _fetchManagerDetails() async {
      Map data = {
        // "IP_SRV_GRP_ID": globals.Glb_service_group_id,
        // "IP_DATE": "16-sep-2022",
        // "connection": globals.Connection_Flag

        "IP_SRV_GRP_ID": globals.Service_Group_ID,
        "IP_DATE": "${selectedDate.toLocal()}".split(' ')[0],
        "IP_LOCATION_ID": globals.LOC_ID,
        "connection": globals.Connection_Flag
      };
      final jobsListAPIUrl = Uri.parse(
          globals.API_url + '/MobileSales/SERVICE_GROUP_WISE_SERVICES');
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
            .map((managers) =>
                Service_Group_Wise_Services_Model.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListClientChannelRep = Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: FutureBuilder<List<Service_Group_Wise_Services_Model>>(
            future: _fetchManagerDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (snapshot.data!.isEmpty == true) {
                  return NoContent();
                }
                return SizedBox(
                    child: ClientChannelDeptListView(data, context));
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

    Widget ServiceGroupName = Container(
        height: MediaQuery.of(context).size.height * 0.07,
        child: FutureBuilder<List<Service_Group_Wise_Services_Model>>(
            future: _fetchManagerDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (snapshot.data!.isEmpty == true) {
                  return NoContent();
                }
                return SizedBox(child: ServiceGroupNameListView(data, context));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return Container();
            }));
    Widget MyboTTomNavvogation = Container(
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
                globals.Glb_service_group_id = "";
                globals.LOC_ID = "";
                globals.Service_Group_ID = "";

                globals.fromDate = "";
                globals.ToDate = "";
                total_amouont = "";
                globals.Service_Group_Name = "";
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
                  globals.Glb_service_group_id = "";

                  globals.Service_Group_ID = "";

                  globals.fromDate = "";
                  globals.ToDate = "";
                  total_amouont = "";
                  globals.Service_Group_Name = "";
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CenterWiseBusiness()));
                },
                icon: Icon(Icons.arrow_back)),
            Text(
              "Services",
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
            Container(child: ServiceGroupName),
            Container(child: verticalListClientChannelRep),
          ],
        ),
      ),
      bottomNavigationBar: MyboTTomNavvogation,
    );
  }
}

class Service_Group_Wise_Services_Model {
  final SERVICE_NAME;
  final SERVICE_STATUS;
  final PATIENT_NAME;
  final BILL_NO;
  final BILL_AMOUNT;
  final NET_AMOUNT;
  final CONCESSION_AMOUNT;
  final BILL_ID;
  final UMR_NO;
  final BILL_DT;
  final CNT;
  final SERVICE_GROUP_NAME;
  final SERVICE_ID;

  Service_Group_Wise_Services_Model({
    required this.SERVICE_NAME,
    required this.SERVICE_STATUS,
    required this.PATIENT_NAME,
    required this.BILL_NO,
    required this.BILL_AMOUNT,
    required this.NET_AMOUNT,
    required this.CONCESSION_AMOUNT,
    required this.BILL_ID,
    required this.UMR_NO,
    required this.BILL_DT,
    required this.CNT,
    required this.SERVICE_GROUP_NAME,
    required this.SERVICE_ID,
  });

  factory Service_Group_Wise_Services_Model.fromJson(
      Map<String, dynamic> json) {
    return Service_Group_Wise_Services_Model(
      SERVICE_NAME: json['SERVICE_NAME'].toString(),
      SERVICE_STATUS: json['PATIENT_NAME'].toString(),
      BILL_NO: json['BILL_NO'].toString(),
      BILL_AMOUNT: json['BILL_AMOUNT'].toString(),
      NET_AMOUNT: json['NET_AMOUNT'].toString(),
      CONCESSION_AMOUNT: json['CONCESSION_AMOUNT'].toString(),
      BILL_ID: json['BILL_ID'].toString(),
      UMR_NO: json['UMR_NO'].toString(),
      BILL_DT: json['BILL_DT'].toString(),
      PATIENT_NAME: json['PATIENT_NAME'].toString(),
      CNT: json['CNT'].toString(),
      SERVICE_GROUP_NAME: json['SERVICE_GROUP_NAME'].toString(),
      SERVICE_ID: json['SERVICE_ID'].toString(),
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
