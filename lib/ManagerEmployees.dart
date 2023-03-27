import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import './allinone.dart';
import 'package:flutter/cupertino.dart';
import './managerbusiness.dart';

import './popup.dart';

import 'ClientBusiness.dart';
import 'clientprofile.dart';
import 'globals.dart' as globals;
import 'dart:async';
import 'package:http/http.dart' as http;

class ManagerEmployees extends StatefulWidget {
  // String empID = "0";

  // ClientsList(String iEmpid) {
  //   this.empID = iEmpid;
  // }
  @override
  _ManagerEmployeesState createState() => _ManagerEmployeesState();
}

class _ManagerEmployeesState extends State<ManagerEmployees> {
  // String empID = "0";

  // _ClientsListState(String iEmpid) {
  //   this.empID = iEmpid;
  // }

  int _selectedValue = 0;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      //  _buildHeader(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllinOne(globals.loginEmpid)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<List<SalesManagers>> _fetchManagerClientpersons() async {
      Map data = {
        "emp_id": globals.selectedEmpid, "session_id": "1",
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
        globals.activeclnt = jsonResponse[0]["ACTIVE"].toString();
        globals.lockedclnt = jsonResponse[0]["IN_ACTIVE"].toString();
        globals.totalclnt = jsonResponse[0]["TOTAL"].toString();

        // setState(() {
        //   _buildHeader(context);
        // });

        return jsonResponse
            .map((managers) => SalesManagers.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalListManager = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      height: 670.0,
      child: FutureBuilder<List<SalesManagers>>(
          future: _fetchManagerClientpersons(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              //   setState(() {});
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
          }),
    );

    Future<List<ManagerClients>> _fetchSalespersons() async {
      Map data = {
        "emp_id": globals.selectedEmpid, "session_id": "1",
        "connection": globals.Connection_Flag
        //"Server_Flag":""
      };

      final jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/EmpReferalDetails');
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
            .map((managers) => ManagerClients.fromJson(managers))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalList = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      height: MediaQuery.of(context).size.height * 1,
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder<List<ManagerClients>>(
          future: _fetchSalespersons(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              return ManagerClientsListView(data, context);
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

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color(0xff123456),
      title: Text("Clients List"),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true)),
    );

    return Scaffold(
      appBar: topAppBar,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            verticalList,
            //verticalListManager,
          ],
        ),
      ),
    );
  }
}

ListView ManagerClientsListView(data, BuildContext context) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildClientsCard(data[index], context);
      });
}

Widget _buildHeader(BuildContext context) {
  return GestureDetector(
    child: Container(
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          // color: MaterialStateColor.resolveWith(
          //     (states) => Color.fromARGB(255, 226, 243, 236)),
          elevation: 6.0,
          child: Column(
            children: [
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.account_circle, size: 25, color: Colors.grey),
                    SizedBox(width: 15),
                    Text(globals.selectedManagerData.empname,
                        style: new TextStyle(
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
                    Text(
                        '\u{20B9} ' +
                            globals.selectedManagerData.business.toString(),
                        style:
                            new TextStyle(color: Colors.green, fontSize: 14.0)),
                    SizedBox(width: 5),
                    Text(
                        '\u{20B9} ' +
                            globals.selectedManagerData.deposits.toString(),
                        style:
                            new TextStyle(color: Colors.blue, fontSize: 14.0)),
                    SizedBox(width: 10),
                    SizedBox(width: 5),
                    Text(
                        '\u{20B9} ' +
                            globals.selectedManagerData.balance.toString(),
                        style:
                            new TextStyle(color: Colors.red, fontSize: 14.0)),
                  ],
                ),
                // ),
                trailing: Icon(Icons.double_arrow_outlined, color: Colors.red),
              ),
              SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.lock_open_rounded, size: 16, color: Colors.green),
                  Text('Active (' + globals.activeclnt.toString() + ')',
                      style: new TextStyle(
                          color: Color(0xff123456),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  Icon(Icons.lock_rounded, size: 16, color: Colors.red),
                  Text('Locked (' + globals.lockedclnt.toString() + ')',
                      style: new TextStyle(
                          color: Color(0xff123456),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  Icon(Icons.summarize, size: 16, color: Colors.blue),
                  Text('Total(' + globals.totalclnt.toString() + ')',
                      style: new TextStyle(
                          color: Color(0xff123456),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.phone_rounded, size: 16, color: Colors.green),
                  Text(globals.selectedManagerData.mobileno.toString(),
                      style: new TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  SizedBox(height: 30.0),
                  Icon(Icons.email_rounded, size: 16, color: Colors.red),
                  Text(globals.selectedManagerData.emailid.toString(),
                      style: new TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0)),
                  InkWell(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => managerbusiness(0)),
                        );
                      })
                ],
              ),
            ],
          )),
    ),
  );
}

