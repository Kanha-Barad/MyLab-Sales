import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import './admin_dashboard.dart';
import 'Sales_Dashboard.dart';
import './service_group_wise_services.dart';
import 'New_Login.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class LocationWiseCollection extends StatefulWidget {
  // const LocationWiseCollection({Key? key}) : super(key: key);

  @override
  State<LocationWiseCollection> createState() => _LocationWiseCollectionState();
}

class _LocationWiseCollectionState extends State<LocationWiseCollection> {
  String empID = "0";

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

  @override
  Widget build(BuildContext context) {
    globals.Service_Group_Name = "";
    DateTime dateToday = new DateTime.now();
    String date = dateToday.toString().substring(0, 10);
    Future<List<CenterWiseSummaryData>> _fetchCenterWiseSummary() async {
      Map data = {
        "Ip_EMP_ID": globals.loginEmpid,
        "IP_DATE": "${selectedDate.toLocal()}".split(' ')[0],
        "IP_FLAG": globals.Radio_Lab_Flag,
        "connection": globals.Connection_Flag
      };
      final jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/DeptWiseSummary');
      var response = await http.post(jobsListAPIUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> resposne = jsonDecode(response.body);

        Map<String, dynamic> user = resposne['Data'][0];

        List jsonResponse = resposne["Data"];
        return jsonResponse
            .map((managers) => CenterWiseSummaryData.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListManagerDetails = Container(
        height: MediaQuery.of(context).size.height * 0.77,
        child: FutureBuilder<List<CenterWiseSummaryData>>(
            future: _fetchCenterWiseSummary(),
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

    Widget Lab_Total_Business_only_Widget = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      height: 40.0,
      child: FutureBuilder<List<CenterWiseSummaryData>>(
          future: _fetchCenterWiseSummary(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty == true) {
                return NoContent();
              }
              var data = snapshot.data;
              return Lab_Total_Business_Only_ListView(data, context);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Container();
          }),
    );

    Widget mybottomNavigationBar = Container(
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
      appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          //  backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          title: Row(
            children: [
              globals.Radio_Lab_Flag == "R"
                  ? Text('Radiology\nBusiness',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15))
                  : Text('Lab\nBusiness',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
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
          leading: InkWell(
            onTap: () {
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
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Color(0xff123456),
              Color(0xff123456),
              //  Color.fromARGB(255, 246, 246, 247)
            ])),
          )),
      body: SingleChildScrollView(
          child: Column(children: [
        SizedBox(child: verticalListManagerDetails),
        Container(child: Lab_Total_Business_only_Widget),
      ])),
      bottomNavigationBar: mybottomNavigationBar,
    );
  }
}

ListView Lab_Total_Business_Only_ListView(data, BuildContext context) {
  if (data != null) {
    return ListView.builder(
        itemCount: data.length,
        //itemCount: 1,
        itemBuilder: (context, index) {
          //return _tile(data[index].position, data[index].company, Icons.work);
          return Lab_Total_Business_Only_Widget(data[index], context);
        });
  }
  return ListView();
}

Widget Lab_Total_Business_Only_Widget(var data, BuildContext context) {
  return Container(
      // height: 150,
      width: MediaQuery.of(context).size.width,
      height: 48,
      color: Color.fromARGB(255, 176, 204, 232),
      // color: Color(0xff123456),
      // color: Color.fromARGB(255, 142, 206, 146),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 65, 15),
          child: globals.Radio_Lab_Flag == "R"
              ? Row(
                  children: [
                    Icon(Icons.summarize_outlined, color: Colors.black),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Total Radiology Business',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500)),
                    Spacer(),
                    Text('\u{20B9} ' + data.RAD_GROSS.toString(),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500))
                  ],
                )
              : Row(
                  children: [
                    Icon(Icons.medical_information_outlined,
                        color: Colors.black),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Total Lab Business',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500)),
                    Spacer(),
                    Text('\u{20B9} ' + data.LAB_GROSS.toString(),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500))
                  ],
                )));
}

