//import 'dart:ffi';
import './clientprofile.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class clientDashboard extends StatefulWidget {
  // String empID = "0";
  // salesManagerDashboard(String iEmpid) {
  //   empID = iEmpid;
  //   this.empID = iEmpid;
  // }

  @override
  State<clientDashboard> createState() => _clientDashboardState();
}

class _clientDashboardState extends State<clientDashboard> {
  // String empID = "0";
  // _salesManagerDashboardState(String iEmpid) {
  //   this.empID = iEmpid;
  // }
  @override
  Widget build(BuildContext context) {
    Map<String, double> todayData = {
      "Payments": double.parse(globals.daypay),
      "Business": double.parse(globals.daybusin),
      // "Xamarin": 2,
      // "Ionic": 2,
    };
    Map<String, double> monthlyData = {
      "Payments": double.parse(globals.monthpay),
      "Business": double.parse(globals.monthbusi),
      // "Xamarin": 2,
      // "Ionic": 2,
    };
    return Scaffold(
        appBar: AppBar(
          title: const Text('Client Dashboard',
              style: TextStyle(fontFamily: 'Tapestry')),
          centerTitle: true,
          backgroundColor: const Color(0xff123456),
          automaticallyImplyLeading: true,
        ),
        body: Container(
            child: GestureDetector(
                child: Container(
          color: const Color.fromARGB(255, 250, 248, 248),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        // const Icon(
                        //   Icons.business_sharp,
                        //   color: Color.fromARGB(255, 19, 19, 114),
                        //   size: 30,
                        // ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              globals.clientName,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800]),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (globals.phoneno.toString() == "null")
                                      ? ""
                                      : globals.phoneno.toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      // fontWeight: FontWeight.bold,
                                      color: Colors.grey[800]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        //  (globals.statusvisit.toString() == "N")
                        //   ?
                        // IconButton(
                        //   onPressed: () {
                        //     globals.selectedClientid = globals.clientsid;

                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: ((context) => ClientProfile())));
                        //   },
                        //   icon: const Icon(
                        //     Icons.lock_open_rounded,
                        //     size: 16,
                        //     color: Colors.green,
                        //   ),
                        // )

                        //(globals.statusvisit.toString() == "N")
                        //?
                        IconButton(
                          onPressed: () {
                            globals.selectedClientid = globals.clientsid;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => ClientProfile(0))));
                          },
                          icon: Row(
                            children: [
                              Icon(
                                Icons.lock_open_rounded,
                                size: 12,
                                color: Colors.green,
                              ),
                              const Icon(
                                Icons.double_arrow_outlined,
                                size: 18,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        )
                        
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Today",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: PieChart(
                                  dataMap: todayData,
                                  chartLegendSpacing: 20,
                                  initialAngleInDegree: 180,
                                  chartRadius:
                                      MediaQuery.of(context).size.width / 3.5,
                                  legendOptions: const LegendOptions(
                                    legendPosition: LegendPosition.bottom,
                                  ),
                                  chartValuesOptions: const ChartValuesOptions(
                                    showChartValuesInPercentage: true,
                                    showChartValueBackground: true,
                                    showChartValues: true,
                                    //  showChartValuesInPercentage: true,
                                    showChartValuesOutside: true,
                                    decimalPlaces: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                "Monthly",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: PieChart(
                                  dataMap: monthlyData,
                                  chartLegendSpacing: 20,
                                  initialAngleInDegree: 130,
                                  ringStrokeWidth: 0,
                                  chartRadius:
                                      MediaQuery.of(context).size.width / 3.5,
                                  legendOptions: const LegendOptions(
                                    showLegendsInRow: false,
                                    legendPosition: LegendPosition.bottom,
                                  ),
                                  chartValuesOptions: const ChartValuesOptions(
                                    //     showChartValuesInPercentage: true,
                                    showChartValueBackground: true,
                                    showChartValues: true,
                                    showChartValuesInPercentage: true,
                                    showChartValuesOutside: true,
                                    decimalPlaces: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 4.0,
                child: Column(
                  children: [
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          child: Row(
                            children: [
                              Icon(Icons.business_center_outlined,
                                  color: Color.fromARGB(255, 90, 136, 236)),
                              SizedBox(
                                width: 10,
                              ),
                              Text('My Business',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text('\u{20B9} ' + globals.mybusiness.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          child: Row(
                            children: [
                              Icon(Icons.payments_outlined,
                                  color: Color.fromARGB(255, 163, 230, 165)),
                              SizedBox(
                                width: 10,
                              ),
                              Text('My Collections',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text('\u{20B9} ' + globals.collection,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          child: Row(
                            children: [
                              Icon(Icons.money_rounded,
                                  color: Color.fromARGB(255, 20, 169, 206)),
                              SizedBox(
                                width: 10,
                              ),
                              Text('My Dues',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text('\u{20B9} ' + globals.dues,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          child: Row(
                            children: [
                              const Icon(Icons.currency_rupee_outlined,
                                  color: Color.fromARGB(255, 194, 30, 150)),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Last Payment',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text('\u{20B9} ' + globals.lastpay,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range_outlined,
                                  color: Color.fromARGB(255, 243, 135, 19)),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Last Payment Date',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text(globals.lastdate,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        onTap: () {}),
                  ],
                ),
              ),
            ),
          ]),
        ))));
  }
}
