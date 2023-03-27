import 'dart:convert';
import 'package:flutter/material.dart';
import 'ClientsList.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

String ClientName = "";
TextEditingController nameController =
    TextEditingController(text: ClientName.toString());
TextEditingController limitController = TextEditingController();

String Id = "";
String Client_name = "";
String CreditlmtFlag = "";
String Checkedval = "";
String Flag = "";

enum menuitem { open, locked }

menuitem val = menuitem.open;

class PopupWidget extends StatefulWidget {
  PopupWidget(_Flag, ClientName, clientid, creditlmtflag) {
    CreditlmtFlag = "";
    Id = "";
    Client_name = "";
    Checkedval = "";
    Flag = "";
    Flag = _Flag;
    Client_name = ClientName;
    print(clientid);
    Id = clientid;
    CreditlmtFlag = creditlmtflag;

    (Flag == "Y") ? val = menuitem.locked : val = menuitem.open;
  }

  @override
  _PopupWidgetState createState() => _PopupWidgetState();
}

class _PopupWidgetState extends State<PopupWidget> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: [
              TextField(
                  decoration: InputDecoration(
                      filled: true,
                      //  hintText: 'Enter text',
                      labelText: 'Client Name'),
                  controller: TextEditingController(
                    text: Client_name,
                  )),
              (CreditlmtFlag == "Y")
                  ? TextField(
                      decoration: InputDecoration(
                          filled: true,
                          //  hintText: 'Enter text',
                          labelText: 'Credit Limit'),
                      controller: limitController,
                      enabled: true,
                    )
                  : TextField(
                      decoration: InputDecoration(
                          filled: true,
                          //  hintText: 'Enter text',
                          labelText: 'Credit Limit'),
                      controller: limitController,
                      enabled: false,
                    )
            ],
          ),
          ListTile(
            title: const Text('Open'),
            trailing: Radio<menuitem>(
              value: menuitem.open,
              activeColor: Colors.green,
              groupValue: val,
              onChanged: (menuitem? value) {
                setState(() {
                  val = menuitem.open;
                  globals.lockstat = val.toString();
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Lock'),
            trailing: Radio<menuitem>(
              activeColor: Colors.red,
              value: menuitem.locked,
              groupValue: val,
              onChanged: (menuitem? value) {
                setState(() {
                  val = menuitem.locked;
                  globals.lockstat = val.toString();
                });
              },
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                updLockStatus();
                //  managerLock();

                Navigator.pop(context);

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClientsList(globals.loginEmpid)));
              },
              child: Container(
                  width: 140,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: Color(0xff123456),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: const Center(
                    child: Text('APPLY',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.white)),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

updLockStatus() async {
  String Flagval = "";
  (val.toString() == "menuitem.locked") ? Flagval = "Y" : Flagval = "N";

  (limitController.text == "")
      ? limitController.text = "0"
      : limitController.text;
  Map data = {
    "CLIENT_ID": Id.toString(),
    "CREDIT_LIMIT": limitController.text,
    "SESSION_ID": "1",
    "LOCK_CLIENT": Flagval,
    "connection": globals.Connection_Flag
    //"Server_Flag":""
  };

  final response =
      await http.post(Uri.parse(globals.API_url + '/MobileSales/CreditLocking'),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

  if (response.statusCode == 200) {
    Map<String, dynamic> resposne = jsonDecode(response.body);
    if (resposne["message"] == "success") {
      limitController.text = '';

      return Fluttertoast.showToast(
        msg: "Successed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromARGB(255, 64, 238, 11),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      limitController.text = '';
      return Fluttertoast.showToast(
          msg: "Failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromARGB(255, 238, 78, 38),
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