String clienlockflag = '';
String ClientName = '';
Widget _buildClientsCard(data, BuildContext context) {
  ClientName = '';
  clienlockflag = '';
  clienlockflag = data.locked;

  ClientName = data.clientname;

  return GestureDetector(
    onTap: () {
      print(globals.selectedClientData);
      globals.clientName = data.clientname;
      globals.selectedClientData = data;
      // globals.selectedClientid = data.clientid.toString();
      // globals.mybusiness = data.business.toString();
      // globals.collection = data.totaldeposits.toString();
      // globals.dues = data.balance.toString();
      // globals.phoneno = data.mobileno.toString();
      // globals.lastpay = data.lastpaidamt.toString();
      // globals.lastdate = data.lastpaiddt.toString();
      // globals.daypay = data.day_wisepay.toString();
      // globals.daybusin = data.day_wisebusiness.toString();
      // globals.monthpay = data.month_wisepay.toString();
      // globals.monthbusi = data.month_wisebusiness.toString();
      // globals.clientsid = data.clientid.toString();
      // globals.dposit = data.deposits.toString();
      globals.selectedClientid = data.clientid.toString();

      globals.fromDate = '';
      globals.ToDate = '';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClientProfile(0)),
      );
    },
    child: Container(
      width: 175.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 1, 7, 0.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          // color: Color.fromARGB(255, 229, 243, 240),
          elevation: 6.0,
          margin: EdgeInsets.all(2.5),
          child: Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.clientname,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    (data.locked == 'Y')
                        ? IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      PopupWidget(
                                          data.locked,
                                          data.clientname,
                                          data.clientid.toString(),
                                          data.IS_CREDIT_LIMIT_REQ.toString()));
                            },
                            icon: Icon(
                              Icons.lock_rounded,
                              color: Colors.red,
                              size: 22,
                            ),
                          )
                        : IconButton(
                            icon: Icon(Icons.lock_open_rounded,
                                size: 22, color: Colors.green),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      PopupWidget(
                                          data.locked,
                                          data.clientname,
                                          data.clientid.toString(),
                                          data.IS_CREDIT_LIMIT_REQ.toString()));
                            },
                          ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\u{20B9} ' + data.business.toString(),
                      style: TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    Text(
                      '\u{20B9} ' + data.deposits.toString(),
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                    Text(
                      '\u{20B9} ' + data.balance.toString(),
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ),
              ),
              Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      data.lastpaiddt.toString(),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      '\u{20B9} ' + data.lastpaidamt.toString(),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    child: Icon(Icons.verified, color: Colors.green),
                    onTap: () {
                      globals.ClientBusinessId = data.clientid.toString();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ClientBusiness(data.clientid.toString())));
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ManagerClients {
  final clientid;
  final clientname;
  final deposits;
  final business;
  final balance;
  final locked;
  final lastpaiddt;
  final lastpaidamt;
  final totaldeposits;
  final totalbusiness;
  final totalbalace;
  final paymentmode;
  final mobileno;
  final day_wisepay;
  final day_wisebusiness;
  final month_wisepay;
  final month_wisebusiness;
  final IS_CREDIT_LIMIT_REQ;

  ManagerClients(
      {required this.clientid,
      required this.clientname,
      required this.locked,
      required this.deposits,
      required this.business,
      required this.balance,
      required this.lastpaiddt,
      required this.lastpaidamt,
      required this.totaldeposits,
      required this.totalbalace,
      required this.totalbusiness,
      required this.paymentmode,
      required this.mobileno,
      required this.day_wisepay,
      required this.day_wisebusiness,
      required this.month_wisepay,
      required this.month_wisebusiness,
      required this.IS_CREDIT_LIMIT_REQ});

  factory ManagerClients.fromJson(Map<String, dynamic> json) {
    if (json['LAST_PAYMENT_DT'] == '') {
      json['LAST_PAYMENT_DT'] = 'No Payment done.';
    }
    if (json['LAST_PAY_AMT'] == '') {
      json['LAST_PAY_AMT'] = '0.00';
    }

    return ManagerClients(
        clientid: json['COMPANY_ID'],
        clientname: json['COMPANY_NAME'],
        deposits: json['DEPOSITS'],
        business: json['BUSINESS'],
        balance: json['BALANCE'],
        lastpaiddt: json['LAST_PAYMENT_DT'],
        lastpaidamt: json['LAST_PAY_AMT'],
        paymentmode: json['CREDIT_CLIENT'],
        totaldeposits: json['TOTAL_DEPOSITS'],
        totalbusiness: json['TOTAL_BUSINESS'],
        totalbalace: json['TOTAL_BALANCE'],
        locked: json['CLIENT_LOCK_STATS'],
        mobileno: json['MOBILE_PHONE'],
        day_wisepay: json["DAY_WISE_PAYMENTAMOUNT"],
        day_wisebusiness: json["DAY_WISE_BUSINESSAMOUNT"],
        month_wisepay: json["MONTH_WISE_PAYMENTAMOUNT"],
        month_wisebusiness: json["MONTH_WISE_BUSINESSAMOUNT"],
        IS_CREDIT_LIMIT_REQ: json["IS_CREDIT_LIMIT_REQ"]);
  }
}

/* Manager Lock */

ListView salesDashboardListView(data, BuildContext context) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildHeader(context);
      });
}

Widget _buildManagerLockCard(var data, BuildContext context) {
  globals.selectedManagerData = data;
  return GestureDetector();
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
  });
  factory SalesManagers.fromJson(Map<String, dynamic> json) {
    if (json['EMAIL_ID'] == "") {
      json['EMAIL_ID'] = 'Not Specified.';
    }
    if (json['EMPLOYEE_NAME'] == null) {
      json['EMPLOYEE_NAME'] = ' ';
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
    );
  }
}

/* Manager Lock */
