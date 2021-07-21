


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:moobie_flutter/Helper/app_link.dart';

class Produk extends StatefulWidget{
  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  List data;
  var client = http.Client();
  Future<List> getData() async {
    http.Response response = await client.get(
      Uri.parse(applink+"api_model.php?act=getdata_produk2"),
        headers: {"Accept":"application/json"}
    );
    setState(() {
      data = json.decode(response.body);
    });
  }

  //Future<bool> _onWillPop() async { Navigator.pop(context);}
  @override
  Widget build(BuildContext context) {
  return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: new Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
              body: Container(
                height: double.infinity,
                width: double.infinity,
                child: Expanded(
                  child: _dataField(),
                ),
              ),
      );
  }


  Widget _dataField() {
return FutureBuilder(
   future: getData(),
      builder: (context, snapshot){
      if(data != null) {
        return ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (context, i) {
            return Text(data[i]["a"]);
          },
        );
      } else {
        return Center(
          child : SizedBox(
            child: CircularProgressIndicator(),
            width: 60,
            height: 60,
          ),
        );
      }


      },
    );
  }
}