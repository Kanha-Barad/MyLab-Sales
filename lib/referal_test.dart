import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import './CenterWiseBusiness.dart';
import './report_by_referal.dart';
import 'New_Login.dart';
import 'admin_dashboard.dart';
import 'Sales_Dashboard.dart';
import 'allbottomnavigationbar.dart';
import 'globals.dart' as globals;

class Referal_Test extends StatefulWidget {
  const Referal_Test({Key? key}) : super(key: key);

  @override
  State<Referal_Test> createState() => _Referal_TestState();
}

class _Referal_TestState extends State<Referal_Test> {
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
  @override
  Widget build(BuildContext context) {
    Future<List<referal_test_model>> _fetchSaleTransaction() async {
      var jobsListAPIUrl = null;
      var dsetName = '';
      List listresponse = [];

      Map data = {
        "IP_REFRL_ID": globals.Referal_Doctor_Id,
        "IP_FROM_DT": "${selectedDate.toLocal()}".split(' ')[0],
        "IP_TO_DT": "${selectedDate.toLocal()}".split(' ')[0],
        "IP_LOCATION_ID": globals.LOC_ID,
        "connection": globals.Connection_Flag
      };

      dsetName = 'result';
      jobsListAPIUrl =
          Uri.parse(globals.API_url + '/MobileSales/REFERAL_TESTS');
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
            .map((strans) => new referal_test_model.fromJson(strans))
            .toList();
      } else {
        throw Exception('Failed to load jobs from API');
      }
    }

    Widget verticalList3 = Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),
      height: 550.0,
      child: FutureBuilder<List<referal_test_model>>(
          future: _fetchSaleTransaction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty == true) {
                return NoContent3();
              }
              var data = snapshot.data;
              return referal_test_ListView(data, context);
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
          automaticallyImplyLeading: false,
          elevation: 0,
          //  backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          title: Row(
            children: [
              Text('Referal Test',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CenterWiseBusiness()));
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
          ])))),
      body: Column(
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
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8, top: 15, bottom: 15),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons.person_search_outlined,
                          color: Color.fromARGB(255, 148, 225, 144),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          globals.REFERAL_DOCTOR,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800]),
                        ),
                        const Spacer(),
                        Text(
                          '\u{20B9} ' + globals.REF_AMOUNT,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(child: verticalList3),
        ],
      ),
      bottomNavigationBar: AllbottomNavigation(),
    );
  }
}

//......................................end class

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

class referal_test_model {
  final SERVICE_AMOUNT;
  final SERVICE_NAME;
  final CNT;
  final AMOUNT;
  final SERVICE_ID;
  final SERVICE_GROUP_ID;

  referal_test_model({
    required this.SERVICE_AMOUNT,
    required this.SERVICE_NAME,
    required this.CNT,
    required this.AMOUNT,
    required this.SERVICE_ID,
    required this.SERVICE_GROUP_ID,
  });

  factory referal_test_model.fromJson(Map<String, dynamic> json) {
    return referal_test_model(
      SERVICE_AMOUNT: json['SERVICE_AMOUNT'],
      SERVICE_NAME: json['SERVICE_NAME'],
      CNT: json['CNT'],
      AMOUNT: json['AMOUNT'],
      SERVICE_ID: json['SERVICE_ID'],
      SERVICE_GROUP_ID: json['SERVICE_GROUP_ID'],
    );
  }
}

ListView referal_test_ListView(data, BuildContext context) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return referal_test_Card(data[index], context);
      });
}

Widget referal_test_Card(var data, BuildContext context) {
  return InkWell(
    onTap: (() {
      globals.SERVICE_GROUP_ID = data.SERVICE_GROUP_ID.toString();
      globals.SERVICE_ID = data.SERVICE_ID.toString();
      globals.SERVICE_NAME_By_Referal = data.SERVICE_NAME.toString();
      globals.CNT = data.CNT.toString();

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => referal_by_report(0, 0)));
    }),
    child: Padding(
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
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.medical_services_outlined,
                    color: Color.fromARGB(255, 83, 76, 175),
                    size: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    data.SERVICE_NAME.toString(),
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
                        data.CNT.toString(),
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
    ),
  );
}
