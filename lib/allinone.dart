import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import './managerbusiness.dart';
//import 'package:sales_app/ClientProfile.dart';
import 'ManagerEmployees.dart';
import 'clientprofile.dart';
import 'globals.dart' as globals;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'SalesClientsList.dart';

class AllinOne extends StatefulWidget {
  String empID = "0";

  AllinOne(String iEmpid) {
    this.empID = iEmpid;
  }

  @override
  _AllinOneState createState() => _AllinOneState(this.empID);
}

class _AllinOneState extends State<AllinOne> {
  String empID = "0";

  _AllinOneState(String iEmpid) {
    this.empID = iEmpid;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<SalesManagers>> _fetchSalespersons() async {
      Map data = {
        "emp_id": empID, "session_id": "1",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };
      final jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/MgnrEmpDtls');
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
            .map((managers) => SalesManagers.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color(0xff123456),
      title: Text("Sales Managers"),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: Icon(Icons.arrow_back)),
    );

    Widget verticalList = Container(
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<List<SalesManagers>>(
            future: _fetchSalespersons(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                return SizedBox(child: salesDashboardListView(data, context));
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
      appBar: topAppBar,
      body: Container(
        // padding: EdgeInsets.all(6.0),
        child: verticalList,
      ),
    );
  }
}

Widget _buildSalesCard(var data, BuildContext context) {
  return GestureDetector(
    onTap: () {
      globals.selectedEmpid = data.empid.toString();
      globals.selectedManagerData = data;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ManagerEmployees()),
      );
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => salesClientslist()),
      //   );
    },
    child: Container(
      // width: 175,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          // color: MaterialStateColor.resolveWith(
          //     (states) => Color.fromARGB(255, 230, 245, 237)),
          // ()
          elevation: 6.0,
          child: Column(
            children: [
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.account_circle, size: 20, color: Colors.grey),
                    SizedBox(width: 15),
                    Text(data.empname,
                        style: TextStyle(
                            color: Color(0xff123456),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0)),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 5),
                    Text('\u{20B9} ' + data.business.toString(),
                        style:
                            new TextStyle(color: Colors.green, fontSize: 14.0)),
                    SizedBox(width: 5),
                    SizedBox(width: 5),
                    Text('\u{20B9} ' + data.deposits.toString(),
                        style:
                            new TextStyle(color: Colors.blue, fontSize: 14.0)),
                    SizedBox(width: 5),
                    SizedBox(width: 5),
                    Text('\u{20B9} ' + data.balance.toString(),
                        style:
                            new TextStyle(color: Colors.red, fontSize: 14.0)),
                  ],
                ),
                // ),
                trailing: Icon(Icons.double_arrow_outlined, color: Colors.red),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.lock_open_rounded, size: 16, color: Colors.green),
                  Text('Active (' + data.acount.toString() + ')',
                      style: new TextStyle(
                          color: Color(0xff123456), fontSize: 14.0)),
                  Icon(Icons.lock_rounded, size: 16, color: Colors.red),
                  Text('Locked (' + data.icount.toString() + ')',
                      style: new TextStyle(
                          color: Color(0xff123456), fontSize: 14.0)),
                  Icon(Icons.summarize, size: 16, color: Colors.blue),
                  Text('Total (' + data.total.toString() + ')',
                      style: new TextStyle(
                          color: Color(0xff123456), fontSize: 14.0)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.phone_rounded, size: 16, color: Colors.green),
                  Text(data.mobileno.toString(),
                      style: new TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  SizedBox(height: 40),
                  Icon(Icons.email_rounded, size: 16, color: Colors.red),
                  Text(data.emailid.toString(),
                      style: new TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  InkWell(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      onTap: () {
                        globals.selectedEmpid = data.empid.toString();
                        globals.selectedManagerData = data;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => managerbusiness(0),
                            ));
                      })
                ],
              ),
            ],
          )),
    ),
  );
}

class SalesManagers {
  final empid;
  final empname;
  final reportmgrid;
  final reportmgrname;
  final deposits;
  final business;
  final balance;
  final acount;
  final icount;
  final total;
  final mobileno;
  final emailid;
  final dayWiseTargetAmt;
  final dayWiseAchieveAmt;

  SalesManagers({
    required this.empid,
    required this.empname,
    required this.reportmgrid,
    required this.reportmgrname,
    required this.deposits,
    required this.business,
    required this.balance,
    required this.acount,
    required this.icount,
    required this.total,
    required this.mobileno,
    required this.emailid,
    required this.dayWiseTargetAmt,
    required this.dayWiseAchieveAmt,
  });
  factory SalesManagers.fromJson(Map<String, dynamic> json) {
    if (json['EMAIL_ID'] == "") {
      json['EMAIL_ID'] = 'Not Specified.';
    }
    return SalesManagers(
      empid: json['EMPLOYEE_ID'],
      empname: json['EMPLOYEE_NAME'],
      reportmgrid: json['REPORTING_MNGR_ID'],
      reportmgrname: json['REPORTING_MNGR_NAME'],
      deposits: json['DEPOSITS'],
      business: json['BUSINESS'],
      balance: json['BALANCE'],
      acount: json['ACTIVE'],
      icount: json['IN_ACTIVE'],
      total: json['TOTAL'],
      mobileno: json['MOBILE_PHONE'],
      emailid: json['EMAIL_ID'],
      dayWiseTargetAmt: json['DAY_WISE_TARGET_AMOUNT'],
      dayWiseAchieveAmt: json['DAY_WISE_ACHIEVED_AMOUNT'],
    );
  }
}

ListView salesDashboardListView(data, BuildContext context) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildSalesCard(data[index], context);
      });
}
