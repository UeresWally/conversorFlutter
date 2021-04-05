import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var url = Uri.parse('https://api.hgbrasil.com/finance?key=47163e1f');
void main() async {

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
  ));
}

Future<Map> getData() async {

  http.Response response = await http.get(url);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final btcController = TextEditingController();

  double dolar;
  double bitcoin;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    btcController.text = "";
  }

  void _realChanged(String text){
    if (text.isEmpty){
      _clearAll();
      return;   
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    btcController.text = (real/bitcoin).toStringAsFixed(6);

  }
  void _dolarChanged(String text){
    if (text.isEmpty){
      _clearAll();
      return;   
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    btcController.text = (dolar * this.dolar / bitcoin).toStringAsFixed(6);
  }
  void _btcChanged(String text){
    if (text.isEmpty){
      _clearAll();
      return;   
    }
    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    dolarController.text = (bitcoin * this.bitcoin / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,  
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando Dados",
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0),
                textAlign: TextAlign.center,)
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar dados :(",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0),
                  textAlign: TextAlign.center,)
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                bitcoin = snapshot.data["results"]["currencies"]["BTC"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Bitcoins", "BTC", btcController, _btcChanged),
                    ],
                  )
                );
              }
          }
        }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f){
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix
    ),
    style: TextStyle(
      color: Colors.amber, fontSize: 25.0
      ),
    onChanged: f,
    keyboardType: TextInputType.number,
    );
}