ListView ManagerDetailsDasboardListView(data, BuildContext context) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildManagerDetails(data[index], context, index);
      });
}

Widget _buildManagerDetails(var data, BuildContext context, index) {
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
                                  )
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
                                  padding:
                                      const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                  child: Column(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Gross Amount'),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                            '\u{20B9} ' + data.GROSS.toString(),
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
                                        child: Text(
                                            '\u{20B9} ' + data.NET.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
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
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      Text('Tests'),
                                      CircleAvatar(
                                        backgroundColor: Colors.green,
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
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (var i
                                          in data.SERVICE_GROUP_NAME.split(','))
                                        Container(
                                            height: 40,
                                            width: 180,
                                            child: InkWell(
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      i.toString(),
                                                    ))))
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      for (var i in data.TOTAL_CNTS.split(','))
                                        Container(
                                          height: 40,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.grey[100],
                                            radius: 15.0,
                                            child: ClipRRect(
                                              child: Text(
                                                i.toString(),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(70.0),
                                            ),
                                          ),
                                        )

                                      //Text(data.SERVICE_GROUP_NAME.toString()),
                                      // Spacer(),
                                      // Text(data.TOTAL.toString())
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (var i
                                          in data.SERVICE_GROUP_ID.split(','))
                                        Container(
                                            height: 40,
                                            width: 40,
                                            child: InkWell(
                                                onTap: () {
                                                  globals.Radio_Lab_Flag == "R"
                                                      ? globals.Radio_Lab_Flag =
                                                          "R"
                                                      : globals.Radio_Lab_Flag =
                                                          "L";
                                                  globals.Radio_Lab_Flag == "L"
                                                      ? globals.Radio_Lab_Flag =
                                                          "L"
                                                      : globals.Radio_Lab_Flag =
                                                          "R";
                                                  globals.Glb_service_group_id =
                                                      i.toString();

                                                  globals.LOC_ID =
                                                      data.LOC_ID.toString();

                                                  print("you clicked");
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Service_Group_Wise_Services()));
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Spacer(),
                                                      Icon(
                                                        Icons.double_arrow,
                                                        color: Colors.black,
                                                      )
                                                    ],
                                                  ),
                                                ))),
                                    ],
                                  ),
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

class CenterWiseSummaryData {
  final GROSS;
  final NET;
  final LOC_ID;
  final LOCATION_NAME;
  final TOTAL;
  final SERVICE_GROUP_NAME;
  final SERVICE_GROUP_ID;
  final TOTAL_CNTS;
  final ORDERS;
  final SAMPLES;
  final LAB_GROSS;
  final RAD_GROSS;

  CenterWiseSummaryData({
    required this.GROSS,
    required this.NET,
    required this.LOC_ID,
    required this.LOCATION_NAME,
    required this.TOTAL,
    required this.SERVICE_GROUP_NAME,
    required this.SERVICE_GROUP_ID,
    required this.TOTAL_CNTS,
    required this.ORDERS,
    required this.SAMPLES,
    required this.LAB_GROSS,
    required this.RAD_GROSS,
  });
  factory CenterWiseSummaryData.fromJson(Map<String, dynamic> json) {
    return CenterWiseSummaryData(
      GROSS: json['GROSS'].toString(),
      NET: json['NET'].toString(),
      LOC_ID: json['LOC_ID'].toString(),
      LOCATION_NAME: json['LOCATION_NAME'].toString(),
      TOTAL: json['TOTAL'].toString(),
      SERVICE_GROUP_NAME: json['SERVICE_GROUP_NAME'].toString(),
      SERVICE_GROUP_ID: json['SERVICE_GROUP_ID'].toString(),
      TOTAL_CNTS: json['TOTAL_CNTS'].toString(),
      ORDERS: json['ORDERS'].toString(),
      SAMPLES: json['SAMPLES'].toString(),
      LAB_GROSS: json['LAB_GROSS'].toString(),
      RAD_GROSS: json['RAD_GROSS'].toString(),
    );
  }
}
