import 'dart:convert';

import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController name = TextEditingController();
  TextEditingController amount = TextEditingController();
  token t=new token();
  String result="";
  bool _isloading=false;
  var orderid = 1960;
   payment()async {
     setState(() {
       _isloading = true;
       orderid++;
     });
     var response = await http.post(
         "https://test.cashfree.com/api/v2/cftoken/order", body:
     jsonEncode(<String, String>{
       "orderId": orderid.toString(),
       "orderAmount": amount.text.toString(),
       "orderCurrency": "INR"
     })
         , headers: <String, String>{
       "x-client-id": "8067757e49bdbf4cbb747578f77608",
       "x-client-secret": "64ad22b3e0464b7e9b901202948e6d49eabd0352",
     }
     );
     t = new token.fromJson(json.decode(response.body));
     if (t.status == "OK" && t.message == "Token generated") {
       Map<String, dynamic> inputParams = {
         "orderId": orderid.toString(),
         "orderAmount": amount.text.toString(),
         "customerName": name.text.toString(),
         "orderCurrency": "INR",
         "appId": "8067757e49bdbf4cbb747578f77608",
         "stage":"TEST",
         "customerEmail":"xyz@gmail.com",
         "customerPhone":"1234567890",
         "tokenData":t.tok,
       };
       CashfreePGSDK.doPayment(inputParams)
           .then((value) =>
           value?.forEach((key, value) {
             result+="$key:$value";
             if (mounted)setState(() {
               this._isloading=false;
             });
           }
           ));
       Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
           builder: (BuildContext context) => finalpage(result)), (
           Route<dynamic> route) => false);
     }
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cashfree payment"),
        ),
        body: this._isloading?Center(child:CircularProgressIndicator()):Container(
          padding:EdgeInsets.all(40),
          child:
        Column(
            children: [
              Container(
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                        labelText: "Enter name"
                    ),
                  )
              ),
              Container(
                  child: TextField(
                    controller: amount,
                    decoration: InputDecoration(
                        labelText: "Enter amount for payment"
                    ),
                  )
              ),
              Container(
                  child: RaisedButton(
                      onPressed: payment,
                      child: Text("Make Payment")
                  )
              )
            ]
        ),
        )
    );
  }
}
class token
{
  String status="";
  String message="";
  String tok="";
  token();
  token.fromJson(Map<String,dynamic>json){
    this.status = json["status"];
    this.message = json["message"];
    this.tok = json["cftoken"];
  }
}
class finalpage extends StatefulWidget
{
  String res="";
  finalpage(this.res);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return finalpagecode(res);
  }
}
class finalpagecode extends State<finalpage>
{
  String res="";
  finalpagecode(this.res);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(child:Text(res)),
    );
  }
}