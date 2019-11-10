import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?format=json&key=e9268c28';

void main() async {
  runApp(MaterialApp(
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)))),
      home: Conversor()));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Conversor extends StatefulWidget {
  @override
  _ConversorState createState() => _ConversorState();
}

class _ConversorState extends State<Conversor> {
  double dolar;
  double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
      if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / dolar).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
      if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
      if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Center(child: Text(' \$ Conversor \$')),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (_, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando Dados',
                  style: TextStyle(color: Colors.amber, fontSize: 20),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text('ERRO AO CARREGAR OS DADOS :(',
                      style: TextStyle(color: Colors.amber, fontSize: 20)),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          'Reais', 'R\$ ', realController, _realChanged),
                      Divider(),
                      buildTextField(
                          'Dolar', 'US\$ ', dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          'Euro', '\€ ', euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

buildTextField(
    String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 20, color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
